import rv_pkg::*;
module rv_core_testbench;

int fd;

logic clk;
logic arstn;

logic [XLEN-1:0]   boot_addr;
assign boot_addr = 'h100dc;

rv_tb_core dut
(
    .clk_i               ( clk               ),
    .arstn_i             ( arstn             ),
    .boot_addr_i         ( boot_addr         )
);

initial begin
    fd = $fopen("dut.core.log", "w");
    $dumpfile("wave.vcd");
    $dumpvars(0,dut.core);
    clk = 0;
    arstn = 0;
    #2; arstn = 1;
    //#10000;
    for (integer i = 0; i < 10000; i=i+1) begin
        @(posedge clk);
        if (dut.core.i_memory_stage.m_valid_o && !dut.core.i_memory_stage.cu_stall_m_i && !dut.core.i_memory_stage.m_stall_req_o) begin
            // console
            $display("%t    0x%x    (0x%x)", 
                        $time, 
                        dut.core.i_memory_stage.m_current_pc_o,
                        dut.core.i_memory_stage.m_instr_o);

            // file
            $fdisplay(fd, "%0t    0x%x    (0x%x)", 
                        $time, 
                        dut.core.i_memory_stage.m_current_pc_o,
                        dut.core.i_memory_stage.m_instr_o);

            #1;
            $fdisplay(fd, 
            
"zero: 0x%x  ra: 0x%x  sp: 0x%x  gp: 0x%x\n  tp: 0x%x  t0: 0x%x  t1: 0x%x  t2: 0x%x\n  s0: 0x%x  s1: 0x%x  a0: 0x%x  a1: 0x%x\n  a2: 0x%x  a3: 0x%x  a4: 0x%x  a5: 0x%x\n  a6: 0x%x  a7: 0x%x  s2: 0x%x  s3: 0x%x\n  s4: 0x%x  s5: 0x%x  s6: 0x%x  s7: 0x%x\n  s8: 0x%x  s9: 0x%x s10: 0x%x s11: 0x%x\n  t3: 0x%x  t4: 0x%x  t5: 0x%x  t6: 0x%x",

            dut.core.i_decode_stage.i_gpr.rf_reg[0],
            dut.core.i_decode_stage.i_gpr.rf_reg[1],
            dut.core.i_decode_stage.i_gpr.rf_reg[2],
            dut.core.i_decode_stage.i_gpr.rf_reg[3],
            dut.core.i_decode_stage.i_gpr.rf_reg[4],
            dut.core.i_decode_stage.i_gpr.rf_reg[5],
            dut.core.i_decode_stage.i_gpr.rf_reg[6],
            dut.core.i_decode_stage.i_gpr.rf_reg[7],
            dut.core.i_decode_stage.i_gpr.rf_reg[8],
            dut.core.i_decode_stage.i_gpr.rf_reg[9],
            dut.core.i_decode_stage.i_gpr.rf_reg[10],
            dut.core.i_decode_stage.i_gpr.rf_reg[11],
            dut.core.i_decode_stage.i_gpr.rf_reg[12],
            dut.core.i_decode_stage.i_gpr.rf_reg[13],
            dut.core.i_decode_stage.i_gpr.rf_reg[14],
            dut.core.i_decode_stage.i_gpr.rf_reg[15],
            dut.core.i_decode_stage.i_gpr.rf_reg[16],
            dut.core.i_decode_stage.i_gpr.rf_reg[17],
            dut.core.i_decode_stage.i_gpr.rf_reg[18],
            dut.core.i_decode_stage.i_gpr.rf_reg[19],
            dut.core.i_decode_stage.i_gpr.rf_reg[20],
            dut.core.i_decode_stage.i_gpr.rf_reg[21],
            dut.core.i_decode_stage.i_gpr.rf_reg[22],
            dut.core.i_decode_stage.i_gpr.rf_reg[23],
            dut.core.i_decode_stage.i_gpr.rf_reg[24],
            dut.core.i_decode_stage.i_gpr.rf_reg[25],
            dut.core.i_decode_stage.i_gpr.rf_reg[26],
            dut.core.i_decode_stage.i_gpr.rf_reg[27],
            dut.core.i_decode_stage.i_gpr.rf_reg[28],
            dut.core.i_decode_stage.i_gpr.rf_reg[29],
            dut.core.i_decode_stage.i_gpr.rf_reg[30],
            dut.core.i_decode_stage.i_gpr.rf_reg[31]
            );

        end
    end

    $fclose(fd);
    $finish();
end

always
	#1 clk <= !clk;

endmodule