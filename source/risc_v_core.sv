module risc_v_core    (input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
                    output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                    output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
                    output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
                    output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK, 
                    output logic [9:0] LEDR);

    logic write_d_mem, test_write, read_d_mem, valid, AS_L, WE_L;
    logic [3:0] byte_enable;
    logic [3:0] fabric_write, fabric_read;
    logic [9:0] program_counter, address;
    logic [31:0] instruction, dummy_instr_writedata, datapath_output, data_in, data_out, fabric_data_out, ram_output, sw_output, ledr_output, SRAM_data_out;
    logic [31:0] readdata_bus [0:2];
    logic [7:0] fill_x;
    logic [6:0] fill_y;
    logic fill_plot, done;
    logic [9:0] VGA_R_10, VGA_G_10, VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;
    logic [2:0] into_vga_colour;
    logic RAM_Select, IO_Select, Graphics_Select;

    assign VGA_R            = VGA_R_10[9:2];
    assign VGA_G            = VGA_G_10[9:2];
    assign VGA_B            = VGA_B_10[9:2];
    assign LEDR[0]          = done;
    
    cpu PROCESSOR           (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .DTAck(valid),
                            .instruction(instruction),
                            .PC_out(program_counter),
                            .WE_L(WE_L),
                            .Address(address),
                            .DataBus_in(data_in),
                            .DataBus_out(data_out),
                            .byte_enable(byte_enable),
                            .AS_L(AS_L),
                            .conduit(done));

    address_decoder AD      (.Address(address),
                            .RAM_Select_H(RAM_Select),
                            .IO_Select_H(IO_Select),
                            .Graphics_Select_H(Graphics_Select));

    ram INSTRUCTION_MEM     (.clock(CLOCK_50),
                            .address(program_counter >> 2),
                            .byteena(4'b1111),
                            .wren(test_write),
                            .data(dummy_instr_writedata),
                            .q(instruction));

    SRAM_Block SRAM         (.AS_L(AS_L),
                            .WE_L(WE_L),
                            .RAM_Select_H(RAM_Select),
                            .Address(address),
                            .Byte_Enable(byte_enable),
                            .Data_In(data_out),
                            .Data_Out(data_in));
    /*
	IO_Handler IO   		(.Clock(CLOCK_50),
							.LEDR_output(LEDR),
							.SW_input(SW),
							.AS_L(AS_L),
							.WE_L(WE_L),
							.IO_Select(IO_Select),
							.Address(address),
							.IO_data_in(data_out),
							.IO_data_out(data_in));

                     
    vga_control VGA_CONTROL (.clk(CLOCK_50),
                            .rst_n(KEY[3]),
                            .data_in(fabric_data_out),
                            .ready(vga_ready), // output to arbiter/cpu
                            .start(fabric_write[3]), // input from arbiter (the write signal)
                            .vga_x(fill_x),
                            .vga_y(fill_y),
                            .vga_colour(into_vga_colour),
                            .vga_plot(fill_plot));  

    vga_adapter             #(.RESOLUTION("160x120")) VGA_0 (.clock(CLOCK_50),
                            .resetn(KEY[3]),
                            .colour(into_vga_colour), // from controller
                            .x(fill_x), // from controller I need to make 
                            .y(fill_y), // from controller 
                            .plot(fill_plot),  // from controller 
                            .VGA_R(VGA_R_10),
                            .VGA_G(VGA_G_10),
                            .VGA_B(VGA_B_10),
                            .*); */           
endmodule: risc_v_core
