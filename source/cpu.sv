`include "defines.sv"

module cpu  (input logic clk, input logic rst_n, input logic [31:0] instruction, 
            output logic [7:0] LED, output logic [31:0] PC_out);
    logic reg_bank_write, PC_en, im_en, alu_SRC;
    logic [2:0] alu_OP, funct3;
    logic [4:0] rs1, rs2, rd0;
    logic [6:0] opcode, funct7;
    logic [11:0] imm_I_TYPE;
    logic [31:0] datapath_out, PC_in, imm;
    enum {START, OPERATE_ALU, WRITE_BACK, INCREMENT_PC, COMPLETE_R} state;

    datapath HW                 (.clk(clk),
                                .rst_n(rst_n),
                                .write_rb(reg_bank_write),
                                .alu_control(alu_OP),
                                .alu_source(alu_SRC),
                                .rs_1(rs1),
                                .rs_2(rs2),
                                .rd_0(rd0),
                                .writedata(datapath_out),
                                .alu_result(datapath_out),
                                .immediate(imm));

    register #(32) PC           (.clock(clk),
                                .reset(rst_n),
                                .in(PC_in),
                                .enable(1'b1),
                                .out(PC_out));

    always @(posedge clk) begin
        if (!rst_n) begin
            PC_in <= 32'h0;
        end else begin
            PC_in <= PC_en ? PC_in + 32'h4 : PC_in;
        end
    end

    assign rs1        = instruction[19:15];
    assign rs2        = instruction[24:20];
    assign rd0        = instruction[11:7];
    assign funct3     = instruction[14:12];
    assign funct7     = instruction[31:25];
    assign opcode     = instruction[6:0];
    assign imm_I_TYPE = instruction[31:20];
    assign imm        = {{20{1'b0}}, imm_I_TYPE};
    assign alu_OP     = funct3;

    always @(posedge clk) begin
        if (!rst_n) begin
            PC_en           <= 1'b0;
            reg_bank_write  <= 1'b0;
        end else begin
            case (state) 
                START: begin
                    case (opcode)
                        `R_TYPE: begin
                            state <= OPERATE_ALU;
                        end
                        `I_TYPE: begin
                            state <= OPERATE_ALU; 
                        end                        
                        default: state <= START;
                    endcase
                end
                OPERATE_ALU: begin
                    state <= WRITE_BACK;

                    if (opcode == `R_TYPE) begin
                        alu_SRC <= 1'b1;
                    end else if (opcode == `I_TYPE) begin
                        alu_SRC <= 1'b0;
                    end 
                end
                WRITE_BACK: begin
                    state <= INCREMENT_PC;
                    reg_bank_write <= 1'b1;
                end
                INCREMENT_PC: begin
                    state <= COMPLETE_R;
                    reg_bank_write <= 1'b0;
                    PC_en <= 1'b1;
                end
                COMPLETE_R: begin
                    state <= START;
                    PC_en <= 0;
                end
            endcase
        end
    end
endmodule: cpu