`timescale 1ns/1ps

// Exercises the real CPU, address decoder, read mux and 32-to-16-bit SDRAM
// bridge. Only the low-level SDRAM controller is replaced by a delayed model.
module tb_ram_exec;
    logic Clock = 0, Reset_L = 0, IRQ_Timer_H = 0;
    wire AS_L, WE_L, DTAck, ram_ack;
    wire [3:0] Byte_Enable;
    wire [31:0] Address, DataBus_Out, data_in, ram_data;
    wire rom_select, ram_select, io_select;
    logic [31:0] rom_data;
    logic [7:0] rom [0:8191];
    string image_path;
    integer ram_fetches = 0, rom_fetches = 0, irq_entries = 0;
    integer ram_data_reads = 0, ram_writes = 0;
    logic active = 0, request_fetch, request_we;
    logic [31:0] request_address, request_data, request_pc, request_instruction;
    logic [3:0] request_be;
    logic fetch_pending = 0;
    logic [31:0] fetched_word;
    wire [15:0] dram_dq;
    integer irq_arm_case = 0, irq_probe_case = 0;
    integer irq_handler_waits = 0;
    logic [5:0] irq_writeback_coverage = 0;
    logic irq_probe = 0, irq_before_handler = 0, irq_return_pending = 0;
    logic [31:0] irq_armed_target, irq_retired_value, irq_resume_pc, irq_expected_count;

    function automatic logic irq_target_instruction(input integer test_case,
                                                     input logic [31:0] instruction);
        case (test_case)
            1: irq_target_instruction = instruction[6:0] == 7'h13;
            2: irq_target_instruction = instruction[6:0] == 7'h37;
            3: irq_target_instruction = instruction[6:0] == 7'h6f;
            4: irq_target_instruction = instruction[6:0] == 7'h67;
            5: irq_target_instruction = instruction[6:0] == 7'h73;
            6: irq_target_instruction = instruction[6:0] == 7'h03;
            default: irq_target_instruction = 0;
        endcase
    endfunction

    always #10 Clock = ~Clock;
    assign DTAck = ram_select ? ram_ack : 1'b1;

    cpu dut (
        .Clock(Clock), .Reset_L(Reset_L), .DTAck(DTAck),
        .IRQ_Timer_H(IRQ_Timer_H), .IRQ_UART_H(1'b0),
        .Instruction(data_in), .DataBus_In(data_in),
        .AS_L(AS_L), .WE_L(WE_L), .Byte_Enable(Byte_Enable),
        .Address(Address), .DataBus_Out(DataBus_Out),
        .Conduit(), .Reset_Out()
    );

    address_decoder decode (
        .Address(Address), .ROM_Select_H(rom_select),
        .RAM_Select_H(ram_select), .IO_Select_H(io_select),
        .Graphics_Select_H(), .Keyboard_Select_H(), .UART_Select_H(),
        .ExpAccel_Select_H(), .I2CSPI_Select_H(),
        .AudioI2S_Select_H(), .AudioI2C_Select_H()
    );

    data_bus_multiplexer mux (
        .Select_SRAM(ram_select), .Select_ROM(rom_select), .Select_IO(io_select),
        .Select_KEYBOARD(1'b0), .Select_UART(1'b0), .Select_EXP(1'b0),
        .Select_I2CSPI(1'b0), .Select_AudioI2S(1'b0),
        .Select_AudioI2C(1'b0), .Select_VGA(1'b0),
        .DataIn_SRAM(ram_data), .DataIn_ROM(rom_data), .DataIn_IO(32'h0),
        .DataIn_KEYBOARD(32'h0), .DataIn_UART(32'h0), .DataIn_EXP(32'h0),
        .DataIn_I2CSPI(32'h0), .DataIn_AudioI2S(32'h0),
        .DataIn_AudioI2C(32'h0), .DataIn_VGA(32'h0), .DataOut_CPU(data_in)
    );

    sdram_mmu bridge (
        .Clock(Clock), .Reset_L(Reset_L), .RamSelect_H(ram_select),
        .AS_L(AS_L), .WE_L(WE_L), .Address(Address),
        .ByteEnable(Byte_Enable), .DataIn(DataBus_Out),
        .DataOut(ram_data), .DTAck_H(ram_ack), .ResetOut_L(),
        .fb_req(1'b0), .fb_addr(32'h0), .fb_len(10'h0),
        .fb_data(), .fb_valid(), .fb_done(),
        .SDRAM_CKE(), .SDRAM_CS_N(), .SDRAM_RAS_N(), .SDRAM_CAS_N(),
        .SDRAM_WE_N(), .SDRAM_ADDR(), .SDRAM_BA(), .SDRAM_DQ(dram_dq),
        .SDRAM_UDQM(), .SDRAM_LDQM()
    );

    // Match the on-chip ROM's falling-edge clock, without Altera primitives.
    always @(negedge Clock) begin
        if (rom_select && Address < 8192)
            rom_data <= {rom[{Address[12:2], 2'b11}],
                         rom[{Address[12:2], 2'b10}],
                         rom[{Address[12:2], 2'b01}],
                         rom[{Address[12:2], 2'b00}]};
        else
            rom_data <= 32'hxxxxxxxx;
    end

    // Inject before the retirement edge, then check architectural state while
    // interrupt entry and the delayed RAM-vector fetch are in progress.
    always @(negedge Clock) begin
        if (Reset_L) begin
            if (irq_probe) begin
                if (dut.HW.REGISTER_BANK.x19 !== irq_retired_value)
                    $fatal(1, "IRQ case %0d changed retired s3: expected=%h actual=%h",
                           irq_probe_case, irq_retired_value, dut.HW.REGISTER_BANK.x19);

                if (irq_before_handler && dut.State == dut.LATCH_INSTRUCTION) begin
                    if (dut.Program_Counter !== {dut.MTVEC_BASE, 2'b00} ||
                        dut.MEPC !== irq_resume_pc)
                        $fatal(1, "IRQ case %0d saved wrong return PC or fetched wrong vector",
                               irq_probe_case);
                    if (dut.reg_bank_write !== 0 || dut.load_upper_imm !== 0 ||
                        dut.jump_link !== 0 || dut.CSR_process !== 0 || dut.mem_or_reg !== 0)
                        $fatal(1, "IRQ case %0d retained instruction controls during vector fetch",
                               irq_probe_case);
                    if (!DTAck) irq_handler_waits = irq_handler_waits + 1;
                end
                if (irq_before_handler && dut.State == dut.START &&
                    dut.Program_Counter == {dut.MTVEC_BASE, 2'b00})
                    irq_before_handler = 0;

                if (irq_return_pending) begin
                    if (dut.State != dut.INCREMENT_PC || dut.Program_Counter !== irq_resume_pc ||
                        dut.HW.REGISTER_BANK.x18 !== irq_expected_count)
                        $fatal(1, "IRQ case %0d failed to resume once after running the ISR",
                               irq_probe_case);
                    irq_writeback_coverage[irq_probe_case - 1] = 1;
                    irq_probe = 0;
                    irq_return_pending = 0;
                end else if (!irq_before_handler && dut.State == dut.MRET_2) begin
                    irq_return_pending = 1;
                end
            end

            if (irq_arm_case != 0 && dut.State == dut.COMPLETE &&
                irq_target_instruction(irq_arm_case, dut.Current_Instruction)) begin
                if (!dut.MIE || IRQ_Timer_H || dut.rd0 != 19)
                    $fatal(1, "Invalid IRQ retirement injection for case %0d", irq_arm_case);
                irq_probe_case = irq_arm_case;
                irq_resume_pc = dut.Program_Counter + 4;
                case (irq_arm_case)
                    1: irq_retired_value = 32'd10;
                    2: irq_retired_value = 32'h12345000;
                    3: begin
                        irq_retired_value = dut.Program_Counter + 4;
                        irq_resume_pc = dut.Program_Counter +
                            {{11{dut.Current_Instruction[31]}}, dut.Current_Instruction[31],
                             dut.Current_Instruction[19:12], dut.Current_Instruction[20],
                             dut.Current_Instruction[30:21], 1'b0};
                    end
                    4: begin
                        irq_retired_value = dut.Program_Counter + 4;
                        irq_resume_pc = {irq_armed_target[31:1], 1'b0};
                    end
                    5: irq_retired_value = 32'd128;
                    6: irq_retired_value = 32'h51a7c0de;
                endcase
                irq_expected_count = dut.HW.REGISTER_BANK.x18 + 1;
                irq_probe = 1;
                irq_before_handler = 1;
                irq_arm_case = 0;
                IRQ_Timer_H <= 1;
            end
        end
    end

    initial begin
        if (!$value$plusargs("image=%s", image_path))
            $fatal(1, "Missing +image=ROM_HEX");
        $readmemh(image_path, rom);
        repeat (4) @(negedge Clock);
        Reset_L = 1;
        repeat (100000) @(posedge Clock);
        $fatal(1, "Timeout at PC=%h state=%0d IRQ entries=%0d s2=%h mie=%h mstatus=%h",
               dut.Program_Counter, dut.State, irq_entries,
               dut.HW.REGISTER_BANK.x18, dut.CSR.mie, dut.CSR.mstatus);
    end

    // Sample before CPU nonblocking updates. An AS_L-high edge is mandatory
    // between requests, just as in the real SDRAM bridge's DONE state.
    always @(posedge Clock) begin
        if (Reset_L) begin
            if (fetch_pending) begin
                if (dut.Current_Instruction !== fetched_word)
                    $fatal(1, "Instruction was not latched from acknowledged read");
                if (AS_L !== 1'b1)
                    $fatal(1, "Fetch did not release AS_L after acknowledgement");
                fetch_pending = 0;
            end
            if (AS_L) begin
                active = 0;
            end else begin
                if (!active) begin
                    active = 1;
                    request_address = Address;
                    request_we = WE_L;
                    request_be = Byte_Enable;
                    request_data = DataBus_Out;
                    request_fetch = dut.instruction_fetch;
                    request_pc = dut.Program_Counter;
                    request_instruction = dut.Current_Instruction;
                    if (request_fetch) begin
                        if (WE_L !== 1'b1 || Byte_Enable !== 4'b1111 ||
                            Address[1:0] !== 2'b00)
                            $fatal(1, "Fetch must be an aligned full-word read");
                        if (ram_select) ram_fetches = ram_fetches + 1;
                        else if (rom_select) rom_fetches = rom_fetches + 1;
                        else $fatal(1, "Fetch outside ROM/RAM: %h", Address);
                    end else if (ram_select) begin
                        if (WE_L) ram_data_reads = ram_data_reads + 1;
                        else ram_writes = ram_writes + 1;
                    end
                    if (io_select && !WE_L) begin
                        if (Address == 32'h00400004) begin
                            IRQ_Timer_H <= 1;
                        end
                        if (Address == 32'h00400008) begin
                            if (irq_probe || irq_arm_case != 0 ||
                                DataBus_Out < 1 || DataBus_Out > 6)
                                $fatal(1, "Invalid IRQ test marker: %h", DataBus_Out);
                            irq_arm_case = DataBus_Out;
                            irq_armed_target = dut.HW.REGISTER_BANK.x19;
                        end
                        if (Address == 32'h00400000) begin
                            if (DataBus_Out !== 32'h600d)
                                $fatal(1, "Program reported failure: %h", DataBus_Out);
                            if (ram_fetches < 30 || rom_fetches < 30 ||
                                ram_data_reads < 7 || ram_writes < 11 || irq_entries != 8 ||
                                irq_writeback_coverage != 6'b111111 || irq_handler_waits == 0)
                                $fatal(1, "Missing execution/interrupt coverage");
                            $display("PASS: ROM copy -> RAM execution -> ROM return; byte/half/word data, ROM/RAM IRQ + mret; six retirement IRQ cases, vector wait clocks=%0d; fetches ROM=%0d RAM=%0d",
                                     irq_handler_waits, rom_fetches, ram_fetches);
                            $finish;
                        end
                    end
                end
                if (Address !== request_address || WE_L !== request_we ||
                    Byte_Enable !== request_be || dut.instruction_fetch !== request_fetch)
                    $fatal(1, "Request changed before bus release");
                if (!WE_L && DataBus_Out !== request_data)
                    $fatal(1, "Write data changed before bus release");
                if (request_fetch) begin
                    if (dut.Program_Counter !== request_pc ||
                        dut.Current_Instruction !== request_instruction)
                        $fatal(1, "PC/instruction changed while fetch pending");
                    if (dut.reg_bank_write !== 1'b0)
                        $fatal(1, "Register write remained enabled during fetch");
                    if (DTAck) begin
                        fetched_word = data_in;
                        fetch_pending = 1;
                    end
                end
            end
            // Keep each interrupt asserted until the CPU masks it on entry.
            if (IRQ_Timer_H && !dut.MIE) begin
                IRQ_Timer_H <= 0;
                irq_entries = irq_entries + 1;
            end
        end
    end
endmodule

// Test-only replacement for the pin-level controller. Each 16-bit access has
// variable latency; acknowledgement stays asserted until AS_L is released.
// The real sdram_mmu still handles byte lanes and assembling 32-bit reads.
module M68kDramController_Verilog (
    input Clock, Reset_L, input [31:0] Address, input [15:0] DataIn,
    input UDS_L, LDS_L, DramSelect_L, WE_L, AS_L,
    input BurstReq_H, input [31:0] BurstAddress, input [9:0] BurstLength,
    output [15:0] BurstData, output BurstValid_H, BurstDone_H,
    output reg [15:0] DataOut, output reg Dtack_L,
    output ResetOut_L, SDram_CKE_H, SDram_CS_L, SDram_RAS_L, SDram_CAS_L,
    output SDram_WE_L, output [12:0] SDram_Addr, output [1:0] SDram_BA,
    inout [15:0] SDram_DQ, output [4:0] DramState
);
    reg [7:0] memory [0:8191];
    integer latency = 0, countdown = 0, transactions = 0;
    reg busy = 0;
    reg [31:0] saved_address;
    reg [15:0] saved_data;
    reg saved_we, saved_uds, saved_lds;
    wire [12:0] offset = saved_address[12:0];
    assign ResetOut_L = Reset_L;
    assign BurstData = 0;
    assign BurstValid_H = 0;
    assign BurstDone_H = 0;
    assign {SDram_CKE_H, SDram_CS_L, SDram_RAS_L, SDram_CAS_L, SDram_WE_L} = 5'b01111;
    assign SDram_Addr = 0;
    assign SDram_BA = 0;
    assign SDram_DQ = 16'hzzzz;
    assign DramState = 0;

    initial begin
        if (!$value$plusargs("latency=%d", latency)) latency = 0;
        for (integer i = 0; i < 8192; i = i + 1) memory[i] = 0;
    end

    always @(posedge Clock) begin
        if (!Reset_L) begin
            busy <= 0;
            Dtack_L <= 1;
            DataOut <= 16'hxxxx;
        end else if (busy) begin
            if (AS_L) begin
                if (Dtack_L) $fatal(1, "Controller request abandoned before ack");
                busy <= 0;
                Dtack_L <= 1;
                DataOut <= 16'hxxxx;
            end else begin
                if (Address !== saved_address || WE_L !== saved_we ||
                    UDS_L !== saved_uds || LDS_L !== saved_lds || DramSelect_L)
                    $fatal(1, "16-bit request changed while active");
                if (Dtack_L) begin
                    if (countdown != 0) countdown <= countdown - 1;
                    else begin
                        if (!saved_we) begin
                            if (!saved_lds) memory[offset] <= saved_data[7:0];
                            if (!saved_uds) memory[offset + 1] <= saved_data[15:8];
                        end
                        DataOut <= {memory[offset + 1], memory[offset]};
                        Dtack_L <= 0;
                    end
                end
            end
        end else if (!AS_L && !DramSelect_L) begin
            if (Address < 32'h08000000 || Address >= 32'h08002000 || Address[0])
                $fatal(1, "Unexpected SDRAM address: %h", Address);
            saved_address <= Address;
            saved_data <= DataIn;
            saved_we <= WE_L;
            saved_uds <= UDS_L;
            saved_lds <= LDS_L;
            countdown <= latency + transactions % 4;
            transactions <= transactions + 1;
            busy <= 1;
        end
    end
endmodule
