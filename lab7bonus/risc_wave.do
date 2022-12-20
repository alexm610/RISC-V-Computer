onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider MEMORY
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[20]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[19]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[18]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[17]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[16]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[15]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[14]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[13]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[12]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[11]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[10]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[9]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[8]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[7]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[6]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[5]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[4]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[3]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[2]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[1]}
add wave -noupdate {/sw_led_tb_top/DUT/MEM/mem[0]}
add wave -noupdate -divider INPUTS
add wave -noupdate /sw_led_tb_top/DUT/CLOCK_50
add wave -noupdate {/sw_led_tb_top/DUT/KEY[1]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[9]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[8]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[7]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[6]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[5]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[4]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[3]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[2]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[1]}
add wave -noupdate {/sw_led_tb_top/DUT/SW[0]}
add wave -noupdate -divider DATAPATH
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /sw_led_tb_top/DUT/CPU/DP/REGFILE/R7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8386 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 206
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
WaveRestoreZoom {0 ps} {959 ps}
