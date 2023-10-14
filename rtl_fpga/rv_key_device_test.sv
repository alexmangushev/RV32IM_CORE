import rv_pkg::*;

module rv_key_device_test
(
    input   logic            CLOCK_50,
    input   logic    [3:0]   KEY,
    input   logic    [7:0]   SW,
    inout   logic    [35:0]  GPIO,
    output  logic    [6:0]   LEDR
);

// Clock, reset
logic               clk;
logic               arstn;
logic               arstn_i;
logic               arstn_ff;

// Data memory interface
logic               data_rvalid;
logic [XLEN-1:0]    data_rdata;
logic               data_req;
logic [XLEN-1:0]    data_addr;
logic               data_we;
logic [XLEN/8-1:0]  data_be;
logic [XLEN-1:0]    data_wdata;

assign clk          = CLOCK_50;
assign arstn_i      = KEY[0];

assign data_addr    = ADDRESS_KEY;
assign data_wdata   = '0;
assign data_req     = key_r & !KEY[2];
assign data_we      = '0;
assign data_be      = '0;

logic led_ff;
always_ff @ (posedge clk or negedge arstn)
if (!arstn)
        led_ff <= '0;
    else if (data_rvalid)
        led_ff <= data_rdata[0];

assign LEDR[0] = led_ff;

rv_key_device driver
(
    .clk_i               ( clk               ),
    .arstn_i             ( arstn             ),
    
    .data_rvalid_o       ( data_rvalid       ),   
    .data_rdata_o        ( data_rdata        ),   
    .data_req_i          ( data_req          ),
    .data_we_i           ( data_we           ),
    .data_be_i           ( data_be           ),
    .data_addr_i         ( data_addr         ),   
    .data_wdata_i        ( data_wdata        ),

    .key                 ( KEY[1]            )
);

logic key_r;

// Save last key state
always_ff @ (posedge clk or negedge arstn)
    if (!arstn)
        key_r <= '1;
    else 
        key_r <= KEY[2];

// reset synchronization
always_ff @(posedge clk or negedge arstn_i)
if (!arstn_i)
    {arstn, arstn_ff} <= '0;
else
    {arstn, arstn_ff} <= {arstn_ff, 1'b1};

endmodule
