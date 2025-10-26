module timer (
    input logic clk,
    input logic reset_n,
    input logic WE_L,
    input logic AS_L,
    input logic data_reg_select,
    input logic control_reg_select,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    output logic irq_out
);

    logic timer_enable;
    logic [1:0] control_reg;
    logic [31:0] data_reg, Timer;

    always @(posedge clk) begin
        if (reset_n == 0) begin
            timer_enable    <= 0;
            control_reg     <= 2'b00;
            data_reg        <= 32'h00000000;
            data_out        <= 32'h00000000;
            Timer           <= 32'h00000000;
            irq_out         <= 1;
        end else begin
            if ((WE_L == 0) && (AS_L == 0)) begin
                if (data_reg_select == 1) begin
                    data_reg <= data_in;
                end

                if (control_reg_select == 1) begin
                    control_reg <= data_in[1:0];
                    Timer       <= data_reg;
                end
            end else if ((WE_L == 1) && (AS_L == 0)) begin
                if (data_reg_select == 1) begin
                    data_out <= data_reg;
                end

                if (control_reg_select == 1) begin
                    data_out <= {{30{1'b0}}, control_reg}; 
                end
            end else begin 
                if (Timer == 32'h00000000) begin
                    if (control_reg[1] == 1) begin // if the second bit is set, then interrupts are enabled
                        irq_out     <= 0; 
                    end

                    Timer <= data_reg; // timer is done, reset the data register
                end else begin
                    if (control_reg[0] == 1) begin // if the first bit is set, then the timer is enabled and countdown can continue
                        Timer <= Timer - 1'b1;
                    end
                end
            end
        end
    end


endmodule: timer