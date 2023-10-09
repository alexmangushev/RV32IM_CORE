import rv_pkg::*;

module rv_ram
#(
    parameter latency = 3
)
(
  // Clock, reset
  input  logic              clk_i,
  input  logic              arstn_i,

  // Data memory interface
  output  logic              data_rvalid_o,
  output  logic [XLEN-1:0]   data_rdata_o,
  input   logic              data_req_i,
  input   logic              data_we_i,
  input   logic [XLEN/8-1:0] data_be_i,
  input   logic [XLEN-1:0]   data_addr_i,
  input   logic [XLEN-1:0]   data_wdata_i
);


//--------------------------
// Data memory model
//--------------------------
logic [XLEN-1:0]    data_mem 	[0:2 ** MEM_LEN-1];
logic [latency-1:0] data_rvalid_delay;
logic [XLEN-1:0]    data_addr;

assign data_addr = data_addr_i >> 2;

// read
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        data_rvalid_o       <= '0;
        data_rvalid_delay   <= '0;
        data_rdata_o        <= '0;
    end 
    else if (data_req_i) begin
        data_rvalid_o       <= data_rvalid_delay[latency-1];
        data_rvalid_delay   <= {data_rvalid_delay[latency-2:0], 1'b1};
        data_rdata_o        <= data_mem[data_addr];
    end else begin
        data_rvalid_delay   <= '0;
        data_rvalid_o       <= '0;
        data_rdata_o        <= '0;
    end

// write
always_ff @(posedge clk_i) begin
    if(data_req_i && data_we_i && data_be_i[0])
        data_mem [data_addr] [7:0]   <= data_wdata_i[7:0];
    if(data_req_i && data_we_i && data_be_i[1])
        data_mem [data_addr] [15:8]  <= data_wdata_i[15:8];
    if(data_req_i && data_we_i && data_be_i[2])
        data_mem [data_addr] [23:16] <= data_wdata_i[23:16];
    if(data_req_i && data_we_i && data_be_i[3])
        data_mem [data_addr] [31:24] <= data_wdata_i[31:24];
end

initial begin
    $readmemh("C:/Users/alexandr/Desktop/ubuntu/RV32IM_CORE/program/mem.v", data_mem);
    data_mem [262140] = 'b1;
    //$readmemh("/mnt/c/Users/alexandr/Desktop/ubuntu/RV32IM_CORE/program/mem.v", data_mem);
end

endmodule