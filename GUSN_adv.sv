module NEURON_LAYER #(
    parameter INT_W  = 8,
    parameter FRAC_W = 8,

    parameter INPTUS  = 1,
    parameter OUTPUTS = 1,

    parameter BATCH_SIZE = 1,

    parameter RAM_ADDR_W = 8,
    
    parameter NUM_W = INT_W + FRAC_W
) (
    
    input clk,
    input nreset,
    input enable,

    input  [NUM_W - 1 : 0]       inputs [0 : INPTUS - 1],

    output [NUM_W - 1 : 0]       mult_v1  [0 : BATCH_SIZE - 1],
    output [NUM_W - 1 : 0]       mult_v2  [0 : BATCH_SIZE - 1],
    input  [NUM_W - 1 : 0]       mult_res [0 : BATCH_SIZE - 1],

    output [RAM_ADDR_W - 1 : 0] ram_addr,
    input  [NUM_W - 1 : 0]      ram_values [0 : BATCH_SIZE - 1]
);

    localparam WEIGHTS_COUNT = (INPUTS*OUTPUTS)
    localparam BATCHES_COUNT = WEIGHTS_COUNT / BATCH_SIZE;
    localparam BATCH_CNT_W  = $clog2(BATCHES_COUNT) == 0 ? 1 : $clog2(BATCHES_COUNT);
    localparam BATCH_SIZE_W = $clog2(BATCH_SIZE)    == 0 ? 1 : $clog2(BATCH_SIZE);
    localparam INPUTS_W     = $clog2(INPTUS)        == 0 ? 1 : $clog2(INPTUS);

    localparam BATCH_SIZE_W2 = $clog2(BATCH_SIZE+1);
    localparam INPUTS_W2     = $clog2(INPUTS+1);

    // typedef struct {
    //     [BATCH_CNT_W-1:0]  batch,
    //     [BATCH_SIZE_W-1:0] off
    // } BATCH_INDEX_LOOKUP_ENTRY_t;

    // typedef BATCH_INDEX_LOOKUP_ENTRY_t BATCH_INDEX_LOOKUP_t [0 : INPTUS-1] [0 : OUTPUTS-1];
    // localparam BATCH_INDEX_LOOKUP_t BATCH_INDEX_LOOKUP = init_BATCH_INDEX_LOOKUP();


    typedef struct {
        [BATCH_SIZE_W2-1:0] f_ram   [0 : BATCH_SIZE-1],
        [INPUTS_W2-1:0]     f_input [0 : BATCH_SIZE-1],
    } BATCH_LOOKUP_ENTRY_t;

    typedef BATCH_LOOKUP_ENTRY_t BATCH_LOOKUP_t [0 : BATCHES_COUNT - 1];
    localparam BATCH_LOOKUP_t BATCH_LOOKUP = init_BATCH_LOOKUP();



    reg  [NUM_W - 1 : 0] res_f [0 : OUTPUTS - 1];
    reg  [NUM_W - 1 : 0] res_b [0 : INPUTS - 1];
    reg  [$clog2(BATCHES_COUNT) - 1 : 0] batch_cnt;


    integer i;
    always @(posedge clk, negedge nreset) begin
        if(!nreset) begin
            res_f <= 0;
            res_b <= 0;
            batch_cnt <= 0;
        end else if (enable) begin
            for(i=0; i<BATCHES_COUNT; i++) begin
                // TODO
            end
        end
    end


    function integer coords_to_index (input integer col, input integer row) begin
        coords_to_index = col + INPTUS * ((INPTUS + row - col) % INPTUS);
    end endfunction

    function BATCH_INDEX_LOOKUP_t init_BATCH_INDEX_LOOKUP ()
        integer idx,
        integer row,
        integer col,
        integer start,
    begin
        idx = 0;
        col = 0;
        row = 0;
        start = 0;
        if(INPTUS > OUTPUTS) begin
            while(start < INPTUS) begin
                while(row < OUTPUTS) begin
                    BATCH_INDEX_LOOKUP_t[row][col].batch = idx / BATCHES_COUNT;
                    BATCH_INDEX_LOOKUP_t[row][col].off   = idx % BATCHES_COUNT;
                    idx++;
                    row = (row+1) % OUTPUTS;
                    col = (col+1) % INPTUS;
                end
                start++;
                col = start;
                row = 0;
            end
        end else begin
            while(start < OUTPUTS) begin
                while(col < INPTUS) begin
                    BATCH_INDEX_LOOKUP_t[row][col].batch = idx / BATCHES_COUNT;
                    BATCH_INDEX_LOOKUP_t[row][col].off   = idx % BATCHES_COUNT;
                    idx++;
                    row = (row+1) % OUTPUTS;
                    col = (col+1) % INPTUS;
                end
                start++;
                row = start;
                col = 0;
            end
        end
    end endfunction

    // function BATCH_INDEX_LOOKUP_t init_BATCH_INDEX_LOOKUP ()
    //     integer idx,
    //     integer row,
    //     integer col,
    //     integer start,
    // begin
    //     idx = 0;
    //     col = 0;
    //     row = 0;
    //     start = 0;
    //     if(INPTUS > OUTPUTS) begin
    //         while(start < INPTUS) begin
    //             while(row < OUTPUTS) begin
    //                 BATCH_INDEX_LOOKUP_t[row][col].batch = idx / BATCHES_COUNT;
    //                 BATCH_INDEX_LOOKUP_t[row][col].off   = idx % BATCHES_COUNT;
    //                 idx++;
    //                 row = (row+1) % OUTPUTS;
    //                 col = (col+1) % INPTUS;
    //             end
    //             start++;
    //             col = start;
    //             row = 0;
    //         end
    //     end else begin
    //         while(start < OUTPUTS) begin
    //             while(col < INPTUS) begin
    //                 BATCH_INDEX_LOOKUP_t[row][col].batch = idx / BATCHES_COUNT;
    //                 BATCH_INDEX_LOOKUP_t[row][col].off   = idx % BATCHES_COUNT;
    //                 idx++;
    //                 row = (row+1) % OUTPUTS;
    //                 col = (col+1) % INPTUS;
    //             end
    //             start++;
    //             row = start;
    //             col = 0;
    //         end
    //     end
    // end endfunction

endmodule
