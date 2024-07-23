`timescale 1ps/1ps

module tb_datapath;
    logic clk, rst_n, write_rb;
    logic [2:0] alu_control;
    logic [4:0] rs_1, rs_2, rd_0;
    logic [31:0] writedata, alu_result;
    int i = 0;
    int correct_answer = 0;

    datapath dut (.*);

    initial forever begin
        clk = 1; #1;
        clk = 0; #1;
    end

    initial begin
        $display("------ Begin datapath.sv testbench ------");
        $display("");

        rst_n = 1; #2;
        rst_n = 0; #2;
        rst_n = 1; #2;

        $display("Test 1: write data to each register");
        write_rb = 0;
        for (i = 0; i < 32; i = i + 1) begin
            rd_0 = i[4:0];
            rs_1 = i[4:0];
            writedata = (i+1) * 2;
            write_rb = 1; #2;
            write_rb = 0; #2;
            if (i == 0) begin
                assert(dut.REGISTER_BANK.readdata_1 == 32'h0) else $error("Register X0 is not hardwired to zero", i);
            end else begin
                assert(dut.REGISTER_BANK.readdata_1 == writedata) else $error("Register X%d wasn't written to properly", i);
            end
        end

        $display("Test 2: operate on registers X23 and X4 - ADD");
        rs_1 = 32'd4;
        rs_2 = 32'd23;
        alu_control = 3'b010;
        correct_answer = ((4+1) * 2) + ((23+1) * 2);
        #8; 
        assert(alu_result == correct_answer) else $error("Addition failed: expected %d, instead got %d", correct_answer, alu_result);

        $display("Test 3: operate on registers X17 and X9 - SUB");
        rs_1 = 32'd17;
        rs_2 = 32'd9;
        alu_control = 3'b110;
        correct_answer = ((17+1) * 2) - ((9+1) * 2);
        #8; 
        assert(alu_result == correct_answer) else $error("Addition failed: expected %d, instead got %d", correct_answer, alu_result);


        #4; 
        $stop;
    end 




endmodule: tb_datapath