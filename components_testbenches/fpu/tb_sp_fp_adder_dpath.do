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
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/a_buf
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/b_buf
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/a_signif
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/b_signif
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/smaller_exp
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/larger_exp
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/incremented_exp
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/exp_inc_reg_in
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/exp_inc_reg_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/smaller_signif
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/larger_signif
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/not_b_exp
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/exp_b_gt_a
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/signif_b_gt_a
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/smaller_signif_reg_en
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/smaller_signif_reg_in
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/smaller_signif_reg_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/not_smaller_signif_reg_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/smaller_exp_cnt_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/ones_complement_decoder
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/sum_c_in
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/sum_c_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/sum_a
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/sum_b
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/sum_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/shifted_sum_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/shifted_sum_reg_en
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/shifted_sum_reg_in
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/shifted_sum_reg_out
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/tmp_sel
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/zero_counter_reset
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/zero_count
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/not_zero_count
add wave -noupdate /tb_sp_fp_adder_dpath/uut_sp_fp_adder/final_exp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {102 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 356
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
WaveRestoreZoom {0 ns} {592 ns}
