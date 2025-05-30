/* opcode */
`define R_TYPE          7'b0110011
`define I_TYPE          7'b0010011
`define S_TYPE          7'b0100011
`define B_TYPE          7'b1100011
`define U_TYPE_LUI      7'b0110111
`define U_TYPE_AUIPC    7'b0010111
`define J_TYPE_JAL      7'b1101111
`define J_TYPE_JALR     7'b1100111
`define LOAD_TYPE       7'b0000011

/* ALUop */
`define ADDSUB          3'b000
`define XOR             3'b100
`define OR              3'b110
`define AND             3'b111
`define SLL             3'b001
`define SR              3'b101
`define SLT             3'b010
`define SLTU            3'b011

`define NUM_SLAVES      1

`define ZERO  7'b1000000
`define ONE   7'b1111001
`define TWO   7'b0100100
`define THREE 7'b0110000
`define FOUR  7'b0011001
`define FIVE  7'b0010010
`define SIX   7'b0000010
`define SEVEN 7'b1111000
`define EIGHT 7'b0000000
`define NINE  7'b0011000
`define A     7'b0001000
`define b     7'b0000011
`define C     7'b1000110
`define d     7'b0100001
`define E     7'b0000110
`define F     7'b0001110
`define OFF   7'b1111111