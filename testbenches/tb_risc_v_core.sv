`timescale 1ps/1ps

module tb_risc_v_core();
    logic CLOCK_50;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [7:0] VGA_R, VGA_G, VGA_B, VGA_X, VGA_Y;
    logic [2:0] VGA_COLOUR;
    logic VGA_PLOT, VGA_HS, VGA_VS, VGA_CLK;
    logic [9:0] SW, LEDR;
    logic [35:0] GPIO_0, GPIO_1;
    
    reg [31:0] i;
    reg [31:0] j;
    int counter = 0;
    int correct_answer = 0;
    logic error;
    reg [31:0] mem_file_1 [0:255];

    risc_v_core dut   (.*);

    initial forever begin
        CLOCK_50 = 1; #1;
        CLOCK_50 = 0; #1;
    end

    initial begin
        $display("------ Begin risc_v_core.sv testbench ------");
        $display("");
        error = 0;
        KEY[0] = 1; #2;
        KEY[0] = 0; #2;
        KEY[0] = 1; #2;
        SW = 10'b0110101011; #2;
        
        j = 0;
        for (i = 0; i < 4096; i = i + 4) begin
            force dut.WE_L = 0;
            force dut.AS_L = 0;
            force dut.ROM_Select = 1;
            force dut.address = i[9:0];
            force dut.data_out = 32'h0;
            #2;
        end

        dut.WE_L = 1;
        release dut.WE_L;
        release dut.AS_L;
        
        release dut.address;
        release dut.data_out;
        #2;
        //KEY[0] = 0;
        $readmemh("instructions.txt", mem_file_1);
        j = 0;
        for (i = 0; i < 1024; i = i + 4) begin
            dut.test_write = 1;
            //force dut.program_counter = i;
            force dut.ROM_Select = 1;
            force dut.address = i;
            force dut.dummy_instr_writedata = mem_file_1[j];
            
            #2;
            j = j + 1;
        end
        dut.test_write = 0;
        #2;
        //release dut.program_counter;
        release dut.address;
        release dut.dummy_instr_writedata;
        release dut.ROM_Select;
        KEY[0] = 1; #2;
        KEY[0] = 0; #2;
        KEY[0] = 1; #10;

        wait (dut.address == 32'h00000114);
        
        //@ (posedge LEDR[9]);
        #4;

        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        $stop;
    end 




endmodule: tb_risc_v_core