import rv_pkg::*;

module rv_tb_core
(
  // Clock, reset
  input  logic              clk_i,
  input  logic              arstn_i,

  input  logic [XLEN-1:0]   boot_addr_i
);

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


logic              data_rvalid_ram;
logic [XLEN-1:0]   data_rdata_ram;
logic              data_req_ram;
logic              data_we_ram;
logic [XLEN/8-1:0] data_be_ram;
logic [XLEN-1:0]   data_addr_ram;
logic [XLEN-1:0]   data_wdata_ram;

rv_core core
(
    .clk_i               ( clk_i             ),
    .arstn_i             ( arstn_i           ),
    .boot_addr_i         ( boot_addr_i       ),

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


rv_mmu mmu
(
  // Data memory interface in
  .data_rvalid_o        ( data_rvalid       ),
  .data_rdata_o         ( data_rdata        ),
  .data_req_i           ( data_req          ),
  .data_we_i            ( data_we           ),
  .data_be_i            ( data_be           ),
  .data_addr_i          ( data_addr         ),
  .data_wdata_i         ( data_wdata        ),

  // Data memory interface out
  .data_rvalid_hex_i    ( ),
  .data_rdata_hex_i     ( ),

  .data_rvalid_sram_i   ( data_rvalid_ram     ),
  .data_rdata_sram_i    ( data_rdata_ram      ),

  .data_rvalid_key_i    ( ),
  .data_rdata_key_i     ( ),

  .data_req_sram_o      ( data_req_ram        ),
  .data_req_o           (                     ),
  .data_we_o            ( data_we_ram         ),
  .data_be_o            ( data_be_ram         ),
  .data_addr_o          ( data_addr_ram       ),
  .data_wdata_o         ( data_wdata_ram      )
);


rv_rom rom
(
    .clk_i               ( clk_i             ),
    .arstn_i             ( arstn_i           ),

    .instr_rvalid_o      ( instr_rvalid      ),
    .instr_rdata_o       ( instr_rdata       ),
    .instr_req_i         ( instr_req         ),
    .instr_addr_i        ( instr_addr        )
);

rv_ram ram
(
    .clk_i               ( clk_i             ),
    .arstn_i             ( arstn_i           ),
    
    .data_rvalid_o       ( data_rvalid_ram   ),   
    .data_rdata_o        ( data_rdata_ram    ),   
    .data_req_i          ( data_req_ram      ),
    .data_we_i           ( data_we_ram       ),
    .data_be_i           ( data_be_ram       ),
    .data_addr_i         ( data_addr_ram     ),   
    .data_wdata_i        ( data_wdata_ram    )
);

endmodule
