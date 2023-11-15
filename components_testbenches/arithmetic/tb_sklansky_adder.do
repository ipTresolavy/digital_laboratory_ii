onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sklansky_adder/a
add wave -noupdate /tb_sklansky_adder/b
add wave -noupdate /tb_sklansky_adder/c_in
add wave -noupdate /tb_sklansky_adder/c_out
add wave -noupdate /tb_sklansky_adder/s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 191
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
WaveRestoreZoom {0 ns} {31 ns}
