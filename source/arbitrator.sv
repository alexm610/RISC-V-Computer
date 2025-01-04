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
                            input logic [3:0] master_ready,
                            output logic [2:0] master_enable,
                            output logic [3:0] master_byte_enable,
                            output logic [31:0] master_address,
                            output logic [3:0] master_read, output logic [3:0] master_write,
                            output logic [31:0] master_writedata, input logic [31:0] master_readdata [0:2]);

    logic write_enabled, read_enabled;
    logic [3:0] slave_module;
    enum {IDLE, OPERATE, STALL, DONE} state;

    // let RAM be in range:     0x00 - 0x7f
    // let SW be in range:      0x80 - 0x8f
    // let LEDR be in range:    0x90 - 0x9f

    always @(*) begin   
        if ((slave_address >= 32'h0) && (slave_address <= 32'h7f)) begin
            slave_module = 3'd1;   // RAM selected 
        end else if ((slave_address >= 32'h80) && (slave_address <= 32'h8F)) begin
            slave_module = 3'd2;   // SW selected 
        end else if ((slave_address >= 32'h90) && (slave_address <= 32'h9F)) begin
            slave_module = 3'd4;   // LEDR selected 
        end else if ((slave_address >= 32'hA0) && (slave_address <= 32'hAF)) begin
            slave_module = 3'd8;
        end else begin 
            slave_module = 3'd0;   // this shouldn't happen; nothing selected
        end  
    end

    assign master_byte_enable = slave_byte_enable;
    assign master_writedata = slave_writedata;
    assign master_write = write_enabled ? slave_module : 4'b0000;
    assign master_read  = read_enabled ? slave_module : 4'b0000;

    always @(posedge clk) begin
        if (!rst_n) begin
            slave_ready             <= 1'b0;
            slave_readdata          <= 32'h0;
            master_enable           <= 3'h0;
            master_address          <= 32'h0;
            
            state                   <= IDLE;
        end else begin 
            case (state) 
                IDLE: begin
                    slave_ready     <= 1'b0;
                    if (slave_read || slave_write) begin
                        state       <= OPERATE;
                        write_enabled   <= slave_write;
                        read_enabled    <= slave_read;
                        master_address  <= slave_address >> 2;

                    end else begin
                        state       <= IDLE;
                        write_enabled   <= 1'b0;
                        read_enabled    <= 1'b0;
                    end
                end
                OPERATE: begin
                    case (slave_module)
                        4'b0001: slave_readdata     <= master_readdata[0];
                        4'b0010: slave_readdata     <= master_readdata[1];
                        4'b0100: slave_readdata     <= master_readdata[2];
                        //4'b1000: slave_readdata     <= master_readdata[3];
                        default: slave_readdata     <= 32'h0;
                    endcase 
                    master_address          <= slave_address >> 2;

                    state                   <= STALL;
                end
                STALL: begin
                    state <= DONE;
                end
                DONE: begin
                    slave_ready             <= 1'b1;
                    state                   <= IDLE;
                end
            endcase
        end
    end
endmodule: arbitrator
