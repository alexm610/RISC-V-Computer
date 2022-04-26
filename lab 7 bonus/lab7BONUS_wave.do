onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL}
add wave -noupdate /lab7bonus_check_tb/DUT/CLOCK_50
add wave -noupdate {/lab7bonus_check_tb/DUT/LEDR[8]}
add wave -noupdate /lab7bonus_check_tb/DUT/data_out_memory
add wave -noupdate /lab7bonus_check_tb/DUT/d_out
add wave -noupdate /lab7bonus_check_tb/DUT/datapath_out
add wave -noupdate /lab7bonus_check_tb/DUT/N
add wave -noupdate /lab7bonus_check_tb/DUT/V
add wave -noupdate /lab7bonus_check_tb/DUT/Z
add wave -noupdate /lab7bonus_check_tb/DUT/halt_signal
add wave -noupdate /lab7bonus_check_tb/DUT/memory_address
add wave -noupdate /lab7bonus_check_tb/DUT/memory_command
add wave -noupdate /lab7bonus_check_tb/DUT/write_equality_comparator
add wave -noupdate /lab7bonus_check_tb/DUT/read_equality_comparator
add wave -noupdate /lab7bonus_check_tb/DUT/bottom_equality_comparator
add wave -noupdate -divider CPU
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/reset
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/in
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/out
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/N
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/V
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/Z
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/w
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/memory_address
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/memory_command
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/sximm8
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/sximm5
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/opcode
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/op
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/out_instruction_register
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/into_pc
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/out_PC_adder
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/out_data_addr_reg
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/load_pc
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/address_select
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/reset_pc
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/load_ir
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/load_addr
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/current_state
add wave -noupdate -radix hexadecimal /lab7bonus_check_tb/DUT/CPU/PC
add wave -noupdate -divider REGISTERS
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate -divider MEMORY
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[30]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[29]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[28]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[27]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[26]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[25]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[24]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[23]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[22]}
add wave -noupdate {/lab7bonus_check_tb/DUT/MEM/mem[21]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[20]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[19]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[18]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[17]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[16]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[15]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[14]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[13]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[12]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[11]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[10]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[9]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[8]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[7]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[6]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[5]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[4]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[3]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[2]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[1]}
add wave -noupdate -radix decimal {/lab7bonus_check_tb/DUT/MEM/mem[0]}
add wave -noupdate -divider DATAPATH
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/readnum
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/vsel
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/loada
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/loadb
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/shift
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/asel
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/bsel
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/ALUop
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/loadc
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/loads
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/writenum
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/write
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/mdata
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/sximm8
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/PC
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/sximm5
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/status_out
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/datapath_out
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/data_out_regfile
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/data_out_RA
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/data_out_RB
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/data_out_shifter
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/Ain
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/Bin
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/status_in
add wave -noupdate /lab7bonus_check_tb/DUT/CPU/DP/ALU_out
add wave -noupdate -radix decimal /lab7bonus_check_tb/DUT/CPU/DP/data_into_regfile
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {465 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 315
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
WaveRestoreZoom {2347 ps} {2461 ps}
