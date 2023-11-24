onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_kalman_filter_dpath/clock
add wave -noupdate /tb_kalman_filter_dpath/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_kalman_filter_dpath/buffer_inputs
add wave -noupdate /tb_kalman_filter_dpath/x_en
add wave -noupdate /tb_kalman_filter_dpath/p_en
add wave -noupdate /tb_kalman_filter_dpath/diff_src
add wave -noupdate /tb_kalman_filter_dpath/mult_src
add wave -noupdate /tb_kalman_filter_dpath/mult_valid
add wave -noupdate /tb_kalman_filter_dpath/div_src
add wave -noupdate /tb_kalman_filter_dpath/div_valid
add wave -noupdate /tb_kalman_filter_dpath/add_src
add wave -noupdate /tb_kalman_filter_dpath/pred_en
add wave -noupdate /tb_kalman_filter_dpath/x_src
add wave -noupdate /tb_kalman_filter_dpath/p_src
add wave -noupdate /tb_kalman_filter_dpath/lidar
add wave -noupdate /tb_kalman_filter_dpath/hcsr04
add wave -noupdate -divider outputs
add wave -noupdate /tb_kalman_filter_dpath/dist
add wave -noupdate /tb_kalman_filter_dpath/mult_ready
add wave -noupdate /tb_kalman_filter_dpath/div_ready
add wave -noupdate -divider debug
add wave -noupdate /tb_kalman_filter_dpath/stimulus_process/valid_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 287
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
WaveRestoreZoom {0 ns} {872 ns}
