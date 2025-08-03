onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 40 TOP_LEVEL
add wave -noupdate /tb_risc_v_core/dut/CLOCK_50
add wave -noupdate /tb_risc_v_core/dut/KEY
add wave -noupdate /tb_risc_v_core/dut/SW
add wave -noupdate /tb_risc_v_core/dut/LEDR
add wave -noupdate /tb_risc_v_core/dut/HEX0
add wave -noupdate /tb_risc_v_core/dut/HEX1
add wave -noupdate /tb_risc_v_core/dut/HEX2
add wave -noupdate /tb_risc_v_core/dut/HEX3
add wave -noupdate /tb_risc_v_core/dut/HEX4
add wave -noupdate /tb_risc_v_core/dut/HEX5
add wave -noupdate /tb_risc_v_core/dut/VGA_R
add wave -noupdate /tb_risc_v_core/dut/VGA_G
add wave -noupdate /tb_risc_v_core/dut/VGA_B
add wave -noupdate /tb_risc_v_core/dut/VGA_HS
add wave -noupdate /tb_risc_v_core/dut/VGA_VS
add wave -noupdate /tb_risc_v_core/dut/VGA_CLK
add wave -noupdate /tb_risc_v_core/dut/test_write
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/instruction
add wave -noupdate /tb_risc_v_core/dut/valid
add wave -noupdate /tb_risc_v_core/dut/AS_L
add wave -noupdate /tb_risc_v_core/dut/WE_L
add wave -noupdate /tb_risc_v_core/dut/byte_enable
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/program_counter
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/address
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/dummy_instr_writedata
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/datapath_output
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/data_in
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/data_out
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/SRAM_data_out
add wave -noupdate /tb_risc_v_core/dut/fill_x
add wave -noupdate /tb_risc_v_core/dut/fill_y
add wave -noupdate /tb_risc_v_core/dut/fill_plot
add wave -noupdate /tb_risc_v_core/dut/VGA_R_10
add wave -noupdate /tb_risc_v_core/dut/VGA_G_10
add wave -noupdate /tb_risc_v_core/dut/VGA_B_10
add wave -noupdate /tb_risc_v_core/dut/VGA_BLANK
add wave -noupdate /tb_risc_v_core/dut/VGA_SYNC
add wave -noupdate /tb_risc_v_core/dut/into_vga_colour
add wave -noupdate /tb_risc_v_core/dut/RAM_Select
add wave -noupdate /tb_risc_v_core/dut/IO_Select
add wave -noupdate /tb_risc_v_core/dut/Graphics_Select
add wave -noupdate -divider -height 40 PROCESSOR
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/Clock
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/Reset_L
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/State
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/DTAck
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/Address
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/Instruction
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/Current_Instruction
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/Program_Counter
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/DataBus_In
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/AS_L
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/Byte_Enable
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/WE_L
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/DataBus_Out
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/Conduit
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/Reset_Out
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/mem_or_reg
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/jump_link
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/load_upper_imm
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/instruction_fetch
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/Program_Counter_Increment
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/funct3
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/funct7
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/opcode
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/imm_I_TYPE
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/imm_S_TYPE
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/imm_B_TYPE
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/imm_U_TYPE
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/imm_J_TYPE
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/datapath_in
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/reg_bank_write
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/alu_SRC
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/negative
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/overflow
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/zero
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/alu_OP
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/rs1
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/rs2
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/rd0
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/writedata
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/datapath_out
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/imm
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/rs2_output
add wave -noupdate -divider -height 40 ADDRESS_DECODER
add wave -noupdate -radix hexadecimal -childformat {{{/tb_risc_v_core/dut/AD/Address[31]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[30]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[29]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[28]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[27]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[26]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[25]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[24]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[23]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[22]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[21]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[20]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[19]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[18]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[17]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[16]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[15]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[14]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[13]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[12]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[11]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[10]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[9]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[8]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[7]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[6]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[5]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[4]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[3]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[2]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[1]} -radix hexadecimal} {{/tb_risc_v_core/dut/AD/Address[0]} -radix hexadecimal}} -subitemconfig {{/tb_risc_v_core/dut/AD/Address[31]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[30]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[29]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[28]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[27]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[26]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[25]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[24]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[23]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[22]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[21]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[20]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[19]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[18]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[17]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[16]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[15]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[14]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[13]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[12]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[11]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[10]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[9]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[8]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[7]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[6]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[5]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[4]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[3]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[2]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[1]} {-height 15 -radix hexadecimal} {/tb_risc_v_core/dut/AD/Address[0]} {-height 15 -radix hexadecimal}} /tb_risc_v_core/dut/AD/Address
add wave -noupdate /tb_risc_v_core/dut/AD/RAM_Select_H
add wave -noupdate /tb_risc_v_core/dut/AD/IO_Select_H
add wave -noupdate /tb_risc_v_core/dut/AD/Graphics_Select_H
add wave -noupdate -divider -height 40 IO_HANDLER
add wave -noupdate /tb_risc_v_core/dut/IO/IO_data_out
add wave -noupdate /tb_risc_v_core/dut/IO/Clock
add wave -noupdate /tb_risc_v_core/dut/IO/Reset_L
add wave -noupdate /tb_risc_v_core/dut/IO/RS_pin
add wave -noupdate /tb_risc_v_core/dut/IO/E_pin
add wave -noupdate /tb_risc_v_core/dut/IO/RW_pin
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/LCD_DataOut
add wave -noupdate /tb_risc_v_core/dut/IO/LCD_WriteEnable
add wave -noupdate /tb_risc_v_core/dut/IO/LCD_CommandOrDisplayData
add wave -noupdate /tb_risc_v_core/dut/IO/SW_input
add wave -noupdate /tb_risc_v_core/dut/IO/AS_L
add wave -noupdate /tb_risc_v_core/dut/IO/WE_L
add wave -noupdate /tb_risc_v_core/dut/IO/IO_Select
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/Address
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/IO_data_in
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/LEDR_output
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/IO_data_out
add wave -noupdate /tb_risc_v_core/dut/IO/hex_enable
add wave -noupdate /tb_risc_v_core/dut/IO/ledr_enable
add wave -noupdate /tb_risc_v_core/dut/IO/LEDR_writedata
add wave -noupdate /tb_risc_v_core/dut/IO/IO_writedata
add wave -noupdate -divider -height 40 INSTRUCTION_MEMORY
add wave -noupdate /tb_risc_v_core/dut/INSTRUCTION_MEMORY/RomSelect_H
add wave -noupdate /tb_risc_v_core/dut/INSTRUCTION_MEMORY/Write_Enable
add wave -noupdate /tb_risc_v_core/dut/INSTRUCTION_MEMORY/Address
add wave -noupdate /tb_risc_v_core/dut/INSTRUCTION_MEMORY/DataIn
add wave -noupdate /tb_risc_v_core/dut/INSTRUCTION_MEMORY/DataOut
add wave -noupdate -divider -height 40 SRAM
add wave -noupdate /tb_risc_v_core/dut/SRAM_MEMORY/RamSelect_H
add wave -noupdate /tb_risc_v_core/dut/SRAM_MEMORY/WE_L
add wave -noupdate /tb_risc_v_core/dut/SRAM_MEMORY/AS_L
add wave -noupdate /tb_risc_v_core/dut/SRAM_MEMORY/Address
add wave -noupdate /tb_risc_v_core/dut/SRAM_MEMORY/ByteEnable
add wave -noupdate /tb_risc_v_core/dut/SRAM_MEMORY/DataIn
add wave -noupdate /tb_risc_v_core/dut/SRAM_MEMORY/DataOut
add wave -noupdate -divider -height 40 DATAPATH
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/write_rb
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/alu_source
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/alu_control
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/rs_1
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/rs_2
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/rd_0
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/writedata
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/immediate
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/negative
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/overflow
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/zero
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/alu_result
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/rs2
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/A_in
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/B_in
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/rs_2_out
add wave -noupdate -divider -height 40 REGFILE
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/write
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/rs1
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/rs2
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/rd
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/writedata
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/readdata_1
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/readdata_2
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/addr_1
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/addr_2
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/addr_d
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x0
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x1
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x2
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x3
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x4
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x5
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x6
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x7
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x8
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x9
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x10
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x11
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x12
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x13
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x14
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x15
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x16
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x17
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x18
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x19
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x20
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x21
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x22
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x23
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x24
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x25
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x26
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x27
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x28
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x29
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x30
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/REGISTER_BANK/x31
add wave -noupdate -divider -height 40 ALU
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/ALU/ALUsrc
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/ALU/ALUop
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/ALU/Ain
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/ALU/Bin
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/ALU/status
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/ALU/out
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/ALU/shamt
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/PROCESSOR/HW/ALU/dummy_output
add wave -noupdate /tb_risc_v_core/dut/PROCESSOR/HW/ALU/overflow
add wave -noupdate -divider -height 40 UART_CONTROLLER
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/IOSelect
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/Clk
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/Reset_L
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/Clock_50Mhz
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/UART_CONTROLLER/RS232_RxData
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/UDS_L
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/WE_L
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/AS_L
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/UART_CONTROLLER/Address
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/UART_CONTROLLER/DataIn
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/UART_CONTROLLER/RS232_TxData
add wave -noupdate /tb_risc_v_core/dut/IO/UART_CONTROLLER/ACIA_IRQ
add wave -noupdate -radix hexadecimal /tb_risc_v_core/dut/IO/UART_CONTROLLER/DataOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2778 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 383
configure wave -valuecolwidth 219
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
WaveRestoreZoom {2727 ps} {2783 ps}
