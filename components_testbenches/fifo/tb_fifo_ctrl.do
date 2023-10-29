onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_fifo_ctrl/clock
add wave -noupdate /tb_fifo_ctrl/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_fifo_ctrl/rd
add wave -noupdate /tb_fifo_ctrl/wr
add wave -noupdate -divider outputs
add wave -noupdate /tb_fifo_ctrl/empty
add wave -noupdate /tb_fifo_ctrl/full
add wave -noupdate /tb_fifo_ctrl/uut/r_addr
add wave -noupdate /tb_fifo_ctrl/uut/w_addr
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 243
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1050 ns}
