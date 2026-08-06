module i2c_master_mmio (
    input  logic        clk,
    input  logic        reset_n,

    input  logic        select,
    input  logic        AS_L,
    input  logic        WE_L,
    input  logic [31:0] Address,
    input  logic [31:0] DataIn,
    output logic [31:0] DataOut,

    output logic        scl,
    inout  wire         sda
);

    typedef enum logic [4:0] {
        ST_IDLE,
        ST_START_A,
        ST_START_B,
        ST_WRITE_SETUP,
        ST_WRITE_HIGH,
        ST_WRITE_LOW,
        ST_WRITE_ACK_SETUP,
        ST_WRITE_ACK_HIGH,
        ST_WRITE_ACK_LOW,
        ST_READ_SETUP,
        ST_READ_HIGH,
        ST_READ_LOW,
        ST_READ_ACK_SETUP,
        ST_READ_ACK_HIGH,
        ST_READ_ACK_LOW,
        ST_STOP_A,
        ST_STOP_B,
        ST_STOP_C,
        ST_DONE
    } state_t;

    logic [15:0] prescale;
    logic [15:0] tick_count;
    logic        tick;
    logic        enable;
    logic        busy;
    logic        done;
    logic        rx_ack;
    logic [7:0]  tx_data;
    logic [7:0]  rx_data;
    logic [7:0]  shift;
    logic [2:0]  bit_count;
    logic        cmd_start;
    logic        cmd_stop;
    logic        cmd_read;
    logic        cmd_write;
    logic        cmd_ack_nack;
    logic        scl_drive_low;
    logic        sda_drive_low;
    state_t      state;

    wire write_access = select && (AS_L == 1'b0) && (WE_L == 1'b0);
    wire read_access  = select && (AS_L == 1'b0) && (WE_L == 1'b1);
    wire [3:0] reg_addr = Address[5:2];

    assign scl = scl_drive_low ? 1'b0 : 1'b1;
    assign sda = sda_drive_low ? 1'b0 : 1'bz;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prescale <= 16'd250;
            tx_data  <= 8'h00;
            enable   <= 1'b0;
        end else begin
            if (write_access) begin
                unique case (reg_addr)
                    4'h0: enable   <= DataIn[0];
                    4'h2: tx_data  <= DataIn[7:0];
                    4'h4: prescale <= (DataIn[15:0] == 16'h0000) ? 16'd1 : DataIn[15:0];
                    default: begin end
                endcase
            end
        end
    end

    always_comb begin
        DataOut = 32'h0;

        if (read_access) begin
            unique case (reg_addr)
                4'h0: DataOut = {31'h0, enable};
                4'h1: DataOut = {25'h0, scl, sda, done, rx_ack, busy, state != ST_IDLE, enable};
                4'h2: DataOut = {24'h0, rx_data};
                4'h3: DataOut = {24'h0, rx_data};
                4'h4: DataOut = {16'h0, prescale};
                4'h5: DataOut = {27'h0, cmd_ack_nack, cmd_write, cmd_read, cmd_stop, cmd_start};
                default: DataOut = 32'h0;
            endcase
        end
    end

    always_comb begin
        tick = (tick_count == prescale);
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tick_count <= 16'h0000;
        end else if ((state == ST_IDLE) || tick) begin
            tick_count <= 16'h0000;
        end else begin
            tick_count <= tick_count + 16'h0001;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state         <= ST_IDLE;
            busy          <= 1'b0;
            done          <= 1'b0;
            rx_ack        <= 1'b1;
            rx_data       <= 8'h00;
            shift         <= 8'h00;
            bit_count     <= 3'd7;
            cmd_start     <= 1'b0;
            cmd_stop      <= 1'b0;
            cmd_read      <= 1'b0;
            cmd_write     <= 1'b0;
            cmd_ack_nack  <= 1'b1;
            scl_drive_low <= 1'b0;
            sda_drive_low <= 1'b0;
        end else begin
            if (write_access && (reg_addr == 4'h5) && enable && !busy) begin
                cmd_start    <= DataIn[0];
                cmd_stop     <= DataIn[1];
                cmd_read     <= DataIn[2];
                cmd_write    <= DataIn[3];
                cmd_ack_nack <= DataIn[4];
                shift        <= tx_data;
                bit_count    <= 3'd7;
                busy         <= 1'b1;
                done         <= 1'b0;
                state        <= DataIn[0] ? ST_START_A :
                                DataIn[3] ? ST_WRITE_SETUP :
                                DataIn[2] ? ST_READ_SETUP :
                                DataIn[1] ? ST_STOP_A : ST_DONE;
            end else if (write_access && (reg_addr == 4'h1)) begin
                if (DataIn[2]) begin
                    done <= 1'b0;
                end
            end

            if (tick) begin
                unique case (state)
                    ST_IDLE: begin
                        busy <= 1'b0;
                    end

                    ST_START_A: begin
                        scl_drive_low <= 1'b0;
                        sda_drive_low <= 1'b0;
                        state         <= ST_START_B;
                    end

                    ST_START_B: begin
                        sda_drive_low <= 1'b1;
                        state         <= ST_WRITE_SETUP;

                        if (!cmd_write) begin
                            state <= cmd_read ? ST_READ_SETUP : (cmd_stop ? ST_STOP_A : ST_DONE);
                        end
                    end

                    ST_WRITE_SETUP: begin
                        scl_drive_low <= 1'b1;
                        sda_drive_low <= ~shift[7];
                        state         <= ST_WRITE_HIGH;
                    end

                    ST_WRITE_HIGH: begin
                        scl_drive_low <= 1'b0;
                        state         <= ST_WRITE_LOW;
                    end

                    ST_WRITE_LOW: begin
                        scl_drive_low <= 1'b1;
                        shift         <= {shift[6:0], 1'b0};

                        if (bit_count == 3'd0) begin
                            bit_count <= 3'd7;
                            state     <= ST_WRITE_ACK_SETUP;
                        end else begin
                            bit_count <= bit_count - 3'd1;
                            state     <= ST_WRITE_SETUP;
                        end
                    end

                    ST_WRITE_ACK_SETUP: begin
                        sda_drive_low <= 1'b0;
                        scl_drive_low <= 1'b1;
                        state         <= ST_WRITE_ACK_HIGH;
                    end

                    ST_WRITE_ACK_HIGH: begin
                        scl_drive_low <= 1'b0;
                        rx_ack        <= sda;
                        state         <= ST_WRITE_ACK_LOW;
                    end

                    ST_WRITE_ACK_LOW: begin
                        scl_drive_low <= 1'b1;
                        state         <= cmd_read ? ST_READ_SETUP : (cmd_stop ? ST_STOP_A : ST_DONE);
                    end

                    ST_READ_SETUP: begin
                        sda_drive_low <= 1'b0;
                        scl_drive_low <= 1'b1;
                        state         <= ST_READ_HIGH;
                    end

                    ST_READ_HIGH: begin
                        scl_drive_low <= 1'b0;
                        state         <= ST_READ_LOW;
                    end

                    ST_READ_LOW: begin
                        scl_drive_low     <= 1'b1;
                        shift[bit_count]  <= sda;

                        if (bit_count == 3'd0) begin
                            rx_data   <= {shift[7:1], sda};
                            bit_count <= 3'd7;
                            state     <= ST_READ_ACK_SETUP;
                        end else begin
                            bit_count <= bit_count - 3'd1;
                            state     <= ST_READ_SETUP;
                        end
                    end

                    ST_READ_ACK_SETUP: begin
                        sda_drive_low <= ~cmd_ack_nack;
                        scl_drive_low <= 1'b1;
                        state         <= ST_READ_ACK_HIGH;
                    end

                    ST_READ_ACK_HIGH: begin
                        scl_drive_low <= 1'b0;
                        state         <= ST_READ_ACK_LOW;
                    end

                    ST_READ_ACK_LOW: begin
                        scl_drive_low <= 1'b1;
                        sda_drive_low <= 1'b0;
                        state         <= cmd_stop ? ST_STOP_A : ST_DONE;
                    end

                    ST_STOP_A: begin
                        sda_drive_low <= 1'b1;
                        scl_drive_low <= 1'b1;
                        state         <= ST_STOP_B;
                    end

                    ST_STOP_B: begin
                        scl_drive_low <= 1'b0;
                        state         <= ST_STOP_C;
                    end

                    ST_STOP_C: begin
                        sda_drive_low <= 1'b0;
                        state         <= ST_DONE;
                    end

                    ST_DONE: begin
                        busy  <= 1'b0;
                        done  <= 1'b1;
                        state <= ST_IDLE;
                    end

                    default: state <= ST_IDLE;
                endcase
            end
        end
    end

endmodule
