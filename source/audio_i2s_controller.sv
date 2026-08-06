module audio_i2s_controller #(
    parameter int FIFO_ADDR_WIDTH = 12
) (
    input  logic        bus_clk,
    input  logic        audio_clk,
    input  logic        reset_n,

    input  logic        select,
    input  logic        AS_L,
    input  logic        WE_L,
    input  logic [31:0] Address,
    input  logic [31:0] DataIn,
    output logic [31:0] DataOut,

    output logic        AUD_XCK,
    output logic        AUD_BCLK,
    output logic        AUD_DACLRCK,
    output logic        AUD_DACDAT,
    output logic        AUD_ADCLRCK,
    input  logic        AUD_ADCDAT
);

    localparam int FIFO_DEPTH = 1 << FIFO_ADDR_WIDTH;
    localparam int STATUS_PAD_WIDTH = 32 - (FIFO_ADDR_WIDTH + 1) - 9;

    logic        enable;
    logic        mute;
    logic        clear_fifo_bus;
    logic        clear_fifo_toggle_bus;
    logic        fifo_wr;
    logic        fifo_full;
    logic        fifo_empty;
    logic [31:0] fifo_rdata;
    logic        fifo_rd;
    logic [FIFO_ADDR_WIDTH:0] fifo_level;

    logic        underrun_toggle_audio;
    logic [2:0]  underrun_toggle_bus_sync;
    logic        underrun_sticky;

    logic [1:0] enable_sync;
    logic [1:0] mute_sync;
    logic [2:0] clear_sync_audio;

    logic [31:0] rx_sample_audio;
    logic        rx_toggle_audio;
    logic [31:0] rx_sample_bus_0;
    logic [31:0] rx_sample_bus_1;
    logic [2:0]  rx_toggle_bus_sync;
    logic [31:0] rx_sample_bus;

    wire write_access = select && (AS_L == 1'b0) && (WE_L == 1'b0);
    wire read_access  = select && (AS_L == 1'b0) && (WE_L == 1'b1);
    wire [3:0] reg_addr = Address[5:2];

    assign AUD_XCK = audio_clk;
    assign AUD_BCLK = audio_clk;
    assign AUD_ADCLRCK = AUD_DACLRCK;
    assign fifo_wr = write_access && (reg_addr == 4'h2) && !fifo_full;

    audio_async_fifo #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) TX_FIFO (
        .wr_clk     (bus_clk),
        .wr_reset_n (reset_n),
        .wr_clear   (clear_fifo_bus),
        .wr_en      (fifo_wr),
        .wr_data    (DataIn),
        .wr_full    (fifo_full),
        .wr_level   (fifo_level),

        .rd_clk     (audio_clk),
        .rd_reset_n (reset_n),
        .rd_clear   (clear_sync_audio[2] ^ clear_sync_audio[1]),
        .rd_en      (fifo_rd),
        .rd_data    (fifo_rdata),
        .rd_empty   (fifo_empty)
    );

    always_ff @(posedge bus_clk or negedge reset_n) begin
        if (!reset_n) begin
            enable                  <= 1'b0;
            mute                    <= 1'b0;
            clear_fifo_bus          <= 1'b0;
            clear_fifo_toggle_bus   <= 1'b0;
            underrun_sticky         <= 1'b0;
            underrun_toggle_bus_sync <= 3'b000;
            rx_toggle_bus_sync      <= 3'b000;
            rx_sample_bus_0         <= 32'h0;
            rx_sample_bus_1         <= 32'h0;
            rx_sample_bus           <= 32'h0;
        end else begin
            clear_fifo_bus <= 1'b0;
            underrun_toggle_bus_sync <= {underrun_toggle_bus_sync[1:0], underrun_toggle_audio};
            rx_toggle_bus_sync <= {rx_toggle_bus_sync[1:0], rx_toggle_audio};
            rx_sample_bus_0 <= rx_sample_audio;
            rx_sample_bus_1 <= rx_sample_bus_0;

            if (underrun_toggle_bus_sync[2] ^ underrun_toggle_bus_sync[1]) begin
                underrun_sticky <= 1'b1;
            end

            if (rx_toggle_bus_sync[2] ^ rx_toggle_bus_sync[1]) begin
                rx_sample_bus <= rx_sample_bus_1;
            end

            if (write_access && (reg_addr == 4'h0)) begin
                enable <= DataIn[0];
                mute   <= DataIn[2];

                if (DataIn[1]) begin
                    clear_fifo_bus        <= 1'b1;
                    clear_fifo_toggle_bus <= ~clear_fifo_toggle_bus;
                end

                if (DataIn[3]) begin
                    underrun_sticky <= 1'b0;
                end
            end
        end
    end

    always_comb begin
        DataOut = 32'h0;

        if (read_access) begin
            unique case (reg_addr)
                4'h0: DataOut = {29'h0, mute, 1'b0, enable};
                4'h1: DataOut = {
                    {STATUS_PAD_WIDTH{1'b0}},
                    fifo_level,
                    5'h0,
                    underrun_sticky,
                    fifo_full,
                    fifo_empty,
                    !fifo_full
                };
                4'h2: DataOut = 32'h0;
                4'h3: DataOut = 32'd4;
                4'h4: DataOut = rx_sample_bus;
                default: DataOut = 32'h0;
            endcase
        end
    end

    logic [7:0]  frame_pos;
    logic [31:0] current_sample;
    logic [15:0] rx_shift;
    logic [15:0] rx_left;

    always_ff @(negedge audio_clk or negedge reset_n) begin
        if (!reset_n) begin
            enable_sync            <= 2'b00;
            mute_sync              <= 2'b00;
            clear_sync_audio       <= 3'b000;
            frame_pos              <= 8'd0;
            current_sample         <= 32'h0;
            fifo_rd                <= 1'b0;
            AUD_DACLRCK            <= 1'b0;
            AUD_DACDAT             <= 1'b0;
            underrun_toggle_audio  <= 1'b0;
            rx_shift               <= 16'h0;
            rx_left                <= 16'h0;
            rx_sample_audio        <= 32'h0;
            rx_toggle_audio        <= 1'b0;
        end else begin
            enable_sync      <= {enable_sync[0], enable};
            mute_sync        <= {mute_sync[0], mute};
            clear_sync_audio <= {clear_sync_audio[1:0], clear_fifo_toggle_bus};
            fifo_rd          <= 1'b0;

            if (!enable_sync[1]) begin
                frame_pos   <= 8'd0;
                AUD_DACLRCK <= 1'b0;
                AUD_DACDAT  <= 1'b0;
            end else begin
                AUD_DACLRCK <= (frame_pos == 8'd0);

                unique case (frame_pos)
                    8'd0: begin
                        AUD_DACDAT <= 1'b0;

                        if (!fifo_empty) begin
                            current_sample <= fifo_rdata;
                            fifo_rd        <= 1'b1;
                        end else begin
                            current_sample        <= 32'h0;
                            underrun_toggle_audio <= ~underrun_toggle_audio;
                        end
                    end

                    8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8,
                    8'd9, 8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16: begin
                        AUD_DACDAT <= mute_sync[1] ? 1'b0 : current_sample[31 - (frame_pos - 8'd1)];
                    end

                    8'd17, 8'd18, 8'd19, 8'd20, 8'd21, 8'd22, 8'd23, 8'd24,
                    8'd25, 8'd26, 8'd27, 8'd28, 8'd29, 8'd30, 8'd31, 8'd32: begin
                        AUD_DACDAT <= mute_sync[1] ? 1'b0 : current_sample[15 - (frame_pos - 8'd17)];
                    end

                    default: begin
                        AUD_DACDAT <= 1'b0;
                    end
                endcase

                if (frame_pos >= 8'd1 && frame_pos <= 8'd16) begin
                    rx_shift <= {rx_shift[14:0], AUD_ADCDAT};

                    if (frame_pos == 8'd16) begin
                        rx_left <= {rx_shift[14:0], AUD_ADCDAT};
                    end
                end else if (frame_pos >= 8'd17 && frame_pos <= 8'd32) begin
                    rx_shift <= {rx_shift[14:0], AUD_ADCDAT};

                    if (frame_pos == 8'd32) begin
                        rx_sample_audio <= {rx_left, rx_shift[14:0], AUD_ADCDAT};
                        rx_toggle_audio <= ~rx_toggle_audio;
                    end
                end

                if (frame_pos == 8'd255) begin
                    frame_pos <= 8'd0;
                end else begin
                    frame_pos <= frame_pos + 8'd1;
                end
            end
        end
    end

endmodule

module audio_async_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 6
) (
    input  logic                  wr_clk,
    input  logic                  wr_reset_n,
    input  logic                  wr_clear,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  wr_full,
    output logic [ADDR_WIDTH:0]   wr_level,

    input  logic                  rd_clk,
    input  logic                  rd_reset_n,
    input  logic                  rd_clear,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  rd_empty
);

    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [ADDR_WIDTH:0] wr_bin;
    logic [ADDR_WIDTH:0] wr_bin_inc;
    logic [ADDR_WIDTH:0] wr_bin_next;
    logic [ADDR_WIDTH:0] wr_gray;
    logic [ADDR_WIDTH:0] wr_gray_inc;
    logic [ADDR_WIDTH:0] wr_gray_next;
    logic [ADDR_WIDTH:0] wr_gray_rd_sync_0;
    logic [ADDR_WIDTH:0] wr_gray_rd_sync_1;
    logic [ADDR_WIDTH:0] wr_bin_rd_sync;

    logic [ADDR_WIDTH:0] rd_bin;
    logic [ADDR_WIDTH:0] rd_bin_next;
    logic [ADDR_WIDTH:0] rd_gray;
    logic [ADDR_WIDTH:0] rd_gray_next;
    logic [ADDR_WIDTH:0] rd_gray_wr_sync_0;
    logic [ADDR_WIDTH:0] rd_gray_wr_sync_1;
    logic [ADDR_WIDTH:0] rd_bin_wr_sync;

    function automatic [ADDR_WIDTH:0] bin_to_gray(input [ADDR_WIDTH:0] bin);
        bin_to_gray = (bin >> 1) ^ bin;
    endfunction

    function automatic [ADDR_WIDTH:0] gray_to_bin(input [ADDR_WIDTH:0] gray);
        integer i;
        begin
            gray_to_bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH - 1; i >= 0; i = i - 1) begin
                gray_to_bin[i] = gray_to_bin[i + 1] ^ gray[i];
            end
        end
    endfunction

    assign wr_bin_inc   = wr_bin + 1'b1;
    assign wr_gray_inc  = bin_to_gray(wr_bin_inc);
    assign wr_full      = (wr_gray_inc == {~rd_gray_wr_sync_1[ADDR_WIDTH:ADDR_WIDTH-1], rd_gray_wr_sync_1[ADDR_WIDTH-2:0]});
    assign wr_bin_next  = wr_bin + ((wr_en && !wr_full) ? 1'b1 : 1'b0);
    assign wr_gray_next = bin_to_gray(wr_bin_next);

    assign rd_bin_next  = rd_bin + ((rd_en && !rd_empty) ? 1'b1 : 1'b0);
    assign rd_gray_next = bin_to_gray(rd_bin_next);
    assign rd_empty     = (rd_gray == wr_gray_rd_sync_1);

    assign rd_data = mem[rd_bin[ADDR_WIDTH-1:0]];

    always_ff @(posedge wr_clk or negedge wr_reset_n) begin
        if (!wr_reset_n) begin
            wr_bin          <= '0;
            wr_gray         <= '0;
            rd_gray_wr_sync_0 <= '0;
            rd_gray_wr_sync_1 <= '0;
            rd_bin_wr_sync  <= '0;
            wr_level        <= '0;
        end else begin
            rd_gray_wr_sync_0 <= rd_gray;
            rd_gray_wr_sync_1 <= rd_gray_wr_sync_0;
            rd_bin_wr_sync    <= gray_to_bin(rd_gray_wr_sync_1);
            wr_level          <= wr_bin - rd_bin_wr_sync;

            if (wr_clear) begin
                wr_bin   <= '0;
                wr_gray  <= '0;
            end else begin
                if (wr_en && !wr_full) begin
                    mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
                end

                wr_bin  <= wr_bin_next;
                wr_gray <= wr_gray_next;
            end
        end
    end

    always_ff @(posedge rd_clk or negedge rd_reset_n) begin
        if (!rd_reset_n) begin
            rd_bin            <= '0;
            rd_gray           <= '0;
            wr_gray_rd_sync_0 <= '0;
            wr_gray_rd_sync_1 <= '0;
        end else begin
            wr_gray_rd_sync_0 <= wr_gray;
            wr_gray_rd_sync_1 <= wr_gray_rd_sync_0;

            if (rd_clear) begin
                rd_bin  <= '0;
                rd_gray <= '0;
            end else begin
                rd_bin  <= rd_bin_next;
                rd_gray <= rd_gray_next;
            end
        end
    end

endmodule
