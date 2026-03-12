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

    // ── FSM state encoding ───────────────────────────────────────────────────
    typedef enum logic [2:0] {
        IDLE        = 3'd0,     // waiting for a RAM bus cycle
        HI_PHASE    = 3'd1,     // 1st 16-bit cycle (high word), waiting for dtack
        HI_RELEASE  = 3'd2,     // 1-clock bus release; controller returns to idling
        LO_PHASE    = 3'd3,     // 2nd 16-bit cycle (low word), waiting for dtack
        DONE        = 3'd4      // assert DTAck_H, present 32-bit read data
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
    logic        ctrl_rst_out;  // ResetOut_L from controller
    logic [4:0]  ctrl_state;    // DramState (debug only)

    // ── Read-data capture registers ──────────────────────────────────────────
    logic [15:0] rdata_hi;      // high word captured at end of HI_PHASE
    logic [15:0] rdata_lo;      // low  word captured at end of LO_PHASE

    // ── Sequential: FSM transitions + read-data capture ─────────────────────
    always_ff @(posedge Clock or negedge Reset_L) begin
        if (!Reset_L) begin
            state    <= IDLE;
            rdata_hi <= 16'h0000;
            rdata_lo <= 16'h0000;
        end else begin
            case (state)

                IDLE:
                    // Start a new 32-bit transaction when RAM is selected
                    // and the CPU has asserted its address strobe.
                    if (RamSelect_H && !AS_L)
                        state <= HI_PHASE;

                HI_PHASE:
                    // Wait for the underlying controller to assert Dtack_L (active-low).
                    if (!ctrl_dtack_n) begin
                        rdata_hi <= ctrl_dout;  // latch high word
                        state    <= HI_RELEASE;
                    end

                HI_RELEASE:
                    // All bus signals are deasserted for exactly one clock (see
                    // combinational block below).  During this clock the underlying
                    // controller is in terminate_bus_cycle; it sees UDS=LDS=1 and
                    // sets NextState = idling, so it arrives in idling at the start
                    // of LO_PHASE — ready to service the second access immediately.
                    state <= LO_PHASE;

                LO_PHASE:
                    // Wait for the second 16-bit Dtack.
                    if (!ctrl_dtack_n) begin
                        rdata_lo <= ctrl_dout;  // latch low word
                        state    <= DONE;
                    end

                DONE:
                    // DTAck_H was pulsed this clock (see comb block); return to IDLE.
                    state <= IDLE;

                default:
                    state <= IDLE;

            endcase
        end
    end

    // ── Combinational: drive the 16-bit controller ───────────────────────────
    always_comb begin
        // Safe defaults — bus fully deasserted.
        // Active during IDLE, HI_RELEASE, and DONE states.
        ctrl_addr  = 32'h0000_0000;
        ctrl_din   = 16'h0000;
        ctrl_uds_n = 1'b1;
        ctrl_lds_n = 1'b1;
        ctrl_sel_n = 1'b1;
        ctrl_we_n  = 1'b1;
        ctrl_as_n  = 1'b1;
        DTAck_H    = 1'b0;
        DataOut    = 32'h0000_0000;
        SDRAM_UDQM = 1'b0;
        SDRAM_LDQM = 1'b0;
        
        case (state)

            HI_PHASE: begin
                // First 16-bit cycle — upper half of the 32-bit word.
                ctrl_addr  = Address;           // controller extracts row/bank/col internally
                ctrl_din   = DataIn[31:16];     // upper 16 bits of CPU write data
                ctrl_uds_n = ~ByteEnable[3];    // D31..D24 enable
                ctrl_lds_n = ~ByteEnable[2];    // D23..D16 enable
                ctrl_sel_n = 1'b0;              // assert DRAM select
                ctrl_we_n  = WE_L;             // pass write-enable straight through
                ctrl_as_n  = 1'b0;              // assert address strobe
                SDRAM_UDQM = WE_L ? 1'b0 : ~ByteEnable[3];  // D31..D24
                SDRAM_LDQM = WE_L ? 1'b0 : ~ByteEnable[2];  // D23..D16
            end

            LO_PHASE: begin
                // Second 16-bit cycle — lower half of the 32-bit word.
                // Adding 2 to the byte address moves the column address up by 1
                // (controller uses Address[10:1] as the column index).
                ctrl_addr  = Address + 32'd2;   // next 16-bit location
                ctrl_din   = DataIn[15:0];      // lower 16 bits of CPU write data
                ctrl_uds_n = ~ByteEnable[1];    // D15..D8 enable
                ctrl_lds_n = ~ByteEnable[0];    // D7..D0 enable
                ctrl_sel_n = 1'b0;
                ctrl_we_n  = WE_L;
                ctrl_as_n  = 1'b0;
                SDRAM_UDQM = WE_L ? 1'b0 : ~ByteEnable[1];  // D15..D8
                SDRAM_LDQM = WE_L ? 1'b0 : ~ByteEnable[0];  // D7..D0
            end

            DONE: begin
                // Transaction complete: pulse DTAck_H and present read data.
                DTAck_H = 1'b1;
                DataOut = {rdata_hi, rdata_lo}; // reassemble 32-bit word
            end

            // IDLE, HI_RELEASE, default: all signals remain at safe defaults above.
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
