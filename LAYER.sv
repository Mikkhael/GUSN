module LAYER #(
    parameter INT_W  = 8,
    parameter FRAC_W = 8,

    parameter INPUTS  = 1,
    parameter OUTPUTS = 1,

    parameter RAM_ADDR_W = 8,
    parameter RAM_ADDR_START = 0,
    
    parameter RAM_DELAY = 3,

    parameter RELU_SHIFT = 4,
    parameter NUM_W = INT_W + FRAC_W
) (
    input clk,
    input nreset,
    input enable,

    input  signed [NUM_W - 1 : 0]       inputs_f [0 : INPUTS  - 1],
    input  signed [NUM_W - 1 : 0]       inputs_b [0 : OUTPUTS - 1],
    output signed [NUM_W - 1 : 0]       output_f [0 : OUTPUTS - 1],
    output signed [NUM_W - 1 : 0]       output_b [0 : INPUTS  - 1],

    output reg signed                       mult_en,
    output     signed [NUM_W - 1 : 0]       mult_v1,
    output     signed [NUM_W - 1 : 0]       mult_v2,
    input      signed [NUM_W - 1 : 0]       mult_res,
    
    output reg                              ram_write,
    output reg        [RAM_ADDR_W - 1 : 0]  ram_addr_write,
    output reg        [RAM_ADDR_W - 1 : 0]  ram_addr_read,
    output reg signed [NUM_W - 1 : 0]       ram_data_write,
    input      signed [NUM_W - 1 : 0]       ram_data_read,

    input  ready_f_in,
    input  ready_b_in,
    output ready_out,

    input start_f,
    input start_b
);

    localparam INPUTS_W  = $clog2(INPUTS+1);
    localparam OUTPUTS_W = $clog2(OUTPUTS+1);

    // State

    reg is_waiting_for_ready;
    reg is_busy;
    reg is_back;

    reg [$clog2(RAM_DELAY+1) - 1:0] cnt_delay;
    reg [OUTPUTS_W - 1 : 0]         cnt_n_ram;
    reg [ INPUTS_W - 1 : 0]         cnt_w_ram;
    reg [OUTPUTS_W - 1 : 0]         cnt_n_real;
    reg [ INPUTS_W - 1 : 0]         cnt_w_real;

    // Out

    reg signed [NUM_W - 1 : 0] results_f [0 : OUTPUTS - 1];
    reg signed [NUM_W - 1 : 0] results_b [0 : INPUTS  - 1];

    wire signed [NUM_W - 1 : 0] v1 = ram_data_read;
    wire signed [NUM_W - 1 : 0] v2 = is_back ?
                                  inputs_b[cnt_n_real] : 
                                  inputs_f[cnt_w_real];

    assign mult_v1 = mult_en ? v1 : 0;
    assign mult_v2 = mult_en ? v2 : 0;

    genvar i;
    generate for(i = 0; i<OUTPUTS; i++) begin
        assign output_f[i] = results_f[i] > 0 ? 
                                    results_f[i] :
                                    results_f[i] >>> RELU_SHIFT;
    end endgenerate

    assign ready_out = !is_busy;

    // Tasks

    task automatic RESET_COUNTERS(); begin
        cnt_delay   <= 0;
        cnt_n_ram   <= 0;
        cnt_w_ram   <= 0;
        cnt_n_real  <= 0;
        cnt_w_real  <= 0;
    end endtask
    
    task automatic RESET_BUSES(); begin
        mult_en   <= 1'd0;
        ram_write <= 1'd0;
        ram_addr_read  <= 0;
        ram_addr_write <= 0;
        ram_data_write <= 0;
    end endtask

    task automatic INC_RAM_READ(); begin
        if(cnt_w_ram == INPUTS) begin
            cnt_w_ram <= 0;
            ram_addr_read <= ram_addr_read + 1'd1;
        end else begin
            cnt_w_ram <= cnt_w_ram + 1'd1;
            ram_addr_read <= ram_addr_read + 1'd1;
        end
        if(cnt_delay != 0) begin
            cnt_delay <= cnt_delay - 1'd1;
        end else begin
            if(cnt_w_real == INPUTS) begin
                cnt_w_real <= 0;
                cnt_n_real <= cnt_n_real + 1'd1;
            end else begin
                cnt_w_real <= cnt_w_real + 1'd1;
            end
        end
    end endtask

    // Main
        
    parameter signed [NUM_W - 1 : 0] MAX_VALUE_POS = {1'b0, {(NUM_W-1){1'b1}}};
    parameter signed [NUM_W - 1 : 0] MAX_VALUE_NEG = {1'b1, {(NUM_W-1){1'b0}}};

    wire signed [NUM_W - 1 : 0] value_to_add_f_1 = results_f[cnt_n_real];
    wire signed [NUM_W - 1 : 0] value_to_add_f_2 = (cnt_w_real == INPUTS ? ram_data_read : mult_res);
    
    wire signed [NUM_W - 1 : 0] value_to_add_f_1_sign = value_to_add_f_1[NUM_W - 1];
    wire signed [NUM_W - 1 : 0] value_to_add_f_2_sign = value_to_add_f_2[NUM_W - 1];

    wire signed [NUM_W - 1 : 0] add_result_f          = value_to_add_f_1 + value_to_add_f_2;
    wire signed [NUM_W - 1 : 0] add_result_f_sign     = add_result_f[NUM_W - 1];

    wire                        add_result_f_overflow = (value_to_add_f_1_sign == value_to_add_f_2_sign) &&
                                                        (value_to_add_f_1_sign != add_result_f_sign);
    wire signed [NUM_W - 1 : 0] add_result_f_clumped  =  
            (add_result_f_overflow &&  value_to_add_f_1_sign) ? MAX_VALUE_NEG :
            (add_result_f_overflow && !value_to_add_f_1_sign) ? MAX_VALUE_POS :
                                                                add_result_f;

    always @(posedge clk, negedge nreset) begin
        if(!nreset) begin
            RESET_COUNTERS();
            RESET_BUSES();
            is_back <= 1'd0;
            is_busy <= 1'd0;
            is_waiting_for_ready <= 1'd0;
            results_f <= '{default: 0};
            results_b <= '{default: 0};
        end else if(enable) begin
            if(is_busy &&  is_back && is_waiting_for_ready) begin // Wait for ready for BackPropagation
                // TODO
            end else 
            if(is_busy && !is_back && is_waiting_for_ready) begin // Wait for ready for ForwardPass
                if(ready_f_in) begin
                    cnt_delay     <= RAM_DELAY;
                    ram_addr_read <= RAM_ADDR_START;
                    mult_en       <= 1'd1;
                    is_waiting_for_ready <= 1'd0;
                end
            end else 
            if(is_busy &&  is_back) begin // Calculate BackPropagation
                // TODO
            end else 
            if(is_busy && !is_back) begin // Calculate ForwardPass
                INC_RAM_READ();
                if(cnt_delay == 0) begin
                    results_f[cnt_n_real] <= add_result_f_clumped;
                    if(cnt_n_real == OUTPUTS-1 && cnt_w_real == INPUTS) begin // Check if last operation
                        is_busy <= 1'd0;
                        RESET_COUNTERS();
                        RESET_BUSES();
                    end
                end
            end else 
            if(start_f || start_b) begin // Wait for start
                RESET_COUNTERS();
                RESET_BUSES();
                is_busy <= 1'd1;
                is_waiting_for_ready <= 1'd1;
                if(start_b) begin
                    results_b <= '{default: 0};
                    is_back  <= 1'b1;
                end else begin
                    results_f <= '{default: 0};
                    is_back  <= 1'b0;
                end
            end
        end
    end
    
endmodule