onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 40 DUT
add wave -noupdate /tb_top_level/dut/CLOCK_50
add wave -noupdate {/tb_top_level/dut/KEY[3]}
add wave -noupdate -divider -height 40 PROCESSOR
add wave -noupdate /tb_top_level/dut/PROCESSOR/rst_n
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/instruction
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/readdata
add wave -noupdate /tb_top_level/dut/PROCESSOR/data_memory_write
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/RS2_readdata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/data_memory_address
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/PC_out
add wave -noupdate /tb_top_level/dut/PROCESSOR/reg_bank_write
add wave -noupdate /tb_top_level/dut/PROCESSOR/PC_en
add wave -noupdate /tb_top_level/dut/PROCESSOR/alu_SRC
add wave -noupdate /tb_top_level/dut/PROCESSOR/mem_or_reg
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/funct3
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/alu_OP
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rs1
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rs2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rd0
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/opcode
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/funct7
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm_I_TYPE
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm_S_TYPE
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/datapath_out
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/PC_in
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/datapath_in
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/readdata_mux
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rs2_output
add wave -noupdate /tb_top_level/dut/PROCESSOR/state
add wave -noupdate -divider -height 40 {INSTRUCTION MEMORY}
add wave -noupdate /tb_top_level/dut/INSTRUCTION_MEM/reset_n
add wave -noupdate /tb_top_level/dut/INSTRUCTION_MEM/write
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/address
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/writedata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/readbyte
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/readword
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/word_address
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/word
add wave -noupdate -childformat {{{/tb_top_level/dut/INSTRUCTION_MEM/memory[0]} -radix hexadecimal} {{/tb_top_level/dut/INSTRUCTION_MEM/memory[1]} -radix hexadecimal} {{/tb_top_level/dut/INSTRUCTION_MEM/memory[2]} -radix hexadecimal}} -subitemconfig {{/tb_top_level/dut/INSTRUCTION_MEM/memory[0]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/INSTRUCTION_MEM/memory[1]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/INSTRUCTION_MEM/memory[2]} {-height 15 -radix hexadecimal}} /tb_top_level/dut/INSTRUCTION_MEM/memory
add wave -noupdate -divider -height 40 {DATA MEMORY}
add wave -noupdate /tb_top_level/dut/DATA_MEM/write
add wave -noupdate /tb_top_level/dut/DATA_MEM/address
add wave -noupdate /tb_top_level/dut/DATA_MEM/writedata
add wave -noupdate /tb_top_level/dut/DATA_MEM/readbyte
add wave -noupdate /tb_top_level/dut/DATA_MEM/readword
add wave -noupdate /tb_top_level/dut/DATA_MEM/word_address
add wave -noupdate /tb_top_level/dut/DATA_MEM/byte0
add wave -noupdate /tb_top_level/dut/DATA_MEM/byte1
add wave -noupdate /tb_top_level/dut/DATA_MEM/byte2
add wave -noupdate /tb_top_level/dut/DATA_MEM/byte3
add wave -noupdate /tb_top_level/dut/DATA_MEM/word
add wave -noupdate /tb_top_level/dut/DATA_MEM/memory
add wave -noupdate -divider -height 40 DATAPATH
add wave -noupdate /tb_top_level/dut/PROCESSOR/HW/rst_n
add wave -noupdate /tb_top_level/dut/PROCESSOR/HW/write_rb
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/alu_source
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/alu_control
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/rs_1
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/rs_2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/rd_0
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/writedata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/immediate
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/negative
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/overflow
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/zero
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/alu_result
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/rs2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/A_in
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/B_in
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/rs_2_out
add wave -noupdate -divider -height 40 REGISTERS
add wave -noupdate /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/reset_n
add wave -noupdate /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/write
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/rs1
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/rs2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/rd
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/writedata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/readdata_1
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/readdata_2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/addr_1
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/addr_2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/addr_d
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x0
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x1
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x3
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x4
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x5
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x6
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x7
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x8
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x9
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x10
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x11
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x12
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x13
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x14
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x15
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x16
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x17
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x18
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x19
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x20
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x21
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x22
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x23
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x24
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x25
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x26
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x27
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x28
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x29
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x30
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/REGISTER_BANK/x31
add wave -noupdate -divider -height 40 ALU
add wave -noupdate /tb_top_level/dut/PROCESSOR/HW/ALU/ALUsrc
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/ALUop
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/Ain
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/Bin
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/status
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/out
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/shamt
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/dummy_output
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/HW/ALU/overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {159 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 470
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
WaveRestoreZoom {138 ps} {182 ps}
