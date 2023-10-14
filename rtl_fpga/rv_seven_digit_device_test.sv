import rv_pkg::*;

module rv_seven_digit_device_test
(
    input   logic            CLOCK_50,
    input   logic    [3:0]   KEY,
    input   logic    [7:0]   SW,
    inout   logic    [35:0]  GPIO,
    output  logic    [6:0]   HEX0,
    output  logic    [6:0]   HEX1,
    output  logic    [6:0]   HEX2,
    output  logic    [6:0]   HEX3,
    output  logic    [6:0]   HEX4,
    output  logic    [6:0]   HEX5,
    output  logic    [6:0]   HEX6,
    output  logic    [6:0]   HEX7
);

// Indicator
logic [55:0]        hex;

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

assign {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = hex;
assign clk          = CLOCK_50;
assign arstn_i      = KEY[0];

assign data_addr    = ADDRESS_HEX;
assign data_wdata   = {24'h123465, SW};
assign data_req     = '1;
assign data_we      = ~KEY[1];
assign data_be      = '0;

rv_seven_digit_device driver
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

    .hex                 ( hex               )
);

// reset synchronization
always_ff @(posedge clk or negedge arstn_i)
if (!arstn_i)
    {arstn, arstn_ff} <= '0;
else
    {arstn, arstn_ff} <= {arstn_ff, 1'b1};

endmodule
