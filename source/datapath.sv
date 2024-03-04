    /*
        Need to instantiate within this datapath module:
            - Instruction memory (ROM)
            - Data memory (RAM)
            - Register bank
            - ALU
            - Program counter hardware 
                - Including the multiplexers that either increment the 
                    program counter by 4 or branches to somewhere else 
            - Connect output of data memory (RAM) to the "writedata" port of 
                the register bank
    */
module datapath (clk, rst_n, rb_wren, alu_control, ram_write, ram_read, ram_writedata, ram_readdata, rom_read);
    logic clk, rst_n, rb_wren, ram_write, ram_read, rom_read;
    logic [31:0] ram_writedata, ram_readdata;


    /*
    NOTE:   the register bank should be modified such that 
            it has two outputs, based on the which two registers
            are to be worked upon (most instructions operate 
            on two registers, send data to ALU, then back into 
            the write-register. Occasionally, there will be some 
            instructions where only one register is modified, in
            which case there should be a multiplexer that either
            sends both register outputs to the ALU, or sends 
            just one register output and a constant into the two 
            ports of the ALU)
    */
    regfile REGISTER_BANK (.clk(clk),
                           .reset_n(rst_n),
                           .data_in(),
                           .data_out(),
                           .write(rb_wren),
                           .writenum(),     // 5-bit code defining which of the 32 registers should be written to into the register bank
                           .readnum())      // 5-bit code defining which of the 32 registers should read from into the decoder

    alu ALU ()


endmodule: datapath 