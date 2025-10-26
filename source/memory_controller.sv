`timescale 1ps/1ps

module memory_controller    (input logic clk, input logic rst_n, input logic read, input logic write, input logic [1:0] byte_enable, input logic [9:0] input_address, input logic [31:0] writedata,
                            output logic wren, output logic [3:0] byte_en, output logic [9:0] output_address, output logic [31:0] readdata);

    logic [1:0] byte_select;
    logic [9:0] address;
    enum {WAIT, IDLE} state; 

    assign wren             = write;
    assign output_address   = input_address[9:2];
    assign readdata         = writedata; 
    assign byte_select      = input_address[1:0];

    always @(*) begin
        case (byte_enable)
            2'h0: byte_en = 4'b0001 << byte_select;      // byte operation
            2'h1: byte_en = 4'b0011 << byte_select;      // half-word operation
            2'h2: byte_en = 4'b1111 << byte_select;      // word operation
            default: byte_en = 4'b0000;
        endcase
    end






    /*
    always @(posedge clk) begin
        if (!rst_n) begin
            wren            <= 1'b0;
            byte_en         <= 4'b000;
            output_address  <= 10'h0;
            readdata        <= 32'h0;
            state           <= IDLE;
        end else begin
            case (state) 
                IDLE: begin
                    wren        <= 1'b0;
                    byte_en     <= 4'h0;
                    if (write) begin
                        state   <= START_WRITE;
                    end else if (read) begin
                        state   <= START_READ;
                    end else begin
                        state   <= IDLE;
                    end 
                end
                START_WRITE: begin
                    
                end
            endcase 
        end
    end
    */



endmodule: memory_controller