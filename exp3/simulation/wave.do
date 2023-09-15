onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Inputs
add wave -noupdate -color Yellow -height 48 /interface_hcsr04_tb/clock_in
add wave -noupdate -color Yellow -height 48 /interface_hcsr04_tb/reset_in
add wave -noupdate -color Yellow -height 48 /interface_hcsr04_tb/medir_in
add wave -noupdate -color Yellow -height 48 /interface_hcsr04_tb/echo_in
add wave -noupdate -divider Outputs
add wave -noupdate -color Magenta -height 48 /interface_hcsr04_tb/trigger_out
add wave -noupdate -color Magenta -height 48 /interface_hcsr04_tb/pronto_out
add wave -noupdate -color Magenta -height 48 /interface_hcsr04_tb/medida_out
add wave -noupdate -divider Debug
add wave -noupdate -color Orange -height 36 /interface_hcsr04_tb/dut/fd/s_1us_tick
add wave -noupdate -color Orange -height 36 /interface_hcsr04_tb/dut/fd/s_conta
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6343170 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 329
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
WaveRestoreZoom {0 ns} {23767349 ns}
