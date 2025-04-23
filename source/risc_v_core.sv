module risc_v_core (
    input logic CLOCK_50, 
    input logic [3:0] KEY, 
    input logic [9:0] SW,
    input logic [35:0] GPIO_0,
    output logic [35:0] GPIO_1,
    output logic [6:0] HEX0, 
    output logic [6:0] HEX1, 
    output logic [6:0] HEX2,
    output logic [6:0] HEX3, 
    output logic [6:0] HEX4, 
    output logic [6:0] HEX5,
    output logic [7:0] VGA_R, 
    output logic [7:0] VGA_G, 
    output logic [7:0] VGA_B,
    output logic VGA_HS, 
    output logic VGA_VS, 
    output logic VGA_CLK, 
    output logic [9:0] LEDR
);

    logic write_d_mem, test_write, read_d_mem, valid, AS_L, WE_L, Reset_L;
    logic [3:0] byte_enable;
    logic [3:0] fabric_write, fabric_read;
    logic [31:0] program_counter;//, address;
    logic [31:0] address;
    logic [31:0] instruction, dummy_instr_writedata, datapath_output, data_in, data_out, fabric_data_out, ram_output, sw_output, ledr_output, SRAM_data_out, data_out_IO, data_out_SRAM;
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
    assign LEDR[9]          = done;
    
    cpu PROCESSOR           (.clk(CLOCK_50),
                            .rst_n(KEY[0]),
                            .DTAck(1'b1),
                            .instruction(instruction),
                            .PC_out(program_counter),
                            .WE_L(WE_L),
                            .Address(address),
                            .DataBus_in(data_in),
                            .DataBus_out(data_out),
                            .byte_enable(byte_enable),
                            .AS_L(AS_L),
                            .conduit(done),
                            .Reset_Out(Reset_L));

    address_decoder AD      (.Address(address),
                            .RAM_Select_H(RAM_Select),
                            .IO_Select_H(IO_Select),
                            .Graphics_Select_H(Graphics_Select));

    data_bus_multiplexer DATABUS_MULTIPLEXER (
        .Select_SRAM(RAM_Select),
        .Select_IO(IO_Select),
        .DataIn_SRAM(data_out_SRAM),
        .DataIn_IO(data_out_IO),
        .DataOut_CPU(data_in)
    );

    ram INSTRUCTION_MEM     (.clock(CLOCK_50),
                            //.address(program_counter >> 2),
                            .address(address),
                            .byteena(4'b1111),
                            .wren(test_write),
                            .data(dummy_instr_writedata),
                            .q(instruction));

    SRAM_Block SRAM         (.Clock(CLOCK_50),
                            .AS_L(AS_L),
                            .WE_L(WE_L),
                            .RAM_Select_H(RAM_Select),
                            .Address(address >> 2),
                            .Byte_Enable(byte_enable),
                            .Data_In(data_out),
                            .Data_Out(data_out_SRAM));
    
	IO_Handler IO   		(.Clock(CLOCK_50),
                            .Reset_L(Reset_L),
							.LEDR_output(LEDR[8:0]),
							.SW_input(SW),
                            .HEX5_output(HEX5),
                            .HEX4_output(HEX4),
                            .HEX3_output(HEX3),
                            .HEX2_output(HEX2),
                            .HEX1_output(HEX1),
                            .HEX0_output(HEX0),
							.AS_L(AS_L),
							.WE_L(WE_L),
							.IO_Select(IO_Select),
							.Address(address),
							.IO_data_in(data_out),
							.IO_data_out(data_out_IO),
                            .RS_pin(GPIO_1[0]),
                            .E_pin(GPIO_1[1]),
                            .RW_pin(GPIO_1[2]),
                            .LCD_DataOut({GPIO_1[3], GPIO_1[4], GPIO_1[5], GPIO_1[6], GPIO_1[7], GPIO_1[8], GPIO_1[9], GPIO_1[10]})
    );
           
    vga_control VGA_CONTROL (.clk(CLOCK_50),
                            .rst_n(Reset_L),
                            .data_in(data_out),
                            .ready(vga_ready), // output to arbiter/cpu
                            .VGA_Select(Graphics_Select),
                            .start(1'b0), // input from arbiter (the write signal)
                            .vga_x(fill_x),
                            .vga_y(fill_y),
                            .vga_colour(into_vga_colour),
                            .vga_plot(fill_plot));  

    vga_adapter             #(.RESOLUTION("160x120")) VGA_0 (.clock(CLOCK_50),
                            .resetn(Reset_L),
                            .colour(into_vga_colour), // from controller
                            .x(fill_x), // from controller I need to make 
                            .y(fill_y), // from controller 
                            .plot(fill_plot),  // from controller 
                            .VGA_R(VGA_R_10),
                            .VGA_G(VGA_G_10),
                            .VGA_B(VGA_B_10),
                            .*);    
endmodule: risc_v_core

module data_bus_multiplexer (
    input logic         Select_SRAM,
    input logic         Select_IO,
    input logic [31:0]  DataIn_SRAM,
    input logic [31:0]  DataIn_IO,
    output logic [31:0] DataOut_CPU
);

    always @(*) begin
        DataOut_CPU <= 32'h00000000;

        if ((Select_SRAM == 1) && (Select_IO == 0)) begin
            DataOut_CPU <= DataIn_SRAM;
        end 

        if ((Select_SRAM == 0) && (Select_IO == 1)) begin
            DataOut_CPU <= DataIn_IO;
        end
    end
endmodule: data_bus_multiplexer