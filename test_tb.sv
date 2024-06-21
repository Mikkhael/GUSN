`timescale 1ns/1ns


module TEST_TB ();


reg clk = 0;
reg nreset = 0;
reg enable = 0;

parameter INPUTS  = 3;
parameter OUTPUTS = 2;
parameter INT_W  = 8;
parameter FRAC_W = 8;
parameter NUM_W  = INT_W + FRAC_W;
parameter RAM_ADDR_W = 8;
parameter RAM_DATA_W = NUM_W;
parameter RAM_SIZE   = 2**RAM_ADDR_W;

reg start_b = 0;
reg start_f = 0;

reg  signed [NUM_W - 1 : 0] inputs       [0 : INPUTS-1];
wire signed [NUM_W - 1 : 0] inputs_diff  [0 : INPUTS-1];
wire signed [NUM_W - 1 : 0] outputs      [0 : OUTPUTS-1];
reg  signed [NUM_W - 1 : 0] outputs_diff [0 : OUTPUTS-1];

wire layer_1_ready;

wire ram_write;
wire [RAM_ADDR_W - 1 : 0] ram_addr_write;
wire [RAM_ADDR_W - 1 : 0] ram_addr_read;
wire [NUM_W - 1 : 0] ram_data_write;
wire [NUM_W - 1 : 0] ram_data_read;

wire mult_en;
wire [NUM_W - 1 : 0] mult_v1;
wire [NUM_W - 1 : 0] mult_v2;
wire [NUM_W - 1 : 0] mult_res;

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
    .FRAC_W  (FRAC_W)
) mult (
    .mult_v1    (mult_v1),
    .mult_v2    (mult_v2),
    .mult_res   (mult_res)
);

LAYER # (
    .INT_W              (INT_W),
    .FRAC_W             (FRAC_W),
    .INPUTS             (INPUTS),
    .OUTPUTS            (OUTPUTS),
    .RAM_ADDR_W         (RAM_ADDR_W),
    .RAM_ADDR_START     (0),
    .RAM_DELAY          (1)
) layer_1 (
    .clk        (clk),
    .nreset     (nreset),
    .enable     (enable),

    .inputs_f   (inputs),
    .inputs_b   (outputs_diff),
    .output_f   (outputs),
    .output_b   (inputs_diff),

    .mult_en    (mult_en),
    .mult_v1    (mult_v1),
    .mult_v2    (mult_v2),
    .mult_res   (mult_res),

    .ram_write      (ram_write),
    .ram_addr_write (ram_addr_write),
    .ram_data_write (ram_data_write),
    .ram_addr_read  (ram_addr_read),
    .ram_data_read  (ram_data_read),

    .ready_f_in (1'd1),
    .ready_b_in (1'd1),
    .ready_out  (layer_1_ready),

    .start_f    (start_f),
    .start_b    (start_b)
);


LAYER_TEST # (
    .INPUTS(INPUTS),.OUTPUTS(OUTPUTS),.INT_W(INT_W),.FRAC_W(FRAC_W),.RAM_SIZE(RAM_SIZE),
    .RAM_ADDR_START     (0),
    .LAYER_ID           (1)
) layer_test_1 (
    .clk(clk),.nreset(nreset),.enable(enable),.ram_data(ram.data),
    .start_f    (layer_1.start_f),
    .ready_f    (layer_1.ready_f_in),
    .start_b    (layer_1.start_b),
    .ready_b    (layer_1.ready_b_in),
    .inputs_f   (layer_1.inputs_f),
    .inputs_b   (layer_1.inputs_b),
    .results_f  (layer_1.results_f),
    .results_b  (layer_1.results_b)
);




always #10 clk = !clk;

initial begin
    #10000000
    $stop;
end

integer i;
initial begin
    for(i = 0; i<(INPUTS + 1) * OUTPUTS; i++) begin
        ram.data[i] = i << (FRAC_W-1); 
        if(i % 2 == 0) ram.data[i] = -ram.data[i];
    end
    #100;
    nreset = 1;
    enable = 1;
    #100;

    for(i = 0; i < INPUTS; i++) begin
        inputs[i] = (i << FRAC_W) + 2**(FRAC_W-1);
    end
    start_f = 1;
    #20
    start_f = 0;

    wait(layer_1_ready);

    $display("LAYER 1 MATCHES F: %d", layer_test_1.matches_f_sim);

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

reg signed [NUM_W - 1 : 0] results_f_sim [0 : OUTPUTS-1];
reg signed [NUM_W - 1 : 0] results_b_sim [0 : INPUTS-1];
reg                        matches_f_sim;
assign matches_f_sim = results_f_sim == layer_1.results_f;

integer i,j;
integer ram_off_sim;
always @(posedge clk, negedge nreset) begin
    if(!nreset) begin
        results_b_sim = '{default : 0};
        results_f_sim = '{default : 0};
    end else if(enable) begin
        if(start_f && ready_f) begin
            results_f_sim = '{default : 0};
            ram_off_sim   = RAM_ADDR_START;
            for(i = 0; i < OUTPUTS; i++) begin
                for(j = 0; j <= INPUTS; j++) begin
                    results_f_sim[i] += j == INPUTS ? ram_data[ram_off_sim] : my_mult(ram_data[ram_off_sim], inputs_f[j]);
                    $display("LAYER %d = I: %d (%h), J: %d (%h), RAM: %d (%h)", LAYER_ID, i, results_f_sim[i], j, inputs_f[j], ram_off_sim, ram_data[ram_off_sim]);
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
    my_mult = temp >> FRAC_W;
end endfunction

endmodule
