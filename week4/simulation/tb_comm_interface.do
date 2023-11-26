onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_comm_interface/clock
add wave -noupdate /tb_comm_interface/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_comm_interface/lidar_dist
add wave -noupdate /tb_comm_interface/hcsr04_dist
add wave -noupdate /tb_comm_interface/dist_estimate
add wave -noupdate /tb_comm_interface/send_data
add wave -noupdate /tb_comm_interface/rx
add wave -noupdate -divider outputs
add wave -noupdate /tb_comm_interface/tx
add wave -noupdate -divider debug
add wave -noupdate /tb_comm_interface/uut_comm_interface/rd_uart
add wave -noupdate /tb_comm_interface/uut_comm_interface/wr_uart
add wave -noupdate /tb_comm_interface/uut_comm_interface/r_data
add wave -noupdate /tb_comm_interface/uut_comm_interface/w_data
add wave -noupdate /tb_comm_interface/uut_comm_interface/tx_full
add wave -noupdate /tb_comm_interface/uut_comm_interface/rx_empty
add wave -noupdate /tb_comm_interface/uut_comm_interface/buffer_inputs
add wave -noupdate /tb_comm_interface/uut_comm_interface/lidar_dist_buf
add wave -noupdate /tb_comm_interface/uut_comm_interface/hcsr04_dist_buf
add wave -noupdate /tb_comm_interface/uut_comm_interface/w_data_src
add wave -noupdate /tb_comm_interface/uut_comm_interface/state
add wave -noupdate /tb_comm_interface/uut_comm_interface/next_state
add wave -noupdate /tb_comm_interface/uut_comm_interface/divisor
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 361
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
WaveRestoreZoom {0 ns} {222 ns}
