`timescale 1ps/1ps

module tb_rtl_reg_file;
    logic clk, reset_n, write;
    logic [4:0] rs1, rs2, rd;
    logic [31:0] writedata, readdata_1, readdata_2;
    int i = 0;

    reg_file dut (.*);

    initial forever begin
        clk = 1; #1; 
        clk = 0; #1;
    end

    initial begin
        $display("------------------Begin reg_file.sv testbench");
        $display("");
        
        reset_n = 1; #2;
        reset_n = 0; #2;
        reset_n = 1; #2;


        $display("Test 1: write data to each register");
        write = 0;
        for (i = 0; i < 32; i = i + 1) begin
            rs1 = i[4:0];
            writedata = (i+1) * 2;
            write = 1; #2;
            write = 0; #2;
        end

        
        #10;
        $stop;
    end


endmodule: tb_rtl_reg_file