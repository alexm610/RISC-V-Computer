onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 40 DUT
add wave -noupdate /tb_datapath/dut/clk
add wave -noupdate /tb_datapath/dut/rst_n
add wave -noupdate /tb_datapath/dut/write_rb
add wave -noupdate /tb_datapath/dut/alu_control
add wave -noupdate /tb_datapath/dut/rs_1
add wave -noupdate /tb_datapath/dut/rs_2
add wave -noupdate /tb_datapath/dut/rd_0
add wave -noupdate -radix hexadecimal /tb_datapath/dut/writedata
add wave -noupdate -radix hexadecimal /tb_datapath/dut/alu_result
add wave -noupdate -divider -height 40 REGISTER_BANK
add wave -noupdate /tb_datapath/dut/REGISTER_BANK/write
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/rs1
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/rs2
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/rd
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/writedata
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/readdata_1
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/readdata_2
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/addr_1
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/addr_2
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/addr_d
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x0
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x1
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x2
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x3
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x4
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x5
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x6
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x7
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x8
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x9
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x10
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x11
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x12
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x13
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x14
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x15
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x16
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x17
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x18
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x19
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x20
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x21
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x22
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x23
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x24
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x25
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x26
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x27
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x28
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x29
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x30
add wave -noupdate -radix hexadecimal /tb_datapath/dut/REGISTER_BANK/x31
add wave -noupdate -divider -height 40 ALU
add wave -noupdate /tb_datapath/dut/ALU/ALUop
add wave -noupdate -radix hexadecimal /tb_datapath/dut/ALU/Ain
add wave -noupdate -radix hexadecimal /tb_datapath/dut/ALU/Bin
add wave -noupdate /tb_datapath/dut/ALU/status
add wave -noupdate -radix hexadecimal /tb_datapath/dut/ALU/out
add wave -noupdate /tb_datapath/dut/ALU/overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {144 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 320
configure wave -valuecolwidth 273
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
WaveRestoreZoom {7370 ps} {7430 ps}
