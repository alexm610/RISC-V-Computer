onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_memory/dut/clock
add wave -noupdate /tb_memory/dut/reset_n
add wave -noupdate /tb_memory/dut/write
add wave -noupdate /tb_memory/dut/address
add wave -noupdate /tb_memory/dut/writedata
add wave -noupdate /tb_memory/dut/readbyte
add wave -noupdate /tb_memory/dut/readword
add wave -noupdate /tb_memory/dut/word_address
add wave -noupdate /tb_memory/dut/word
add wave -noupdate /tb_memory/dut/memory
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {1567 ps}
