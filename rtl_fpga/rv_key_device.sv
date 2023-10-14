import rv_pkg::*;

module rv_key_device
(
    // Clock, reset
    input   logic               clk_i,
    input   logic               arstn_i,

    // Data memory interface
    output  logic               data_rvalid_o,
    output  logic [XLEN-1:0]    data_rdata_o,
    input   logic               data_req_i,
    input   logic               data_we_i,
    input   logic [XLEN/8-1:0]  data_be_i,
    input   logic [XLEN-1:0]    data_addr_i,
    input   logic [XLEN-1:0]    data_wdata_i,

    // Key input
    input  logic                key
);

logic key_r;
logic key_pressed_r;

// Save last key state
always_ff @ (posedge clk_i or negedge arstn_i)
    if (!arstn_i)
        key_r <= '1;
    else 
        key_r <= key;

// Save press of key
always_ff @ (posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        key_pressed_r   <= '0;
        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
    end
    else if (data_req_i && data_addr_i == ADDRESS_KEY) begin
        key_pressed_r   <= '0;
        data_rvalid_o   <= '1;
        data_rdata_o    <= key_pressed_r;
    end
    else begin
        key_pressed_r   <= key_pressed_r | (key_r & !key);
        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
    end

endmodule