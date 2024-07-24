module cpu (input logic clk, input logic rst_n, output logic [7:0] LED);
    logic reg_bank_write, pc_en;
    logic [2:0] alu_OP;
    logic [4:0] rs1, rs2, rd0;
    logic [31:0] instruction_mem_out, datapath_out, data_mem_out, pc_in, pc_out;
    enum {START, DECODE} state;

    datapath HW                 (.clk(clk),
                                .rst_n(rst_n),
                                .write_rb(reg_bank_write),
                                .alu_control(alu_OP),
                                .rs_1(rs1),
                                .rs_2(rs2),
                                .rd_0(rd0),
                                .writedata(datapath_out),
                                .alu_result(datapath_out));

    register #(32) PC           (.clk(clk),
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
                                .data(),
                                .wren(),
                                .q(instruction_mem_out));

    /*memory DATA_MEMORY          (.clock(clk),
                                .address(),
                                .data(),
                                .wren(),
                                .q());
    */

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_en           <= 1'b0;
            reg_bank_write  <= 1'b0;
        end else begin
            case (state) 
                START: begin
                    pc_en <= 1;
                end
            endcase
        end
    end
endmodule: cpu