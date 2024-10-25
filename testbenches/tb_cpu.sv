`timescale 1ps/1ps

module tb_cpu;
    logic clk, rst_n, data_memory_write;
    logic [9:0] data_memory_address;
    logic [31:0] instruction, readdata, PC_out, RS2_readdata, conduit;
    int i = 4;
    int j = 0;
    int counter = 0;
    int correct_answer = 0;
    logic error;
    reg [31:0] mem_file_1 [0:255];

    cpu dut (.*);

    initial forever begin
        clk = 1; #1;
        clk = 0; #1;
    end

    initial begin
        $display("------ Begin cpu.sv testbench ------");
        $display("");
       
        /*
        TEST 1

        ADDI X3, X13, 34 // immediate is in decimal form
        0x02268193

        */
        readdata = 32'h0BADF00D;
        error = 1'b0;
        instruction = 32'h02268193;
        rst_n = 1'b1; #2;
        rst_n = 1'b0; #2;
        rst_n = 1'b1; #2;

        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X3.out == 32'd34);
        /*
        TEST 2

        ADDI X29, X0, 198 // immediate is in decimal form
        0x0C600E93
        */
        instruction = 32'h0C600E93; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X29.out == 32'd198);
        /*
        TEST 3

        XORI X20, X30, 76 // immediate is in decimal form
        0x04CF4A13
        */
        instruction = 32'h04CF4A13; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X20.out == 32'd76);
        /*
        TEST 4

        XORI X15, X7, 203 // immediate is in decimal form
        0x0CB3C793
        */
        instruction = 32'h0CB3C793; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X15.out == 32'd203);

        /*
        TEST 5

        ORI X12, X6, 43 // immediate is in decimal form
        0x02B36613
        */
        instruction = 32'h02B36613; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X12.out == 32'd43);

        /*
        TEST 6

        ORI X19, X31, 172 // immediate is in decimal form
        0X0ACFE993
        */
        instruction = 32'h0ACFE993; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X19.out == 32'd172);

        /*
        TEST 7

        ANDI X9, X20, 21 // immediate is in decimal form
        0X015A7493
        */
        instruction = 32'h015A7493; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X9.out == (32'd21 & dut.HW.REGISTER_BANK.X20.out));

        /*
        TEST 8

        ANDI X25, X29, 115 // immediate is in decimal form
        0X073EFC93
        */
        instruction = 32'h073EFC93; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X25.out == (32'd115 & dut.HW.REGISTER_BANK.X29.out));

        /*
        TEST 9

        SLLI X17, X9, 9 // immediate is in decimal form
        0x00949893
        */
        instruction = 32'h00949893; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X17.out == (dut.HW.REGISTER_BANK.X9.out << 9));

        /*
        TEST 10

        SLLI X31, X15, 3 // immediate is in decimal form
        0x00379f93
        */
        instruction = 32'h00379f93; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X31.out == (dut.HW.REGISTER_BANK.X15.out << 3));

        /*
        TEST 11

        SRLI X18, X17, 2 // immediate is in decimal form
        0x0028d913
        */
        instruction = 32'h0028d913; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X18.out == (dut.HW.REGISTER_BANK.X17.out >> 2));

        /*
        TEST 12

        SRLI X6, X9, 1 // immediate is in decimal form
        0x0014d313
        */
        instruction = 32'h0014d313; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X6.out == (dut.HW.REGISTER_BANK.X9.out >> 1));
        
        /*
        TEST 13

        ADDI, X2, X0, 1 // immediate is in decimal form
        0x00100113
        */
        instruction = 32'h00100113; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X2.out == (32'd1));

        /*
        TEST 14

        SLLI X1, X2, 31 // immediate is in decimal form
        0x01f11093
        */
        instruction = 32'h01f11093; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X1.out == (dut.HW.REGISTER_BANK.X2.out << 32'd31));


        /*
        TEST 15

        SRAI X12, X1, 2 // immediate is in decimal form
        0x4020d613
        */
        instruction = 32'h4020d613; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X12.out == (dut.HW.REGISTER_BANK.X1.out >>> 2));

        /*
        TEST 16

        SRLI X27, X12, 1 // immediate is in decimal form
        0x00165d93
        */
        instruction = 32'h00165d93; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X27.out == (dut.HW.REGISTER_BANK.X12.out >> 1));
        
        /*
        TEST 17

        SRAI X28, X27, 1 // immediate is in decimal form
        0x401dde13
        */
        instruction = 32'h401dde13; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X28.out == (dut.HW.REGISTER_BANK.X27.out >>> 1));

        /*
        TEST 18

        LB X0, 0(X2) // immediate is in decimal form
        0x00010003
        */
        readdata = 32'h0BADF01D;
        instruction = 32'h00010003; #2;
        $display(PC_out);
        wait(PC_out == i);
        $display(PC_out);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X0.out == ({24'h0, readdata[7:0]}));
        #2;

        /*
        TEST 19

        LH X4, 0(X2) // immediate is in decimal form
        0x00011203
        */
        readdata = 32'h0BADF01D;
        instruction = 32'h00011203; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X4.out == ({16'h0, readdata[15:0]}));
        #2;

        /*
        TEST 20

        LW X13, 0(X2) // immediate is in decimal form
        0x00012683
        */
        readdata = 32'h0BADF01D;
        instruction = 32'h00012683; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X13.out == (readdata[31:0]));
        #2;

        /*
        TEST 21

        STLI X13, X9, 3 // immediate is in decimal form
        0x0034a693
        */
        instruction = 32'h0034A693; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X13.out == ((dut.HW.REGISTER_BANK.X9.out < 3) ? 1 : 0));
        #2;

        /*
        TEST 22

        STLI X13, X9, 5 // immediate is in decimal form
        0x0054a693
        */
        instruction = 32'h0054a693; #2;
        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X13.out == ((dut.HW.REGISTER_BANK.X9.out < 5) ? 1 : 0));
        #2;

        /*
        TEST 23

        ADDI X1, X0, 127 // immediate is in decimal form
        0xFFF00093

        */
        readdata = 32'h0BADF00D;
        error = 1'b0;
        instruction = 32'h07F00093;

        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X1.out == 32'h7F); // number should be sign extended

        /*
        TEST 24

        SLTI X2, X1, -128
        0Xf800a113
        */
        instruction = 32'hF800A113;

        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X2.out == 32'h0); // signed comparison: 127 is not less than -128

        /*
        TEST 24

        SLTIU X2, X1, -128
        0xF800B113
        */
        instruction = 32'hF800B113;

        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X2.out == 32'h1); // unsigned comparison: 127 is less than -128(unsigned)

        /*
        TEST 25

        ADD X14, X2, X3
        0x00310733
        */
        instruction = 32'h00310733;

        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X14.out == (dut.HW.REGISTER_BANK.X2.out + dut.HW.REGISTER_BANK.X3.out));

        /*
        TEST 26

        SUB X15, X2, X3
        0x402187b3
        */
        instruction = 32'h402187B3;

        wait(PC_out == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X15.out == (dut.HW.REGISTER_BANK.X3.out - dut.HW.REGISTER_BANK.X2.out));

        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        $stop;
    end 




endmodule: tb_cpu