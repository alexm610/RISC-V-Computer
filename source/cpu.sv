`include "defines.sv"

module cpu  (input logic clk, input logic rst_n, input logic [31:0] instruction, input logic [31:0] readdata, 
            output logic data_memory_write, output logic [31:0] conduit, output logic [31:0] RS2_readdata, output logic [9:0] data_memory_address, output logic [31:0] PC_out);
    logic reg_bank_write, PC_en, alu_SRC, negative, overflow, zero, mem_or_reg;
    logic [2:0] funct3;
    logic [3:0] alu_OP;
    logic [4:0] rs1, rs2, rd0;
    logic [6:0] opcode, funct7;
    logic [11:0] imm_I_TYPE;
    logic [31:0] datapath_out, PC_in, imm, datapath_in, readdata_mux;
    enum {WAIT, START, WRITE_BACK, INCREMENT_PC, COMPLETE, ACCESS_MEMORY_1, ACCESS_MEMORY_2} state;

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
                                .rs2(RS2_readdata));

    register #(32) PC           (.clock(clk),
                                .reset(rst_n),
                                .in(PC_in),
                                .enable(1'b1),
                                .out(PC_out));

    always @(funct3) begin
        case (funct3) 
            32'h0: readdata_mux = {{24{readdata[7]}}, readdata[7:0]};       // sign-extended byte load
            32'h1: readdata_mux = {{16{readdata[15]}}, readdata[15:0]};     // sign-extended half-word load
            32'h2: readdata_mux = readdata[31:0];
            32'h4: readdata_mux = {{24{1'b0}}, readdata[7:0]};              // zero-extended byte load
            32'h5: readdata_mux = {{16{1'b0}}, readdata[15:0]};             // zero-extended half-word load
            default: readdata_mux = readdata;
        endcase
    end

    assign datapath_in          = mem_or_reg ? readdata_mux : datapath_out;
    assign conduit              = datapath_out;
    assign rs1                  = instruction[19:15];
    assign rs2                  = instruction[24:20];
    assign rd0                  = instruction[11:7];
    assign funct3               = instruction[14:12];
    assign funct7               = instruction[31:25];
    assign opcode               = instruction[6:0];
    assign imm_I_TYPE           = instruction[31:20];
    assign imm                  = {{20{imm_I_TYPE[11]}}, imm_I_TYPE};
    assign alu_OP               = {funct7[5], funct3};
    assign data_memory_address  = datapath_out[9:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            PC_in <= 32'h0;
        end else begin
            PC_in <= PC_en ? PC_in + 32'h4 : PC_in;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            PC_en               <= 1'b0;
            reg_bank_write      <= 1'b0;
            data_memory_write   <= 1'b0;
            mem_or_reg          <= 1'b0;
            state               <= WAIT;
        end else begin
            case (state) 
                WAIT: begin
                    PC_en       <= 1'b0;
                    state       <= START;
                end
                START: begin
                    PC_en               <= 1'b0;
                    reg_bank_write      <= 1'b0;
                    data_memory_write   <= 1'b0;
                    mem_or_reg          <= 1'b0;
                    case (opcode)
                        `R_TYPE: begin
                            state       <= WRITE_BACK;
                            alu_SRC     <= 1'b1;
                        end
                        `I_TYPE: begin
                            state       <= WRITE_BACK;
                            alu_SRC     <= 1'b0; 
                        end       
                        `LOAD_TYPE: begin
                            state       <= ACCESS_MEMORY_1;
                            alu_SRC     <= 1'b0;
                        end                 
                        default: state <= START;
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
            endcase
        end
    end
endmodule: cpu
