onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider MEMORY
add wave -noupdate {/lab7_check_tb/DUT/MEM/mem[0]}
add wave -noupdate {/lab7_check_tb/DUT/MEM/mem[1]}
add wave -noupdate {/lab7_check_tb/DUT/MEM/mem[2]}
add wave -noupdate {/lab7_check_tb/DUT/MEM/mem[3]}
add wave -noupdate {/lab7_check_tb/DUT/MEM/mem[4]}
add wave -noupdate {/lab7_check_tb/DUT/MEM/mem[5]}
add wave -noupdate {/lab7_check_tb/DUT/MEM/mem[6]}
add wave -noupdate -divider {TOP LEVEL}
add wave -noupdate /lab7_check_tb/DUT/wait_signal
add wave -noupdate /lab7_check_tb/DUT/memory_address
add wave -noupdate /lab7_check_tb/DUT/memory_command
add wave -noupdate /lab7_check_tb/DUT/write_equality_comparator
add wave -noupdate /lab7_check_tb/DUT/read_equality_comparator
add wave -noupdate /lab7_check_tb/DUT/bottom_equality_comparator
add wave -noupdate -divider CPU
add wave -noupdate /lab7_check_tb/DUT/CPU/clk
add wave -noupdate /lab7_check_tb/DUT/CPU/reset
add wave -noupdate /lab7_check_tb/DUT/CPU/in
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/datapath_out
add wave -noupdate /lab7_check_tb/DUT/CPU/current_state
add wave -noupdate /lab7_check_tb/DUT/CPU/memory_address
add wave -noupdate /lab7_check_tb/DUT/CPU/memory_command
add wave -noupdate /lab7_check_tb/DUT/CPU/out_instruction_register
add wave -noupdate /lab7_check_tb/DUT/CPU/into_pc
add wave -noupdate /lab7_check_tb/DUT/CPU/PC
add wave -noupdate /lab7_check_tb/DUT/CPU/out_PC_adder
add wave -noupdate /lab7_check_tb/DUT/CPU/out_data_addr_reg
add wave -noupdate /lab7_check_tb/DUT/CPU/load_pc
add wave -noupdate /lab7_check_tb/DUT/CPU/reset_pc
add wave -noupdate /lab7_check_tb/DUT/CPU/address_select
add wave -noupdate /lab7_check_tb/DUT/CPU/load_ir
add wave -noupdate /lab7_check_tb/DUT/CPU/load_addr
add wave -noupdate -divider REGISTERS
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /lab7_check_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate -divider MEMORY
add wave -noupdate /lab7_check_tb/DUT/MEM/write
add wave -noupdate /lab7_check_tb/DUT/MEM/read_address
add wave -noupdate /lab7_check_tb/DUT/MEM/write_address
add wave -noupdate /lab7_check_tb/DUT/MEM/din
add wave -noupdate /lab7_check_tb/DUT/MEM/dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 273
configure wave -valuecolwidth 107
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
WaveRestoreZoom {0 ps} {230 ps}
