onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group ram /TEST_TB/ram/clk
add wave -noupdate -expand -group ram /TEST_TB/ram/ram_write
add wave -noupdate -expand -group ram /TEST_TB/ram/ram_addr_write
add wave -noupdate -expand -group ram /TEST_TB/ram/ram_addr_read
add wave -noupdate -expand -group ram /TEST_TB/ram/ram_data_write
add wave -noupdate -expand -group ram /TEST_TB/ram/ram_data_read
add wave -noupdate -expand -group mult /TEST_TB/mult/mult_v1
add wave -noupdate -expand -group mult /TEST_TB/mult/mult_v2
add wave -noupdate -expand -group mult /TEST_TB/mult/mult_res
add wave -noupdate -expand -group mult /TEST_TB/mult/res
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/clk
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/nreset
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/enable
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/inputs_f
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/inputs_b
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/output_f
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/output_b
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/mult_en
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/mult_v1
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/mult_v2
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/mult_res
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ram_write
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ram_addr_write
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ram_addr_read
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ram_data_write
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ram_data_read
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ready_f_in
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ready_b_in
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/ready_out
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/start_f
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/start_b
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/is_waiting_for_ready
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/is_busy
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/is_back
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/cnt_delay
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/cnt_n_ram
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/cnt_w_ram
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/cnt_n_real
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/cnt_w_real
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/v1
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/v2
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/results_f
add wave -noupdate -expand -group layer_1 /TEST_TB/layer_1/results_b
add wave -noupdate /TEST_TB/results_f_sim
add wave -noupdate /TEST_TB/results_b_sim
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {149 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 164
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {915 ns}
