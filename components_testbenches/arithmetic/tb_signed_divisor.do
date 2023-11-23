onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_signed_divisor/clock
add wave -noupdate /tb_signed_divisor/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_signed_divisor/valid
add wave -noupdate -radix decimal /tb_signed_divisor/dividend
add wave -noupdate -radix decimal /tb_signed_divisor/divisor
add wave -noupdate -divider outputs
add wave -noupdate /tb_signed_divisor/ready
add wave -noupdate -radix decimal /tb_signed_divisor/quotient
add wave -noupdate -radix decimal /tb_signed_divisor/remainder
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10350 ns} 0}
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
WaveRestoreZoom {9421 ns} {14279 ns}
