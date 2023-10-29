onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_reg_file/clock
add wave -noupdate -divider inputs
add wave -noupdate /tb_reg_file/uut/w_addr
add wave -noupdate /tb_reg_file/uut/r_addr
add wave -noupdate /tb_reg_file/uut/w_data
add wave -noupdate /tb_reg_file/uut/reg_mux_outs
add wave -noupdate -divider outputs
add wave -noupdate -divider debug
add wave -noupdate /tb_reg_file/uut/reg_mux_outs
add wave -noupdate -expand /tb_reg_file/uut/reg_write_enables
add wave -noupdate -expand /tb_reg_file/uut/reg_write_enables
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 236
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
WaveRestoreZoom {0 ns} {95 ns}
