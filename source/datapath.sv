    /**
     ** 
     ** Need to instantiate within this datapath module:
     **      - Instruction memory (ROM)
     **      - Data memory (RAM)
     **      - Register bank
     **      - ALU
     **      - Program counter hardware 
     **          - Including the multiplexers that either increment the 
     **              program counter by 4 or branches to somewhere else 
     **      - Connect output of data memory (RAM) to the "writedata" port of 
     **          the register bank
    */
module datapath (clk, rst_n, rb_wren, alu_control, ram_write, ram_read, ram_writedata, ram_readdata, rom_read);
    logic clk, rst_n, rb_wren, ram_write, ram_read, rom_read;
    logic [31:0] ram_writedata, ram_readdata;
    logic [31:0] A_out, B_out;


    /**
     **   NOTE:     the register bank should be modified such that 
     **             it has two outputs, based on the which two registers
     **             are to be worked upon (most instructions operate 
     **             on two registers, send data to ALU, then back into 
     **             the write-register. Occasionally, there will be some 
     **             instructions where only one register is modified, in
     **             which case there should be a multiplexer that either
     **             sends both register outputs to the ALU, or sends 
     **             just one register output and a constant into the two 
     **             ports of the ALU)
    */
    regfile REGISTER_BANK  (.clk(clk),
                            .reset_n(rst_n),
                            .rs1(),
                            .rs2(),
                            .rd(),
                            .write(),
                            .writedata(),
                            .readdata_1(A_out),
                            .readdata_2(B_out));

    alu ALU    (.Ain(A_out),
                .Bin(B_out),
                .ALUop(),
                .out(),
                .status());

    register #(32) PC  (.clk(clk),
                        .reset(rst_n),
                        .in(),
                        .enable(pc_en),
                        .out());

    


endmodule: datapath 