onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_hcsr04_ctrl/clock
add wave -noupdate /tb_hcsr04_ctrl/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_hcsr04_ctrl/mensurar
add wave -noupdate /tb_hcsr04_ctrl/echo
add wave -noupdate /tb_hcsr04_ctrl/pulse_sent
add wave -noupdate /tb_hcsr04_ctrl/timeout
add wave -noupdate -divider outputs
add wave -noupdate /tb_hcsr04_ctrl/generate_pulse
add wave -noupdate /tb_hcsr04_ctrl/reset_counters
add wave -noupdate /tb_hcsr04_ctrl/store_measurement
add wave -noupdate /tb_hcsr04_ctrl/pronto
add wave -noupdate /tb_hcsr04_ctrl/db_estado
add wave -noupdate /tb_hcsr04_ctrl/pulse_width
add wave -noupdate -divider debug
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {60177 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 248
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
WaveRestoreZoom {44660 ns} {64960 ns}
