onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_divisor_dpath/clock
add wave -noupdate /tb_divisor_dpath/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_divisor_dpath/load
add wave -noupdate /tb_divisor_dpath/shift_quotient
add wave -noupdate /tb_divisor_dpath/set_quotient_bit
add wave -noupdate /tb_divisor_dpath/shift_divisor
add wave -noupdate /tb_divisor_dpath/restore_sub
add wave -noupdate /tb_divisor_dpath/write_remainder
add wave -noupdate -radix unsigned /tb_divisor_dpath/dividend
add wave -noupdate -radix unsigned /tb_divisor_dpath/divisor
add wave -noupdate -divider outputs
add wave -noupdate /tb_divisor_dpath/neg_remainder
add wave -noupdate /tb_divisor_dpath/finished
add wave -noupdate -radix unsigned /tb_divisor_dpath/quotient
add wave -noupdate -radix unsigned /tb_divisor_dpath/remainder
add wave -noupdate -divider debug
add wave -noupdate /tb_divisor_dpath/uut_divisor_dpath/divisor_reg_en
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/divisor_reg_in
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/divisor_reg_out
add wave -noupdate /tb_divisor_dpath/uut_divisor_dpath/remainder_reg_reset
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/remainder_reg_in
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/remainder_reg_out
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/b
add wave -noupdate /tb_divisor_dpath/uut_divisor_dpath/c_in
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/s
add wave -noupdate /tb_divisor_dpath/uut_divisor_dpath/quotient_reg_en
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/quotient_reg_in
add wave -noupdate -radix unsigned /tb_divisor_dpath/uut_divisor_dpath/quotient_reg_out
add wave -noupdate /tb_divisor_dpath/uut_divisor_dpath/iteration_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {639 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 370
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
WaveRestoreZoom {605 ns} {781 ns}
