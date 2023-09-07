import rv_pkg::*;
module rv_core_testbench;


logic clk;
logic arstn;

logic [XLEN-1:0]   boot_addr;
assign boot_addr = 'h100dc;

// Instruction memory interface
logic              instr_rvalid;
logic [XLEN-1:0]   instr_rdata;
logic              instr_req;
logic [XLEN-1:0]   instr_addr;

// Data memory interface
logic              data_rvalid;
logic [XLEN-1:0]   data_rdata;
logic              data_req;
logic              data_we;
logic [XLEN/8-1:0] data_be;
logic [XLEN-1:0]   data_addr;
logic [XLEN-1:0]   data_wdata;

rv_core dut
(
    .clk_i               ( clk               ),
    .arstn_i             ( arstn             ),
    .boot_addr_i         ( boot_addr         ),

    .instr_rvalid_i      ( instr_rvalid      ),
    .instr_rdata_i       ( instr_rdata       ),
    .instr_req_o         ( instr_req         ),
    .instr_addr_o        ( instr_addr        ),

    .data_rvalid_i       ( data_rvalid       ),   
    .data_rdata_i        ( data_rdata        ),   
    .data_req_o          ( data_req          ),
    .data_we_o           ( data_we           ),
    .data_be_o           ( data_be           ),
    .data_addr_o         ( data_addr         ),   
    .data_wdata_o        ( data_wdata        )
);

//--------------------------
// Instruction memory model
//--------------------------
logic [XLEN-1:0] instr_mem 	[0:2 ** MEM_LEN-1];

always_ff @(posedge clk or negedge arstn)
    if (!arstn) begin
        instr_rvalid    <= '0;
        instr_rdata     <= '0;
    end 
    /*else if (data_req) begin
        instr_rvalid    <= '1;
        instr_rdata     <= instr_mem[instr_addr >> 2];
    end else begin
        instr_rvalid    <= '0;
        instr_rdata     <= '0;
    end*/

initial
    $readmemh("C:/Users/alexandr/Desktop/ubuntu/RV32IM_CORE/program/mem.v", instr_mem);

//--------------------------
// Data memory model
//--------------------------
logic [XLEN-1:0] data_mem 	[0:2 ** XLEN-1];

always_ff @(posedge clk or negedge arstn)
    if (!arstn) begin
        data_rvalid    <= '0;
        data_rdata     <= '0;
    end 
    else if (instr_req) begin
        data_rvalid    <= '1;
        data_rdata     <= instr_mem[instr_addr >> 2];
    end else begin
        data_rvalid    <= '0;
        data_rdata     <= '0;
    end

//--------------------------

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,dut);
    clk = 0;
    arstn = 0;
    #2; arstn = 1;
    #10000;
    $display("PASS");
    $finish();
end

always
	#1 clk <= !clk;

endmodule