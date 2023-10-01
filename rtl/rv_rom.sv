import rv_pkg::*;

module rv_rom
#(
    parameter latency = 3
)
(
  // Clock, reset
  input  logic              clk_i,
  input  logic              arstn_i,

  // Instruction memory interface
  output  logic              instr_rvalid_o,
  output  logic [XLEN-1:0]   instr_rdata_o,
  input   logic              instr_req_i,
  input   logic [XLEN-1:0]   instr_addr_i
);

logic [latency-1:0] instr_rvalid_delay;
logic [XLEN-1:0]    instr_addr;

always_comb
if ((instr_addr_i >> 2) >= ADDRESS_GATE)
            instr_addr = (instr_addr_i - ADDRESS_DEC_GE) >> 2;
        else 
            instr_addr = (instr_addr_i - ADDRESS_DEC_LT) >> 2;

//--------------------------
// Instruction memory model
//--------------------------
logic [XLEN-1:0] instr_mem 	[0:2 ** MEM_LEN-1];

always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        instr_rvalid_o      <= '0;
        instr_rvalid_delay  <= '0;
        instr_rdata_o       <= '0;
    end 
    else if (instr_req_i) begin
        instr_rvalid_o      <= instr_rvalid_delay[latency-1];
        instr_rvalid_delay  <= {instr_rvalid_delay[latency-2:0], 1'b1};
        instr_rdata_o       <= instr_mem[instr_addr];
    end else begin
        instr_rvalid_o      <= '0;
        instr_rdata_o       <= '0;
        instr_rvalid_delay  <= '0;
    end

initial
    $readmemh("C:/Users/alexandr/Desktop/ubuntu/RV32IM_CORE/program/mem.v", instr_mem);
    //$readmemh("/mnt/c/Users/alexandr/Desktop/ubuntu/RV32IM_CORE/program/mem.v", instr_mem);

endmodule