// Editor-only stubs for VHDL/Quartus-generated blocks used by Verilog wrappers.
// This file is referenced only by source/risc_v_core.f for VS Code slang-server.

module M68xxIODecoder (
    input  logic        IOSelect,
    input  logic        UDS_L,
    input  logic        AS_L,
    input  logic [31:0] Address,
    output logic        ACIA1_Port_Enable,
    output logic        ACIA1_Baud_Enable
);
endmodule

module ACIA_Clock (
    input  logic       Clk,
    input  logic [2:0] BaudRateSelect,
    output logic       ACIA_Clk
);
endmodule

module Latch3Bit (
    input  logic       Enable,
    input  logic       Clk,
    input  logic       Reset,
    input  logic [2:0] DataIn,
    output logic [2:0] Q
);
endmodule

module ACIA_6850 (
    input  logic       Clk,
    input  logic       Reset_H,
    input  logic       CS_H,
    input  logic       Write_L,
    input  logic       RS,
    input  logic       RxClock,
    input  logic       TxClock,
    input  logic       RxData,
    input  logic       DCD_L,
    input  logic       CTS_L,
    input  logic [7:0] DataIn,
    output logic       IRQ_L,
    output logic       TxData,
    output logic [7:0] DataOut
);
endmodule

module LCD_Controller (
    input  logic       Clk,
    input  logic       Reset,
    output logic       RS,
    output logic       E,
    output logic       RW,
    input  logic [7:0] DataIn,
    input  logic       WriteEnable,
    input  logic       LCDCommandOrDisplayData,
    output logic [7:0] LCDDataOut
);
endmodule

module lpm_bustri0 (
    input  logic        enabledt,
    input  logic [31:0] data,
    output logic [31:0] tridata
);
endmodule

module lpm_bustri2 (
    input logic enabledt
);
endmodule
