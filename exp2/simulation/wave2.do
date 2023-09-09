onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 36 /rx_serial_tb/bitPeriod
add wave -noupdate -height 36 /rx_serial_tb/casos_teste
add wave -noupdate -height 36 /rx_serial_tb/clock_in
add wave -noupdate -height 36 /rx_serial_tb/clockPeriod
add wave -noupdate -height 36 /rx_serial_tb/entrada_serial_in
add wave -noupdate -height 36 /rx_serial_tb/keep_simulating
add wave -noupdate -height 36 /rx_serial_tb/paridade_recebida_out
add wave -noupdate -height 36 /rx_serial_tb/pronto_out
add wave -noupdate -height 36 /rx_serial_tb/reset_in
add wave -noupdate -height 36 /rx_serial_tb/serialData
add wave -noupdate -height 36 -expand /rx_serial_tb/DUT/s_dados_ascii
add wave -noupdate -height 36 /rx_serial_tb/DUT/s_tick
add wave -noupdate -height 36 /rx_serial_tb/DUT/RX_UC/Eatual
add wave -noupdate /rx_serial_tb/DUT/U3_TICK/IQ
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99850 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 267
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
WaveRestoreZoom {98504 ns} {101196 ns}
