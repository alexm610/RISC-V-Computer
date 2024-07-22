`define S_WAIT           7'b0000000
`define S_DECODE         7'b0000001
`define S_MOV_immediate  7'b0000010
`define S_MOV_register1  7'b0000011
`define S_MOV_register2  7'b0000100
`define S_MOV_register3  7'b0000101
`define S_ADD1           7'b0000110
`define S_ADD2           7'b0000111
`define S_ADD3           7'b0001000
`define S_ADD4           7'b0001001
`define S_CMP1           7'b0001010
`define S_CMP2           7'b0001011
`define S_CMP3           7'b0001100
`define S_CMP4           7'b0001101
`define S_AND1           7'b0001110
`define S_AND2           7'b0001111
`define S_AND3           7'b0010000
`define S_AND4           7'b0010001
`define S_MVN1           7'b0010010
`define S_MVN2           7'b0010011
`define S_MVN3           7'b0010100
`define S_MVN4           7'b0010101
`define S_MOV_immediate2 7'b0010110
`define S_ADDRESS_SELECT 7'b0010111
`define S_ADDRESS_GET    7'b0011000
`define S_LDR1    	 7'b0011001
`define S_LDR2		 7'b0011010
`define S_LDR3		 7'b0011011
`define S_LDR4  	 7'b0011100
`define S_LDR5	         7'b0011101
`define S_STR1		 7'b0011110
`define S_STR2		 7'b0011111
`define S_STR3		 7'b0100000
`define S_STR4		 7'b0100001
`define S_STR5		 7'b0100010
`define S_STR6		 7'b0100011
`define S_STR7		 7'b0100100
`define S_HALT           7'b0100101
`define S_HALT1		 7'b0100110
`define S_B_instruction  7'b0100111
`define S_B1             7'b0101000
`define S_BEQ1           7'b0101001
`define S_BNE1           7'b0101010
`define S_BLT1           7'b0101011   
`define S_BLE1           7'b0101100
`define S_BLT2		 7'b0101101
`define S_BLT3		 7'b0101110
`define S_BLT22		 7'b0101111
`define S_BLT33		 7'b0110000
`define S_BL1	         7'b0110001
`define S_BX1		 7'b0110010
`define S_BLX1     	 7'b0110011
`define S_B2	 	 7'b0110100	
`define S_BEQ2 	 	 7'b0110101
`define S_BEQ3		 7'b0110110
`define S_BNE2		 7'b0110111
`define S_BNE3		 7'b0111000
`define S_BLE2		 7'b0111001
`define S_BLE3		 7'b0111010
`define S_BL2		 7'b0111011
`define S_BX2		 7'b0111100
`define S_BX3		 7'b0111101
`define S_BX4		 7'b0111110
`define S_BLX2		 7'b0111111
`define S_BLX3		 7'b1000000
`define S_BLX4		 7'b1000001
`define S_BLX5		 7'b1000010

`define M_READ	         7'b1100000
`define M_WRITE		     7'b1110000
`define M_NONE	 	     7'b1010000

`define MOVE_instruction 3'b110
`define ALU_instruction  3'b101
`define LDR_instruction  3'b011
`define STR_instruction  3'b100
`define B_instruction    3'b001
`define HALT    	 3'b111
`define CALL_instruction 3'b010



`define MOV_immediate    2'b10
`define MOV_register     2'b00
`define ADD              2'b00
`define CMP              2'b01
`define AND              2'b10
`define MVN              2'b11
`define MEM              2'b00
`define Branch           2'b00 
`define Direct_Call	 2'b11
`define Return		 2'b00
`define Indirect_Call    2'b10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    

`define Cond_B           3'b000             
`define Cond_BEQ         3'b001
`define Cond_BNE         3'b010
`define Cond_BLT         3'b011           
`define Cond_BLE         3'b100

module CPU (clk, reset, in, out, N, V, Z, w, memory_address, memory_command);
    input clk, reset; 
    input [15:0] in;
    output [15:0] out; 
    output N, V, Z;
    output w;
    output [8:0] memory_address;
    output [6:0] memory_command;
    reg [6:0] memory_command;
    reg [15:0] sximm8;
    wire [15:0] sximm5;
    reg w; // this is now the halt signal, indicating that state machine is in halt state
    reg [6:0] current_state;
    wire [2:0] opcode;
    wire [1:0] op;
    reg [2:0] readnum_and_writenum;
    reg loadA, loadB, asel, bsel, loadC, loadS, write;
    reg [1:0] vsel, shift, ALUop;
    wire [15:0] out_instruction_register;
    wire [8:0] into_pc, PC;
    wire [8:0] out_PC_adder, out_data_addr_reg;
    reg load_pc, address_select;
    reg [2:0] reset_pc;
    reg load_ir, load_addr;

    assign sximm5 = {{11{out_instruction_register[4]}}, out_instruction_register[4:0]};

    // INSTANTIATE DATAPATH
    datapath DP (clk, readnum_and_writenum, vsel, loadA, loadB, shift, asel, bsel, ALUop, loadC, loadS, readnum_and_writenum, write, {N, V, Z}, out, sximm5, in, sximm8, (PC + 1'b1));

    // INSTANTIATE THE INSTRUCTION REGISTER
    reg_load_enable #(16) Instruction_Register (clk, in, load_ir, out_instruction_register);
    
    // INSTANTIATE PROGRAM COUNTER REGISTER
    reg_load_enable #(9) Program_Counter (clk, into_pc, load_pc, PC);

    // DATA ADDRESS REGISTER
    reg_load_enable #(9) Data_Address (clk, out[8:0], load_addr, out_data_addr_reg);

    // PROGRAM COUNTER MULTIPLEXOR
    multiplexer_3input_onehot #(9) Mux_PC (out[8:0], 9'b0, out_PC_adder, ({out_instruction_register[7], out_instruction_register[7:0]} + out_PC_adder), reset_pc, into_pc);
    assign out_PC_adder = PC + 1;

    // MEMORY ADDRESS OUTPUT
    multiplexer_2input #(9) Mux_mem_addr (PC, out_data_addr_reg, address_select, memory_address);

    assign opcode = out_instruction_register[15:13];
    assign op = out_instruction_register[12:11];

    always @(posedge clk) begin 
        if (reset) begin
            current_state = `S_WAIT;
	        // set PC signals to reset here!!!!
	        reset_pc = 3'b100;
	        load_pc = 1'b1;
		w = 1'b0; // set halt signal to 0 initially 
        end else begin 
            case (current_state)
		        `S_WAIT: current_state = `S_ADDRESS_SELECT;
		        `S_ADDRESS_SELECT: current_state = `S_ADDRESS_GET;
		        `S_ADDRESS_GET: current_state = `S_DECODE;
                `S_DECODE:  if ({opcode, op} == {`MOVE_instruction, `MOV_immediate}) begin
                                current_state = `S_MOV_immediate;
                            end else if ({opcode, op} == {`MOVE_instruction, `MOV_register}) begin
                                current_state = `S_MOV_register1;
                            end else if ({opcode, op} == {`ALU_instruction, `ADD}) begin
                                current_state = `S_ADD1;
                            end else if ({opcode, op} == {`ALU_instruction, `CMP}) begin
                                current_state = `S_CMP1;
                            end else if ({opcode, op} == {`ALU_instruction, `AND}) begin
                                current_state = `S_AND1;
                            end else if ({opcode, op} == {`ALU_instruction, `MVN}) begin
                                current_state = `S_MVN1;
                            end else if ({opcode, op} == {`HALT, 2'b00}) begin
				current_state = `S_HALT;
				w = 1'b1;
			    end else if ({opcode, op} == {`LDR_instruction, `MEM}) begin
				current_state = `S_LDR1;
		   	    end else if ({opcode, op} == {`STR_instruction, `MEM}) begin
				current_state = `S_STR1;
                            end else if ({opcode, op} == {`B_instruction, `Branch}) begin
                                current_state = `S_B_instruction;
                            end else if ({opcode, op} == {`CALL_instruction, `Direct_Call}) begin 
				current_state = `S_BL1;
			    end else if ({opcode, op} == {`CALL_instruction, `Return}) begin
				current_state = `S_BX1;
			    end else if ({opcode, op} == {`CALL_instruction, `Indirect_Call}) begin
				current_state = `S_BLX1;
			    end



                `S_MOV_immediate: current_state = `S_MOV_immediate2;
		        `S_MOV_immediate2: current_state = `S_WAIT;                     
                `S_MOV_register1: current_state = `S_MOV_register2;
                `S_MOV_register2: current_state = `S_MOV_register3;
                `S_MOV_register3: current_state = `S_WAIT;
                `S_ADD1: current_state = `S_ADD2;
                `S_ADD2: current_state = `S_ADD3;
                `S_ADD3: current_state = `S_ADD4;
                `S_ADD4: current_state = `S_WAIT;
                `S_CMP1: current_state = `S_CMP2;
                `S_CMP2: current_state = `S_CMP3;
                `S_CMP3: current_state = `S_WAIT;           
                `S_AND1: current_state = `S_AND2;
                `S_AND2: current_state = `S_AND3;
                `S_AND3: current_state = `S_AND4;
                `S_AND4: current_state = `S_WAIT;
                `S_MVN1: current_state = `S_MVN2;
                `S_MVN2: current_state = `S_MVN3;
                `S_MVN3: current_state = `S_WAIT; 
		        `S_LDR1: current_state = `S_LDR2;
		        `S_LDR2: current_state = `S_LDR3;
		        `S_LDR3: current_state = `S_LDR4;
		        `S_LDR4: current_state = `S_LDR5;
		        `S_LDR5: current_state = `S_WAIT;  
		        `S_STR1: current_state = `S_STR2;
		        `S_STR2: current_state = `S_STR3;
		        `S_STR3: current_state = `S_STR4;
		        `S_STR4: current_state = `S_STR5;
		        `S_STR5: current_state = `S_STR6;
		        `S_STR6: current_state = `S_STR7;
		        `S_STR7: current_state = `S_WAIT;
		        `S_HALT: current_state = `S_HALT1;
		        `S_HALT1: current_state = `S_HALT1;

                `S_B_instruction: if (out_instruction_register[10:8] == `Cond_B) begin
                                      current_state = `S_B1;
                                  end else if (out_instruction_register[10:8] == `Cond_BEQ) begin
                                      current_state = `S_BEQ1;
                                  end else if (out_instruction_register[10:8] == `Cond_BLE) begin
                                      current_state = `S_BLE1;
                                  end else if (out_instruction_register[10:8] == `Cond_BLT) begin
                                      current_state = `S_BLT1;
                                  end else if (out_instruction_register[10:8] == `Cond_BNE) begin
                                      current_state = `S_BNE1;
                                  end     
                `S_B1: current_state = `S_ADDRESS_SELECT;
		`S_B2: current_state = `S_ADDRESS_SELECT;

                `S_BEQ1: current_state = (Z == 1'b1) ? `S_BEQ2 : `S_BEQ3;
		`S_BEQ2: current_state = `S_ADDRESS_SELECT;
		`S_BEQ3: current_state = `S_ADDRESS_SELECT; 

		`S_BNE1: current_state = (Z == 1'b0) ? `S_BNE2 : `S_BNE3;
		`S_BNE2: current_state = `S_ADDRESS_SELECT;
		`S_BNE3: current_state = `S_ADDRESS_SELECT;


                

                `S_BLT1: current_state = (N !== V) ? `S_BLT2 : `S_BLT3;
		`S_BLT2: current_state = `S_ADDRESS_SELECT;
		`S_BLT3: current_state = `S_ADDRESS_SELECT;
		

		`S_BLE1: current_state = ((N !== V) | (Z == 1'b1)) ? `S_BLE2 : `S_BLE3;
		`S_BLE2: current_state = `S_ADDRESS_SELECT;
		`S_BLE3: current_state = `S_ADDRESS_SELECT;                

	
		`S_BL1: current_state = `S_BL2;
		`S_BL2: current_state = `S_ADDRESS_SELECT;



		`S_BX1: current_state = `S_BX2;
		`S_BX2: current_state = `S_BX3;
		`S_BX3: current_state = `S_ADDRESS_SELECT;//`S_BX4;
		`S_BX4: current_state = `S_ADDRESS_SELECT;

		`S_BLX1: current_state = `S_BLX2;
		`S_BLX2: current_state = `S_BLX3;
		`S_BLX3: current_state = `S_BLX4;
		`S_BLX4: current_state = `S_ADDRESS_SELECT;//`S_BLX5;
		`S_BLX5: current_state = `S_ADDRESS_SELECT;

		        default: current_state = `S_WAIT;
            endcase 

            case(current_state) 
                `S_WAIT: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, load_pc, reset_pc, address_select, memory_command, load_ir} = {1'b0, 16'b0, 1'b1, 3'b010, 1'b0, `M_READ, 1'b1};
		        `S_ADDRESS_SELECT: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, load_pc, reset_pc, address_select, memory_command, load_ir} = {1'b0, 16'b0, 1'b0, 3'b010, 1'b1, `M_READ, 1'b1};
		        `S_ADDRESS_GET: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, load_pc, reset_pc, address_select, memory_command, load_ir} = {1'b0, 16'b0, 1'b0, 3'b010, 1'b1, `M_READ, 1'b1}; 
		        `S_DECODE: {load_ir} = {1'b0}; // instruction should be loaded into instruciton register by the time you're in decode state: after this point, you don't want instruction register to be updated until a new instruciton is on dout of RAM
                `S_MOV_immediate: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, sximm8} = {1'b0, out_instruction_register[10:8], 1'b1, 2'b10, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0, {{8{out_instruction_register[7]}}, out_instruction_register[7:0]}};
                `S_MOV_immediate2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, sximm8, load_pc} = {1'b0, out_instruction_register[10:8], 1'b1, 2'b10, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0, {{8{out_instruction_register[7]}}, out_instruction_register[7:0]}, 1'b0};
                `S_MOV_register1: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[2:0], 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, out_instruction_register[4:3], 1'b0, 1'b0};
                `S_MOV_register2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[2:0], 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, out_instruction_register[4:3], 1'b1, 1'b0};
                `S_MOV_register3: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[7:5], 1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, out_instruction_register[4:3], 1'b0, 1'b0};

                `S_ADD1: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b0};
                `S_ADD2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[2:0], 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b0};
                `S_ADD3: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b1, 1'b0};
                `S_ADD4: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[7:5], 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b0};

                `S_CMP1: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b1};
                `S_CMP2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[2:0], 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b1};
                `S_CMP3: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b1};
                `S_CMP4: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[7:5], 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b1};
                `S_AND1: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b0};
                `S_AND2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[2:0], 1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b1, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b0};
                `S_AND3: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b1, 1'b0};
                `S_AND4: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[7:5], 1'b1, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, out_instruction_register[12:11], out_instruction_register[4:3], 1'b0, 1'b0};
		        `S_MVN1: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[2:0], 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b1, 2'b11, out_instruction_register[4:3], 1'b0, 1'b0};
                `S_MVN2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[2:0], 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, out_instruction_register[4:3], 1'b1, 1'b0};
                `S_MVN3: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[7:5], 1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, out_instruction_register[4:3], 1'b0, 1'b0};
		        `S_LDR1: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b1, 1'b1, 1'b0, 2'b00, 2'b00, 1'b1, 1'b0};
		        `S_LDR2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 1'b1, 1'b0};
		        `S_LDR3: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, load_addr, address_select} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0};
		        `S_LDR4: {memory_command, address_select, load_addr} = {`M_READ, 1'b0, 1'b1};  // now set datapath input to mdata, via vsel signal
		        `S_LDR5: {load_addr, vsel, write, readnum_and_writenum} = {1'b0, 2'b11, 1'b1, out_instruction_register[7:5]};
		        `S_STR1: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, load_addr} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b1, 1'b1, 1'b0, 2'b00, 2'b00, 1'b1, 1'b0, 1'b0};
		        `S_STR2: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, load_addr} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 1'b1, 1'b0, 1'b0};
		        `S_STR3: {w, readnum_and_writenum, write, vsel, asel, bsel, loadA, loadB, ALUop, shift, loadC, loadS, load_addr, address_select} = {1'b0, out_instruction_register[10:8], 1'b0, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0};
		        `S_STR4: {readnum_and_writenum, asel, bsel, loadA, loadB, ALUop, shift, loadC} = {out_instruction_register[7:5], 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, 2'b00, 1'b1};
		        `S_STR5: {loadA, loadB, loadC, load_addr} = {1'b0, 1'b0, 1'b1, 1'b0}; // contents of register Rd are now on datapath_out
		        `S_STR6: {memory_command, address_select, load_addr, loadC} = {`M_WRITE, 1'b0, 1'b0, 1'b0};
		        `S_STR7: {memory_command, address_select, load_addr} = {`M_WRITE, 1'b0, 1'b1};
		`S_B_instruction: {load_pc} = {1'b0};

                `S_B1:   {address_select, reset_pc, load_pc} = {1'b1, 3'b001, 1'b1};
		`S_B2: {load_pc} = {1'b1};

                `S_BEQ1: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b0};
		`S_BEQ2: {address_select, reset_pc, load_pc} = {1'b1, 3'b001, 1'b1};
		`S_BEQ3: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b1};


                `S_BNE1: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b0};
		`S_BNE2: {address_select, reset_pc, load_pc} = {1'b1, 3'b001, 1'b1};
		`S_BNE3: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b1};
		
                `S_BLT1: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b0};
		`S_BLT2: {address_select, reset_pc, load_pc} = {1'b1, 3'b001, 1'b1};
		`S_BLT3: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b1};

                `S_BLE1: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b0};
		`S_BLE2: {address_select, reset_pc, load_pc} = {1'b1, 3'b001, 1'b1};
		`S_BLE3: {address_select, reset_pc, load_pc} = {1'b1, 3'b010, 1'b1};


		`S_BL1: {vsel, write, readnum_and_writenum} = {2'b01, 1'b1, 3'b111}; 		// put PC + 1 into R7
		`S_BL2: {write, address_select, reset_pc, load_pc} = {1'b0, 1'b1, 3'b001, 1'b1};	// turn off write signal, and increment the PC to PC+1+sximm8

		// need to set PC to be equal to whatever is in Rd
			// read from register Rd onto register C in the datapath
			// set reset_pc == 3'b111 to select outputdatapath[8:0] as the input to the PC
			// 
		`S_BX1: {readnum_and_writenum, loadA, loadB, shift, ALUop, asel, bsel, loadS, loadC} = {out_instruction_register[7:5], 1'b0, 1'b1, 2'b00, 2'b00, 1'b1, 1'b0, 1'b0, 1'b1};
		`S_BX2: {loadA, loadB, loadS, loadC} = {1'b0, 1'b0, 1'b0, 1'b1};
		`S_BX3: {address_select, reset_pc, load_pc, loadC} = {1'b1, 3'b111, 1'b1, 1'b0};
		`S_BX4: {load_pc} = {1'b1}; 

		// BLX !!!!!!!!!!!!!!!!
		`S_BLX1: {vsel, write, readnum_and_writenum} = {2'b01, 1'b1, 3'b111}; // put PC + 1 into R7
		`S_BLX2: {write, readnum_and_writenum, loadA, loadB, shift, ALUop, asel, bsel, loadS, loadC} = {1'b0, out_instruction_register[7:5], 1'b0, 1'b1, 2'b00, 2'b00, 1'b1, 1'b0, 1'b0, 1'b1};
		`S_BLX3: {loadA, loadB, loadS, loadC} = {1'b0, 1'b0, 1'b0, 1'b1};
		`S_BLX4: {address_select, reset_pc, load_pc, loadC} = {1'b1, 3'b111, 1'b1, 1'b0};
		`S_BLX5: {load_pc} = {1'b1};


                `S_HALT: {load_pc, load_addr, w} = {1'b1, 1'b0, 1'b0}; 
		        `S_HALT1: {load_pc, w} = {1'b0, 1'b1};
            endcase
        end
    end
endmodule

module multiplexer_3input_onehot (a3, a2, a1, a0, s, out); 
    parameter k = 1;
    input [k-1:0] a3, a2, a1, a0;
    input [2:0] s; 
    output reg [k-1:0] out;

    always @(*) begin
        case(s)
            3'b001: out = a0;
            3'b010: out = a1;
            3'b100: out = a2;
	    3'b111: out = a3;
            default: out = {k{1'bx}};
        endcase
    end
endmodule
