`timescale 1ps/1ps

module tb_datapath;
    logic clk, rst_n, write_rb;
    logic [2:0] alu_control;
    logic [4:0] rs_1, rs_2, rd_0;
    logic [31:0] writedata, alu_result;
    int i = 0;
    int j = 0;
    int counter = 0;
    int correct_answer = 0;
    logic error;

    datapath dut (.*);

    initial forever begin
        clk = 1; #1;
        clk = 0; #1;
    end

    initial begin
        $display("------ Begin datapath.sv testbench ------");
        $display("");

        error = 1'b0;

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
                assert(dut.REGISTER_BANK.readdata_1 == 32'h0) else begin $error("Register X0 is not hardwired to zero", i); error = 1'b1; end 
            end else begin
                assert(dut.REGISTER_BANK.readdata_1 == writedata) else begin $error("Register X%d wasn't written to properly", i); error = 1'b1; end
            end
        end

        alu_control = 3'b010;
        for (i = 1; i < 32; i = i + 1) begin
            for (j = 1; j < 32; j = j + 1) begin
                $display("Test %d: ADD X%d X%d\n", counter+1, i[4:0], j[4:0]);
                rs_1 = i[4:0];
                rs_2 = j[4:0];
                correct_answer = ((rs_1 + 1) * 2) + ((rs_2 + 1) * 2);
                #8;
                assert(alu_result == correct_answer) else begin $error("Addition failed: expected %d, instead got %d", correct_answer, alu_result); error = 1'b1; end
                counter = counter + 1;
            end
        end

        alu_control = 3'b110;
        for (i = 1; i < 32; i = i + 1) begin
            for (j = 1; j < 32; j = j + 1) begin
                $display("Test %d: SUB X%d X%d\n", counter+1, i[4:0], j[4:0]);
                rs_1 = i[4:0];
                rs_2 = j[4:0];
                correct_answer = ((rs_1 + 1) * 2) - ((rs_2 + 1) * 2);
                #8;
                assert(alu_result == correct_answer) else begin $error("Subtraction failed: expected %d, instead got %d", correct_answer, alu_result); error = 1'b1; end
                counter = counter + 1;
            end
        end

        alu_control = 3'b000;
        for (i = 1; i < 32; i = i + 1) begin
            for (j = 1; j < 32; j = j + 1) begin
                $display("Test %d: AND X%d X%d\n", counter+1, i[4:0], j[4:0]);
                rs_1 = i[4:0];
                rs_2 = j[4:0];
                correct_answer = ((rs_1 + 1) * 2) & ((rs_2 + 1) * 2);
                #8;
                assert(alu_result == correct_answer) else begin $error("Logical And failed: expected %d, instead got %d", correct_answer, alu_result); error = 1'b1; end
                counter = counter + 1;
            end
        end

        alu_control = 3'b001;
        for (i = 1; i < 32; i = i + 1) begin
            for (j = 1; j < 32; j = j + 1) begin
                $display("Test %d: OR X%d X%d\n", counter+1, i[4:0], j[4:0]);
                rs_1 = i[4:0];
                rs_2 = j[4:0];
                correct_answer = ((rs_1 + 1) * 2) | ((rs_2 + 1) * 2);
                #8;
                assert(alu_result == correct_answer) else begin $error("Logical Or failed: expected %d, instead got %d", correct_answer, alu_result); error = 1'b1; end
                counter = counter + 1;
            end
        end

        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        #4; 
        $stop;
    end 




endmodule: tb_datapath