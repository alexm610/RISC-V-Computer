`timescale 1ps/1ps

module tb_reg_file;
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
            rd = i[4:0];
            writedata = (i+1) * 2;
            write = 1; #2;
            write = 0; #2;
        end

        $display("Test 2: read from X0, confirm 0x0 is output");
        rs1 = 5'h0; #2;
        assert(readdata_1 == 32'h0) else $error("Register X0 is not hardwired to zero");

        $display("Test 3: read from X14 and X29, confirm output is correct per Xi = (i+1)*2");
        rs1 = 5'd14;
        rs2 = 5'd29; #2;
        assert(readdata_1 == (14+1) * 2) else $error("Register X14 has incorrect output");
        assert(readdata_2 == 32'd60) else $error("Register X29 has incorrect output");

        $display("Test 4: write to register using RD");
        writedata = 32'hF00D;
        rd = 5'd20; #2;
        assert(dut.x20 != 32'hF00D) else $error("Register X20 was written to too early");
        write = 1'b1; #2;
        assert(dut.x20 == 32'hF00D) else $error("Register X20 was not written to properly from writedata bus");
        
        #10;
        $stop;
    end


endmodule: tb_reg_file