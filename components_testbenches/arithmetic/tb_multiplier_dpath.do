onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_multiplier_dpath/clock
add wave -noupdate /tb_multiplier_dpath/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_multiplier_dpath/load
add wave -noupdate /tb_multiplier_dpath/shift_operands
add wave -noupdate -radix unsigned /tb_multiplier_dpath/multiplicand
add wave -noupdate -radix unsigned /tb_multiplier_dpath/multiplier
add wave -noupdate -divider outputs
add wave -noupdate -radix unsigned /tb_multiplier_dpath/product
add wave -noupdate /tb_multiplier_dpath/finished
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {383 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
configure wave -valuecolwidth 109
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
WaveRestoreZoom {0 ns} {3862 ns}
