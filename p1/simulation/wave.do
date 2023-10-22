onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 36 /sonar_tb/clock_in
add wave -noupdate -height 36 /sonar_tb/reset_in
add wave -noupdate -divider Inputs
add wave -noupdate /sonar_tb/ligar_in
add wave -noupdate -color Yellow -height 36 /sonar_tb/echo_in
add wave -noupdate -divider Outputs
add wave -noupdate -color Magenta -height 36 /sonar_tb/dut/medida0
add wave -noupdate -color Magenta -height 36 /sonar_tb/dut/medida1
add wave -noupdate -color Magenta -height 36 /sonar_tb/dut/medida2
add wave -noupdate -color Magenta -height 36 /sonar_tb/fim_posicao_out
add wave -noupdate -color Magenta -height 36 /sonar_tb/saida_serial_out
add wave -noupdate -color Magenta -height 36 /sonar_tb/entrada_serial_in
add wave -noupdate -color Magenta -height 36 /sonar_tb/trigger_out
add wave -noupdate -color Magenta -height 36 /sonar_tb/pwm_out
add wave -noupdate -divider Debug
add wave -noupdate -color Orange -height 36 /sonar_tb/dut/fd/s_tick
add wave -noupdate -color Orange -height 36 /sonar_tb/dut/uc/state
add wave -noupdate -color Orange -height 36 /sonar_tb/dut/uc/mode
add wave -noupdate -color Orange -height 36 /sonar_tb/dut/fd/s_data_out
add wave -noupdate -color Orange -height 36 /sonar_tb/dut/fd/update_angle
add wave -noupdate -color Orange -height 36 /sonar_tb/dut/fd/s_largura
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
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
WaveRestoreZoom {0 ns} {128939559 ns}
