typedef struct {
    logic                       ram_read;
    logic                       ram_write;
    logic [RAM_ADDR_W - 1 : 0]  ram_addr;
    logic [NUM_W - 1 : 0]       ram_data_write;
    logic [NUM_W - 1 : 0]       mult_v1;
    logic [NUM_W - 1 : 0]       mult_v2;
} arb_struct_t;