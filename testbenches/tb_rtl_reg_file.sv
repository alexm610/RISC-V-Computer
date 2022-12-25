`timescale 1ps/1ps

module tb_rtl_reg_file;
    logic clk, reset_n, write;
    logic [4:0] writenum, readnum;
    logic [31:0] data_in;
    logic [31:0] data_out;
    int i;

    reg_file dut (.*);

    initial forever begin
        clk = 1; #1; 
        clk = 0; #1;
    end

    initial begin
        $display("------------------Begin reg_file.sv testbench");
        $display("");
        
        $display("Test 1: write data to each register, confirm ");
        for (i = 0; i < 32; i = i + 1) begin
            write = 0; #2;
            writenum = i[31:0];
            data_in = i[31:0];
            #2; write = 1; #2;
        end

        

        $stop;
    end


endmodule: tb_rtl_reg_file