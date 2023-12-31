onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_lidar_ctrl/clock
add wave -noupdate /tb_lidar_ctrl/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_lidar_ctrl/rx_empty
add wave -noupdate /tb_lidar_ctrl/r_data
add wave -noupdate -divider outputs
add wave -noupdate /tb_lidar_ctrl/rd_uart
add wave -noupdate /tb_lidar_ctrl/dist_l
add wave -noupdate /tb_lidar_ctrl/dist_h
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 178
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
WaveRestoreZoom {0 ns} {1512 ns}
