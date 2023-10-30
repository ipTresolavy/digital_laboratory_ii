onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart/clock
add wave -noupdate /tb_uart/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_uart/divisor
add wave -noupdate /tb_uart/rd_uart
add wave -noupdate /tb_uart/rx
add wave -noupdate /tb_uart/w_data
add wave -noupdate -divider outputs
add wave -noupdate /tb_uart/r_data
add wave -noupdate /tb_uart/rx_empty
add wave -noupdate /tb_uart/tx
add wave -noupdate /tb_uart/tx_full
add wave -noupdate -divider debug
add wave -noupdate /tb_uart/uut_uart/rx_unit/state_reg
add wave -noupdate /tb_uart/uut_uart/tx_unit/state_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 244
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
WaveRestoreZoom {0 ns} {885066 ns}
