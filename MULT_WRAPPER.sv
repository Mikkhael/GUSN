module MULT_WRAPPER #(
    parameter INT_W  = 8,
    parameter FRAC_W = 8,
    parameter NUM_W = INT_W + FRAC_W
) (
    input  signed  [NUM_W - 1 : 0] mult_v1,
    input  signed  [NUM_W - 1 : 0] mult_v2,
    output signed  [NUM_W - 1 : 0] mult_res
);

wire signed [NUM_W*2 - 1 : 0] res;

assign res      = mult_v1 * mult_v2;
assign mult_res = res >> FRAC_W;

endmodule