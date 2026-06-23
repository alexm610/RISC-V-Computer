// sdram_mmu.sv
//
// Memory-management unit for the 64MB SDRAM.  Replaces SDRAM_wrapper as the
// single owner of the SDRAM controller, arbitrating between two requesters:
//
//   1. CPU port   - 32-bit single-word interface, identical ports and
//                   identical proven FSM to the old SDRAM_wrapper (each
//                   32-bit transaction is split into two 16-bit controller
//                   cycles; byte/halfword phases with no active enables are
//                   skipped in DECODE_BE).
//
//   2. FB port    - 16-bit burst-read interface for the VGA scanout line
//                   fetcher.  fb_req held high with fb_addr/fb_len stable;
//                   words stream out on fb_data/fb_valid; fb_done pulses
//                   for one cycle on completion.
//
// ── Arbitration ─────────────────────────────────────────────────────────────
// Arbitration lives in the controller's idling state with fixed priority:
//
//       refresh  >  framebuffer burst  >  CPU
//
// A CPU access that arrives during a burst simply waits for dtack (the CPU
// FSM here is dtack-driven and holds its strobes, exactly as it already does
// across refresh today).  A burst that arrives during a CPU 16-bit cycle
// waits at most one cycle + termination (~10 clocks).  A 320-word line burst
// holds the bus for ~6.5us; with line-doubled 320x240 scanout that is one
// burst per two scanlines, i.e. ~10% of CPU memory bandwidth.
//
// A burst may land BETWEEN the two 16-bit halves of a CPU transaction; this
// is harmless - the low half is already registered in rdata_lo and the
// wrapper FSM resumes when dtack returns.
//
// ── Framebuffer addressing contract ─────────────────────────────────────────
// Each burst must stay inside ONE SDRAM row (1024 columns = 2KB).  The
// scanout module guarantees this with a 1024-byte line stride and a
// 2KB-aligned framebuffer base, so a 320-word line starts at column 0 or 512.
//
// CPU writes to the framebuffer region are ordinary single-word writes
// through the CPU port - no special path.

module sdram_mmu (
    input  logic        Clock,
    input  logic        Reset_L,

    // ── CPU port (identical to old SDRAM_wrapper) ───────────────────────────
    input  logic        RamSelect_H,
    input  logic        WE_L,
    input  logic        AS_L,
    input  logic [31:0] Address,
    input  logic [3:0]  ByteEnable,
    input  logic [31:0] DataIn,
    output logic [31:0] DataOut,
    output logic        DTAck_H,
    output logic        ResetOut_L,

    // ── Framebuffer burst-read port ─────────────────────────────────────────
    input  logic        fb_req,        // hold high until fb_done
    input  logic [31:0] fb_addr,       // byte address of first 16-bit word
    input  logic [9:0]  fb_len,        // number of 16-bit words (1..512, one row)
    output logic [15:0] fb_data,       // streamed word (updates on negedge Clock)
    output logic        fb_valid,      // 1 cycle per word; sample on ending posedge
    output logic        fb_done,       // 1 cycle pulse at burst completion

    // ── SDRAM pins ──────────────────────────────────────────────────────────
    output logic        SDRAM_CKE,
    output logic        SDRAM_CS_N,
    output logic        SDRAM_RAS_N,
    output logic        SDRAM_CAS_N,
    output logic        SDRAM_WE_N,
    output logic [12:0] SDRAM_ADDR,
    output logic [1:0]  SDRAM_BA,
    inout  wire  [15:0] SDRAM_DQ,
    output logic        SDRAM_UDQM,
    output logic        SDRAM_LDQM
);

    // ════════════════════════════════════════════════════════════════════════
    // CPU bridge FSM - verbatim from the proven SDRAM_wrapper
    // ════════════════════════════════════════════════════════════════════════

    typedef enum logic [2:0] {
        IDLE        = 3'd0,
        DECODE_BE   = 3'd1,
        LOW_ONLY    = 3'd2,
        HIGH_ONLY   = 3'd3,
        LOW_HALF    = 3'd4,
        PULSE_AS    = 3'd5,
        HIGH_HALF   = 3'd6,
        DONE        = 3'd7
    } state_t;

    state_t state;
    logic [31:0] ctrl_addr;
    logic [15:0] ctrl_din;
    logic [15:0] ctrl_dout;
    logic        ctrl_uds_n;
    logic        ctrl_lds_n;
    logic        ctrl_sel_n;
    logic        ctrl_we_n;
    logic        ctrl_as_n;
    logic        ctrl_dtack_n;
    logic [4:0]  ctrl_state;
    logic [15:0] rdata_hi;
    logic [15:0] rdata_lo;

    // DQM driven directly from the controller-facing strobes via continuous
    // assign - same clock domain / timing relationship as the working 68K
    // reference design.  (Do NOT compute DQM in the always_comb.)
    // During a framebuffer burst the CPU bridge is idle, so its default
    // ctrl_uds_n/ctrl_lds_n = 1 would hold DQM HIGH and MASK every read word.
    // Force DQM low for the whole burst (fb_req brackets it); otherwise follow
    // the CPU strobes exactly as the proven single-access path does.
    assign SDRAM_UDQM   = fb_req ? 1'b0 : ctrl_uds_n;
    assign SDRAM_LDQM   = fb_req ? 1'b0 : ctrl_lds_n;

    always @(posedge Clock or negedge Reset_L) begin
        if (!Reset_L) begin
            state       <= IDLE;
            rdata_hi    <= 16'h0;
            rdata_lo    <= 16'h0;
        end else begin
            case (state)
                IDLE: begin
                    if ((RamSelect_H == 1'b1) && (AS_L == 1'b0)) begin
                        state   <= DECODE_BE;
                    end
                    rdata_hi    <= 16'h0;
                    rdata_lo    <= 16'h0;
                end

                DECODE_BE: begin
                    if (WE_L == 1'b1) begin
                        state <= LOW_HALF;
                    end else begin
                        case (ByteEnable)
                            4'b0001: state <= LOW_ONLY;
                            4'b0010: state <= LOW_ONLY;
                            4'b0011: state <= LOW_ONLY;
                            4'b0100: state <= HIGH_ONLY;
                            4'b1000: state <= HIGH_ONLY;
                            4'b1100: state <= HIGH_ONLY;
                            4'b1111: state <= LOW_HALF;
                            default: state <= IDLE;
                        endcase
                    end
                end

                LOW_ONLY: begin
                    if (ctrl_dtack_n == 1'b0) begin
                        state               <= DONE;
                        rdata_lo            <= ctrl_dout;
                    end
                end

                HIGH_ONLY: begin
                    if (ctrl_dtack_n == 1'b0) begin
                        state               <= DONE;
                        rdata_hi            <= ctrl_dout;
                    end
                end

                LOW_HALF: begin
                    if (ctrl_dtack_n == 1'b0) begin
                        state               <= PULSE_AS;
                        rdata_lo            <= ctrl_dout;
                    end
                end

                PULSE_AS: begin
                    if (ctrl_dtack_n == 1'b1) begin
                        state                   <= HIGH_HALF;
                    end
                end

                HIGH_HALF: begin
                    if (ctrl_dtack_n == 1'b0) begin
                        state               <= DONE;
                        rdata_hi            <= ctrl_dout;
                    end
                end

                DONE: begin
                    if (AS_L == 1'b1) begin
                        state               <= IDLE;
                    end
                end

                default: begin
                    state                   <= IDLE;
                end
            endcase
        end
    end

    always @(*) begin
        ctrl_addr       = 32'h0;
        ctrl_din        = 16'h0;
        ctrl_uds_n      = 1'b1;
        ctrl_lds_n      = 1'b1;
        ctrl_sel_n      = 1'b1;
        ctrl_as_n       = 1'b1;
        ctrl_we_n       = 1'b1;
        DTAck_H         = 1'b0;
        DataOut         = 32'h0;

        case (state)
            LOW_ONLY: begin
                ctrl_addr   = {Address[31:2], 2'b00};
                ctrl_din    = DataIn[15:0];
                ctrl_sel_n  = 1'b0;
                ctrl_as_n   = 1'b0;
                ctrl_we_n   = WE_L;
                if (WE_L == 1'b1) begin
                    ctrl_uds_n  = 1'b0;
                    ctrl_lds_n  = 1'b0;
                end else begin
                    ctrl_uds_n  = ~ByteEnable[1];
                    ctrl_lds_n  = ~ByteEnable[0];
                end
            end

            HIGH_ONLY: begin
                ctrl_addr   = {Address[31:2], 2'b00} + 32'h2;
                ctrl_din    = DataIn[31:16];
                ctrl_sel_n  = 1'b0;
                ctrl_as_n   = 1'b0;
                ctrl_we_n   = WE_L;
                if (WE_L == 1'b1) begin
                    ctrl_uds_n  = 1'b0;
                    ctrl_lds_n  = 1'b0;
                end else begin
                    ctrl_uds_n  = ~ByteEnable[3];
                    ctrl_lds_n  = ~ByteEnable[2];
                end
            end

            LOW_HALF: begin
                ctrl_addr   = {Address[31:2], 2'b00};
                ctrl_din    = DataIn[15:0];
                ctrl_sel_n  = 1'b0;
                ctrl_as_n   = 1'b0;
                ctrl_we_n   = WE_L;
                if (WE_L == 1'b1) begin
                    ctrl_uds_n  = 1'b0;
                    ctrl_lds_n  = 1'b0;
                end else begin
                    ctrl_uds_n  = ~ByteEnable[1];
                    ctrl_lds_n  = ~ByteEnable[0];
                end
            end

            HIGH_HALF: begin
                ctrl_addr   = {Address[31:2], 2'b00} + 32'h2;
                ctrl_din    = DataIn[31:16];
                ctrl_sel_n  = 1'b0;
                ctrl_as_n   = 1'b0;
                ctrl_we_n   = WE_L;
                if (WE_L == 1'b1) begin
                    ctrl_uds_n  = 1'b0;
                    ctrl_lds_n  = 1'b0;
                end else begin
                    ctrl_uds_n  = ~ByteEnable[3];
                    ctrl_lds_n  = ~ByteEnable[2];
                end
            end

            DONE: begin
                DTAck_H         = 1'b1;
                DataOut         = {rdata_hi, rdata_lo};
            end

            default: ;
        endcase
    end

    // ════════════════════════════════════════════════════════════════════════
    // SDRAM controller (modified: burst-read port, arbitration in idling)
    // ════════════════════════════════════════════════════════════════════════

    M68kDramController_Verilog u_dram_ctrl (
        .Clock        (Clock),
        .Reset_L      (Reset_L),
        .Address      (ctrl_addr),
        .DataIn       (ctrl_din),
        .UDS_L        (ctrl_uds_n),
        .LDS_L        (ctrl_lds_n),
        .DramSelect_L (ctrl_sel_n),
        .WE_L         (ctrl_we_n),
        .AS_L         (ctrl_as_n),

        .BurstReq_H   (fb_req),
        .BurstAddress (fb_addr),
        .BurstLength  (fb_len),
        .BurstData    (fb_data),
        .BurstValid_H (fb_valid),
        .BurstDone_H  (fb_done),

        .DataOut      (ctrl_dout),
        .Dtack_L      (ctrl_dtack_n),
        .ResetOut_L   (ResetOut_L),
        .SDram_CKE_H  (SDRAM_CKE),
        .SDram_CS_L   (SDRAM_CS_N),
        .SDram_RAS_L  (SDRAM_RAS_N),
        .SDram_CAS_L  (SDRAM_CAS_N),
        .SDram_WE_L   (SDRAM_WE_N),
        .SDram_Addr   (SDRAM_ADDR),
        .SDram_BA     (SDRAM_BA),
        .SDram_DQ     (SDRAM_DQ),
        .DramState    (ctrl_state)
    );

endmodule: sdram_mmu