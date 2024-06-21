`timescale 1ns/1ns


module TEST_TB ();


reg clk = 0;
reg nreset = 0;
reg enable = 0;

parameter INPUTS  = 3;
parameter OUTPUTS = 2;
parameter INT_W  = 9;
parameter FRAC_W = 8;
parameter NUM_W  = INT_W + FRAC_W;
parameter RAM_ADDR_W = 8;
parameter RAM_DATA_W = NUM_W;
parameter RAM_SIZE   = 2**RAM_ADDR_W;

parameter RELU_SHIFT = 4;
parameter RELU_MAX   = 1;

parameter LAYERS_COUNT      = 3;
parameter integer LAYER_SIZES [0:3] = {INPUTS, 5, 4, OUTPUTS};

reg start_b = 0;
reg start_f = 0;

reg  signed [NUM_W - 1 : 0] inputs       [0 : INPUTS-1];
wire signed [NUM_W - 1 : 0] inputs_diff  [0 : INPUTS-1];
wire signed [NUM_W - 1 : 0] outputs      [0 : OUTPUTS-1];
reg  signed [NUM_W - 1 : 0] outputs_diff [0 : OUTPUTS-1];

wand all_ready = 1'd1;

wor  ram_write;
wor  [RAM_ADDR_W - 1 : 0] ram_addr_write;
wor  [RAM_ADDR_W - 1 : 0] ram_addr_read;
wor  [NUM_W - 1 : 0] ram_data_write;
wire [NUM_W - 1 : 0] ram_data_read;

wor  mult_en;
wor  signed [NUM_W - 1 : 0] mult_v1;
wor  signed [NUM_W - 1 : 0] mult_v2;
wor                         mult_shift;
wire signed [NUM_W - 1 : 0] mult_res;

RAM_WRAPPER #(
    .ADDR_W (RAM_ADDR_W),
    .DATA_W (RAM_DATA_W),
    .SIZE   (RAM_SIZE)
) ram (
    .clk        (clk),

    .ram_write       (ram_write),
    .ram_addr_write  (ram_addr_write),
    .ram_data_write  (ram_data_write),
    .ram_addr_read   (ram_addr_read),
    .ram_data_read   (ram_data_read)
);

MULT_WRAPPER #(
    .INT_W   (INT_W),
    .FRAC_W  (FRAC_W),
    .SHIFT   (RELU_SHIFT)
) mult (
    .mult_v1    (mult_v1),
    .mult_v2    (mult_v2),
    .mult_shift (mult_shift),
    .mult_res   (mult_res)
);

genvar i;
generate for(i = 0; i < LAYERS_COUNT; i++) begin : generate_layers

localparam i_prev = (i == 0)                ? 0 : i - 1;
localparam i_next = (i == LAYERS_COUNT - 1) ? 0 : i + 1;

localparam L_INPUTS  = LAYER_SIZES[i];
localparam L_OUTPUTS = LAYER_SIZES[i+1];
localparam L_RAM_START = i == 0 ? 0 : (generate_layers[i_prev].L_RAM_START + ((1 + LAYER_SIZES[i_prev]) *  LAYER_SIZES[i]));

wire signed [NUM_W - 1 : 0] l_outputs_f [0 : L_OUTPUTS - 1];
wire signed [NUM_W - 1 : 0] l_outputs_b [0 : L_INPUTS - 1];

wire l_ready_f;
wire l_ready_b;
wire l_ready_out;

wire signed [NUM_W - 1 : 0] l_inputs_f  [0 : L_INPUTS-1];
wire signed [NUM_W - 1 : 0] l_inputs_b  [0 : L_OUTPUTS-1];

if(i != 0) begin
    assign l_inputs_f = generate_layers[i_prev].l_outputs_f;
    assign l_ready_f  = generate_layers[i_prev].l_ready_out;
end else begin
    assign l_inputs_f = inputs;
    assign l_ready_f = 1;
    assign inputs_diff = l_outputs_b;
end
if(i != LAYERS_COUNT - 1) begin
    assign l_inputs_b = generate_layers[i_next].l_outputs_b;
    assign l_ready_b  = generate_layers[i_next].l_ready_out;
end else begin
    assign l_inputs_b = outputs_diff;
    assign l_ready_b = 1;
    assign outputs = l_outputs_f;
end

assign all_ready = l_ready_out;

LAYER # (
    .INT_W              (INT_W),
    .FRAC_W             (FRAC_W),
    .RAM_ADDR_W         (RAM_ADDR_W),
    .INPUTS             (L_INPUTS),
    .OUTPUTS            (L_OUTPUTS),
    .RAM_ADDR_START     (L_RAM_START),
    .RELU_SHIFT         (RELU_SHIFT),
    .RELU_MAX           (RELU_MAX),
    .RAM_DELAY          (1)
) layer (
    .clk        (clk),
    .nreset     (nreset),
    .enable     (enable),

    .inputs_f   (l_inputs_f),
    .inputs_b   (l_inputs_b),
    .output_f   (l_outputs_f),
    .output_b   (l_outputs_b),

    .mult_en    (mult_en),
    .mult_v1    (mult_v1),
    .mult_v2    (mult_v2),
    .mult_shift (mult_shift),
    .mult_res   (mult_res),

    .ram_write      (ram_write),
    .ram_addr_write (ram_addr_write),
    .ram_data_write (ram_data_write),
    .ram_addr_read  (ram_addr_read),
    .ram_data_read  (ram_data_read),

    .ready_f_in (l_ready_f),
    .ready_b_in (l_ready_b),
    .ready_out  (l_ready_out),

    .start_f    (start_f),
    .start_b    (start_b)
);

LAYER_TEST # (
    .INPUTS(L_INPUTS),.OUTPUTS(L_OUTPUTS),.INT_W(INT_W),.FRAC_W(FRAC_W),.RAM_SIZE(RAM_SIZE),
    .RAM_ADDR_START     (L_RAM_START),
    .LAYER_ID           (i + 1)
) layer_test (
    .clk(clk),.nreset(nreset),.enable(enable),.ram_data(ram.data),
    .start_f    (layer.start_f),
    .ready_f    (layer.ready_f_in),
    .start_b    (layer.start_b),
    .ready_b    (layer.ready_b_in),
    .inputs_f   (layer.inputs_f),
    .inputs_b   (layer.inputs_b),
    .results_f  (layer.results_f),
    .results_b  (layer.results_b)
);

end endgenerate

assign outputs     = generate_layers[LAYERS_COUNT - 1].l_outputs_f;
assign inputs_diff = generate_layers[0].l_outputs_b;

generate for(i = 0; i < OUTPUTS; i++) begin
    assign outputs_diff[i] = loss_function(1, i, outputs);
end endgenerate

parameter OUTPUTS_W = $clog2(OUTPUTS);
function [NUM_W - 1 : 0] loss_function (
    input [OUTPUTS_W-1 : 0] label,
    input [OUTPUTS_W-1 : 0] output_id,
    input signed [NUM_W - 1 : 0] outputs [0 : OUTPUTS - 1]);
begin
    if(label == output_id) loss_function = (RELU_MAX - outputs[output_id]);
    else                   loss_function = (0        - outputs[output_id]);
end endfunction


always #10 clk = !clk;

initial begin
    #10000000
    $stop;
end

integer j;
initial begin
    for(j = 0; j<RAM_SIZE; j++) begin
        ram.data[j] = $random() % (1 << (FRAC_W + 1));
        if($random() % 2 == 0) ram.data[j] = -ram.data[j];
    end
    #100;
    nreset = 1;
    enable = 1;
    #100;

    for(j = 0; j < INPUTS; j++) begin
        inputs[j] = (j << FRAC_W) + 2**(FRAC_W-1);
    end
    start_f = 1;
    #20
    start_f = 0;

    wait(all_ready);

    $display("LAYER 1 MATCHES F: %d", generate_layers[0].layer_test.matches_f_sim);
    $display("LAYER 2 MATCHES F: %d", generate_layers[1].layer_test.matches_f_sim);
    $display("LAYER 3 MATCHES F: %d", generate_layers[2].layer_test.matches_f_sim);

    #20;
    start_b = 1;
    #20
    start_b = 0;

    wait(all_ready);

    $display("LAYER 3 MATCHES B: %d", generate_layers[2].layer_test.matches_b_sim);
    $display("LAYER 2 MATCHES B: %d", generate_layers[1].layer_test.matches_b_sim);
    $display("LAYER 1 MATCHES B: %d", generate_layers[0].layer_test.matches_b_sim);

    #100;
    $stop;
end


endmodule

module LAYER_TEST # (
    parameter INPUTS  = 3,
    parameter OUTPUTS = 2,
    parameter INT_W  = 8,
    parameter FRAC_W = 8,
    parameter RAM_SIZE   = 0,
    parameter RELU_SHIFT = 4,
    parameter RELU_MAX   = 1,
    parameter RAM_ADDR_START = 0,
    parameter LAYER_ID = 0,
    parameter NUM_W  = INT_W + FRAC_W
)(
    input clk,
    input nreset,
    input enable,

    input start_f,
    input ready_f,
    input start_b,
    input ready_b,

    input signed [NUM_W - 1 : 0] inputs_f  [0 : INPUTS-1],
    input signed [NUM_W - 1 : 0] results_f [0 : OUTPUTS-1],
    input signed [NUM_W - 1 : 0] inputs_b  [0 : OUTPUTS-1],
    input signed [NUM_W - 1 : 0] results_b [0 : INPUTS-1],


    input [NUM_W - 1 : 0] ram_data [0 : RAM_SIZE-1]
);

parameter signed [NUM_W - 1 : 0] MAX_VALUE_POS = {1'b0, {(NUM_W-1){1'b1}}};
parameter signed [NUM_W - 1 : 0] MAX_VALUE_NEG = {1'b1, {(NUM_W-1){1'b0}}};


reg signed [NUM_W*2 - 1 : 0] temp;
reg signed [NUM_W*2 - 1 : 0] temp2;
reg signed [NUM_W   - 1 : 0] results_f_sim [0 : OUTPUTS-1];
reg signed [NUM_W   - 1 : 0] results_b_sim [0 : INPUTS-1];
reg                        matches_f_sim;
reg                        matches_b_sim;
assign matches_f_sim = results_f_sim == results_f;
assign matches_b_sim = results_b_sim == results_b;


wire results_f_diffshift_sim [0 : OUTPUTS-1];

genvar g;
generate for(g=0; g<OUTPUTS; g++) begin
assign results_f_diffshift_sim[g] =
        results_f_sim[g] > (RELU_MAX << FRAC_W) ? 1 :
        results_f_sim[g] < 0                    ? 1 :
                                                  0;
end endgenerate

reg is_waiting_for_ready_f = 1'd0;
reg is_waiting_for_ready_b = 1'd0;

integer i,j;
integer ram_off_sim;
always @(posedge clk, negedge nreset) begin
    if(!nreset) begin
        results_b_sim = '{default : 0};
        results_f_sim = '{default : 0};
        is_waiting_for_ready_f = 1'd0;
        is_waiting_for_ready_b = 1'd0;
    end else if(enable) begin
        if(start_f) is_waiting_for_ready_f <= 1'd1;
        if(start_b) is_waiting_for_ready_b <= 1'd1;
        if(is_waiting_for_ready_f && ready_f) begin
            is_waiting_for_ready_f <= 1'd0;
            results_f_sim = '{default : 0};
            ram_off_sim   = RAM_ADDR_START;
            for(i = 0; i < OUTPUTS; i++) begin
                for(j = 0; j <= INPUTS; j++) begin
                    temp2 = my_mult(ram_data[ram_off_sim], inputs_f[j]);
                    temp = results_f_sim[i] + (j == INPUTS ?
                                $signed(ram_data[ram_off_sim]) : 
                                temp2
                            );
                         if(temp < MAX_VALUE_NEG) results_f_sim[i] = MAX_VALUE_NEG;
                    else if(temp > MAX_VALUE_POS) results_f_sim[i] = MAX_VALUE_POS;
                    else                          results_f_sim[i] = temp;
                    // $display("LAYER %0d = OUT: %0d (%h) [%h] <%h>, IN: %0d (%h), RAM: %0d (%h)", LAYER_ID, i, results_f_sim[i], temp, temp2, j, inputs_f[j], ram_off_sim, ram_data[ram_off_sim]);
                    ram_off_sim += 1;
                end
            end 
        end
        if(is_waiting_for_ready_b && ready_b) begin
            is_waiting_for_ready_b <= 1'd0;
            results_b_sim = '{default : 0};
            ram_off_sim   = RAM_ADDR_START;
            for(i = 0; i < OUTPUTS; i++) begin
                for(j = 0; j <= INPUTS; j++) begin
                    if(j == INPUTS) begin
                        temp   = 0;
                        temp2 = -1;
                    end else begin
                        temp2 = my_mult(ram_data[ram_off_sim], inputs_b[i]);
                        temp2 = results_f_diffshift_sim[i] ? (temp2 >>> RELU_SHIFT) : temp2;
                        temp  = temp2 + results_b_sim[j];
                             if(temp < MAX_VALUE_NEG) results_b_sim[j] = MAX_VALUE_NEG;
                        else if(temp > MAX_VALUE_POS) results_b_sim[j] = MAX_VALUE_POS;
                        else                          results_b_sim[j] = temp;
                    end
                    $display("BACK_A %0d = OUT: %0d (%h) [%h] <%h>, IN: %0d (%h), RAM: %0d (%h)", LAYER_ID, j, results_b_sim[j], temp, temp2, i, inputs_b[i], ram_off_sim, ram_data[ram_off_sim]);
                    ram_off_sim += 1;
                end
            end 
        end
    end
end

function signed [NUM_W - 1 : 0] my_mult(input signed [NUM_W - 1 : 0] v1, input signed [NUM_W - 1 : 0] v2 );
    logic signed [NUM_W*2 - 1 : 0] temp;
begin
    temp = v1 * v2;
    temp = temp >>> FRAC_W;
    // $display("-   %h * %h = %h", v1, v2, temp);
         if(temp > MAX_VALUE_POS) my_mult = MAX_VALUE_POS;
    else if(temp < MAX_VALUE_NEG) my_mult = MAX_VALUE_NEG;
    else                          my_mult = temp;
end endfunction

endmodule
