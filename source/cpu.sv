`include "defines.sv"

module cpu  (input logic clk, input logic rst_n, input logic [31:0] instruction, input logic [31:0] readdata, 
            output logic data_memory_write, output logic [31:0] conduit, output logic [31:0] RS2_readdata, output logic [9:0] data_memory_address, output logic [31:0] PC_out);
    logic reg_bank_write, PC_en, alu_SRC, negative, overflow, zero, mem_or_reg, jump_link;
    logic [2:0] funct3;
    logic [3:0] alu_OP, PC_mux;
    logic [4:0] rs1, rs2, rd0;
    logic [6:0] opcode, funct7;
    logic [11:0] imm_I_TYPE, imm_S_TYPE, imm_B_TYPE;
    logic [31:0] imm_J_TYPE;
    logic [31:0] datapath_out, PC_in, imm, datapath_in, readdata_mux, rs2_output;
    enum {WAIT, START, WRITE_BACK, INCREMENT_PC, COMPLETE, ACCESS_MEMORY_1, ACCESS_MEMORY_2, WRITE_MEMORY_1, WRITE_MEMORY_2, BRANCH_EQ, BRANCH_NE, BRANCH_LT, BRANCH_GE, BRANCH_LTU, BRANCH_GEU, JUMP_LINK_1, JUMP_LINK_2} state;

    datapath HW                 (.clk(clk),
                                .rst_n(rst_n),
                                .write_rb(reg_bank_write),
                                .alu_control(alu_OP),
                                .alu_source(alu_SRC),
                                .rs_1(rs1),
                                .rs_2(rs2),
                                .rd_0(rd0),
                                .writedata(datapath_in),
                                .alu_result(datapath_out),
                                .immediate(imm),
                                .negative(negative),
                                .overflow(overflow),
                                .zero(zero),
                                .rs2(rs2_output));

    register #(32) PC           (.clock(clk),
                                .reset(rst_n),
                                .in(PC_in),
                                .enable(PC_en),
                                .out(PC_out));

    multiplexer_4input #(32) PC_MUX (.a3(imm + datapath_in), .a2(32'h0), .a1(PC_out + imm), .a0(PC_out + 32'h4), .s(PC_mux), .out(PC_in));
    
    always @(*) begin
        case (funct3) 
            3'h0: RS2_readdata = {{24{32'h0}}, rs2_output[7:0]};
            3'h1: RS2_readdata = {{16{32'h0}}, rs2_output[15:0]};
            3'h2: RS2_readdata = rs2_output;
            default: RS2_readdata = rs2_output;
        endcase
    end

    always @(*) begin
        case (funct3) 
            32'h0: readdata_mux = {{24{readdata[7]}}, readdata[7:0]};       // sign-extended byte load
            32'h1: readdata_mux = {{16{readdata[15]}}, readdata[15:0]};     // sign-extended half-word load
            32'h2: readdata_mux = readdata[31:0];
            32'h4: readdata_mux = {{24{1'b0}}, readdata[7:0]};              // zero-extended byte load
            32'h5: readdata_mux = {{16{1'b0}}, readdata[15:0]};             // zero-extended half-word load
            default: readdata_mux = readdata;
        endcase
    end

    assign datapath_in          = jump_link ? (PC_out + 32'h4) : (mem_or_reg ? readdata_mux : datapath_out);
    //assign conduit              = datapath_out;
    assign rs1                  = instruction[19:15];
    assign rs2                  = instruction[24:20];
    assign rd0                  = instruction[11:7];
    assign funct3               = instruction[14:12];
    assign funct7               = instruction[31:25];
    assign opcode               = instruction[6:0];
    assign imm_I_TYPE           = instruction[31:20];
    assign imm_S_TYPE           = {instruction[31:25], instruction[11:7]}; 
    assign imm_B_TYPE           = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
    assign imm_J_TYPE           = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:25], instruction[24:21], 1'b0};
    assign data_memory_address  = datapath_out[8:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            jump_link           <= 1'b0;
            PC_en               <= 1'b0;
            reg_bank_write      <= 1'b0;
            data_memory_write   <= 1'b0;
            mem_or_reg          <= 1'b0;
            state               <= WAIT;
            alu_OP              <= 4'h0;
            PC_mux              <= 4'b0100; 
        end else begin
            case (state) 
                WAIT: begin
                    PC_en       <= 1'b0;
                    PC_mux      <= 4'b0001;
                    state       <= START;
                    jump_link   <= 1'b0;
                end
                START: begin
                    PC_en               <= 1'b0;
                    PC_mux              <= 4'b0001;
                    reg_bank_write      <= 1'b0;
                    data_memory_write   <= 1'b0;
                    mem_or_reg          <= 1'b0;
                    imm                 <= 32'h0;
                    jump_link           <= 1'b0;
                    case (opcode)
                        `R_TYPE: begin
                            state       <= WRITE_BACK;
                            alu_OP      <= {funct7[5], funct3};
                            alu_SRC     <= 1'b1;
                        end
                        `I_TYPE: begin
                            state       <= WRITE_BACK;
                            alu_OP      <= {funct7[5], funct3};
                            alu_SRC     <= 1'b0; 
                            imm         <= {{20{imm_I_TYPE[11]}}, imm_I_TYPE};
                        end       
                        `LOAD_TYPE: begin
                            state       <= ACCESS_MEMORY_1;
                            alu_OP[2:0] <= `ADDSUB; 
                            imm         <= {{20{imm_I_TYPE[11]}}, imm_I_TYPE};
                            alu_SRC     <= 1'b0;
                            
                        end              
                        `S_TYPE: begin
                            state       <= WRITE_MEMORY_1;
                            imm         <= {{20{imm_S_TYPE[11]}}, imm_S_TYPE};
                            alu_SRC     <= 1'b0;
                            alu_OP[2:0] <= `ADDSUB;
                        end   
                        `B_TYPE: begin
                            case (funct3)
                                3'h0: begin 
                                        state       <= BRANCH_EQ;
                                        alu_OP      <= {1'b1, `ADDSUB}; 
                                end
                                3'h1: begin
                                        state       <= BRANCH_NE;
                                        alu_OP      <= {1'b1, `ADDSUB};
                                end
                                3'h4: begin 
                                        state       <= BRANCH_LT;
                                        alu_OP      <= {1'b0, `SLT}; // we don't care what the MSB of alu_OP is when using the "set less than" operation    
                                end
                                3'h5: begin 
                                        state       <= BRANCH_GE;
                                        alu_OP      <= {1'b0, `SLT};
                                end
                                3'h6: begin 
                                        state       <= BRANCH_LTU;
                                        alu_OP      <= {1'b0, `SLTU};
                                end
                                3'h7: begin 
                                        state       <= BRANCH_GEU;
                                        alu_OP      <= {1'b0, `SLTU};
                                end
                            endcase
                            alu_SRC     <= 1'b1;
                            imm         <= {{19{imm_B_TYPE[11]}}, imm_B_TYPE, 1'b0};    // zeroth bit of immediate for B-type instructions is always zero (for byte alignment)
                        end
                        `J_TYPE_JAL: begin
                            state           <= JUMP_LINK_1;
                            jump_link       <= 1'b1;
                            imm             <= imm_J_TYPE;
                            PC_mux          <= 4'b0010;
                        end
                        `J_TYPE_JALR: begin
                            state           <= JUMP_LINK_2;
                            jump_link       <= 1'b1;
                            imm             <= {{20{imm_I_TYPE[11]}}, imm_I_TYPE};
                            PC_mux          <= 4'b1000;
                        end
                        7'b0000000: begin
                            conduit[0] <= 1'b1;
                            state <= START;
                        end
                        default: state  <= START;
                    endcase
                end
                WRITE_BACK: begin
                    state           <= COMPLETE; 
                    reg_bank_write  <= 1'b1;
                end
                COMPLETE: begin
                    state <= INCREMENT_PC;
                    PC_en <= 1'b1;
                    reg_bank_write  <= 1'b0;
                end
                INCREMENT_PC: begin
                    state   <= WAIT;
                    PC_en   <= 1'b0;
                end
                ACCESS_MEMORY_1: begin
                    state       <= ACCESS_MEMORY_2;
                    mem_or_reg  <= 1'b1;
                end
                ACCESS_MEMORY_2: begin
                    state           <= COMPLETE;
                    reg_bank_write  <= 1'b1;
                end
                WRITE_MEMORY_1: begin
                    state       <= WRITE_MEMORY_2;
                    data_memory_write <= 1'b1;
                end
                WRITE_MEMORY_2: begin
                    state <= COMPLETE;
                    data_memory_write <= 1'b0;
                end
                BRANCH_EQ: begin
                    state   <= COMPLETE;
                    if (zero) begin
                        PC_mux  <= 4'b0010; // add immediate to PC
                    end else begin
                        PC_mux  <= 4'b0001; // normally increment PC
                    end
                end
                BRANCH_NE: begin
                    state   <= COMPLETE;
                    if (!zero) begin
                        PC_mux  <= 4'b0010; // increment PC with immediate
                    end else begin
                        PC_mux  <= 4'b0001;
                    end
                end
                BRANCH_LT: begin
                    state   <= COMPLETE;
                    if (datapath_out == 32'h1) begin // rs1 is less than rs2
                        PC_mux  <= 4'b0010;
                    end else begin 
                        PC_mux  <= 4'b0001;
                    end 
                end 
                BRANCH_GE: begin
                    state   <= COMPLETE;
                    if (datapath_out == 32'h0) begin
                        PC_mux  <= 4'b0010;
                    end else begin 
                        PC_mux  <= 4'b0001;
                    end 
                end 
                BRANCH_LTU: begin
                    state   <= COMPLETE;
                    if (datapath_out == 32'h1) begin 
                        PC_mux  <= 4'b0010;
                    end else begin 
                        PC_mux  <= 4'b0001;
                    end 
                end
                BRANCH_GEU: begin 
                    state   <= COMPLETE;
                    if (datapath_out == 32'h0) begin
                        PC_mux  <= 4'b0010;
                    end else begin 
                        PC_mux  <= 4'b0001;
                    end 
                end 
                JUMP_LINK_1: begin
                    state           <= COMPLETE;
                    reg_bank_write  <= 1'b1; // the writedata line into the datapath (into the register bank) has PC_out + 4 on it, so we just need to set write HIGH
                end
                JUMP_LINK_2: begin
                    state           <= COMPLETE;
                    reg_bank_write  <= 1'b1;
                    jump_link       <= 1'b0;
                    alu_OP[2:0]     <= `ADDSUB;
                    alu_SRC         <= 1'b0;
                end
            endcase
        end
    end
endmodule: cpu
