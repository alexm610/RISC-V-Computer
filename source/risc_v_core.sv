module risc_v_core    (input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
                    output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                    output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
                    output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
                    output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK, 
                    output logic [9:0] LEDR);

    logic write_d_mem, test_write, read_d_mem, valid;
    logic [3:0] d_mem_byteenable;
    logic [3:0] fabric_write, fabric_read;
    logic [3:0] byte_enable;
    logic [9:0] program_counter, address_d_mem, address;
    logic [31:0] instruction, dummy_instr_writedata, datapath_output, readdata, d_mem_writedata, fabric_data_out, ram_output, sw_output, ledr_output;
    logic [31:0] readdata_bus [0:2];
    logic [7:0] fill_x;
    logic [6:0] fill_y;
    logic fill_plot;
    logic [9:0] VGA_R_10, VGA_G_10, VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;
    logic [2:0] into_vga_colour;

    assign readdata_bus[0]  = ram_output;
    assign readdata_bus[1]  = sw_output;
    assign readdata_bus[2]  = ledr_output;
    assign VGA_R            = VGA_R_10[9:2];
    assign VGA_G            = VGA_G_10[9:2];
    assign VGA_B            = VGA_B_10[9:2];
    
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
                            .master_ready({3'b000, vga_ready}),
                            .master_enable(),
                            .master_byte_enable(byte_enable),
                            .master_address(address),
                            .master_read(fabric_read),
                            .master_write(fabric_write),
                            .master_writedata(fabric_data_out),
                            .master_readdata(readdata_bus));

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
    
    vga_adapter #(.RESOLUTION("160x120")) VGA_0 (.clock(CLOCK_50),
                            .resetn(KEY[3]),
                            .colour(into_vga_colour), // from controller
                            .x(fill_x), // from controller I need to make 
                            .y(fill_y), // from controller 
                            .plot(fill_plot),  // from controller 
                            .VGA_R(VGA_R_10),
                            .VGA_G(VGA_G_10),
                            .VGA_B(VGA_B_10),
                            .*);

    vga_control VGA_CONTROLLER (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .data_in(fabric_data_out),
                            .ready(vga_ready), // output to arbiter/cpu
                            .start(fabric_write[3]), // input from arbiter (the write signal)
                            .vga_x(fill_x),
                            .vga_y(fill_y),
                            .vga_colour(into_vga_colour),
                            .vga_plot(fill_plot));                   
endmodule: risc_v_core
