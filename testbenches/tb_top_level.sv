`timescale 1ps/1ps

module tb_top_level();
    logic CLOCK_50;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] SW, LEDR;

    int i = 4;
    int j = 0;
    int counter = 0;
    int correct_answer = 0;
    logic error;
    reg [31:0] mem_file_1 [0:255];

    top_level dut   (.*);

    initial forever begin
        CLOCK_50 = 1; #1;
        CLOCK_50 = 0; #1;
    end

    initial begin
        $display("------ Begin top_level.sv testbench ------");
        $display("");
        error = 0;
        KEY[3] = 1; #2;
        KEY[3] = 0; #2;
        KEY[3] = 1; #2;
        SW = 10'b0110101011; #2;
        
        j = 0;
        for (i = 0; i < 1024; i = i + 4) begin
            force dut.write_d_mem = 1;
            force dut.address_d_mem = i[7:0];
            force dut.d_mem_writedata = 32'h0;

            #2;
            j = j + 1;
        end
        dut.test_write = 0;
        dut.write_d_mem = 0;
        release dut.write_d_mem;
        release dut.address_d_mem;
        release dut.d_mem_writedata;
        #2;
        
        $readmemh("instructions.txt", mem_file_1);
        j = 0;
        for (i = 0; i < 256; i = i + 4) begin
            dut.test_write = 1;
            force dut.program_counter = i[7:0];
            force dut.dummy_instr_writedata = mem_file_1[j];
            
            #2;
            j = j + 1;
        end
        dut.test_write = 0;
        #2;
        release dut.program_counter;
        release dut.dummy_instr_writedata;
        KEY[3] = 1; #2;
        KEY[3] = 0; #2;
        KEY[3] = 1; #10;

        @ (posedge dut.datapath_output[0]);
        #4;

        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        $stop;
    end 




endmodule: tb_top_level