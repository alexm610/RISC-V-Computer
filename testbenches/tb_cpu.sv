`timescale 1ps/1ps

module tb_cpu;
    logic clk, rst_n;
    logic [7:0] LED;
    int i = 0;
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
        rst_n = 1'b1; #2;

        $readmemh("C:\\Users\\alexm\\math\\RISC-V-Computer\\testbenches\\add.mem", mem_file_1);
        for (i = 0; i < 5; i = i + 1) begin
            dut.im_en = 1'b1;
            dut.pc_in = i[8:0];
            dut.data_in = mem_file_1[i];
            #2;
        end
        dut.im_en = 1'b0;

        $display("------ Begin cpu.sv testbench ------");
        $display("");
        /*
        tEST 1

        ADD X2, X3, X5
        ADD X7, X4, X6
        */

        error = 1'b0;

        rst_n = 1; #2;
        rst_n = 0; #2;
        rst_n = 1; #2;

        #4;
        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        $stop;
    end 




endmodule: tb_cpu