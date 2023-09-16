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
add wave -noupdate -color Orange -height 48 /interface_hcsr04_tb/dut/fd/s_half
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52416230 ns} 0} {{Cursor 2} {52357410 ns} 0} {{Cursor 3} {52545710 ns} 0} {{Cursor 4} {52555710 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 241
configure wave -valuecolwidth 88
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
WaveRestoreZoom {52332137 ns} {52746108 ns}
