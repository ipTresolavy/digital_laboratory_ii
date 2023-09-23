onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 36 /trena_saida_serial_tb/clock_in
add wave -noupdate -height 36 /trena_saida_serial_tb/reset_in
add wave -noupdate -divider Inputs
add wave -noupdate -color Yellow -height 36 /trena_saida_serial_tb/mensurar_in
add wave -noupdate -color Yellow -height 36 /trena_saida_serial_tb/echo_in
add wave -noupdate -divider Outputs
add wave -noupdate -color Magenta -height 36 /trena_saida_serial_tb/medida0_out
add wave -noupdate -color Magenta -height 36 /trena_saida_serial_tb/medida1_out
add wave -noupdate -color Magenta -height 36 /trena_saida_serial_tb/medida2_out
add wave -noupdate -color Magenta -height 36 /trena_saida_serial_tb/pronto_out
add wave -noupdate -color Magenta -height 36 /trena_saida_serial_tb/saida_serial_out
add wave -noupdate -color Magenta -height 36 /trena_saida_serial_tb/trigger_out
add wave -noupdate -divider Debug
add wave -noupdate -color Orange -height 36 /trena_saida_serial_tb/dut/uc/state
add wave -noupdate -color Orange -height 36 /trena_saida_serial_tb/dut/fd/s_data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11283694 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
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
WaveRestoreZoom {11283600 ns} {11285060 ns}
