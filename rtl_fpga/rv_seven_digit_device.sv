import rv_pkg::*;

module rv_seven_digit_device
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

    // Seven digit indicators
    output  logic [55:0]        hex
);

logic [XLEN-1:0] data_ff;
logic            data_ff_en;

assign data_ff_en = (data_addr_i == ADDRESS_HEX && data_we_i);

genvar i;
generate
    for (i = 0; i < 8; i++) begin : dr
        seven_digit_driver driver
        (
            .number             (data_ff[(i+1)*4-1:i*4]),
            .seven_digit_data   (hex    [(i+1)*7-1:i*7])
        );
    end
endgenerate

always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
        data_ff         <= '0;
    end
    else if (data_ff_en) begin
        data_rvalid_o   <= '1;
        data_ff         <= data_wdata_i;
    end

endmodule
