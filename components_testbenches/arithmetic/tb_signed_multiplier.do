onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_signed_multiplier/clock
add wave -noupdate /tb_signed_multiplier/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_signed_multiplier/valid
add wave -noupdate /tb_signed_multiplier/multiplicand
add wave -noupdate /tb_signed_multiplier/multiplier
add wave -noupdate -divider outputs
add wave -noupdate /tb_signed_multiplier/ready
add wave -noupdate /tb_signed_multiplier/product
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 401
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
WaveRestoreZoom {0 ns} {846 ns}
