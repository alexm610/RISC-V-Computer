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