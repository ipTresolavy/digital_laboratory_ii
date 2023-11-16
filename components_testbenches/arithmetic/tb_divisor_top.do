onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_divisor_top/clock
add wave -noupdate /tb_divisor_top/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_divisor_top/valid
add wave -noupdate -radix unsigned /tb_divisor_top/dividend
add wave -noupdate -radix unsigned /tb_divisor_top/divisor
add wave -noupdate -divider outputs
add wave -noupdate /tb_divisor_top/ready
add wave -noupdate -radix unsigned /tb_divisor_top/quotient
add wave -noupdate -radix unsigned /tb_divisor_top/remainder
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1345 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 327
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
WaveRestoreZoom {1167 ns} {1613 ns}
