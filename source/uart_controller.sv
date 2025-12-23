// uart_mmio_8bit.sv
// MMIO UART (8-N-1), polled, 8-bit CPU bus: Address/AS_L/WE_L/DataIn/DataOut

module uart_mmio_8bit #(
    parameter logic [31:0] BASE_ADDR = 32'h1000_0000,
    parameter int unsigned CLK_HZ    = 50_000_000,
    parameter int unsigned BAUD      = 115_200
) (
    input  logic        CLOCK_50MHz,
    input  logic        RESET_L,

    input  logic        AS_L,          // active-low address strobe
    input  logic        WE_L,          // active-low write enable (0=write, 1=read)
    input  logic [31:0] Address,       // byte address
    input  logic [7:0]  DataIn,        // write data
    output logic [7:0]  DataOut,       // read data (combinational)

    input  logic        uart_rx,
    output logic        uart_tx
);

    logic clk, reset_n;
    assign clk     = CLOCK_50MHz;
    assign reset_n = RESET_L;

    // -----------------------------
    // Address decode (16-byte window)
    // -----------------------------
    // Peripheral responds at BASE_ADDR .. BASE_ADDR+0xF
    logic       bus_sel, bus_wr, bus_rd;
    logic [3:0] off;

    assign bus_sel = (~AS_L) && (Address[31:4] == BASE_ADDR[31:4]);
    assign bus_wr  = bus_sel && (~WE_L);
    assign bus_rd  = bus_sel && ( WE_L);
    assign off     = Address[3:0];

    localparam logic [3:0] REG_DATA   = 4'h0;
    localparam logic [3:0] REG_STATUS = 4'h1;
    localparam logic [3:0] REG_BAUD_L = 4'h2;
    localparam logic [3:0] REG_BAUD_H = 4'h3;
    localparam logic [3:0] REG_CTRL   = 4'h4;

    // -----------------------------
    // Default baud divisor
    // -----------------------------
    function automatic int unsigned calc_div(input int unsigned clk_hz, input int unsigned baud);
        int unsigned q;
        begin
            q = (baud == 0) ? 0 : (clk_hz / baud);
            calc_div = (q == 0) ? 0 : (q - 1);
        end
    endfunction

    localparam int unsigned BAUDDIV_RESET = calc_div(CLK_HZ, BAUD);

    // -----------------------------
    // Registers / status
    // -----------------------------
    logic        tx_en, rx_en, loopback;
    logic [15:0] bauddiv; // clocks_per_bit_minus_1

    logic [7:0]  rx_data;
    logic        rx_valid;
    logic        rx_overrun_sticky;
    logic        rx_frameerr_sticky;

    // -----------------------------
    // UART RX synchronizer
    // -----------------------------
    logic rx_ff1, rx_ff2;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_ff1 <= 1'b1;
            rx_ff2 <= 1'b1;
        end else begin
            rx_ff1 <= uart_rx;
            rx_ff2 <= rx_ff1;
        end
    end

    logic rx_in;
    assign rx_in = loopback ? uart_tx : rx_ff2;

    // -----------------------------
    // TX engine (8N1)
    // -----------------------------
    logic        tx_busy;
    logic [3:0]  tx_bit_idx;   // 0..9
    logic [9:0]  tx_shift;     // bit0=start, bits1..8=data, bit9=stop
    logic [15:0] tx_cnt;       // countdown within a bit

    // -----------------------------
    // RX engine (8N1, mid-bit sample)
    // -----------------------------
    typedef enum logic [1:0] {RX_IDLE, RX_START, RX_DATA, RX_STOP} rx_state_t;
    rx_state_t   rx_state;
    logic [2:0]  rx_bit_idx;   // 0..7
    logic [7:0]  rx_shift;
    logic [15:0] rx_cnt;

    function automatic [15:0] half_div(input [15:0] div);
        // div=(ticks_per_bit-1). half bit ~= (ticks_per_bit/2)-1
        logic [15:0] ticks;
        logic [15:0] half_ticks;
        begin
            ticks = div + 16'd1;
            half_ticks = ticks >> 1;
            if (half_ticks == 16'd0) half_div = 16'd0;
            else half_div = half_ticks - 16'd1;
        end
    endfunction

    // -----------------------------
    // Combinational read mux
    // -----------------------------
    always_comb begin
        DataOut = 8'h00;

        if (bus_sel && WE_L) begin
            unique case (off)
                REG_DATA:   DataOut = rx_data;

                REG_STATUS: begin
                    DataOut        = 8'h00;
                    DataOut[0]     = ~tx_busy;            // TX_READY
                    DataOut[1]     = rx_valid;            // RX_VALID
                    DataOut[2]     = rx_overrun_sticky;   // OVERRUN (sticky)
                    DataOut[3]     = rx_frameerr_sticky;  // FRAME_ERR (sticky)
                end

                REG_BAUD_L: DataOut = bauddiv[7:0];
                REG_BAUD_H: DataOut = bauddiv[15:8];

                REG_CTRL: begin
                    DataOut        = 8'h00;
                    DataOut[0]     = tx_en;
                    DataOut[1]     = rx_en;
                    DataOut[2]     = loopback;
                end

                default:    DataOut = 8'h00;
            endcase
        end
    end

    // -----------------------------
    // Sequential logic
    // -----------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tx_en     <= 1'b1;
            rx_en     <= 1'b1;
            loopback  <= 1'b0;
            bauddiv   <= BAUDDIV_RESET[15:0];

            rx_data            <= 8'h00;
            rx_valid           <= 1'b0;
            rx_overrun_sticky  <= 1'b0;
            rx_frameerr_sticky <= 1'b0;

            uart_tx    <= 1'b1;
            tx_busy    <= 1'b0;
            tx_bit_idx <= 4'd0;
            tx_shift   <= 10'h3FF;
            tx_cnt     <= 16'd0;

            rx_state   <= RX_IDLE;
            rx_bit_idx <= 3'd0;
            rx_shift   <= 8'h00;
            rx_cnt     <= 16'd0;
        end else begin
            // ---- Read side-effect: reading DATA clears RX_VALID
            if (bus_rd && (off == REG_DATA)) begin
                rx_valid <= 1'b0;
            end

            // ---- Writes
            if (bus_wr) begin
                unique case (off)
                    REG_DATA: begin
                        // Start TX only if enabled and idle
                        if (tx_en && !tx_busy) begin
                            tx_shift   <= {1'b1, DataIn, 1'b0}; // stop,data,start
                            tx_bit_idx <= 4'd0;
                            tx_busy    <= 1'b1;
                            uart_tx    <= 1'b0;                 // start bit
                            tx_cnt     <= bauddiv;
                        end
                    end

                    REG_STATUS: begin
                        // W1C sticky bits
                        if (DataIn[2]) rx_overrun_sticky  <= 1'b0;
                        if (DataIn[3]) rx_frameerr_sticky <= 1'b0;
                    end

                    REG_BAUD_L: bauddiv[7:0]  <= DataIn;
                    REG_BAUD_H: bauddiv[15:8] <= DataIn;

                    REG_CTRL: begin
                        tx_en    <= DataIn[0];
                        rx_en    <= DataIn[1];
                        loopback <= DataIn[2];

                        if (DataIn[3]) rx_valid <= 1'b0; // CLR_RX

                        if (DataIn[4]) begin             // CLR_ERR
                            rx_overrun_sticky  <= 1'b0;
                            rx_frameerr_sticky <= 1'b0;
                        end
                    end

                    default: begin end
                endcase
            end

            // ---- If TX disabled, force idle
            if (!tx_en) begin
                tx_busy <= 1'b0;
                uart_tx <= 1'b1;
            end

            // ---- TX engine
            if (tx_en && tx_busy) begin
                if (tx_cnt != 16'd0) begin
                    tx_cnt <= tx_cnt - 16'd1;
                end else begin
                    // end of current bit time
                    if (tx_bit_idx == 4'd9) begin
                        // stop bit time finished
                        tx_busy <= 1'b0;
                        uart_tx <= 1'b1;
                    end else begin
                        tx_bit_idx <= tx_bit_idx + 4'd1;
                        tx_cnt     <= bauddiv;

                        // shift to next bit; new bit0 is old bit1
                        tx_shift <= {1'b1, tx_shift[9:1]};
                        uart_tx  <= tx_shift[1];
                    end
                end
            end

            // ---- RX engine
            if (!rx_en) begin
                rx_state <= RX_IDLE;
                rx_cnt   <= 16'd0;
            end else begin
                unique case (rx_state)
                    RX_IDLE: begin
                        if (rx_in == 1'b0) begin
                            rx_state <= RX_START;
                            rx_cnt   <= half_div(bauddiv);
                        end
                    end

                    RX_START: begin
                        if (rx_cnt != 16'd0) begin
                            rx_cnt <= rx_cnt - 16'd1;
                        end else begin
                            // sample middle of start bit
                            if (rx_in == 1'b0) begin
                                rx_state   <= RX_DATA;
                                rx_bit_idx <= 3'd0;
                                rx_cnt     <= bauddiv;
                            end else begin
                                rx_state <= RX_IDLE; // glitch
                            end
                        end
                    end

                    RX_DATA: begin
                        if (rx_cnt != 16'd0) begin
                            rx_cnt <= rx_cnt - 16'd1;
                        end else begin
                            rx_shift[rx_bit_idx] <= rx_in;
                            rx_cnt <= bauddiv;

                            if (rx_bit_idx == 3'd7) rx_state <= RX_STOP;
                            else rx_bit_idx <= rx_bit_idx + 3'd1;
                        end
                    end

                    RX_STOP: begin
                        if (rx_cnt != 16'd0) begin
                            rx_cnt <= rx_cnt - 16'd1;
                        end else begin
                            if (rx_in != 1'b1) rx_frameerr_sticky <= 1'b1;

                            // 1-byte buffer: preserve old byte, drop new if not read
                            if (rx_valid) begin
                                rx_overrun_sticky <= 1'b1;
                            end else begin
                                rx_data  <= rx_shift;
                                rx_valid <= 1'b1;
                            end

                            rx_state <= RX_IDLE;
                        end
                    end

                    default: rx_state <= RX_IDLE;
                endcase
            end
        end
    end

endmodule
