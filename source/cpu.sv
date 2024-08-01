`include "defines.sv"
module cpu (input logic clk, input logic rst_n, output logic [7:0] LED);
    logic reg_bank_write, pc_en, im_en;
    logic [2:0] alu_OP, funct3;
    logic [4:0] rs1, rs2, rd0;
    logic [6:0] opcode, funct7;
    logic [31:0] instruction_mem_out, datapath_out, data_mem_out, pc_in, pc_out, data_in;
    enum {START, OPERATE_ALU, WRITE_BACK, INCREMENT_PC, COMPLETE_R} state;

    datapath HW                 (.clk(clk),
                                .rst_n(rst_n),
                                .write_rb(reg_bank_write),
                                .alu_control(alu_OP),
                                .rs_1(rs1),
                                .rs_2(rs2),
                                .rd_0(rd0),
                                .writedata(datapath_out),
                                .alu_result(datapath_out));

    register #(32) PC           (.clock(clk),
                                .reset(rst_n),
                                .in(pc_in),
                                .enable(pc_en),
                                .out(pc_out));

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_in <= 32'h0;
        end else begin
            pc_in <= pc_en ? pc_in + 32'h4 : pc_in;
        end
    end

    memory INSTRUCTION_MEMORY   (.clock(clk),
                                .address(pc_in),
                                .data(data_in),
                                .wren(im_en),
                                .q(instruction_mem_out));

    /*memory DATA_MEMORY          (.clock(clk),
                                .address(),
                                .data(),
                                .wren(),
                                .q());
    */

    assign rs1      = instruction_mem_out[19:15];
    assign rs2      = instruction_mem_out[24:20];
    assign rd0      = instruction_mem_out[11:7];
    assign funct3   = instruction_mem_out[14:12];
    assign funct7   = instruction_mem_out[31:25];
    assign opcode   = instruction_mem_out[6:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_en           <= 1'b0;
            reg_bank_write  <= 1'b0;
        end else begin
            case (state) 
                START: begin
                    case (opcode)
                        `R_TYPE: begin
                            state <= OPERATE_ALU;


                        end
                        
                        default: state <= START;
                    endcase
                end
                OPERATE_ALU: begin
                    state <= WRITE_BACK;
                end
                WRITE_BACK: begin
                    state <= INCREMENT_PC;
                    reg_bank_write <= 1'b1;
                end
                INCREMENT_PC: begin
                    state <= COMPLETE_R;
                    reg_bank_write <= 1'b0;
                    pc_en <= 1'b1;
                end
                COMPLETE_R: begin
                    state <= START;
                    pc_en <= 0;
                end
            endcase
        end
    end
endmodule: cpu