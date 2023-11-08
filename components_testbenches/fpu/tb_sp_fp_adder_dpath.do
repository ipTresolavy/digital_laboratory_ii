onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sp_fp_adder_dpath/clock
add wave -noupdate /tb_sp_fp_adder_dpath/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_sp_fp_adder_dpath/buffer_inputs
add wave -noupdate /tb_sp_fp_adder_dpath/load_smaller
add wave -noupdate /tb_sp_fp_adder_dpath/shift_smaller_signif
add wave -noupdate /tb_sp_fp_adder_dpath/store_sum
add wave -noupdate /tb_sp_fp_adder_dpath/count_zeroes
add wave -noupdate /tb_sp_fp_adder_dpath/a
add wave -noupdate /tb_sp_fp_adder_dpath/b
add wave -noupdate -divider outputs
add wave -noupdate /tb_sp_fp_adder_dpath/y
add wave -noupdate /tb_sp_fp_adder_dpath/equal_exps
add wave -noupdate /tb_sp_fp_adder_dpath/sum_is_zero
add wave -noupdate /tb_sp_fp_adder_dpath/finished_shift
add wave -noupdate -divider debug
add wave -noupdate /tb_sp_fp_adder_dpath/expected_result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 346
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
WaveRestoreZoom {0 ns} {817 ns}
