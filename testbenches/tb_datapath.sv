`timescale 1ps/1ps

module tb_datapath;
    logic clk, rst_n, write_rb;
    logic [2:0] alu_control;
    logic [4:0] rs_1, rs_2, rd_0;
    logic [31:0] writedata, alu_result;

    datapath dut (.*);

    initial forever begin
        clk = 1; #1;
        clk = 0; #1;
    end

    initial begin
        $display("")

        #10; 
        $stop;
    end 




endmodule: tb_datapath