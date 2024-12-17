`timescale 1ps/1ps
`include "defines.sv"

module arbitrator  (input logic clk, input logic rst_n, 
                            // Slave (CPU-facing)
                            output logic slave_ready,
                            input logic [3:0] slave_byte_enable,
                            input logic [9:0] slave_address,
                            input logic slave_read, input logic slave_write,
                            input logic [31:0] slave_writedata, output logic [31:0] slave_readdata,
                            // Master (Peripheral-facing)
                            input logic [1:0] master_ready,
                            output logic [2:0] master_enable,
                            output logic [3:0] master_byte_enable,
                            output logic [31:0] master_address,
                            output logic [2:0] master_read, output logic [2:0] master_write,
                            output logic [31:0] master_writedata, input logic [31:0] master_readdata [0:2]);

    logic write_enabled, read_enabled;
    logic [2:0] slave_module;
    enum {IDLE, RAM_1, RAM_2, SW_1, LEDR_1} state;

    // let RAM be in range:     0x00 - 0x7f
    // let SW be in range:      0x80 - 0x8f
    // let LEDR be in range:    0x90 - 0x9f

    always @(*) begin   
        if ((slave_address >= 32'h0) && (slave_address <= 32'h7f)) begin
            slave_module = 3'd1;   // RAM selected 
        end else if ((slave_address >= 32'h80) && (slave_address <= 32'h8f)) begin
            slave_module = 3'd2;   // SW selected 
        end else if ((slave_address >= 32'h90) && (slave_address <= 32'h9f)) begin
            slave_module = 3'd4;   // LEDR selected 
        end else begin 
            slave_module = 3'd0;   // this shouldn't happen; nothing selected
        end  
    end

    assign master_byte_enable = slave_byte_enable;
    assign master_writedata = slave_writedata;

    always @(posedge clk) begin
        if (!rst_n) begin
            slave_ready             <= 1'b0;
            slave_readdata          <= 32'h0;
            master_enable           <= 3'h0;
            master_address          <= 32'h0;
            master_read             <= 3'b000;
            master_write            <= 3'b000;

            state                   <= IDLE;
        end else begin 
            case (state) 
                IDLE: begin
                    slave_ready     <= 1'b0;
                    if (slave_read || slave_write) begin
                        case (slave_module)
                            3'b001: state   <= RAM_1;
                            3'b010: state   <= SW_1;
                            3'b100: state   <= LEDR_1;
                            default: state  <= IDLE;
                        endcase 
                        write_enabled   <= slave_write;
                        read_enabled    <= slave_read;
                    end else begin
                        state       <= IDLE;
                    end
                end
                RAM_1: begin
                    master_write[0]            <= write_enabled;
                    master_read[0]             <= read_enabled;
                    master_address          <= slave_address >> 2;
                    slave_readdata          <= master_readdata[0];
                    
                    state                   <= RAM_2;
                end
                RAM_2: begin
                    master_write            <= 1'b0;
                    master_read             <= 1'b0;

                    slave_ready             <= 1'b1;    
                    state                   <= IDLE;
                end
            endcase
        end
    end
endmodule: arbitrator
