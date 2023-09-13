import rv_pkg::*;
module rv_core_testbench;

int fd;

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
    else if (instr_req) begin
        instr_rvalid    <= '1;
        instr_rdata     <= instr_mem[instr_addr >> 2];
    end else begin
        instr_rvalid    <= '0;
        instr_rdata     <= '0;
    end

initial
    $readmemh("C:/Users/alexandr/Desktop/ubuntu/RV32IM_CORE/program/mem.v", instr_mem);

//--------------------------
// Data memory model
//--------------------------
logic [XLEN-1:0] data_mem 	[0:2 ** XLEN-1];

assign data_rdata = (data_mem[data_addr >> 2] === 'x) ? '0 : data_mem[data_addr >> 2];

// read
always_ff @(posedge clk or negedge arstn)
    if (!arstn) begin
        data_rvalid    <= '0;
        //data_rdata     <= '0;
    end 
    else if (data_req) begin
        data_rvalid    <= '1;
        //data_rdata     <= data_mem[data_addr >> 2];
    end else begin
        data_rvalid    <= '0;
        //data_rdata     <= '0;
    end

// write
always_ff @(posedge clk) begin
    if(data_req && data_we && data_be[0])
        data_mem [data_addr[15:2]] [7:0]   <= data_wdata[7:0];
    if(data_req && data_we && data_be[1])
        data_mem [data_addr[15:2]] [15:8]  <= data_wdata[15:8];
    if(data_req && data_we && data_be[2])
        data_mem [data_addr[15:2]] [23:16] <= data_wdata[23:16];
    if(data_req && data_we && data_be[3])
        data_mem [data_addr[15:2]] [31:24] <= data_wdata[31:24];
end
//--------------------------

initial begin
    fd = $fopen("dut.log", "w");
    $dumpfile("wave.vcd");
    $dumpvars(0,dut);
    clk = 0;
    arstn = 0;
    #2; arstn = 1;
    //#10000;
    for (integer i = 0; i < 10000; i=i+1) begin
        @(posedge clk);
        if (dut.i_memory_stage.m_valid_o && !dut.i_memory_stage.cu_stall_m_i && !dut.i_memory_stage.m_stall_req_o) begin
            // console
            $display("%t    0x%x    (0x%x)", 
                        $time, 
                        dut.i_memory_stage.m_current_pc_o,
                        dut.i_memory_stage.m_instr_o);

            // file
            $fdisplay(fd, "%0t    0x%x    (0x%x)", 
                        $time, 
                        dut.i_memory_stage.m_current_pc_o,
                        dut.i_memory_stage.m_instr_o);

            #1;
            $fdisplay(fd, 
            
"zero: 0x%x  ra: 0x%x  sp: 0x%x  gp: 0x%x\n  tp: 0x%x  t0: 0x%x  t1: 0x%x  t2: 0x%x\n  s0: 0x%x  s1: 0x%x  a0: 0x%x  a1: 0x%x\n  a2: 0x%x  a3: 0x%x  a4: 0x%x  a5: 0x%x\n  a6: 0x%x  a7: 0x%x  s2: 0x%x  s3: 0x%x\n  s4: 0x%x  s5: 0x%x  s6: 0x%x  s7: 0x%x\n  s8: 0x%x  s9: 0x%x s10: 0x%x s11: 0x%x\n  t3: 0x%x  t4: 0x%x  t5: 0x%x  t6: 0x%x",

            dut.i_decode_stage.i_gpr.rf_reg[0],
            dut.i_decode_stage.i_gpr.rf_reg[1],
            dut.i_decode_stage.i_gpr.rf_reg[2],
            dut.i_decode_stage.i_gpr.rf_reg[3],
            dut.i_decode_stage.i_gpr.rf_reg[4],
            dut.i_decode_stage.i_gpr.rf_reg[5],
            dut.i_decode_stage.i_gpr.rf_reg[6],
            dut.i_decode_stage.i_gpr.rf_reg[7],
            dut.i_decode_stage.i_gpr.rf_reg[8],
            dut.i_decode_stage.i_gpr.rf_reg[9],
            dut.i_decode_stage.i_gpr.rf_reg[10],
            dut.i_decode_stage.i_gpr.rf_reg[11],
            dut.i_decode_stage.i_gpr.rf_reg[12],
            dut.i_decode_stage.i_gpr.rf_reg[13],
            dut.i_decode_stage.i_gpr.rf_reg[14],
            dut.i_decode_stage.i_gpr.rf_reg[15],
            dut.i_decode_stage.i_gpr.rf_reg[16],
            dut.i_decode_stage.i_gpr.rf_reg[17],
            dut.i_decode_stage.i_gpr.rf_reg[18],
            dut.i_decode_stage.i_gpr.rf_reg[19],
            dut.i_decode_stage.i_gpr.rf_reg[20],
            dut.i_decode_stage.i_gpr.rf_reg[21],
            dut.i_decode_stage.i_gpr.rf_reg[22],
            dut.i_decode_stage.i_gpr.rf_reg[23],
            dut.i_decode_stage.i_gpr.rf_reg[24],
            dut.i_decode_stage.i_gpr.rf_reg[25],
            dut.i_decode_stage.i_gpr.rf_reg[26],
            dut.i_decode_stage.i_gpr.rf_reg[27],
            dut.i_decode_stage.i_gpr.rf_reg[28],
            dut.i_decode_stage.i_gpr.rf_reg[29],
            dut.i_decode_stage.i_gpr.rf_reg[30],
            dut.i_decode_stage.i_gpr.rf_reg[31]
            );

        end
    end

    $fclose(fd);
    $finish();
end

always
	#1 clk <= !clk;

endmodule