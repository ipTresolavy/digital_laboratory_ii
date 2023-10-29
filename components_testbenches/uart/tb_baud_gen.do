onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_baud_gen/clock
add wave -noupdate /tb_baud_gen/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_baud_gen/uut/divisor
add wave -noupdate -divider outputs
add wave -noupdate /tb_baud_gen/tick
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {30 ns} 1} {{Cursor 4} {8670 ns} 1}
quietly wave cursor active 2
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {9135 ns}
