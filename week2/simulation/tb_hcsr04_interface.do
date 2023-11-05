onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_hcsr04_interface/clock
add wave -noupdate /tb_hcsr04_interface/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_hcsr04_interface/reset_counters
add wave -noupdate /tb_hcsr04_interface/generate_pulse
add wave -noupdate /tb_hcsr04_interface/echo
add wave -noupdate /tb_hcsr04_interface/watchdog_en
add wave -noupdate /tb_hcsr04_interface/reset_watchdog
add wave -noupdate -divider outputs
add wave -noupdate /tb_hcsr04_interface/mensurar
add wave -noupdate /tb_hcsr04_interface/pulse_sent
add wave -noupdate /tb_hcsr04_interface/trigger
add wave -noupdate /tb_hcsr04_interface/dist_l
add wave -noupdate /tb_hcsr04_interface/dist_h
add wave -noupdate -divider debug
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50304090 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 366
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
WaveRestoreZoom {49936748 ns} {50635268 ns}
