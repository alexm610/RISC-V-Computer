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
        

        /*
        rst_n = 1'b1; #2;
        $readmemh("C:\\Users\\alexm\\math\\RISC-V-Computer\\testbenches\\add.mem", mem_file_1);
        for (i = 0; i < 2; i = i + 1) begin
            dut.im_en = 1'b1;
            dut.pc_in = i[8:0];
            dut.data_in = mem_file_1[i];
            #2;
        end
        dut.im_en = 1'b0;
        */


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
        
        /*
        TEST 2

        ADDI X29, X0, 198 // immediate is in decimal form
        0x0C600E93
        */
        instruction = 32'h0C600E93; #2;
        wait(PC_out == i);
        i = i + 4;

        
        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        $stop;
    end 




endmodule: tb_cpu