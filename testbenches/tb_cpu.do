onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 40 CPU
add wave -noupdate /tb_cpu/dut/Clock
add wave -noupdate /tb_cpu/dut/Reset_L
add wave -noupdate /tb_cpu/dut/DTAck
add wave -noupdate /tb_cpu/dut/Instruction
add wave -noupdate /tb_cpu/dut/DataBus_In
add wave -noupdate /tb_cpu/dut/AS_L
add wave -noupdate /tb_cpu/dut/Byte_Enable
add wave -noupdate /tb_cpu/dut/WE_L
add wave -noupdate /tb_cpu/dut/DataBus_Out
add wave -noupdate /tb_cpu/dut/Address
add wave -noupdate /tb_cpu/dut/Conduit
add wave -noupdate /tb_cpu/dut/Reset_Out
add wave -noupdate /tb_cpu/dut/State
add wave -noupdate /tb_cpu/dut/mem_or_reg
add wave -noupdate /tb_cpu/dut/jump_link
add wave -noupdate /tb_cpu/dut/load_upper_imm
add wave -noupdate /tb_cpu/dut/funct3
add wave -noupdate /tb_cpu/dut/funct7
add wave -noupdate /tb_cpu/dut/opcode
add wave -noupdate /tb_cpu/dut/imm_I_TYPE
add wave -noupdate /tb_cpu/dut/imm_S_TYPE
add wave -noupdate /tb_cpu/dut/imm_B_TYPE
add wave -noupdate /tb_cpu/dut/imm_U_TYPE
add wave -noupdate /tb_cpu/dut/imm_J_TYPE
add wave -noupdate /tb_cpu/dut/datapath_in
add wave -noupdate /tb_cpu/dut/Program_Counter
add wave -noupdate /tb_cpu/dut/Current_Instruction
add wave -noupdate /tb_cpu/dut/reg_bank_write
add wave -noupdate /tb_cpu/dut/alu_SRC
add wave -noupdate /tb_cpu/dut/negative
add wave -noupdate /tb_cpu/dut/overflow
add wave -noupdate /tb_cpu/dut/zero
add wave -noupdate /tb_cpu/dut/alu_OP
add wave -noupdate /tb_cpu/dut/rs1
add wave -noupdate /tb_cpu/dut/rs2
add wave -noupdate /tb_cpu/dut/rd0
add wave -noupdate /tb_cpu/dut/writedata
add wave -noupdate /tb_cpu/dut/datapath_out
add wave -noupdate /tb_cpu/dut/imm
add wave -noupdate /tb_cpu/dut/rs2_output
add wave -noupdate -divider -height 40 DATAPATH
add wave -noupdate /tb_cpu/dut/HW/write_rb
add wave -noupdate /tb_cpu/dut/HW/alu_source
add wave -noupdate /tb_cpu/dut/HW/alu_control
add wave -noupdate /tb_cpu/dut/HW/rs_1
add wave -noupdate /tb_cpu/dut/HW/rs_2
add wave -noupdate /tb_cpu/dut/HW/rd_0
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/writedata
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/immediate
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/alu_result
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/A_in
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/B_in
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/rs_2_out
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/rs2
add wave -noupdate -divider -height 40 REG_FILE
add wave -noupdate /tb_cpu/dut/HW/REGISTER_BANK/write
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/rs1
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/rs2
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/rd
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/writedata
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/readdata_1
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/readdata_2
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/addr_1
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/addr_2
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/addr_d
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x0
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x1
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x2
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x3
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x4
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x5
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x6
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x7
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x8
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x9
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x10
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x11
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x12
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x13
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x14
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x15
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x16
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x17
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x18
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x19
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x20
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x21
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x22
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x23
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x24
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x25
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x26
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x27
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x28
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x29
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x30
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/REGISTER_BANK/x31
add wave -noupdate -divider -height 40 ALU
add wave -noupdate /tb_cpu/dut/HW/ALU/ALUop
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/ALU/Ain
add wave -noupdate -radix decimal /tb_cpu/dut/HW/ALU/Bin
add wave -noupdate /tb_cpu/dut/HW/ALU/status
add wave -noupdate -radix hexadecimal /tb_cpu/dut/HW/ALU/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {458 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 274
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {468 ps} {485 ps}
