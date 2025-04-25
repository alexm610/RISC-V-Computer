`timescale 1ps/1ps

module tb_cpu;
    logic Clock, Reset_L, DTAck, AS_L, WE_L, Conduit, Reset_Out;
    logic [3:0] Byte_Enable;
    logic [31:0] Instruction, DataBus_In, DataBus_Out, Address, address_dummy;
    int i = 4;
    int j = 0;
    int counter = 0;
    int correct_answer = 0;
    logic error;
    reg [31:0] mem_file_1 [0:255];

    cpu dut (.*);

    initial forever begin
        Clock = 1; #1;
        Clock = 0; #1;
    end

    initial begin
        $display("------ Begin cpu.sv testbench ------");
        $display("");
       
        /*
        TEST 1

        ADDI X3, X13, 34 // immediate is in decimal form
        0x02268193

        */
        DataBus_In = 32'h0BADF00D;
        error = 1'b0;
        Instruction = 32'h02268193;
        Reset_L = 1'b1; #2;
        Reset_L = 1'b0; #2;
        Reset_L = 1'b1; #2;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X3.out == 32'd34);
        /*
        TEST 2

        ADDI X29, X0, 198 // immediate is in decimal form
        0x0C600E93
        */
        Instruction = 32'h0C600E93; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X29.out == 32'd198);

        /*
        TEST 3

        XORI X20, X30, 76 // immediate is in decimal form
        0x04CF4A13
        */
        Instruction = 32'h04CF4A13; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X20.out == 32'd76);
        /*
        TEST 4

        XORI X15, X7, 203 // immediate is in decimal form
        0x0CB3C793
        */
        Instruction = 32'h0CB3C793; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X15.out == 32'd203);

        /*
        TEST 5

        ORI X12, X6, 43 // immediate is in decimal form
        0x02B36613
        */
        Instruction = 32'h02B36613; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X12.out == 32'd43);

        /*
        TEST 6

        ORI X19, X31, 172 // immediate is in decimal form
        0X0ACFE993
        */
        Instruction = 32'h0ACFE993; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X19.out == 32'd172);

        /*
        TEST 7

        ANDI X9, X20, 21 // immediate is in decimal form
        0X015A7493
        */
        Instruction = 32'h015A7493; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X9.out == (32'd21 & dut.HW.REGISTER_BANK.X20.out));

        /*
        TEST 8

        ANDI X25, X29, 115 // immediate is in decimal form
        0X073EFC93
        */
        Instruction = 32'h073EFC93; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X25.out == (32'd115 & dut.HW.REGISTER_BANK.X29.out));

        /*
        TEST 9

        SLLI X17, X9, 9 // immediate is in decimal form
        0x00949893
        */
        Instruction = 32'h00949893; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X17.out == (dut.HW.REGISTER_BANK.X9.out << 9));

        /*
        TEST 10

        SLLI X31, X15, 3 // immediate is in decimal form
        0x00379f93
        */
        Instruction = 32'h00379f93; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X31.out == (dut.HW.REGISTER_BANK.X15.out << 3));

        /*
        TEST 11

        SRLI X18, X17, 2 // immediate is in decimal form
        0x0028d913
        */
        Instruction = 32'h0028d913; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X18.out == (dut.HW.REGISTER_BANK.X17.out >> 2));

        /*
        TEST 12

        SRLI X6, X9, 1 // immediate is in decimal form
        0x0014d313
        */
        Instruction = 32'h0014d313; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X6.out == (dut.HW.REGISTER_BANK.X9.out >> 1));
        
        /*
        TEST 13

        ADDI, X2, X0, 1 // immediate is in decimal form
        0x00100113
        */
        Instruction = 32'h00100113; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X2.out == (32'd1));

        /*
        TEST 14

        SLLI X1, X2, 31 // immediate is in decimal form
        0x01f11093
        */
        Instruction = 32'h01f11093; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X1.out == (dut.HW.REGISTER_BANK.X2.out << 32'd31));


        /*
        TEST 15

        SRAI X12, X1, 2 // immediate is in decimal form
        0x4020d613
        */
        Instruction = 32'h4020d613; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X12.out == (dut.HW.REGISTER_BANK.X1.out >>> 2));

        /*
        TEST 16

        SRLI X27, X12, 1 // immediate is in decimal form
        0x00165d93
        */
        Instruction = 32'h00165d93; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X27.out == (dut.HW.REGISTER_BANK.X12.out >> 1));
        
        /*
        TEST 17

        SRAI X28, X27, 1 // immediate is in decimal form
        0x401dde13
        */
        Instruction = 32'h401dde13; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X28.out == (dut.HW.REGISTER_BANK.X27.out >>> 1));

        /*
        TEST 18

        LB X4, 0(X2) // immediate is in decimal form
        0x00010203
        */
        DTAck = 1;
        DataBus_In = 32'h0BADF01D;
        Instruction = 32'h00010203; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X4.out == ({{24{DataBus_In[7]}}, DataBus_In[7:0]}));
        #2;

        /*
        TEST 19

        LH X4, 0(X2) // immediate is in decimal form
        0x00011203
        */
        DataBus_In = 32'h0BADF01D;
        Instruction = 32'h00011203; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X4.out == ({{16{DataBus_In[15]}}, DataBus_In[15:0]}));
        #2;

        /*
        TEST 20

        LW X13, 0(X2) // immediate is in decimal form
        0x00012683
        */
        DataBus_In = 32'h0BADF01D;
        Instruction = 32'h00012683; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X13.out == (DataBus_In[31:0]));
        #2;

        /*
        TEST 21

        STLI X13, X9, 3 // immediate is in decimal form
        0x0034a693
        */
        Instruction = 32'h0034A693; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X13.out == ((dut.HW.REGISTER_BANK.X9.out < 3) ? 1 : 0));
        #2;

        /*
        TEST 22

        STLI X13, X9, 5 // immediate is in decimal form
        0x0054a693
        */
        Instruction = 32'h0054a693; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X13.out == ((dut.HW.REGISTER_BANK.X9.out < 5) ? 1 : 0));
        #2;

        /*
        TEST 23

        ADDI X1, X0, 127 // immediate is in decimal form
        0xFFF00093

        */
        DataBus_In = 32'h0BADF00D;
        error = 1'b0;
        Instruction = 32'h07F00093;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X1.out == 32'h7F); // number should be sign extended

        /*
        TEST 24

        SLTI X2, X1, -128
        0Xf800a113
        */
        Instruction = 32'hF800A113;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X2.out == 32'h0); // signed comparison: 127 is not less than -128

        /*
        TEST 24

        SLTIU X2, X1, -128
        0xF800B113
        */
        Instruction = 32'hF800B113;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X2.out == 32'h1); // unsigned comparison: 127 is less than -128(unsigned)

        /*
        TEST 25

        ADD X14, X2, X3
        0x00310733
        */
        Instruction = 32'h00310733;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X14.out == (dut.HW.REGISTER_BANK.X2.out + dut.HW.REGISTER_BANK.X3.out));

        /*
        TEST 26

        SUB X15, X2, X3
        0x402187b3
        */
        Instruction = 32'h402187B3;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X15.out == (dut.HW.REGISTER_BANK.X3.out - dut.HW.REGISTER_BANK.X2.out));

        /*
        TEST 27

        XOR X13, X1, X9
        0x0090C6B3
        */
        Instruction = 32'h0090C6B3;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X13.out == (dut.HW.REGISTER_BANK.X1.out ^ dut.HW.REGISTER_BANK.X9.out));

        /*
        TEST 28

        OR X11, X4, X25
        0x019265b3
        */
        Instruction = 32'h019265B3;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X11.out == (dut.HW.REGISTER_BANK.X4.out | dut.HW.REGISTER_BANK.X25.out));

        /*
        TEST 29

        AND X30, X20, X9
        0x009a7f33
        */
        Instruction = 32'h009A7F33;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X30.out == (dut.HW.REGISTER_BANK.X20.out & dut.HW.REGISTER_BANK.X9.out));

        /*
        TEST 30

        SLL X26, X9, X2
        0x00249d33
        */
        Instruction = 32'h00249D33;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X26.out == (dut.HW.REGISTER_BANK.X9.out << dut.HW.REGISTER_BANK.X2.out));

        /*
        TEST 31

        SRL X8, X17, X6
        0x0068d433
        */
        Instruction = 32'h0068d433;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X8.out == (dut.HW.REGISTER_BANK.X17.out >> dut.HW.REGISTER_BANK.X6.out));

        /*
        TEST 31

        SRA X22, X12, X2
        0x40265b33
        */
        Instruction = 32'h40265B33;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X22.out == (dut.HW.REGISTER_BANK.X12.out >>> dut.HW.REGISTER_BANK.X2.out));

        /*
        TEST 32

        SRL X22, X12, X2
        0x00265b33
        */
        Instruction = 32'h00265B33;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X22.out == (dut.HW.REGISTER_BANK.X12.out >> dut.HW.REGISTER_BANK.X2.out));

        /*
        TEST 33

        ADDI X5, X0, 7
        0x00700293
        */
        Instruction = 32'h00700293;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X5.out == (32'd7));

        /*
        TEST 34

        ADDI X6, X0, -8
        0xff800313
        */
        Instruction = 32'hFF800313;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X6.out == (32'h0 - 32'd8));

        /*
        TEST 35

        SLT X7, X5, X6
        0x0062a3b3
        */
        Instruction = 32'h0062A3B3;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X7.out == (32'h0));

        /*
        TEST 36

        SLTU X7, X5, X6
        0x0062B3B3
        */
        Instruction = 32'h0062B3B3;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X7.out == (32'h1));


    

        /*
        TEST 37

        LBU X4, 0(X2) // immediate is in decimal form
        0x00014203
        */
        DataBus_In = 32'hFFFFFFFF;
        Instruction = 32'h00014203; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X4.out == ({{24{1'b0}}, DataBus_In[7:0]}));
        #2;

        /*
        TEST 38

        LB X4, 0(X2) // immediate is in decimal form
        0x00014203
        */
        DataBus_In = 32'hFFFFFFFF;
        Instruction = 32'h00010203; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X4.out == ({{24{DataBus_In[7]}}, DataBus_In[7:0]}));
        #2;

        /*
        TEST 39

        LHU X4, 0(X2) // immediate is in decimal form
        0x00015203
        */
        DataBus_In = 32'hFFFFFFFF;
        Instruction = 32'h00015203; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X4.out == ({{16{1'b0}}, DataBus_In[15:0]}));
        #2;

        /*
        TEST 40

        LH X4, 0(X2) // immediate is in decimal form
        0x00011203
        */
        DataBus_In = 32'hFFFFFFFF;
        Instruction = 32'h00011203; #2;
        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X4.out == ({{16{DataBus_In[15]}}, DataBus_In[15:0]}));
        #2;

        /*
        TEST 41

        ADD X11, X0 X0 // assert that X0 is hardwired to zero 
        0x000005B3
        */
        Instruction = 32'h000005B3;

        wait(Address == i);
        i = i + 4;
        assert(dut.HW.REGISTER_BANK.X11.out == (32'h0));
        #2;

        /*
        TEST 42

        SW X5, 0(X9) 
        0x0054a023
        */
        Instruction = 32'h0054A023;
        
        address_dummy = dut.HW.REGISTER_BANK.X9.out;
        wait(Address == i);
        i = i + 4;
        assert(DataBus_Out == (dut.HW.REGISTER_BANK.X5.out));
        assert(address_dummy == (dut.HW.REGISTER_BANK.X9.out));
        assert(Byte_Enable == 4'b1111);
        #2;

        /*
        TEST 43

        SH X6, 0(X13) 
        0x00669023
        */
        Instruction = 32'h00669023;
        address_dummy = dut.HW.REGISTER_BANK.X13.out;
        wait(Address == i);
        i = i + 4;
        assert(DataBus_Out == (dut.HW.REGISTER_BANK.X6.out));
        assert(address_dummy == (dut.HW.REGISTER_BANK.X13.out));
        assert(Byte_Enable == 4'b0000); // cannot store half-word at address offset = 3, thus byte enable should be disabled
        #2;

        /*
        TEST 44

        SB X31, 0(X13) 
        0x01f68023
        */
        Instruction = 32'h01F68023;
        address_dummy = dut.HW.REGISTER_BANK.X13.out;
        wait(Address == i);
        i = i + 4;
        assert(DataBus_Out == (dut.HW.REGISTER_BANK.X31.out));
        assert(address_dummy == (dut.HW.REGISTER_BANK.X13.out));
        assert(Byte_Enable == 4'b1000);
        #2;


        if (!error) begin
            $display("No errors thrown!");
        end else begin
            $display("Error(s) thrown.");
        end

        $stop;
    end 
endmodule: tb_cpu