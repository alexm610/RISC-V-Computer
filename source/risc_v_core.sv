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
    //inout logic PS2_CLK,
    //inout logic PS2_DAT
);

    logic write_d_mem, test_write, read_d_mem, valid, AS_L, WE_L, Reset_L, UART_Select;
    logic [7:0] data_out_RS232;
    logic CLOCK_25;
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
    logic RAM_Select, IO_Select, Graphics_Select, ROM_Select, Keyboard_Select;
    logic [31:0] data_out_KEYBOARD;

    assign VGA_R            = VGA_R_10[9:2];
    assign VGA_G            = VGA_G_10[9:2];
    assign VGA_B            = VGA_B_10[9:2];
    assign LEDR[9]          = done;

    cpu PROCESSOR (
        .Clock(CLOCK_50),
        .Reset_L(KEY[0]),
        .DTAck(1'b1),
        .Instruction(instruction),
        .DataBus_In(data_in),
        .AS_L(AS_L),
        .Byte_Enable(byte_enable),
        .WE_L(WE_L),
        .DataBus_Out(data_out),
        .Address(address),
        .Conduit(done),
        .Reset_Out(Reset_L));

    address_decoder AD (
        .Address(address),
        .ROM_Select_H(ROM_Select),
        .RAM_Select_H(RAM_Select),
        .IO_Select_H(IO_Select),
        .Graphics_Select_H(Graphics_Select),
        .Keyboard_Select_H(Keyboard_Select),
        .UART_Select_H(UART_Select)
    );

    data_bus_multiplexer DATABUS_MULTIPLEXER (
        .Select_SRAM(RAM_Select),
        .Select_IO(IO_Select),
        .Select_ROM(ROM_Select),
        .Select_KEYBOARD(Keyboard_Select),
        .Select_UART(UART_Select),
        .DataIn_KEYBOARD(data_out_KEYBOARD),
        .DataIn_SRAM(data_out_SRAM),
        .DataIn_IO(data_out_IO),
        .DataIn_ROM(instruction),
        .DataIn_UART(data_out_UART),
        .DataOut_CPU(data_in)
    );

    OnChipROM16KWords INSTRUCTION_MEMORY (
        .Clock(CLOCK_50),
        .RomSelect_H(ROM_Select),
        .Write_Enable(test_write),
        .Address(address>>2),
        .DataIn(dummy_instr_writedata),
        .DataOut(instruction)
    );

    OnChipRam256kbyte SRAM_MEMORY (
        .Clock(CLOCK_50),
        .RamSelect_H(RAM_Select),
        .WE_L(WE_L),
        .AS_L(AS_L),
        .Address(address>>2),
        .ByteEnable(byte_enable),
        .DataIn(data_out),
        .DataOut(data_out_SRAM)
    );

	IO_Handler IO (.Clock(CLOCK_50),
        .Reset_L(Reset_L),
        .byte_enable(byte_enable),
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

    uart_controller UART_0 (
        .clk(CLOCK_50),
        .reset(~Reset_L),
        .AS_L(AS_L),
        .WE_L(WE_L),
        .UART_SEL_H(UART_Select),
        .addr(address>>2),
        .wdata(data_out),
        .rdata(data_out_UART),
        .tx(GPIO_1[35]),
        .rx(GPIO_0[35])
    );
           
    vga_control VGA_CONTROL (
        .clk(CLOCK_50),
        .rst_n(Reset_L),
        .data_in(data_out),
        .ready(vga_ready), // output to arbiter/cpu
        .VGA_Select(Graphics_Select),
        .start(1'b0), // input from arbiter (the write signal)
        .vga_x(fill_x),
        .vga_y(fill_y),
        .vga_colour(into_vga_colour),
        .vga_plot(fill_plot)
    );  

    vga_adapter #(.RESOLUTION("160x120")) VGA_0 (
        .clock(CLOCK_50),
        .resetn(Reset_L),
        .colour(into_vga_colour), // from controller
        .x(fill_x), // from controller I need to make 
        .y(fill_y), // from controller 
        .plot(fill_plot),  // from controller 
        .VGA_R(VGA_R_10),
        .VGA_G(VGA_G_10),
        .VGA_B(VGA_B_10),
        .*
    );  
endmodule: risc_v_core

module data_bus_multiplexer (
    input logic         Select_SRAM,
    input logic         Select_IO,
    input logic         Select_ROM,
    input logic         Select_KEYBOARD,
    input logic         Select_UART,
    input logic [31:0]  DataIn_UART,
    input logic [31:0]  DataIn_KEYBOARD,
    input logic [31:0]  DataIn_SRAM,
    input logic [31:0]  DataIn_IO,
    input logic [31:0]  DataIn_ROM,
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

        if (Select_ROM == 1) begin
            DataOut_CPU <= DataIn_ROM;
        end

        if (Select_KEYBOARD == 1) begin
            DataOut_CPU <= DataIn_KEYBOARD;
        end
    end
endmodule: data_bus_multiplexer
