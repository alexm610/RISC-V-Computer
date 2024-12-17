module top_level    (input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
                    output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                    output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
                    /*output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
                    output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
                    output logic [7:0] VGA_X, output logic [7:0] VGA_Y,
                    output logic [2:0] VGA_COLOUR, output logic VGA_PLOT,*/
                    output logic [9:0] LEDR);

    logic write_d_mem, test_write, read_d_mem, valid;
    logic [3:0] d_mem_byteenable;
    logic [2:0] fabric_write, fabric_read;
    logic [3:0] byte_enable;
    logic [9:0] program_counter, address_d_mem, address;
    logic [31:0] instruction, dummy_instr_writedata, datapath_output, readdata, d_mem_writedata, fabric_data_out, ram_output, sw_output, ledr_output;

    cpu PROCESSOR           (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .read_valid(valid),
                            .instruction(instruction),
                            .conduit(datapath_output),
                            .PC_out(program_counter),
                            .data_memory_write(write_d_mem),
                            .data_memory_address(address_d_mem),
                            .readdata(readdata),
                            .RS2_readdata(d_mem_writedata),
                            .data_memory_read(read_d_mem),
                            .byte_enable(d_mem_byteenable));

    arbitrator FABRIC       (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .slave_ready(valid),
                            .slave_byte_enable(d_mem_byteenable),
                            .slave_address(address_d_mem),
                            .slave_read(read_d_mem),
                            .slave_write(write_d_mem),
                            .slave_writedata(d_mem_writedata),
                            .slave_readdata(readdata),
                            .master_ready(),
                            .master_enable(),
                            .master_byte_enable(byte_enable),
                            .master_address(address),
                            .master_read(fabric_read),
                            .master_write(fabric_write),
                            .master_writedata(fabric_data_out),
                            .master_readdata({ram_output, sw_output, ledr_output}));

    ram INSTRUCTION_MEM     (.clock(CLOCK_50),
                            .address(program_counter >> 2),
                            .byteena(4'b1111),
                            .wren(test_write),
                            .data(dummy_instr_writedata),
                            .q(instruction));
    
    ram DATA_MEM            (.clock(CLOCK_50),
                            .address(address),
                            .byteena(byte_enable),
                            .wren(fabric_write[0]),
                            .data(fabric_data_out),
                            .q(ram_output));

    sw_peripheral SWITCHES  (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .switch_input(SW),
                            .switch_output(sw_output));

    ledr_peripheral LIGHTS  (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .write(fabric_write[2]),
                            .writedata(fabric_data_out),
                            .ledr_output(LEDR));
    
    /*
    memory INSTRUCTION_MEM  (.clock(CLOCK_50),
                            .reset_n(KEY[3]),
                            .write(test_write),
                            .read(1'b1),
                            .address(program_counter),
                            .writedata(dummy_instr_writedata),
                            .readbyte(),
                            .readword(instruction));

    memory DATA_MEM         (.clock(CLOCK_50),
                            .reset_n(KEY[3]),
                            .write(write_d_mem),
                            .read(read_d_mem),
                            .address(address_d_mem),
                            .writedata(d_mem_writedata),
                            .readbyte(),
                            .readword(readdata));
    */
endmodule: top_level
