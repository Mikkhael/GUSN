module MULT_WRAPPER #(
    parameter INT_W  = 8,
    parameter FRAC_W = 8,
    parameter NUM_W = INT_W + FRAC_W
) (
    input  signed  [NUM_W - 1 : 0] mult_v1,
    input  signed  [NUM_W - 1 : 0] mult_v2,
    output signed  [NUM_W - 1 : 0] mult_res
);

wire signed [NUM_W*2        - 1 : 0] res;
wire signed [NUM_W*2-FRAC_W - 1 : 0] res_shifted;

parameter signed [NUM_W - 1 : 0] MAX_VALUE_POS = {1'b0, {(NUM_W-1){1'b1}}};
parameter signed [NUM_W - 1 : 0] MAX_VALUE_NEG = {1'b1, {(NUM_W-1){1'b0}}};

assign res         = mult_v1 * mult_v2;
assign res_shifted = res >>> FRAC_W;

assign mult_res = 
    res_shifted > MAX_VALUE_POS ? MAX_VALUE_POS :
    res_shifted < MAX_VALUE_NEG ? MAX_VALUE_NEG :
                                  res_shifted;
  

endmodule