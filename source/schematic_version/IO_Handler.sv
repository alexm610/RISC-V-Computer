`include "defines.sv"

module IO_Handler   (input logic Clock, input logic Reset_L, input logic [9:0] SW_input, input logic AS_L, input logic WE_L, input logic IO_Select, input logic [31:0] Address, input logic [31:0] IO_data_in, input logic [3:0] byte_enable,
                    output logic [6:0] HEX0_output, output logic [6:0] HEX1_output, output logic [6:0] HEX2_output, output logic [6:0] HEX3_output, output logic [6:0] HEX4_output, output logic [6:0] HEX5_output, output logic [8:0] LEDR_output, output logic [31:0] IO_data_out, output logic UART_Rx, output logic UART_Tx,
    output logic RS_pin,
    output logic E_pin,
    output logic RW_pin,
    output logic [7:0] LCD_DataOut                    
);

    reg         hex_enable, ledr_enable, IO_data_out_enable;
    wire [6:0]  hex0_wire, hex1_wire, hex2_wire, hex3_wire, hex4_wire, hex5_wire;
    reg [6:0]   HEX0_writedata, HEX1_writedata, HEX2_writedata, HEX3_writedata, HEX4_writedata, HEX5_writedata;
    reg [8:0]   LEDR_writedata;
    reg [31:0]  IO_writedata, UART_data_out;
    logic LCD_WriteEnable, LCD_CommandOrDisplayData;

    OnChipM68xxIO UART_CONTROLLER (
        .IOSelect(IO_Select),
        .Clk(Clock),
        .Reset_L(Reset_L),
        .Clock_50Mhz(Clock),
        .RS232_RxData(UART_Rx),
        .UDS_L(~byte_enable[0]),
        .WE_L(WE_L),
        .AS_L(AS_L),
        .Address(Address),
        .DataIn(IO_data_in[7:0]),
        .RS232_TxData(UART_Tx),
        .ACIA_IRQ(),
        .DataOut(UART_data_out)
    );

    LCD_Controller LCD (
        .Clk(Clock),
        .Reset(Reset_L),
        .RS(RS_pin),
        .E(E_pin),
        .RW(RW_pin),
        .DataIn(IO_data_in[7:0]),
        .WriteEnable(LCD_WriteEnable),
        .LCDCommandOrDisplayData(LCD_CommandOrDisplayData),
        .LCDDataOut(LCD_DataOut)
    );

    data_to_HEX_converter D2H0 (
        .data(IO_data_in),
        .hex0(HEX0_writedata),
        .hex1(HEX1_writedata),
        .hex2(HEX2_writedata),
        .hex3(HEX3_writedata),
        .hex4(HEX4_writedata),
        .hex5(HEX5_writedata)
    );

    register #(7) H0 (
        .clock(Clock),
        .reset(1'b1),
        .in(HEX0_writedata),
        .enable(hex_enable),
        .out(HEX0_output)
    );

    register #(7) H1 (
        .clock(Clock),
        .reset(1'b1),
        .in(HEX1_writedata),
        .enable(hex_enable),
        .out(HEX1_output)
    );

    register #(7) H2 (
        .clock(Clock),
        .reset(1'b1),
        .in(HEX2_writedata),
        .enable(hex_enable),
        .out(HEX2_output)
    );

    register #(7) H3 (
        .clock(Clock),
        .reset(1'b1),
        .in(HEX3_writedata),
        .enable(hex_enable),
        .out(HEX3_output)
    );

    register #(7) H4 (
        .clock(Clock),
        .reset(1'b1),
        .in(HEX4_writedata),
        .enable(hex_enable),
        .out(HEX4_output)
    );

    register #(7) H5 (
        .clock(Clock),
        .reset(1'b1),
        .in(HEX5_writedata),
        .enable(hex_enable),
        .out(HEX5_output)
    );

    register #(9) L0 (
        .clock(Clock),
        .reset(1'b1),
        .in(IO_data_in),
        .enable(ledr_enable),
        .out(LEDR_output)
    );
    
    assign IO_data_out = IO_writedata;
    
    always @(*) begin
        IO_writedata        <= 32'h0;
        hex_enable          <= 0;
        ledr_enable         <= 0;
        LCD_WriteEnable     <= 0;
        LCD_CommandOrDisplayData <= 0;

        if (Address[15:0] == 16'h0000) begin // we are reading from switches
            if ((AS_L == 0) && (WE_L == 1)) begin
                IO_writedata    <= SW_input;
            end
        end else if (Address[15:0] == 16'h0004) begin // we are writing to LEDs
            if ((AS_L == 0) && (WE_L == 0)) begin
                ledr_enable <= 1;
            end
        end else if (Address[15:0] == 16'h0008) begin // we are writing to HEX display
            if ((AS_L == 0) && (WE_L == 0)) begin
                hex_enable <= 1;
            end
        end else if (Address[15:0] == 16'h000C) begin
            if ((AS_L == 0) && (WE_L == 0)) begin
                LCD_WriteEnable <= 1;
                LCD_CommandOrDisplayData <= 0;
            end
        end else if (Address[15:0] == 16'h0010) begin
            if ((AS_L == 0) && (WE_L == 0)) begin
                LCD_WriteEnable <= 1;
                LCD_CommandOrDisplayData <= 1;
            end
        end else if ((Address[15:4] == 12'h004) && (byte_enable[0] == 1) && (AS_L == 0)) begin
            IO_writedata        <= UART_data_out;
        end
    end
endmodule: IO_Handler

module data_to_HEX_converter (input logic [31:0] data, output logic [6:0] hex0, output logic [6:0] hex1, output logic [6:0] hex2, output logic [6:0] hex3, output logic [6:0] hex4, output logic [6:0] hex5);
    always @(*) begin
        case (data[3:0])
            4'h0: hex0 <= `ZERO;
            4'h1: hex0 <= `ONE;
            4'h2: hex0 <= `TWO;
            4'h3: hex0 <= `THREE;
            4'h4: hex0 <= `FOUR;
            4'h5: hex0 <= `FIVE;
            4'h6: hex0 <= `SIX;
            4'h7: hex0 <= `SEVEN;
            4'h8: hex0 <= `EIGHT;
            4'h9: hex0 <= `NINE;
            4'hA: hex0 <= `A;
            4'hB: hex0 <= `b;
            4'hC: hex0 <= `C;
            4'hD: hex0 <= `d;
            4'hE: hex0 <= `E;
            4'hF: hex0 <= `F;
        endcase

        case (data[7:4])
            4'h0: hex1 <= `ZERO;
            4'h1: hex1 <= `ONE;
            4'h2: hex1 <= `TWO;
            4'h3: hex1 <= `THREE;
            4'h4: hex1 <= `FOUR;
            4'h5: hex1 <= `FIVE;
            4'h6: hex1 <= `SIX;
            4'h7: hex1 <= `SEVEN;
            4'h8: hex1 <= `EIGHT;
            4'h9: hex1 <= `NINE;
            4'hA: hex1 <= `A;
            4'hB: hex1 <= `b;
            4'hC: hex1 <= `C;
            4'hD: hex1 <= `d;
            4'hE: hex1 <= `E;
            4'hF: hex1 <= `F;
        endcase

        case (data[11:8])
            4'h0: hex2 <= `ZERO;
            4'h1: hex2 <= `ONE;
            4'h2: hex2 <= `TWO;
            4'h3: hex2 <= `THREE;
            4'h4: hex2 <= `FOUR;
            4'h5: hex2 <= `FIVE;
            4'h6: hex2 <= `SIX;
            4'h7: hex2 <= `SEVEN;
            4'h8: hex2 <= `EIGHT;
            4'h9: hex2 <= `NINE;
            4'hA: hex2 <= `A;
            4'hB: hex2 <= `b;
            4'hC: hex2 <= `C;
            4'hD: hex2 <= `d;
            4'hE: hex2 <= `E;
            4'hF: hex2 <= `F;
        endcase

        case (data[15:12])
            4'h0: hex3 <= `ZERO;
            4'h1: hex3 <= `ONE;
            4'h2: hex3 <= `TWO;
            4'h3: hex3 <= `THREE;
            4'h4: hex3 <= `FOUR;
            4'h5: hex3 <= `FIVE;
            4'h6: hex3 <= `SIX;
            4'h7: hex3 <= `SEVEN;
            4'h8: hex3 <= `EIGHT;
            4'h9: hex3 <= `NINE;
            4'hA: hex3 <= `A;
            4'hB: hex3 <= `b;
            4'hC: hex3 <= `C;
            4'hD: hex3 <= `d;
            4'hE: hex3 <= `E;
            4'hF: hex3 <= `F;
        endcase

        case (data[19:16])
            4'h0: hex4 <= `ZERO;
            4'h1: hex4 <= `ONE;
            4'h2: hex4 <= `TWO;
            4'h3: hex4 <= `THREE;
            4'h4: hex4 <= `FOUR;
            4'h5: hex4 <= `FIVE;
            4'h6: hex4 <= `SIX;
            4'h7: hex4 <= `SEVEN;
            4'h8: hex4 <= `EIGHT;
            4'h9: hex4 <= `NINE;
            4'hA: hex4 <= `A;
            4'hB: hex4 <= `b;
            4'hC: hex4 <= `C;
            4'hD: hex4 <= `d;
            4'hE: hex4 <= `E;
            4'hF: hex4 <= `F;
        endcase

        case (data[23:20])
            4'h0: hex5 <= `ZERO;
            4'h1: hex5 <= `ONE;
            4'h2: hex5 <= `TWO;
            4'h3: hex5 <= `THREE;
            4'h4: hex5 <= `FOUR;
            4'h5: hex5 <= `FIVE;
            4'h6: hex5 <= `SIX;
            4'h7: hex5 <= `SEVEN;
            4'h8: hex5 <= `EIGHT;
            4'h9: hex5 <= `NINE;
            4'hA: hex5 <= `A;
            4'hB: hex5 <= `b;
            4'hC: hex5 <= `C;
            4'hD: hex5 <= `d;
            4'hE: hex5 <= `E;
            4'hF: hex5 <= `F;
        endcase 
    end
endmodule: data_to_HEX_converter
