onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_multiplier_ctrl/clock
add wave -noupdate /tb_multiplier_ctrl/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_multiplier_ctrl/valid
add wave -noupdate /tb_multiplier_ctrl/finished
add wave -noupdate -divider outputs
add wave -noupdate /tb_multiplier_ctrl/ready
add wave -noupdate /tb_multiplier_ctrl/load
add wave -noupdate /tb_multiplier_ctrl/shift_operands
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 234
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
WaveRestoreZoom {0 ns} {494 ns}
