onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_kalman_filter/clock
add wave -noupdate /tb_kalman_filter/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_kalman_filter/i_valid
add wave -noupdate /tb_kalman_filter/lidar
add wave -noupdate /tb_kalman_filter/hcsr04
add wave -noupdate -divider outputs
add wave -noupdate /tb_kalman_filter/o_valid
add wave -noupdate /tb_kalman_filter/dist
add wave -noupdate -divider debug
add wave -noupdate /tb_kalman_filter/uut_kalman_filter/datapath/p_reg_out
add wave -noupdate /tb_kalman_filter/uut_kalman_filter/control_unit/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {54 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 288
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
WaveRestoreZoom {0 ns} {244 ns}
