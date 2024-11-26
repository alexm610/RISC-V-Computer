onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 40 CPU
add wave -noupdate /tb_cpu/dut/clk
add wave -noupdate /tb_cpu/dut/rst_n
add wave -noupdate -radix hexadecimal /tb_cpu/dut/instruction
add wave -noupdate -radix hexadecimal /tb_cpu/dut/readdata
add wave -noupdate -radix hexadecimal /tb_cpu/dut/data_memory_write
add wave -noupdate -radix hexadecimal /tb_cpu/dut/conduit
add wave -noupdate -radix hexadecimal -childformat {{{/tb_cpu/dut/RS2_readdata[31]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[30]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[29]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[28]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[27]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[26]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[25]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[24]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[23]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[22]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[21]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[20]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[19]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[18]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[17]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[16]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[15]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[14]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[13]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[12]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[11]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[10]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[9]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[8]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[7]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[6]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[5]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[4]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[3]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[2]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[1]} -radix hexadecimal} {{/tb_cpu/dut/RS2_readdata[0]} -radix hexadecimal}} -subitemconfig {{/tb_cpu/dut/RS2_readdata[31]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[30]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[29]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[28]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[27]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[26]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[25]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[24]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[23]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[22]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[21]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[20]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[19]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[18]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[17]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[16]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[15]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[14]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[13]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[12]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[11]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[10]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[9]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[8]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[7]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[6]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[5]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[4]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[3]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[2]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[1]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/RS2_readdata[0]} {-height 15 -radix hexadecimal}} /tb_cpu/dut/RS2_readdata
add wave -noupdate -radix hexadecimal /tb_cpu/dut/rs2_output
add wave -noupdate -radix hexadecimal -childformat {{{/tb_cpu/dut/data_memory_address[9]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[8]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[7]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[6]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[5]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[4]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[3]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[2]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[1]} -radix hexadecimal} {{/tb_cpu/dut/data_memory_address[0]} -radix hexadecimal}} -subitemconfig {{/tb_cpu/dut/data_memory_address[9]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[8]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[7]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[6]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[5]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[4]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[3]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[2]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[1]} {-height 15 -radix hexadecimal} {/tb_cpu/dut/data_memory_address[0]} {-height 15 -radix hexadecimal}} /tb_cpu/dut/data_memory_address
add wave -noupdate -radix hexadecimal /tb_cpu/dut/PC_out
add wave -noupdate /tb_cpu/dut/reg_bank_write
add wave -noupdate /tb_cpu/dut/PC_en
add wave -noupdate /tb_cpu/dut/alu_SRC
add wave -noupdate /tb_cpu/dut/negative
add wave -noupdate /tb_cpu/dut/overflow
add wave -noupdate /tb_cpu/dut/zero
add wave -noupdate /tb_cpu/dut/mem_or_reg
add wave -noupdate /tb_cpu/dut/alu_OP
add wave -noupdate /tb_cpu/dut/funct3
add wave -noupdate /tb_cpu/dut/rs1
add wave -noupdate /tb_cpu/dut/rs2
add wave -noupdate /tb_cpu/dut/rd0
add wave -noupdate /tb_cpu/dut/opcode
add wave -noupdate /tb_cpu/dut/funct7
add wave -noupdate /tb_cpu/dut/imm_I_TYPE
add wave -noupdate /tb_cpu/dut/imm_S_TYPE
add wave -noupdate -radix hexadecimal /tb_cpu/dut/datapath_out
add wave -noupdate -radix hexadecimal /tb_cpu/dut/PC_in
add wave -noupdate -radix hexadecimal /tb_cpu/dut/imm
add wave -noupdate -radix hexadecimal /tb_cpu/dut/datapath_in
add wave -noupdate /tb_cpu/dut/state
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
add wave -noupdate -divider -height 40 PC
add wave -noupdate /tb_cpu/dut/PC/enable
add wave -noupdate -radix hexadecimal /tb_cpu/dut/PC/in
add wave -noupdate -radix hexadecimal /tb_cpu/dut/PC/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {455 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
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
WaveRestoreZoom {432 ps} {464 ps}
