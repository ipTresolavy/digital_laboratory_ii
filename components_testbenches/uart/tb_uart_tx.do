onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart_tx/clock
add wave -noupdate /tb_uart_tx/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_uart_tx/din
add wave -noupdate /tb_uart_tx/s_tick
add wave -noupdate /tb_uart_tx/tx_start
add wave -noupdate -divider outputs
add wave -noupdate /tb_uart_tx/tx
add wave -noupdate /tb_uart_tx/tx_done_tick
add wave -noupdate -divider debug
add wave -noupdate /tb_uart_tx/uut_uart_tx/state_reg
add wave -noupdate /tb_uart_tx/uut_uart_tx/n_reg
add wave -noupdate /tb_uart_tx/uut_uart_tx/s_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {172310 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 182
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
WaveRestoreZoom {158133 ns} {186487 ns}
