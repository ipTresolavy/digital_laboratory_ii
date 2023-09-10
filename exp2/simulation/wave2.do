onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 36 /rx_serial_tb/caso
add wave -noupdate -divider Inputs
add wave -noupdate -color Yellow -height 36 /rx_serial_tb/clock_in
add wave -noupdate -color Yellow -height 36 /rx_serial_tb/reset_in
add wave -noupdate -color Yellow -height 36 /rx_serial_tb/entrada_serial_in
add wave -noupdate -divider Outputs
add wave -noupdate -color Magenta -height 36 /rx_serial_tb/pronto_out
add wave -noupdate -color Magenta -height 36 /rx_serial_tb/paridade_recebida_out
add wave -noupdate -divider Debug
add wave -noupdate -color Orange -height 36 /rx_serial_tb/DUT/s_dados_ascii
add wave -noupdate -color Orange -height 36 /rx_serial_tb/DUT/s_tick
add wave -noupdate -color Orange -height 36 /rx_serial_tb/serialData
add wave -noupdate -color Orange -height 36 /rx_serial_tb/DUT/RX_UC/Eatual
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5863 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 253
configure wave -valuecolwidth 252
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
WaveRestoreZoom {0 ns} {1339758 ns}
