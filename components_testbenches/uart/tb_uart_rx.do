onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart_rx/clock
add wave -noupdate /tb_uart_rx/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_uart_rx/rx
add wave -noupdate /tb_uart_rx/s_tick
add wave -noupdate -divider outputs
add wave -noupdate /tb_uart_rx/uut_uart_rx/b_reg
add wave -noupdate -divider debug
add wave -noupdate /tb_uart_rx/uut_uart_rx/state_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {165978 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {455879 ns}
