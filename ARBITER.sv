module ARBITER #(
    parameter SOURCES = 1,
) (
    output arb_struct_out,
    input  arb_structs_in,

    input  n_mult_en,
);

`include "arb_struct.svh"

wire arb_struct_t arb_structs_in [0 : SOURCES - 1];
     arb_struct_t arb_struct_out;

wire n_mult_en [0 : SOURCES - 1];

logic done;
integer i;
always_comb begin
    done = 0;
    for(i = 0; i < SOURCES; i++) begin
        if(n_mult_en[i]) begin
            arb_struct_out <= arb_structs_in[i];
        end else if(done) begin
            $error(" N_MULT_EN INVALID !!!")
        end
    end
end

endmodule