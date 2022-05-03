onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider REGISTERS
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate -divider DATAPATH
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/clk
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/readnum
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/vsel
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/loada
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/loadb
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/write
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/PC
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/datapath_out
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/data_out_regfile
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/data_out_RA
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/data_out_RB
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/data_out_shifter
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/ALU_out
add wave -noupdate /sw_led_test_tb/DUT/CPU/DP/data_into_regfile
add wave -noupdate -divider CPU
add wave -noupdate /sw_led_test_tb/DUT/CPU/clk
add wave -noupdate /sw_led_test_tb/DUT/CPU/reset
add wave -noupdate /sw_led_test_tb/DUT/CPU/in
add wave -noupdate /sw_led_test_tb/DUT/CPU/out
add wave -noupdate /sw_led_test_tb/DUT/CPU/w
add wave -noupdate /sw_led_test_tb/DUT/CPU/memory_address
add wave -noupdate -radix decimal /sw_led_test_tb/DUT/CPU/memory_command
add wave -noupdate /sw_led_test_tb/DUT/CPU/current_state
add wave -noupdate /sw_led_test_tb/DUT/CPU/opcode
add wave -noupdate /sw_led_test_tb/DUT/CPU/op
add wave -noupdate /sw_led_test_tb/DUT/CPU/readnum_and_writenum
add wave -noupdate /sw_led_test_tb/DUT/CPU/write
add wave -noupdate /sw_led_test_tb/DUT/CPU/ALUop
add wave -noupdate /sw_led_test_tb/DUT/CPU/out_instruction_register
add wave -noupdate /sw_led_test_tb/DUT/CPU/into_pc
add wave -noupdate -radix decimal /sw_led_test_tb/DUT/CPU/PC
add wave -noupdate /sw_led_test_tb/DUT/CPU/out_PC_adder
add wave -noupdate /sw_led_test_tb/DUT/CPU/load_pc
add wave -noupdate /sw_led_test_tb/DUT/CPU/address_select
add wave -noupdate /sw_led_test_tb/DUT/CPU/reset_pc
add wave -noupdate /sw_led_test_tb/DUT/CPU/load_ir
add wave -noupdate /sw_led_test_tb/DUT/CPU/load_addr
add wave -noupdate -divider MEMORY
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[32]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[31]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[30]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[29]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[28]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[27]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[26]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[25]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[24]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[23]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[22]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[21]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[20]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[19]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[18]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[17]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[16]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[15]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[14]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[13]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[12]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[11]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[10]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[9]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[8]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[7]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[6]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[5]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[4]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[3]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[2]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[1]}
add wave -noupdate {/sw_led_test_tb/DUT/MEM/mem[0]}
add wave -noupdate -divider LED
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[9]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[8]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[7]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[6]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[5]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[4]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[3]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[2]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[1]}
add wave -noupdate {/sw_led_test_tb/DUT/LEDR[0]}
add wave -noupdate -divider SWITCH
add wave -noupdate {/sw_led_test_tb/DUT/SW[9]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[8]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[7]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[6]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[5]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[4]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[3]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[2]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[1]}
add wave -noupdate {/sw_led_test_tb/DUT/SW[0]}
add wave -noupdate -divider HEX
add wave -noupdate /sw_led_test_tb/HEX0
add wave -noupdate /sw_led_test_tb/HEX1
add wave -noupdate /sw_led_test_tb/HEX2
add wave -noupdate /sw_led_test_tb/HEX3
add wave -noupdate /sw_led_test_tb/HEX4
add wave -noupdate /sw_led_test_tb/HEX5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {593 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 258
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
WaveRestoreZoom {515 ps} {631 ps}
