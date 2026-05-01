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
    output logic [9:0] LEDR,
    //inout logic PS2_CLK,
    //inout logic PS2_DAT,
    output logic        DRAM_CLK,
    output logic        DRAM_CKE,
    output logic        DRAM_CS_N,
    output logic        DRAM_RAS_N,
    output logic        DRAM_CAS_N,
    output logic        DRAM_WE_N,
    output logic [12:0] DRAM_ADDR,
    output logic [1:0]  DRAM_BA,
    inout  wire  [15:0] DRAM_DQ,
    output logic        DRAM_UDQM,
    output logic        DRAM_LDQM
);

    logic write_d_mem, test_write, read_d_mem, valid, AS_L, WE_L, Reset_L, UART_Select, Exponent_Accelerator_Select, vga_ready;
    logic [7:0] data_out_RS232;
    logic [3:0] byte_enable;
    logic [3:0] fabric_write, fabric_read;
    logic [31:0] program_counter;
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
    logic sdram_dtack_h, sdram_reset_out;
    logic clk_25, clk_50, clk_50_180;
    logic [7:0] data_out_I2CSPI;
    logic I2CSPI_Select;

    assign DRAM_CLK         = clk_50_180;
    assign VGA_R            = VGA_R_10[9:2];
    assign VGA_G            = VGA_G_10[9:2];
    assign VGA_B            = VGA_B_10[9:2];
    assign LEDR[9]          = IRQ_timer;

    pll_alex_0002 PLL_ALEX (
        .refclk(CLOCK_50),
        .rst(~KEY[0]),
        .outclk_0(clk_25),
        .outclk_1(clk_50),
        .outclk_2(clk_50_180)
  );  

    cpu PROCESSOR (
        .Clock(clk_50),
        .Reset_L(KEY[0] & sdram_reset_out),
        .DTAck(RAM_Select ? sdram_dtack_h : 1'b1),
        .IRQ_Timer_H(IRQ_timer),
        .IRQ_UART_H(1'b0),
        .Instruction(instruction),
        .DataBus_In(data_in),
        .AS_L(AS_L),
        .Byte_Enable(byte_enable),
        .WE_L(WE_L),
        .DataBus_Out(data_out),
        .Address(address),
        .Conduit(done),
        .Reset_Out(Reset_L)
    );

    address_decoder AD (
        .Address(address),
        .ROM_Select_H(ROM_Select),
        .RAM_Select_H(RAM_Select),
        .IO_Select_H(IO_Select),
        .Graphics_Select_H(Graphics_Select),
        .Keyboard_Select_H(Keyboard_Select),
        .UART_Select_H(UART_Select),
        .ExpAccel_Select_H(Exponent_Accelerator_Select),
        .I2CSPI_Select_H(I2CSPI_Select)
    );

    data_bus_multiplexer DATABUS_MULTIPLEXER (
        .Select_SRAM(RAM_Select),
        .Select_IO(IO_Select),
        .Select_ROM(ROM_Select),
        .Select_KEYBOARD(Keyboard_Select),
        .Select_UART(UART_Select),
        .Select_EXP(Exponent_Accelerator_Select),
        .Select_I2CSPI(I2CSPI_Select),
        .DataIn_KEYBOARD(data_out_KEYBOARD),
        .DataIn_SRAM(data_out_SRAM),
        .DataIn_IO(data_out_IO),
        .DataIn_ROM(instruction),
        .DataIn_UART(data_out_UART),
        .DataIn_EXP(data_out_EXP),
        .DataIn_I2CSPI(data_out_I2CSPI),
        .DataOut_CPU(data_in)
    );

    OnChipROM16KWords INSTRUCTION_MEMORY (
        .Clock(clk_50),
        .RomSelect_H(ROM_Select),
        .Write_Enable(test_write),
        .Address(address>>2),
        .DataIn(dummy_instr_writedata),
        .DataOut(instruction)
    );

    SDRAM_wrapper SDRAM_MEMORY (
        .Clock       (clk_50),
        .Reset_L     (KEY[0]),
        .RamSelect_H (RAM_Select),
        .WE_L        (WE_L),
        .AS_L        (AS_L),
        .Address     (address),         
        .ByteEnable  (byte_enable),
        .DataIn      (data_out),
        .DataOut     (data_out_SRAM),
        .DTAck_H     (sdram_dtack_h),
        .ResetOut_L  (sdram_reset_out),
        .SDRAM_CKE   (DRAM_CKE),        
        .SDRAM_CS_N  (DRAM_CS_N),
        .SDRAM_RAS_N (DRAM_RAS_N),
        .SDRAM_CAS_N (DRAM_CAS_N),
        .SDRAM_WE_N  (DRAM_WE_N),
        .SDRAM_ADDR  (DRAM_ADDR),
        .SDRAM_BA    (DRAM_BA),
        .SDRAM_DQ    (DRAM_DQ),
        .SDRAM_UDQM  (DRAM_UDQM),
        .SDRAM_LDQM  (DRAM_LDQM)
    );

	IO_Handler IO (
        .Clock(clk_50),
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
        .LCD_DataOut({GPIO_1[3], GPIO_1[4], GPIO_1[5], GPIO_1[6], GPIO_1[7], GPIO_1[8], GPIO_1[9], GPIO_1[10]}),
        .IRQ_timer0_H(IRQ_timer)
    );

    OnChipM68xxIO UART_0 (
	    .IOSelect(UART_Select),
	    .Clk(clk_50),
	    .Reset_L(Reset_L),
	    .Clock_50Mhz(clk_50),
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

    IIC_SPI_Interface I2C_SPI_0 (
	    .Clk(clk_50),
	    .Reset_L(Reset_L),
	    .WE_L(WE_L),
	    .AS_L(AS_L),
	    .miso_i(GPIO_0[29]),
	    .IIC_SPI_Select(I2CSPI_Select),
	    .Address(address),
	    .DataIn(data_out),
	    .IIC0_IRQ_L(),
	    .sck_o(GPIO_0[26]),
	    .mosi_o(GPIO_0[28]),
	    .SPI_IRQ(),
	    .SCL_GPIO_0(),
	    .SDA_GPIO_0(),
	    .DataOut(data_out_I2CSPI),
	    .SSN_O(GPIO_0[27])
    );
       
    vga_control VGA_CONTROL (
        .clk(clk_50),
        .rst_n(Reset_L),
        .data_in(data_out),
        .ready(vga_ready), 
        .VGA_Select(Graphics_Select),
        .start(1'b0), 
        .vga_x(fill_x),
        .vga_y(fill_y),
        .vga_colour(into_vga_colour),
        .vga_plot(fill_plot)
    );  

    vga_adapter #(.RESOLUTION("160x120")) VGA_0 (
        .clock(clk_50),
        .resetn(Reset_L),
        .colour(into_vga_colour), 
        .x(fill_x),  
        .y(fill_y),  
        .plot(fill_plot),   
        .VGA_R(VGA_R_10),
        .VGA_G(VGA_G_10),
        .VGA_B(VGA_B_10),
        .*
    );  

    exponent_accelerator EXP_ACCELERATOR_0 (
        .clk(CLOCK_50),
        .reset_n(Reset_L),
        .exp_select(Exponent_Accelerator_Select),
        .WE_L(WE_L),
        .AS_L(AS_L),
        .addr(address[3:0]),
        .writedata(data_out),
        .readdata(data_out_EXP)
    );
endmodule: risc_v_core

module data_bus_multiplexer (
    input logic         Select_SRAM,
    input logic         Select_IO,
    input logic         Select_ROM,
    input logic         Select_KEYBOARD,
    input logic         Select_UART,
    input logic         Select_EXP,
    input logic         Select_I2CSPI,
    input logic [31:0]  DataIn_EXP,
    input logic [31:0]  DataIn_UART,
    input logic [31:0]  DataIn_KEYBOARD,
    input logic [31:0]  DataIn_SRAM,
    input logic [31:0]  DataIn_IO,
    input logic [31:0]  DataIn_ROM,
    input logic [31:0]  DataIn_I2CSPI,
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
        end else 

        if (Select_I2CSPI == 1) begin
            DataOut_CPU     = DataIn_I2CSPI;
        end
    end
endmodule: data_bus_multiplexer
