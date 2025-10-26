`include "defines.sv"

module cpu (
    input logic         Clock,
    input logic         Reset_L,
    input logic         DTAck,
    input logic [31:0]  Instruction,
    input logic [31:0]  DataBus_In,
    output logic        AS_L,
    output logic [3:0]  Byte_Enable,
    output logic        WE_L,
    output logic [31:0] DataBus_Out,
    output logic [31:0] Address,
    output logic        Conduit,
    output logic        Reset_Out
);

    // CPU signals
    enum {LATCH_INSTRUCTION, INITIALIZE, START, WRITE_BACK, INCREMENT_PC, COMPLETE, ACCESS_MEMORY_1, ACCESS_MEMORY_2, WRITE_MEMORY_1, WRITE_MEMORY_2, BRANCH_EQ, BRANCH_NE, BRANCH_LT, BRANCH_GE, BRANCH_LTU, BRANCH_GEU, JUMP_LINK_1, JUMP_LINK_2, JUMP_LINK_3, LOAD_UPPER_IMM_1} State;
    logic           mem_or_reg, jump_link, load_upper_imm, instruction_fetch, save_pc;
    logic [1:0]     Program_Counter_Increment;
    logic [2:0]     funct3;
    logic [6:0]     funct7, opcode;
    logic [11:0]    imm_I_TYPE, imm_S_TYPE, imm_B_TYPE;
    logic [19:0]    imm_U_TYPE;
    logic [20:0]    imm_J_TYPE;
    logic [31:0]    datapath_in, Program_Counter, Current_Instruction;

    // Data path signals
    logic           reg_bank_write, alu_SRC, negative, overflow, zero;
    logic [3:0]     alu_OP;
    logic [4:0]     rs1, rs2, rd0;
    logic [31:0]    writedata, datapath_out, imm, rs2_output;

    datapath HW (
        .clk(Clock),
        .rst_n(Reset_L),
        .write_rb(reg_bank_write),
        .alu_control(alu_OP),
        .alu_source(alu_SRC),
        .rs_1(rs1),
        .rs_2(rs2),
        .rd_0(rd0),
        .writedata(writedata),
        .alu_result(datapath_out),
        .immediate(imm),
        .negative(negative),
        .overflow(overflow),
        .zero(zero),
        .rs2(rs2_output)
    );

    assign datapath_in          = mem_or_reg ? DataBus_In : datapath_out;
    assign rs1                  = Current_Instruction[19:15];
    assign rs2                  = Current_Instruction[24:20];
    assign rd0                  = Current_Instruction[11:7];
    assign funct3               = Current_Instruction[14:12];
    assign funct7               = Current_Instruction[31:25];
    assign opcode               = Current_Instruction[6:0];
    assign imm_I_TYPE           = Current_Instruction[31:20];
    assign imm_S_TYPE           = {Current_Instruction[31:25], Current_Instruction[11:7]}; 
    assign imm_B_TYPE           = {Current_Instruction[31], Current_Instruction[7], Current_Instruction[30:25], Current_Instruction[11:8]};
    assign imm_J_TYPE           = {Current_Instruction[31], Current_Instruction[19:12], Current_Instruction[20], Current_Instruction[30:21], 1'b0};
    assign imm_U_TYPE           = Current_Instruction[31:12];
    assign Address              = instruction_fetch ? Program_Counter : datapath_out;
    assign DataBus_Out          = rs2_output;
    
    always @(*) begin
        Byte_Enable <= 4'b0000; // disable Byte_Enable by default

        if (funct3 == 3'h0) begin
            /*case (Address[1:0]) 
                2'b00: Byte_Enable <= 4'b0001; // we are writing a byte at no offset
                2'b01: Byte_Enable <= 4'b0010; // we are writing a byte at offset = 1
                2'b10: Byte_Enable <= 4'b0100; // writing a byte at offset = 2
                2'b11: Byte_Enable <= 4'b1000; // writing a byte at offset = 3
            endcase*/
            Byte_Enable <= 4'b0001; 
        end 

        if (funct3 == 3'h1) begin
            /*case (Address[1:0]) 
                2'b00: Byte_Enable <= 4'b0011; // writing a half-word at offset = 0
                2'b01: Byte_Enable <= 4'b0110; // writing a half-word at offset = 1
                2'b10: Byte_Enable <= 4'b1100; // writing a half-word at offset = 2
                default: Byte_Enable <= 4'b0000; // we cannot write a half word at offset = 3, as this is misaligned
            endcase*/
            Byte_Enable <= 4'b0011; 
        end

        if (funct3 == 3'h2) begin
            /*Byte_Enable <= 4'b0000; // disable Byte_Enable, unless condition below is met

            if (Address[1:0] == 2'b00) begin
                Byte_Enable <= 4'b1111;
            end*/
            Byte_Enable <= 4'b1111;
        end
    end

     always @(*) begin
        if (mem_or_reg == 1) begin
            case (funct3) 
                3'h0: writedata <= {{24{datapath_in[7]}}, datapath_in[7:0]};
                3'h1: writedata <= {{16{datapath_in[15]}}, datapath_in[15:0]};
                3'h2: writedata <= datapath_in;
                3'h4: writedata <= {{24{1'b0}}, datapath_in[7:0]};
                3'h5: writedata <= {{16{1'b0}}, datapath_in[15:0]};
                default: writedata <= 32'd0;
            endcase
        end else if (jump_link == 1) begin
            writedata <= Program_Counter + 32'h4;
        end else if (load_upper_imm == 1) begin
            writedata <= imm;
        end else begin  
            writedata <= datapath_in;
        end
    end

    always @(posedge Clock, negedge Reset_L) begin
        if (Reset_L == 0) begin
            State                       <= INITIALIZE;
            Program_Counter             <= 32'h00000000;
            AS_L                        <= 1;
            WE_L                        <= 1;
            mem_or_reg                  <= 0;
            alu_OP                      <= 4'h0;
            alu_SRC                     <= 1;
            Conduit                     <= 0;
            jump_link                   <= 0;
            imm                         <= 32'h00000000;
            reg_bank_write              <= 0;
            load_upper_imm              <= 0;
            Conduit                     <= 0;
            Program_Counter_Increment   <= 2'b00;
            Reset_Out                   <= 0;
            instruction_fetch           <= 1;
        end else begin
            case (State) 
                INITIALIZE: begin
                    State               <= START;
                    Current_Instruction <= Instruction;
                    Reset_Out           <= 1;
                    instruction_fetch   <= 1;
                    save_pc             <= 1;
                end
                START: begin
                    save_pc             <= 0;
                    case (opcode)
                        `R_TYPE: begin
                            State       <= WRITE_BACK;
                            alu_OP      <= {funct7[5], funct3};
                            alu_SRC     <= 1'b1;
                        end
                        `I_TYPE: begin
                            State       <= WRITE_BACK;
                            alu_OP      <= {funct7[5], funct3};
                            alu_SRC     <= 1'b0; 
                            imm         <= {{20{imm_I_TYPE[11]}}, imm_I_TYPE};
                        end       
                        `LOAD_TYPE: begin
                            State       <= ACCESS_MEMORY_1;
                            alu_OP      <= {1'b0, `ADDSUB}; 
                            imm         <= {{20{imm_I_TYPE[11]}}, imm_I_TYPE};
                            alu_SRC     <= 1'b0;
                            instruction_fetch <= 0;
                        end              
                        `S_TYPE: begin
                            State       <= WRITE_MEMORY_1;
                            imm         <= {{20{imm_S_TYPE[11]}}, imm_S_TYPE};
                            alu_SRC     <= 1'b0;
                            alu_OP      <= {1'b0, `ADDSUB};
                            instruction_fetch <= 0;
                        end   
                        `B_TYPE: begin
                            case (funct3)
                                3'h0: begin 
                                        State       <= BRANCH_EQ;
                                        alu_OP      <= {1'b1, `ADDSUB}; 
                                end
                                3'h1: begin
                                        State       <= BRANCH_NE;
                                        alu_OP      <= {1'b1, `ADDSUB};
                                end
                                3'h4: begin 
                                        State       <= BRANCH_LT;
                                        alu_OP      <= {1'b0, `SLT}; // we don't care what the MSB of alu_OP is when using the "set less than" operation    
                                end
                                3'h5: begin 
                                        State       <= BRANCH_GE;
                                        alu_OP      <= {1'b0, `SLT};
                                end
                                3'h6: begin 
                                        State       <= BRANCH_LTU;
                                        alu_OP      <= {1'b0, `SLTU};
                                end
                                3'h7: begin 
                                        State       <= BRANCH_GEU;
                                        alu_OP      <= {1'b0, `SLTU};
                                end
                            endcase
                            alu_SRC     <= 1'b1;
                            imm         <= {{19{imm_B_TYPE[11]}}, imm_B_TYPE, 1'b0};    // zeroth bit of immediate for B-type instructions is always zero (for byte alignment)
                        end
                        `J_TYPE_JAL: begin
                            State           <= JUMP_LINK_1;
                            jump_link       <= 1'b1;
                            imm             <= {{11{imm_J_TYPE[20]}}, imm_J_TYPE};
                        end
                        `J_TYPE_JALR: begin
                            State           <= JUMP_LINK_2;
                            jump_link       <= 1'b1;
                            imm             <= {{20{imm_I_TYPE[11]}}, imm_I_TYPE};
                        end
                        `U_TYPE_LUI: begin
                            State           <= LOAD_UPPER_IMM_1;
                            imm             <= (imm_U_TYPE << 12); 
                            load_upper_imm  <= 1'b1; 
                        end
                        `U_TYPE_AUIPC: begin
                            State           <= LOAD_UPPER_IMM_1;
                            imm             <= (imm_U_TYPE << 12) + Program_Counter;
                            load_upper_imm  <= 1'b1; 
                        end 
                        7'b0000000: begin
                            Conduit <= 1'b1;
                            State <= START;
                        end
                        default: State  <= START;
                    endcase
                end
                WRITE_BACK: begin
                    State           <= COMPLETE; 
                    reg_bank_write  <= 1'b1;
                    // increment program counter to next instruction, ie., no jumping
                    //Program_Counter <= Program_Counter + 32'h4;
                    Program_Counter_Increment <= 2'b00;
                end
                COMPLETE: begin
                    State <= INCREMENT_PC;
                    // disable control signals in preparation for next instruction cycle
                    reg_bank_write  <= 1'b0;
                    mem_or_reg      <= 1'b0;
                    WE_L            <= 1'b1;
                    AS_L            <= 1'b1;
                    load_upper_imm  <= 0;
                    instruction_fetch <= 1;
                    jump_link       <= 0;
                    if (Program_Counter_Increment == 2'b00) begin
                        // increment program counter by 4
                        Program_Counter <= Program_Counter + 32'h4;
                    end else if (Program_Counter_Increment == 2'b01) begin
                        // increment program counter by immediate
                        Program_Counter <= Program_Counter + imm;
                    end else if (Program_Counter_Increment == 2'b10) begin
                        // set program counter to output of data path
                        Program_Counter <= datapath_out;
                    end
                end
                INCREMENT_PC: begin
                    State   <= LATCH_INSTRUCTION;
                    // delay one clock cycle for new instruction to appear on output bus of SRAM
                end
                LATCH_INSTRUCTION: begin
                    State <= START;
                    Current_Instruction <= Instruction;
                    save_pc <= 1;
                end
                ACCESS_MEMORY_1: begin
                    State       <= ACCESS_MEMORY_2;
                    mem_or_reg  <= 1'b1;
                    // WE_L        <= 1'b1;
                    AS_L        <= 1'b0;
                end
                ACCESS_MEMORY_2: begin
                    State           <= DTAck ? COMPLETE : ACCESS_MEMORY_2;
                    reg_bank_write  <= 1'b1;
                    // increment program counter to next instruction, ie., no jumping
                    // Program_Counter <= Program_Counter + 32'h4;
                    Program_Counter_Increment <= 2'b00;
                end
                WRITE_MEMORY_1: begin
                    State       <= WRITE_MEMORY_2;
                    WE_L        <= 1'b0;
                    AS_L        <= 1'b0;
                end
                WRITE_MEMORY_2: begin
                    State <= DTAck ? COMPLETE : WRITE_MEMORY_2;
                    // increment program counter to next instruction, ie., no jumping
                    //Program_Counter <= Program_Counter + 32'h4;
                    Program_Counter_Increment <= 2'b00;
                end
                BRANCH_EQ: begin
                    State   <= COMPLETE;
                    if (zero) begin
                        // add immediate to PC
                        // Program_Counter <= Program_Counter + imm;
                        Program_Counter_Increment <= 2'b01;
                    end else begin
                        // normally increment PC
                        //Program_Counter <= Program_Counter + 32'h4;
                        Program_Counter_Increment <= 2'b00;
                    end
                end
                BRANCH_NE: begin
                    State   <= COMPLETE;
                    if (!zero) begin
                        // increment PC with immediate
                        //Program_Counter <= Program_Counter + imm;
                        Program_Counter_Increment <= 2'b01;
                    end else begin
                        // increment program counter to next instruction
                        //Program_Counter <= Program_Counter + 32'h4;
                        Program_Counter_Increment <= 2'b00;
                    end
                end
                BRANCH_LT: begin
                    State   <= COMPLETE;
                    if (datapath_out == 32'h1) begin // rs1 is less than rs2
                        // increment PC with immediate
                        //Program_Counter <= Program_Counter + imm;
                        Program_Counter_Increment <= 2'b01;
                    end else begin 
                        // increment program counter to next instruction
                        //Program_Counter <= Program_Counter + 32'h4;
                        Program_Counter_Increment <= 2'b00;
                    end 
                end 
                BRANCH_GE: begin
                    State   <= COMPLETE;
                    if (datapath_out == 32'h0) begin
                        // increment PC with immediate
                        //Program_Counter <= Program_Counter + imm;
                        Program_Counter_Increment <= 2'b01;
                    end else begin 
                        // increment program counter to next instruction
                        //Program_Counter <= Program_Counter + 32'h4;
                        Program_Counter_Increment <= 2'b00;
                    end 
                end 
                BRANCH_LTU: begin
                    State   <= COMPLETE;
                    if (datapath_out == 32'h1) begin 
                        // increment PC with immediate
                        //Program_Counter <= Program_Counter + imm;
                        Program_Counter_Increment <= 2'b01;
                    end else begin 
                        // increment program counter to next instruction
                        //Program_Counter <= Program_Counter + 32'h4;
                        Program_Counter_Increment <= 2'b00;
                    end 
                end
                BRANCH_GEU: begin 
                    State   <= COMPLETE;
                    if (datapath_out == 32'h0) begin
                        // increment PC with immediate
                        //Program_Counter <= Program_Counter + imm;
                        Program_Counter_Increment <= 2'b01;
                    end else begin 
                        // increment program counter to next instruction
                        Program_Counter_Increment <= 2'b00;
                        //Program_Counter <= Program_Counter + 32'h4;
                    end 
                end 
                JUMP_LINK_1: begin
                    State           <= COMPLETE;
                    // the writedata line into the datapath (into the register bank) has PC_out + 4 on it, so we just need to set write HIGH
                    reg_bank_write  <= 1'b1; 
                    jump_link       <= 1;
                    // increment program counter with immediate
                    //Program_Counter <= Program_Counter + imm;
                    Program_Counter_Increment <= 2'b01;
                end
                JUMP_LINK_2: begin
                    State           <= JUMP_LINK_3;
                    // write to register bank PC + 4
                    reg_bank_write  <= 1'b1;
                    // disable jump_link so the destination register is not updated after this state
                    jump_link       <= 1'b0;
                    // begin ALU operation to sum RS1 + imm
                    alu_OP[2:0]     <= `ADDSUB;
                    alu_SRC         <= 1'b0;

                end
                JUMP_LINK_3: begin
                    State           <= COMPLETE;

                    // we are no longer writing to the register bank
                    reg_bank_write  <= 0;

                    // program counter gets RS1 + imm
                    //Program_Counter <= datapath_out;
                    Program_Counter_Increment <= 2'b10;
                end
                LOAD_UPPER_IMM_1: begin
                    State           <= COMPLETE; 
                    reg_bank_write  <= 1'b1; // the U-type immediate is on the datapath_in line, just need to write to destination register 
                    // program counter is normally incremented
                    //Program_Counter <= Program_Counter + 32'h4;
                    Program_Counter_Increment <= 2'b00;
                end
            endcase 
        end
    end 
endmodule