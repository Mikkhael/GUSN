module NEURON #(
    parameter INT_W  = 8,
    parameter FRAC_W = 8,

    parameter INPTUS  = 1,
    parameter OUTPUTS = 1,

    parameter RAM_ADDR_W = 8,
    parameter RAM_ADDR_START   = 0,
    parameter RAM_ADDR_ROW_OFF = 0,
    parameter RAM_ADDR_BIAS    = 0,
    
    parameter RAM_DELAY = 3,

    parameter NUM_W = INT_W + FRAC_W
) (
    input clk,
    input nreset,
    input enable,

    input      [NUM_W - 1 : 0]       inputs_f [0 : INPTUS - 1],
    input      [NUM_W - 1 : 0]       inputs_b [0 : OUTPUTS - 1],
    output reg [NUM_W - 1 : 0]       output_f,
    output reg [NUM_W - 1 : 0]       output_b,

    output reg                       mult_en,
    output     [NUM_W - 1 : 0]       mult_v1,
    output     [NUM_W - 1 : 0]       mult_v2,
    input      [NUM_W - 1 : 0]       mult_res,

    RAM_INTF.neuron ram_intf,

    input  ready_f_in,
    input  ready_b_in,
    output ready_out,

    input start_init,
    input start_f,
    input start_b
);

    enum { IDLE, WAIT_F, MULT_F, BIAS_F, WAIT_B, MULT_B } state;
    
    assign ready_out = state == IDLE;

    localparam INPUTS_W  = $clog2(INPUTS)  == 0 ? 1 : $clog2(INPTUS);
    localparam OUTPUTS_W = $clog2(OUTPUTS) == 0 ? 1 : $clog2(OUTPUTS);
    localparam MAX_CNT_W = INPUTS_W > OUTPUTS_W ? INPUTS_W : OUTPUTS_W;

    reg [MAX_CNT_W-1 : 0] cnt_ram;
    reg [MAX_CNT_W-1 : 0] cnt;

    reg [$clog2(RAM_DELAY+1) - 1:0] ram_delay_cnt;

    assign mult_v1 = ram_intf.data_read;
    assign mult_v2 = state == MULT_F ? inputs_f[cnt] : inputs_b[cnt];

    always @(posedge clk, negedge nreset) begin
        if(!nreset) begin
            output_f        <= 0;
            output_b        <= 0;
            ram_intf.read   <= 0;
            ram_intf.write  <= 0;
            mult_en         <= 0;
            ram_delay_cnt   <= 0;
            input_cnt_ram   <= 0;
            output_cnt_ram  <= 0;
            input_cnt       <= 0;
            output_cnt      <= 0;
            state    <= IDLE;
        end else if(enable) begin
            case(state)
                IDLE: begin
                    if(start_f) begin
                        output_f <= 0;
                        state    <= WAIT_F;
                    end else 
                    if(start_b) begin

                    end
                end

                WAIT_F: begin
                    if(ready_f_in) begin
                        cnt           <= 0;
                        cnt_ram       <= 1;
                        ram_intf.read <= 1;
                        mult_en       <= 1;
                        ram_intf.addr <= RAM_ADDR_START;
                        ram_delay_cnt <= RAM_DELAY;
                        state <= MULT_F;
                    end
                end

                MULT_F: begin
                    if(cnt_ram == INPUTS) begin
                        ram_intf.addr <= RAM_ADDR_BIAS;
                    end else begin
                        cnt_ram       <= cnt_ram       + 1'd1;
                        ram_intf.addr <= ram_intf.addr + 1'd1;
                    end
                    if(ram_delay_cnt != 0) begin
                        ram_delay_cnt <= ram_delay_cnt - 1'd1;
                    end else begin
                        if(cnt == INPUTS) begin
                            output_f <= output_f + ram_intf.data_read;
                            state <= IDLE;
                        end else begin
                            output_f <= output_f + mult_res;
                            cnt <= cnt + 1'd1;
                        end
                    end
                end

            endcase
        end
    end
    
endmodule