module risc_v_core (
    input logic CLOCK_50, 
    input logic [3:0] KEY, 
    input logic [9:0] SW,
    inout logic [35:0] GPIO_0,
    inout logic [35:0] GPIO_1,
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

    logic write_d_mem, test_write, read_d_mem, valid, AS_L, WE_L, Reset_L, UART_Select, Exponent_Accelerator_Select, vga_ready;
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
    logic RAM_Select, IO_Select, Graphics_Select, ROM_Select, Keyboard_Select, IRQ_timer;
    logic [31:0] data_out_KEYBOARD, data_out_EXP;
    logic [31:0] data_out_UART;

    assign VGA_R            = VGA_R_10[9:2];
    assign VGA_G            = VGA_G_10[9:2];
    assign VGA_B            = VGA_B_10[9:2];
    assign LEDR[9]          = done;

    cpu PROCESSOR (
        .Clock(CLOCK_50),
        .Reset_L(KEY[0]),
        .DTAck(1'b1),
        .IRQ_Timer_H(IRQ_timer),
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
        .UART_Select_H(UART_Select),
        .ExpAccel_Select_H(Exponent_Accelerator_Select)
    );

    data_bus_multiplexer DATABUS_MULTIPLEXER (
        .Select_SRAM(RAM_Select),
        .Select_IO(IO_Select),
        .Select_ROM(ROM_Select),
        .Select_KEYBOARD(Keyboard_Select),
        .Select_UART(UART_Select),
        .Select_EXP(Exponent_Accelerator_Select),
        .DataIn_KEYBOARD(data_out_KEYBOARD),
        .DataIn_SRAM(data_out_SRAM),
        .DataIn_IO(data_out_IO),
        .DataIn_ROM(instruction),
        .DataIn_UART(data_out_UART),
        .DataIn_EXP(data_out_EXP),
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
        .Reset_L(KEY[0]),
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
        .LCD_DataOut({GPIO_1[3], GPIO_1[4], GPIO_1[5], GPIO_1[6], GPIO_1[7], GPIO_1[8], GPIO_1[9], GPIO_1[10]}),
        .IRQ_timer0_H(IRQ_timer)
    );

    /*uart_mmio_32bit_8N2 UART_0 (
        .CLOCK_50MHz(CLOCK_50),
        .RESET_L(KEY[0]),
        .AS_L(AS_L),
        .WE_L(WE_L),
        //.UART_SEL_H(UART_Select),
        .Address(address),
        .DataIn(data_out),
        .DataOut(data_out_UART),
        .uart_tx(GPIO_1[35]),
        .uart_rx(GPIO_1[34])
    );*/

    OnChipM68xxIO UART_0 (
	    .IOSelect(UART_Select),
	    .Clk(CLOCK_50),
	    .Reset_L(KEY[0]),
	    .Clock_50Mhz(CLOCK_50),
	    .RS232_RxData(GPIO_1[34]),
	    .UDS_L(1'b0),
	    .WE_L(WE_L),
	    .AS_L(AS_L),
	    .Address(address),
	    .DataIn(data_out),
	    .RS232_TxData(GPIO_1[35]),
	    .ACIA_IRQ(),
	    .DataOut(data_out_UART)
    );
       
    vga_control VGA_CONTROL (
        .clk(CLOCK_50),
        .rst_n(KEY[0]),
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
        .resetn(KEY[0]),
        .colour(into_vga_colour), // from controller
        .x(fill_x), // from controller I need to make 
        .y(fill_y), // from controller 
        .plot(fill_plot),  // from controller 
        .VGA_R(VGA_R_10),
        .VGA_G(VGA_G_10),
        .VGA_B(VGA_B_10),
        .*
    );  

    /*exponent_accelerator EXP_ACCELERATOR_0 (
        .clk(CLOCK_50),
        .reset_n(Reset_L),
        .exp_select(Exponent_Accelerator_Select),
        .WE_L(WE_L),
        .AS_L(AS_L),
        .addr(address[3:0]),
        .writedata(data_out),
        .readdata(data_out_EXP)
    );*/  
endmodule: risc_v_core

module data_bus_multiplexer (
    input logic         Select_SRAM,
    input logic         Select_IO,
    input logic         Select_ROM,
    input logic         Select_KEYBOARD,
    input logic         Select_UART,
    input logic         Select_EXP,
    input logic [31:0]  DataIn_EXP,
    input logic [31:0]  DataIn_UART,
    input logic [31:0]  DataIn_KEYBOARD,
    input logic [31:0]  DataIn_SRAM,
    input logic [31:0]  DataIn_IO,
    input logic [31:0]  DataIn_ROM,
    output logic [31:0] DataOut_CPU
);

    always @(*) begin
        DataOut_CPU = 32'h00000000;

        if ((Select_SRAM == 1) && (Select_IO == 0)) begin
            DataOut_CPU = DataIn_SRAM;
        end else 

        if ((Select_SRAM == 0) && (Select_IO == 1)) begin
            DataOut_CPU = DataIn_IO;
        end else 

        if (Select_ROM == 1) begin
            DataOut_CPU = DataIn_ROM;
        end else 

        if (Select_KEYBOARD == 1) begin
            DataOut_CPU = DataIn_KEYBOARD;
        end else

        if (Select_EXP == 1) begin
            DataOut_CPU     = DataIn_EXP;
        end else

        if (Select_UART == 1) begin
            DataOut_CPU     = DataIn_UART;
        end
    end
endmodule: data_bus_multiplexer
