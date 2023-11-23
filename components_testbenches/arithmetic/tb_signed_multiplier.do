onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_signed_multiplier/clock
add wave -noupdate /tb_signed_multiplier/reset
add wave -noupdate -divider inputs
add wave -noupdate /tb_signed_multiplier/valid
add wave -noupdate /tb_signed_multiplier/multiplicand
add wave -noupdate /tb_signed_multiplier/multiplier
add wave -noupdate -divider outputs
add wave -noupdate /tb_signed_multiplier/ready
add wave -noupdate /tb_signed_multiplier/product
add wave -noupdate -divider debug
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/product
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/state
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/next_state
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/mult_ready
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/buffer_signal
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/signal_reg_in
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/signal_reg_out
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/n_multiplier
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/inv_multiplier
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/n_multiplicand
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/inv_multiplicand
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/n_product
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/inv_product
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/multiplicand_in
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/multiplier_in
add wave -noupdate /tb_signed_multiplier/uut_signed_multiplier/product_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {737 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 401
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
WaveRestoreZoom {0 ns} {788 ns}
