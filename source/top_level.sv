module top_level    (input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
                    output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                    output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
                    output logic [9:0] LEDR);

    logic write_d_mem;
    logic [9:0] program_counter, address_d_mem;
    logic [31:0] instruction, dummy_instr_writedata, datapath_output, readdata, d_mem_writedata;

    cpu PROCESSOR           (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .instruction(instruction),
                            .conduit(datapath_output),
                            .PC_out(program_counter),
                            .data_memory_write(write_d_mem),
                            .data_memory_address(address_d_mem),
                            .readdata(readdata),
                            .RS2_readdata(d_mem_writedata));

    memory INSTRUCTION_MEM  (.clock(CLOCK_50),
                            .reset_n(KEY[3]),
                            .write(1'b0),
                            .address(program_counter),
                            .writedata(dummy_instr_writedata),
                            .readbyte(),
                            .readword(instruction));

    memory DATA_MEM         (.clock(CLOCK_50),
                            .reset_n(KEY[3]),
                            .write(write_d_mem),
                            .address(address_d_mem),
                            .writedata(d_mem_writedata),
                            .readbyte(),
                            .readword(readdata));
endmodule: top_level
