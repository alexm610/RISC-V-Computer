// uart_mmio_32bit.sv
// Word-spaced MMIO UART (8-N-1), polled
// BASE + 0x00 DATA, +0x04 STATUS, +0x08 CTRL, +0x0C BAUDDIV (RO)
//
// Hardcoded: 50 MHz clock, 115200 baud -> BAUDDIV = (50_000_000/115200)-1 = 433

module uart_mmio_32bit #(
    parameter logic [31:0] BASE_ADDR = 32'h1000_0000
) (
    input  logic         CLOCK_50MHz,
    input  logic         RESET_L,

    input  logic         AS_L,          // active-low address strobe
    input  logic         WE_L,          // active-low write enable (0=write, 1=read)
    input  logic [31:0]  Address,       // byte address
    input  logic [31:0]  DataIn,        // 32-bit bus; UART uses low byte where relevant
    output logic [31:0]  DataOut,       // 32-bit read data

    input  logic         uart_rx,
    output logic         uart_tx
);

    logic clk, reset_n;
    assign clk     = CLOCK_50MHz;
    assign reset_n = RESET_L;

    // Hardcoded baud divisor for 50MHz -> 115200
    localparam logic [15:0] BAUDDIV = 16'd433; // ticks_per_bit_minus_1

    // Word-spaced register select: 0x0,0x4,0x8,0xC
    // Use Address[3:2] within a 16-byte window
    logic        bus_sel, bus_wr, bus_rd;
    logic [1:0]  woff;

    assign bus_sel = (~AS_L) && (Address[31:4] == BASE_ADDR[31:4]);
    assign bus_wr  = bus_sel && (~WE_L);
    assign bus_rd  = bus_sel && ( WE_L);
    assign woff    = Address[3:2];

    localparam logic [1:0] REG_DATA    = 2'd0; // +0x00
    localparam logic [1:0] REG_STATUS  = 2'd1; // +0x04
    localparam logic [1:0] REG_CTRL    = 2'd2; // +0x08
    localparam logic [1:0] REG_BAUDDIV = 2'd3; // +0x0C (RO)

    // CTRL bits
    logic tx_en, rx_en, loopback;

    // RX status
    logic [7:0] rx_data;
    logic       rx_valid;
    logic       rx_overrun_sticky;
    logic       rx_frameerr_sticky;

    // RX sync
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

    // TX engine (8N1)
    logic        tx_busy;
    logic [3:0]  tx_bit_idx;   // 0..9
    logic [9:0]  tx_shift;     // bit0=start, bits1..8=data, bit9=stop
    logic [15:0] tx_cnt;

    // RX engine (8N1, mid-bit sample)
    typedef enum logic [1:0] {RX_IDLE, RX_START, RX_DATA, RX_STOP} rx_state_t;
    rx_state_t   rx_state;
    logic [2:0]  rx_bit_idx;
    logic [7:0]  rx_shift;
    logic [15:0] rx_cnt;

    function automatic [15:0] half_div(input [15:0] div);
        logic [15:0] ticks;
        logic [15:0] half_ticks;
        begin
            ticks = div + 16'd1;          // ticks_per_bit
            half_ticks = ticks >> 1;      // /2
            if (half_ticks == 16'd0) half_div = 16'd0;
            else half_div = half_ticks - 16'd1;
        end
    endfunction

    // --------------- Read mux ---------------
    always_comb begin
        DataOut = 32'h0;

        if (bus_sel && WE_L) begin
            unique case (woff)
                REG_DATA:   DataOut = {24'h0, rx_data};

                REG_STATUS: begin
                    DataOut[0] = ~tx_busy;           // TX_READY
                    DataOut[1] = rx_valid;           // RX_VALID
                    DataOut[2] = rx_overrun_sticky;  // OVERRUN (sticky)
                    DataOut[3] = rx_frameerr_sticky; // FRAME_ERR (sticky)
                end

                REG_CTRL: begin
                    DataOut[0] = tx_en;
                    DataOut[1] = rx_en;
                    DataOut[2] = loopback;
                end

                REG_BAUDDIV: begin
                    DataOut = {16'h0, BAUDDIV};
                end

                default: DataOut = 32'h0;
            endcase
        end
    end

    // --------------- Sequential ---------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tx_en     <= 1'b1;
            rx_en     <= 1'b1;
            loopback  <= 1'b0;

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
            // Reading DATA clears RX_VALID
            if (bus_rd && (woff == REG_DATA)) begin
                rx_valid <= 1'b0;
            end

            // Writes
            if (bus_wr) begin
                unique case (woff)
                    REG_DATA: begin
                        if (tx_en && !tx_busy) begin
                            tx_shift   <= {1'b1, DataIn[7:0], 1'b0}; // stop,data,start
                            tx_bit_idx <= 4'd0;
                            tx_busy    <= 1'b1;
                            uart_tx    <= 1'b0;     // start bit
                            tx_cnt     <= BAUDDIV;
                        end
                    end

                    REG_STATUS: begin
                        // W1C sticky bits
                        if (DataIn[2]) rx_overrun_sticky  <= 1'b0;
                        if (DataIn[3]) rx_frameerr_sticky <= 1'b0;
                    end

                    REG_CTRL: begin
                        tx_en    <= DataIn[0];
                        rx_en    <= DataIn[1];
                        loopback <= DataIn[2];

                        if (DataIn[3]) rx_valid <= 1'b0; // CLR_RX
                        if (DataIn[4]) begin            // CLR_ERR
                            rx_overrun_sticky  <= 1'b0;
                            rx_frameerr_sticky <= 1'b0;
                        end
                    end

                    default: begin end
                endcase
            end

            // If TX disabled, force idle
            if (!tx_en) begin
                tx_busy <= 1'b0;
                uart_tx <= 1'b1;
            end

            // TX engine
            if (tx_en && tx_busy) begin
                if (tx_cnt != 16'd0) begin
                    tx_cnt <= tx_cnt - 16'd1;
                end else begin
                    if (tx_bit_idx == 4'd9) begin
                        tx_busy <= 1'b0;
                        uart_tx <= 1'b1;
                    end else begin
                        tx_bit_idx <= tx_bit_idx + 4'd1;
                        tx_cnt     <= BAUDDIV;

                        tx_shift <= {1'b1, tx_shift[9:1]};
                        uart_tx  <= tx_shift[1];
                    end
                end
            end

            // RX engine
            if (!rx_en) begin
                rx_state <= RX_IDLE;
                rx_cnt   <= 16'd0;
            end else begin
                unique case (rx_state)
                    RX_IDLE: begin
                        if (rx_in == 1'b0) begin
                            rx_state <= RX_START;
                            rx_cnt   <= half_div(BAUDDIV);
                        end
                    end

                    RX_START: begin
                        if (rx_cnt != 16'd0) rx_cnt <= rx_cnt - 16'd1;
                        else begin
                            if (rx_in == 1'b0) begin
                                rx_state   <= RX_DATA;
                                rx_bit_idx <= 3'd0;
                                rx_cnt     <= BAUDDIV;
                            end else begin
                                rx_state <= RX_IDLE;
                            end
                        end
                    end

                    RX_DATA: begin
                        if (rx_cnt != 16'd0) rx_cnt <= rx_cnt - 16'd1;
                        else begin
                            rx_shift[rx_bit_idx] <= rx_in;
                            rx_cnt <= BAUDDIV;

                            if (rx_bit_idx == 3'd7) rx_state <= RX_STOP;
                            else rx_bit_idx <= rx_bit_idx + 3'd1;
                        end
                    end

                    RX_STOP: begin
                        if (rx_cnt != 16'd0) rx_cnt <= rx_cnt - 16'd1;
                        else begin
                            if (rx_in != 1'b1) rx_frameerr_sticky <= 1'b1;

                            if (rx_valid) rx_overrun_sticky <= 1'b1;
                            else begin
                                rx_data  <= rx_shift;
                                rx_valid <= 1'b1;
                            end

                            rx_state <= RX_IDLE;
                        end
                    end
                endcase
            end
        end
    end

endmodule
