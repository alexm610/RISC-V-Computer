`timescale 1ps/1ps

module tb_cpu;
    logic clk, rst_n;
    logic [7:0] LED;
    logic [31:0] instruction, PC_out;
    int i = 4;
    int j = 0;
    int counter = 0;
    int correct_answer = 0;
    logic error;
    reg [31:0] mem_file_1 [0:1];

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
        

        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        $stop;
    end 




endmodule: tb_cpu