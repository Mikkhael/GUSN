module LAYER #(
    parameter INT_W  = 'x,
    parameter FRAC_W = 'x,

    parameter INPUTS  = 'x,
    parameter OUTPUTS = 'x,

    parameter RAM_ADDR_W = 'x,
    parameter RAM_ADDR_START = 'x,
    
    parameter RAM_DELAY = 'x,

    parameter RELU_SHIFT = 'x,
    parameter LEARNING_SHIFT = 'x,
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
    output                                  mult_shift,
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

    enum {
        IDLE,
        WAIT_FOR_READY_F,
        CALC_F,
        WAIT_FOR_READY_B,
        CALC_B1,
        CALC_B2,
        FINALIZE
    } state;

    wire is_waiting_for_ready   = state == WAIT_FOR_READY_F || state == WAIT_FOR_READY_B;
    wire is_busy                = state != IDLE;
    wire is_back                = state == WAIT_FOR_READY_B || state == CALC_B1 || state == CALC_B2;
    wire is_back_weights        = state == CALC_B2;

    reg [$clog2(RAM_DELAY+1) - 1:0] cnt_delay;
    reg [OUTPUTS_W - 1 : 0]         cnt_n_ram;
    reg [ INPUTS_W - 1 : 0]         cnt_w_ram;
    reg [OUTPUTS_W - 1 : 0]         cnt_n_real;
    reg [ INPUTS_W - 1 : 0]         cnt_w_real;

    wire is_last_weight = cnt_n_real == OUTPUTS-1 && cnt_w_real == INPUTS;

    // Out

    reg signed [NUM_W - 1 : 0] results_f        [0 : OUTPUTS - 1];
    wire                       results_f_shifts [0 : OUTPUTS - 1];
    reg signed [NUM_W - 1 : 0] results_b        [0 : INPUTS  - 1];

    wire signed [NUM_W - 1 : 0] v1 = is_back_weights ? 
                                  inputs_f[cnt_w_real] : // input
                                  ram_data_read;         // weight
    wire signed [NUM_W - 1 : 0] v2 = is_back ?
                                  inputs_b[cnt_n_real] : // output
                                  inputs_f[cnt_w_real];  // input

    assign mult_v1 = mult_en ? v1 : 0;
    assign mult_v2 = mult_en ? v2 : 0;
    assign mult_shift = (mult_en && is_back) ? results_f_shifts[cnt_n_real] : 1'd0;

    genvar i;
    generate for(i = 0; i<OUTPUTS; i++) begin
        assign output_f[i]         = activation_clamped_RELU(results_f[i]);
        assign results_f_shifts[i] = activation_clamped_RELU_diffshift(results_f[i]);
    end endgenerate
    assign output_b = results_b;

    assign ready_out = !is_busy;

    function signed [NUM_W - 1 : 0] activation_clamped_RELU (input signed [NUM_W - 1 : 0] in); begin
        activation_clamped_RELU =
            // in > (RELU_MAX << FRAC_W) ? ((in - (RELU_MAX << FRAC_W)) >>> RELU_SHIFT) + (RELU_MAX << FRAC_W) :
            in < 0                    ? ((in                       ) >>> RELU_SHIFT)                        :
                                        ((in                       )               );
    end endfunction
    
    function activation_clamped_RELU_diffshift (input signed [NUM_W - 1 : 0] in); begin
        activation_clamped_RELU_diffshift =
            // in > (RELU_MAX << FRAC_W) ? 1'd1 :
            in < 0                    ? 1'd1 :
                                        1'd0;
    end endfunction

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

    function signed [NUM_W - 1 : 0] get_clumped_sum (input signed [NUM_W - 1 : 0] v1, input signed [NUM_W - 1 : 0] v2);
        logic v1_sign, v2_sign, res_sign;
        logic overflow;
        logic signed [NUM_W - 1 : 0] res;
    begin
        v1_sign  = v1[NUM_W - 1];
        v2_sign  = v2[NUM_W - 1];
        res      = v1 + v2;
        res_sign = res[NUM_W - 1];
        overflow = (v1_sign == v2_sign) && (v1_sign != res_sign);
        get_clumped_sum = 
            (overflow && !v1_sign) ? MAX_VALUE_POS :
            (overflow &&  v1_sign) ? MAX_VALUE_NEG :
                                     res;
    end endfunction

    always @(posedge clk, negedge nreset) begin
        if(!nreset) begin
            RESET_COUNTERS();
            RESET_BUSES();
            state     <= IDLE;
            results_f <= '{default: 0};
            results_b <= '{default: 0};
        end else if(enable) begin
            if(state == WAIT_FOR_READY_B) begin // Wait for ready for BackPropagation
                if(ready_b_in) begin
                    cnt_delay      <= RAM_DELAY;
                    ram_addr_read  <= RAM_ADDR_START;
                    mult_en        <= 1'd1;
                    state          <= CALC_B1;
                end
            end else 
            if(state == WAIT_FOR_READY_F) begin // Wait for ready for ForwardPass
                if(ready_f_in) begin
                    cnt_delay      <= RAM_DELAY;
                    ram_addr_read  <= RAM_ADDR_START;
                    mult_en        <= 1'd1;
                    state          <= CALC_F;
                end
            end else 
            if(state == CALC_B1) begin // Calculate BackPropagation - Phase 1 (inputs)
                INC_RAM_READ();
                if(cnt_delay == 0) begin
                    if(cnt_w_real != INPUTS) begin
                        results_b[cnt_w_real] <= get_clumped_sum( results_b[cnt_w_real], mult_res);
                    end
                    if(is_last_weight) begin // Check if last operation
                        RESET_COUNTERS();
                        RESET_BUSES();
                        cnt_delay       <= RAM_DELAY;
                        ram_addr_read   <= RAM_ADDR_START;
                        ram_addr_write  <= RAM_ADDR_START - 1'd1;
                        mult_en         <= 1'd1;
                        state           <= CALC_B2;
                    end
                end
            end else
            if(state == CALC_B2) begin // Calculate BackPropagation - Phase 2 (weights)
                INC_RAM_READ();
                if(cnt_delay == 0) begin
                    ram_write      <= 1'd1;
                    ram_addr_write <= ram_addr_write + 1'd1;
                         if(cnt_w_real != INPUTS)          ram_data_write <= get_clumped_sum(ram_data_read, mult_res >>> LEARNING_SHIFT);
                    else if(results_f_shifts[cnt_n_real])  ram_data_write <= get_clumped_sum(ram_data_read, inputs_b[cnt_n_real] >>> (RELU_SHIFT + LEARNING_SHIFT));
                    else                                   ram_data_write <= get_clumped_sum(ram_data_read, inputs_b[cnt_n_real] >>> LEARNING_SHIFT);
                    if(is_last_weight) begin // Check if last operation
                        state <= FINALIZE;
                    end
                end
            end else
            if(state == CALC_F) begin // Calculate ForwardPass
                INC_RAM_READ();
                if(cnt_delay == 0) begin
                    results_f[cnt_n_real] <= get_clumped_sum(
                        results_f[cnt_n_real],
                        cnt_w_real == INPUTS ? ram_data_read : mult_res
                    );
                    if(is_last_weight) begin // Check if last operation
                        RESET_COUNTERS();
                        RESET_BUSES();
                        state <= IDLE;
                    end
                end
            end else 
            if(state == FINALIZE) begin
                RESET_COUNTERS();
                RESET_BUSES();
                state <= IDLE;
            end else
            if(state == IDLE && (start_f || start_b)) begin // Wait for start
                RESET_COUNTERS();
                RESET_BUSES();
                if(start_b) begin
                    results_b <= '{default: 0};
                    state     <= WAIT_FOR_READY_B;
                end else begin
                    results_f <= '{default: 0};
                    state     <= WAIT_FOR_READY_F;
                end
            end
        end
    end
    
endmodule