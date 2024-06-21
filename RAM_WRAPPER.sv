module RAM_WRAPPER #(
    parameter ADDR_W = 8,
    parameter DATA_W = 8,
    
    parameter SIZE = 2**ADDR_W
) (

    input clk,

    input                        ram_write,
    input      [ADDR_W - 1 : 0]  ram_addr_write,
    input      [ADDR_W - 1 : 0]  ram_addr_read,
    input      [DATA_W - 1 : 0]  ram_data_write,
    output reg [DATA_W - 1 : 0]  ram_data_read
);

reg [DATA_W - 1 : 0] data [0 : SIZE - 1];

always @(posedge clk) begin
    ram_data_read <= data[ram_addr_read];
    if(ram_write) begin
        data[ram_addr_write] <= ram_data_write;
    end
end

endmodule