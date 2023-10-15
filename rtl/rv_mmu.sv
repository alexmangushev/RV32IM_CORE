import rv_pkg::*;

module rv_mmu
(
  // Data memory interface in
  output  logic              data_rvalid_o,
  output  logic [XLEN-1:0]   data_rdata_o,
  input   logic              data_req_i,
  input   logic              data_we_i,
  input   logic [XLEN/8-1:0] data_be_i,
  input   logic [XLEN-1:0]   data_addr_i,
  input   logic [XLEN-1:0]   data_wdata_i,

  // Data memory interface out
  input   logic              data_rvalid_hex_i,
  input   logic [XLEN-1:0]   data_rdata_hex_i,

  input   logic              data_rvalid_sram_i,
  input   logic [XLEN-1:0]   data_rdata_sram_i,

  input   logic              data_rvalid_key_i,
  input   logic [XLEN-1:0]   data_rdata_key_i,

  output  logic              data_req_sram_o,  
  output  logic              data_req_o,
  output  logic              data_we_o,
  output  logic [XLEN/8-1:0] data_be_o,
  output  logic [XLEN-1:0]   data_addr_o,
  output  logic [XLEN-1:0]   data_wdata_o
);

// Don't set request for memory if working with pereferial 
assign data_req_sram_o  = (~data_addr_i[XLEN-1]) ? data_req_i : '0 ;
assign data_req_o       = data_req_i;
assign data_we_o        = data_we_i;
assign data_be_o        = data_be_i;
assign data_wdata_o     = data_wdata_i;  

always_comb 
    if (data_addr_i >= ADDRESS_GATE && data_addr_i < ADDRESS_PER) begin
        data_addr_o = data_addr_i - ADDRESS_DEC_GE;
    end
    else if (data_addr_i < ADDRESS_GATE) begin
        data_addr_o = data_addr_i - ADDRESS_DEC_LT;
    end
    else
        data_addr_o = data_addr_i;

// rvalid and rdata
always_comb
  if (data_addr_o == ADDRESS_HEX) begin
    data_rvalid_o   = data_rvalid_hex_i;
    data_rdata_o    = data_rdata_hex_i;
  end
  else if (data_addr_o == ADDRESS_KEY) begin
    data_rvalid_o   = data_rvalid_key_i;
    data_rdata_o    = data_rdata_key_i;
  end 
  else begin
    data_rvalid_o   = data_rvalid_sram_i;
    data_rdata_o    = data_rdata_sram_i;
  end
  

endmodule