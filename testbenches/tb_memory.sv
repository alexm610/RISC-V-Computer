`timescale 1ps/1ps

module tb_memory;
    logic clock, reset_n, write;
    logic [7:0] readbyte;
    logic [9:0] address;
    logic [31:0] writedata, readword;
    int i = 0;

    memory dut (.*);

    initial forever begin 
        clock = 1; #1;
        clock = 0; #1;
    end 

    initial begin 
        $display("------ Begin memory.sv testbench ------");
        $display("");



        reset_n = 1; #2;
        reset_n = 0; #2;
        reset_n = 1; 

        $display("Fill memory with data");
        address = 32'h0;
        writedata = 32'h0BADF00D;
        write = 0;
        #2;
        write = 1; 
        #2;
        write = 0;
        #4;
        assert(readword == writedata);
        #2;

        address = 32'h1;
        #2;
        assert(readword == writedata);
        assert(readbyte == writedata[15:8]);
        #2;

        address = 32'h4;
        writedata = 32'hABC56F33;
        #2;
        write = 1; 
        #2;
        write = 0;
        #2;
        assert(readword == writedata);
        assert(readbyte == writedata[7:0]);
        #4;

        $stop;
    end 

endmodule: tb_memory    