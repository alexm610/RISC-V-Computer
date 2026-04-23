// SDRAM_32bit_Wrapper.sv
//
// Drop-in replacement for OnChipRam256kbyte.
// Wraps M68kDramController_Verilog (16-bit) to present a 32-bit interface
// matching the CPU's bus.  Each 32-bit transaction is split into two
// sequential 16-bit bus cycles through the underlying controller.
//
// ── FSM ─────────────────────────────────────────────────────────────────────
//
//   IDLE ──► HI_PHASE ──(dtack)──► HI_RELEASE ──► LO_PHASE ──(dtack)──► DONE ──► IDLE
//
//   HI_RELEASE is a mandatory 1-clock bus release between the two 16-bit
//   cycles.  While the wrapper deasserts all strobes the underlying controller
//   sees UDS=LDS=1 inside its terminate_bus_cycle state and transitions back
//   to idling, ready to accept the second cycle on the very next clock.
//
// ── Address mapping ──────────────────────────────────────────────────────────
//   Cycle 1 (high word):  ctrl_addr = Address        (cpu byte address)
//   Cycle 2 (low  word):  ctrl_addr = Address + 2    (next 16-bit location)
//
//   Pass Address straight from the CPU — do NOT >>2 before this module.
//
// ── Byte-enable mapping ──────────────────────────────────────────────────────
//   ByteEnable[3] → UDS_L (cycle 1)   covers D31..D24
//   ByteEnable[2] → LDS_L (cycle 1)   covers D23..D16
//   ByteEnable[1] → UDS_L (cycle 2)   covers D15..D8
//   ByteEnable[0] → LDS_L (cycle 2)   covers D7..D0
//
// ── New ports vs OnChipRam256kbyte ───────────────────────────────────────────
//   DTAck_H    — 1-cycle high pulse when the 32-bit transaction is done.
//                Connect to CPU's DTAck input (via a mux: RAM_Select? DTAck_H : 1'b1)
//   ResetOut_L — mirrors SDRAM controller's ResetOut_L (held low ~100 µs on
//                power-up during SDRAM init).  AND with KEY[0] for CPU Reset_L.
//   SDRAM_*    — physical SDRAM pins; add to top-level port list and .qsf.

module SDRAM_wrapper (
    input  logic        Clock,
    input  logic        Reset_L,        // active-low board reset (KEY[0])

    // ── CPU-facing interface (matches OnChipRam256kbyte naming) ─────────────
    input  logic        RamSelect_H,    // active-high: SDRAM address range selected
    input  logic        WE_L,           // active-low write enable from CPU
    input  logic        AS_L,           // active-low address strobe from CPU
    input  logic [31:0] Address,        // byte address — do NOT >>2 before this module
    input  logic [3:0]  ByteEnable,     // [3]=D31..24  [2]=D23..16  [1]=D15..8  [0]=D7..0
    input  logic [31:0] DataIn,         // write data from CPU
    output logic [31:0] DataOut,        // read data to CPU (stable in DONE state)
    output logic        DTAck_H,        // pulses high for 1 clock when transaction done
    output logic        ResetOut_L,     // low during SDRAM init; high when ready

    // ── Physical SDRAM pins (wire directly to DE1-SoC DRAM_* header pins) ───
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

    // ── Wires to/from the 16-bit SDRAM controller ───────────────────────────
    logic [31:0] ctrl_addr;     // address bus into controller
    logic [15:0] ctrl_din;      // 16-bit write data into controller
    logic [15:0] ctrl_dout;     // 16-bit read data out of controller
    logic        ctrl_uds_n;    // upper byte strobe (active-low)
    logic        ctrl_lds_n;    // lower byte strobe (active-low)
    logic        ctrl_sel_n;    // DramSelect_L into controller
    logic        ctrl_we_n;     // WE_L into controller
    logic        ctrl_as_n;     // AS_L into controller
    logic        ctrl_dtack_n;  // Dtack_L from controller (active-low)

    logic [4:0]  ctrl_state;    // DramState (debug only)

    // ── Read-data capture registers ──────────────────────────────────────────
    logic [15:0] rdata_hi;      // high word captured at end of HI_PHASE
    logic [15:0] rdata_lo;      // low  word captured at end of LO_PHASE


    assign SDRAM_UDQM   = ctrl_uds_n;
    assign SDRAM_LDQM   = ctrl_lds_n;

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
                    case (ByteEnable) 
                        4'b0001: state <= LOW_ONLY;
                        4'b0010: state <= LOW_ONLY;
                        4'b0100: state <= HIGH_ONLY;
                        4'b1000: state <= HIGH_ONLY;
                        4'b0011: state <= LOW_ONLY;
                        4'b1100: state <= HIGH_ONLY;
                        4'b1111: state <= LOW_HALF;
                        default: state <= IDLE;
                    endcase
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
                ctrl_addr   = Address;
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
                ctrl_addr   = Address + 32'h2;
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
                ctrl_addr   = Address;
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
                ctrl_addr   = Address + 32'h2;
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

    // ── Underlying 16-bit M68k SDRAM controller ──────────────────────────────
    M68kDramController_Verilog u_dram_ctrl (
        .Clock        (Clock),
        .Reset_L      (Reset_L),

        // 68000-style 16-bit CPU bus (driven by the FSM above)
        .Address      (ctrl_addr),
        .DataIn       (ctrl_din),
        .UDS_L        (ctrl_uds_n),
        .LDS_L        (ctrl_lds_n),
        .DramSelect_L (ctrl_sel_n),
        .WE_L         (ctrl_we_n),
        .AS_L         (ctrl_as_n),

        // Responses back to the wrapper FSM
        .DataOut      (ctrl_dout),
        .Dtack_L      (ctrl_dtack_n),
        .ResetOut_L   (ResetOut_L),

        // Physical SDRAM pins — pass straight to top-level ports
        .SDram_CKE_H  (SDRAM_CKE),
        .SDram_CS_L   (SDRAM_CS_N),
        .SDram_RAS_L  (SDRAM_RAS_N),
        .SDram_CAS_L  (SDRAM_CAS_N),
        .SDram_WE_L   (SDRAM_WE_N),
        .SDram_Addr   (SDRAM_ADDR),
        .SDram_BA     (SDRAM_BA),
        .SDram_DQ     (SDRAM_DQ),

        // Debug: connect to SignalTap or LEDs if needed
        .DramState    (ctrl_state)
    );

    // Expose the controller's reset-done signal so the top level can gate the CPU.
    // This is LOW for ~100 µs after power-on (SDRAM init) then goes HIGH.
    //assign ResetOut_L = ctrl_rst_out;

endmodule : SDRAM_wrapper
