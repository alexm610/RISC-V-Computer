module BLT_test_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;
  reg CLOCK_50;

  lab7bonus_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
 
  initial forever begin
    CLOCK_50 = 0; #5;
    CLOCK_50 = 1; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    /*
    if (DUT.MEM.mem[0] !== 16'b1101000000000001) begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b1101000100000011) begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[2] !== 16'b1101001000000101) begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[3] !== 16'b1010100000000001) begin err = 1; $display("FAILED: mem[3] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[4] !== 16'b0010001100000001) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[5] !== 16'b1101001100101100) begin err = 1; $display("FAILED: mem[5] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[6] !== 16'b1101001101100011) begin err = 1; $display("FAILED: mem[6] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[7] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[7] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    */

    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

    #10; // waiting for RST state to cause reset of PC
    //if (DUT.CPU.PC !== 9'h0) begin err = 1; $display("FAILED: PC did not reset to 0."); $stop; end

    // If your simlation never gets past the the line below, check if your CMP instruction is working
    @(posedge LEDR[8]); // set LEDR[8] to one when executing HALT

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    // NOTE: if HALT is working, PC won't change after reaching 0xE
    //if (DUT.CPU.PC !== 9'hF) begin err = 1; $display("FAILED: PC at HALT is incorrect."); $stop; end
 /*   if (DUT.CPU.DP.REGFILE.R4 !== 16'h1) begin err = 1; $display("FAILED: R4 incorrect at exit; did MOV R4,#1 not work?"); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h4) begin err = 1; $display("FAILED: R0 incorrect at exit; did LDR R0,[R0] not work?"); $stop; end

    // check memory contents for result
    if (DUT.MEM.mem[8'h14] === 16'h0) begin 
      err = 1; 
      $display("FAILED: mem[0x14] (result) is wrong;");
      if (DUT.CPU.DP.REGFILE.R3 === 16'h10)
        $display("        hint: check if your BLT instruction skipped MOV R3, result"); 
      $stop; 
    end*/
    //if (DUT.MEM.mem[8'h14] !== 16'd850)  begin err = 1; $display("FAILED: mem[0x14] (result) is wrong;"); $stop; end

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule