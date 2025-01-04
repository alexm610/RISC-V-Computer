onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 40 DUT
add wave -noupdate /tb_top_level/dut/CLOCK_50
add wave -noupdate {/tb_top_level/dut/KEY[3]}
add wave -noupdate -radix hexadecimal /tb_top_level/SW
add wave -noupdate -radix hexadecimal /tb_top_level/LEDR
add wave -noupdate -divider -height 40 PROCESSOR
add wave -noupdate /tb_top_level/dut/PROCESSOR/clk
add wave -noupdate /tb_top_level/dut/PROCESSOR/rst_n
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/instruction
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/PC_out
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/PC_in
add wave -noupdate /tb_top_level/dut/PROCESSOR/PC_en
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/readdata
add wave -noupdate /tb_top_level/dut/PROCESSOR/read_valid
add wave -noupdate /tb_top_level/dut/PROCESSOR/byte_enable
add wave -noupdate /tb_top_level/dut/PROCESSOR/data_memory_write
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/RS2_readdata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/data_memory_address
add wave -noupdate /tb_top_level/dut/PROCESSOR/data_memory_read
add wave -noupdate /tb_top_level/dut/PROCESSOR/reg_bank_write
add wave -noupdate /tb_top_level/dut/PROCESSOR/alu_SRC
add wave -noupdate /tb_top_level/dut/PROCESSOR/negative
add wave -noupdate /tb_top_level/dut/PROCESSOR/overflow
add wave -noupdate /tb_top_level/dut/PROCESSOR/zero
add wave -noupdate /tb_top_level/dut/PROCESSOR/mem_or_reg
add wave -noupdate /tb_top_level/dut/PROCESSOR/jump_link
add wave -noupdate /tb_top_level/dut/PROCESSOR/load_upper_imm
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/funct3
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/alu_OP
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/PC_mux
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rs1
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rs2
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rd0
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/opcode
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/funct7
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm_I_TYPE
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm_S_TYPE
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm_B_TYPE
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm_U_TYPE
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm_J_TYPE
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/datapath_out
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/imm
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/datapath_in
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/readdata_mux
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/rs2_output
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/shift_amount
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/loaded_data_shifted
add wave -noupdate -radix hexadecimal /tb_top_level/dut/PROCESSOR/RS2_temp
add wave -noupdate {/tb_top_level/dut/PROCESSOR/conduit[0]}
add wave -noupdate /tb_top_level/dut/PROCESSOR/state
add wave -noupdate -divider -height 40 INTERCONNECT
add wave -noupdate /tb_top_level/dut/FABRIC/slave_ready
add wave -noupdate -radix hexadecimal /tb_top_level/dut/FABRIC/slave_address
add wave -noupdate /tb_top_level/dut/FABRIC/slave_read
add wave -noupdate /tb_top_level/dut/FABRIC/slave_write
add wave -noupdate -radix hexadecimal /tb_top_level/dut/FABRIC/slave_writedata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/FABRIC/slave_readdata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/FABRIC/master_enable
add wave -noupdate -radix hexadecimal /tb_top_level/dut/FABRIC/master_address
add wave -noupdate /tb_top_level/dut/FABRIC/master_read
add wave -noupdate /tb_top_level/dut/FABRIC/master_write
add wave -noupdate -radix hexadecimal /tb_top_level/dut/FABRIC/master_writedata
add wave -noupdate -radix hexadecimal -childformat {{{/tb_top_level/dut/FABRIC/master_readdata[0]} -radix hexadecimal} {{/tb_top_level/dut/FABRIC/master_readdata[1]} -radix hexadecimal} {{/tb_top_level/dut/FABRIC/master_readdata[2]} -radix hexadecimal}} -subitemconfig {{/tb_top_level/dut/FABRIC/master_readdata[0]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/FABRIC/master_readdata[1]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/FABRIC/master_readdata[2]} {-height 15 -radix hexadecimal}} /tb_top_level/dut/FABRIC/master_readdata
add wave -noupdate -radix binary /tb_top_level/dut/FABRIC/slave_module
add wave -noupdate /tb_top_level/dut/FABRIC/write_enabled
add wave -noupdate /tb_top_level/dut/FABRIC/read_enabled
add wave -noupdate /tb_top_level/dut/FABRIC/state
add wave -noupdate -divider -height 40 {INSTRUCTION MEMORY}
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/address
add wave -noupdate /tb_top_level/dut/INSTRUCTION_MEM/byteena
add wave -noupdate /tb_top_level/dut/INSTRUCTION_MEM/clock
add wave -noupdate /tb_top_level/dut/INSTRUCTION_MEM/wren
add wave -noupdate -radix hexadecimal /tb_top_level/dut/INSTRUCTION_MEM/q
add wave -noupdate -divider -height 40 {DATA MEMORY}
add wave -noupdate -radix hexadecimal /tb_top_level/dut/DATA_MEM/address
add wave -noupdate /tb_top_level/dut/DATA_MEM/byteena
add wave -noupdate /tb_top_level/dut/DATA_MEM/clock
add wave -noupdate -radix hexadecimal -childformat {{{/tb_top_level/dut/DATA_MEM/data[31]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[30]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[29]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[28]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[27]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[26]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[25]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[24]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[23]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[22]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[21]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[20]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[19]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[18]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[17]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[16]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[15]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[14]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[13]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[12]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[11]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[10]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[9]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[8]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[7]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[6]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[5]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[4]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[3]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[2]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[1]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/data[0]} -radix hexadecimal}} -subitemconfig {{/tb_top_level/dut/DATA_MEM/data[31]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[30]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[29]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[28]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[27]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[26]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[25]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[24]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[23]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[22]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[21]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[20]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[19]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[18]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[17]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[16]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[15]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[14]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[13]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[12]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[11]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[10]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[9]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[8]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[7]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[6]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[5]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[4]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[3]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[2]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[1]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/data[0]} {-height 15 -radix hexadecimal}} /tb_top_level/dut/DATA_MEM/data
add wave -noupdate /tb_top_level/dut/DATA_MEM/wren
add wave -noupdate -radix hexadecimal -childformat {{{/tb_top_level/dut/DATA_MEM/q[31]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[30]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[29]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[28]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[27]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[26]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[25]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[24]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[23]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[22]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[21]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[20]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[19]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[18]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[17]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[16]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[15]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[14]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[13]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[12]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[11]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[10]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[9]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[8]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[7]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[6]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[5]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[4]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[3]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[2]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[1]} -radix hexadecimal} {{/tb_top_level/dut/DATA_MEM/q[0]} -radix hexadecimal}} -subitemconfig {{/tb_top_level/dut/DATA_MEM/q[31]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[30]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[29]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[28]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[27]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[26]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[25]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[24]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[23]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[22]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[21]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[20]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[19]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[18]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[17]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[16]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[15]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[14]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[13]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[12]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[11]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[10]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[9]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[8]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[7]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[6]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[5]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[4]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[3]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[2]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[1]} {-height 15 -radix hexadecimal} {/tb_top_level/dut/DATA_MEM/q[0]} {-height 15 -radix hexadecimal}} /tb_top_level/dut/DATA_MEM/q
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
add wave -noupdate -divider -height 40 SWITCHES
add wave -noupdate -radix hexadecimal /tb_top_level/dut/SWITCHES/switch_input
add wave -noupdate -radix hexadecimal /tb_top_level/dut/SWITCHES/switch_output
add wave -noupdate -divider -height 40 LIGHTS
add wave -noupdate /tb_top_level/dut/LIGHTS/write
add wave -noupdate -radix hexadecimal /tb_top_level/dut/LIGHTS/writedata
add wave -noupdate -radix hexadecimal /tb_top_level/dut/LIGHTS/ledr_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {649 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 366
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
WaveRestoreZoom {794 ps} {824 ps}
