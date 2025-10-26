// uart_controller.sv
module uart_controller #(
    parameter CLK_FREQ = 50_000_000,  // System clock frequency in Hz
    parameter BAUD_RATE = 115200      // UART baud rate
) (
    input  logic        clk,
    input  logic        reset,

    // Bus interface
    input  logic        AS_L,         // Address strobe (active low)
    input  logic        WE_L,         // Write enable (active low)
    input  logic        UART_SEL_H,   // Chip select (active high)
    input  logic [1:0]  addr,         // 0 = DATA, 1 = STATUS
    input  logic [31:0] wdata,
    output logic [31:0] rdata,

    // UART pins
    output logic        tx,
    input  logic        rx
);

    // ----------------------------------------------------------------
    // Bus decode
    // ----------------------------------------------------------------
    logic write_en, read_en;
    assign write_en = UART_SEL_H && !AS_L && !WE_L;
    assign read_en  = UART_SEL_H && !AS_L &&  WE_L;

    // ----------------------------------------------------------------
    // Baud generator
    // ----------------------------------------------------------------
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    logic [$clog2(CLKS_PER_BIT)-1:0] baud_cnt;
    logic baud_tick;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_cnt  <= 0;
            baud_tick <= 0;
        end else begin
            if (baud_cnt == CLKS_PER_BIT-1) begin
                baud_cnt  <= 0;
                baud_tick <= 1;
            end else begin
                baud_cnt  <= baud_cnt + 1;
                baud_tick <= 0;
            end
        end
    end

    // ----------------------------------------------------------------
    // TX logic (blocking-friendly: assert busy immediately when CPU writes)
    // ----------------------------------------------------------------
    logic [10:0] tx_shift;   // {stop2, stop1, data[7:0], start}
    logic [3:0]  tx_bit_cnt;
    logic        tx_busy;

    assign tx = tx_shift[0];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_shift   <= 11'h7FF; // line idle = high
            tx_bit_cnt <= 4'd0;
            tx_busy    <= 1'b0;
        end else begin
            // If CPU issues a write to DATA and transmitter is idle, accept it
            if (write_en && (addr == 2'd0) && !tx_busy) begin
                // Frame: start(0), data[7:0], stop(1), stop(1)
                tx_shift   <= {2'b11, wdata[7:0], 1'b0};
                tx_bit_cnt <= 4'd0;
                tx_busy    <= 1'b1; // IMMEDIATELY mark busy so CPU polling will see it next read
            end
            // Otherwise if transmitting, shift at baud rate
            else if (tx_busy && baud_tick) begin
                tx_shift   <= {1'b1, tx_shift[10:1]}; // shift right, fill with 1
                tx_bit_cnt <= tx_bit_cnt + 4'd1;
                if (tx_bit_cnt == 4'd10)
                    tx_busy <= 1'b0; // finished
            end
        end
    end

    // ----------------------------------------------------------------
    // RX logic (8-N-2)
    // ----------------------------------------------------------------
    logic rx_meta, rx_sync;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    logic [3:0]  rx_bit_index;
    logic [7:0]  rx_data_reg;
    logic [$clog2(CLKS_PER_BIT)-1:0] rx_clk_cnt;
    logic        rx_busy;
    logic        rx_ready;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_busy      <= 1'b0;
            rx_ready     <= 1'b0;
            rx_bit_index <= 4'd0;
            rx_clk_cnt   <= 0;
            rx_data_reg  <= 8'd0;
        end else begin
            if (!rx_busy) begin
                if (rx_sync == 1'b0) begin // start bit detected
                    rx_busy      <= 1'b1;
                    rx_bit_index <= 4'd0;
                    rx_clk_cnt   <= CLKS_PER_BIT / 2; // sample mid start bit
                end
            end else begin
                if (rx_clk_cnt == CLKS_PER_BIT-1) begin
                    rx_clk_cnt <= 0;
                    rx_bit_index <= rx_bit_index + 4'd1;
                    case (rx_bit_index)
                        4'd0: ; // start
                        4'd1: rx_data_reg[0] <= rx_sync;
                        4'd2: rx_data_reg[1] <= rx_sync;
                        4'd3: rx_data_reg[2] <= rx_sync;
                        4'd4: rx_data_reg[3] <= rx_sync;
                        4'd5: rx_data_reg[4] <= rx_sync;
                        4'd6: rx_data_reg[5] <= rx_sync;
                        4'd7: rx_data_reg[6] <= rx_sync;
                        4'd8: rx_data_reg[7] <= rx_sync;
                        4'd9: ; // stop1
                        4'd10: begin
                            rx_ready <= 1'b1;
                            rx_busy  <= 1'b0;
                        end
                    endcase
                end else begin
                    rx_clk_cnt <= rx_clk_cnt + 1'b1;
                end
            end

            // clear RX ready when CPU reads DATA reg
            if (read_en && (addr == 2'd0))
                rx_ready <= 1'b0;
        end
    end

    // ----------------------------------------------------------------
    // MMIO readback: DATA @ addr==0, STATUS @ addr==1
    // STATUS bits: bit1 = TX_BUSY, bit0 = RX_READY (matches your C)
    // ----------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) rdata <= 32'd0;
        else if (read_en) begin
            unique case (addr)
                2'd0: rdata <= {24'd0, rx_data_reg};
                2'd1: rdata <= {30'd0, tx_busy, rx_ready}; // bit1=tx_busy, bit0=rx_ready
                default: rdata <= 32'd0;
            endcase
        end else begin
            rdata <= rdata; // hold last
        end
    end

endmodule
