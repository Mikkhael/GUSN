onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group ram /TEST_TB/ram/clk
add wave -noupdate -group ram /TEST_TB/ram/ram_write
add wave -noupdate -group ram /TEST_TB/ram/ram_addr_write
add wave -noupdate -group ram /TEST_TB/ram/ram_addr_read
add wave -noupdate -group ram /TEST_TB/ram/ram_data_write
add wave -noupdate -group ram /TEST_TB/ram/ram_data_read
add wave -noupdate -group mult /TEST_TB/mult/mult_v1
add wave -noupdate -group mult /TEST_TB/mult/mult_v2
add wave -noupdate -group mult /TEST_TB/mult/mult_res
add wave -noupdate -group mult /TEST_TB/mult/res
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/clk}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/nreset}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/enable}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/inputs_f}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/inputs_b}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/output_f}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/output_b}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/mult_en}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/mult_v1}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/mult_v2}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/mult_res}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ram_write}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ram_addr_write}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ram_addr_read}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ram_data_write}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ram_data_read}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ready_f_in}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ready_b_in}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/ready_out}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/start_f}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/start_b}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/is_waiting_for_ready}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/is_busy}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/is_back}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/cnt_delay}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/cnt_n_ram}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/cnt_w_ram}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/cnt_n_real}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/cnt_w_real}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/v1}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer/v2}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer_test/results_f_sim}
add wave -noupdate -expand -group {Layer 3} {/TEST_TB/generate_layers[2]/layer_test/results_b_sim}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/clk}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/nreset}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/enable}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/inputs_f}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/inputs_b}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/output_f}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/output_b}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/mult_en}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/mult_v1}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/mult_v2}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/mult_res}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ram_write}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ram_addr_write}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ram_addr_read}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ram_data_write}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ram_data_read}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ready_f_in}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ready_b_in}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/ready_out}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/start_f}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/start_b}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/is_waiting_for_ready}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/is_busy}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/is_back}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/cnt_delay}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/cnt_n_ram}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/cnt_w_ram}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/cnt_n_real}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/cnt_w_real}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/v1}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer/v2}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer_test/results_f_sim}
add wave -noupdate -group {Layer 2} {/TEST_TB/generate_layers[1]/layer_test/results_b_sim}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/clk}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/nreset}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/enable}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/inputs_f}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/inputs_b}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/output_f}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/output_b}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/mult_en}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/mult_v1}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/mult_v2}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/mult_res}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ram_write}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ram_addr_write}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ram_addr_read}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ram_data_write}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ram_data_read}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ready_f_in}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ready_b_in}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/ready_out}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/start_f}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/start_b}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/is_waiting_for_ready}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/is_busy}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/is_back}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/cnt_delay}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/cnt_n_ram}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/cnt_w_ram}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/cnt_n_real}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/cnt_w_real}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/v1}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer/v2}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer_test/results_f_sim}
add wave -noupdate -group {Layer 1} {/TEST_TB/generate_layers[0]/layer_test/results_b_sim}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {149 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 130
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
WaveRestoreZoom {546307 ns} {547248 ns}
