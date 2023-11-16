onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_divisor_ctrl/clock
add wave -noupdate /tb_divisor_ctrl/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_divisor_ctrl/valid
add wave -noupdate /tb_divisor_ctrl/neg_remainder
add wave -noupdate /tb_divisor_ctrl/finished
add wave -noupdate -divider outputs
add wave -noupdate /tb_divisor_ctrl/ready
add wave -noupdate /tb_divisor_ctrl/load
add wave -noupdate /tb_divisor_ctrl/shift_quotient
add wave -noupdate /tb_divisor_ctrl/set_quotient_bit
add wave -noupdate /tb_divisor_ctrl/shift_divisor
add wave -noupdate /tb_divisor_ctrl/restore_sub
add wave -noupdate /tb_divisor_ctrl/write_remainder
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 237
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
WaveRestoreZoom {0 ns} {946 ns}
