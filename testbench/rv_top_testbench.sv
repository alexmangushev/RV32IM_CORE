module rv_top_testbench;
import rv_pkg::*;

logic [XLEN-1:0] tmp;
logic clk;
logic arstn;

// instruction signals
logic [ILEN-1:0]    instr_rdata;
logic               instr_ready;
logic [XLEN-1:0]    instr_addr;
logic				instr_valid;

// data signals
logic [XLEN-1:0]    data_rdata;
logic               data_ready;
logic [XLEN-1:0]    data_addr;
logic [XLEN-1:0]	data_wdata;
logic 				data_write;
logic				data_valid;


logic [XLEN-1:0] data_gen_queue [$];
logic [XLEN-1:0] data_backup;

rv_memory_unit dut
(
    .clk_i          (clk),
    .arstn_i        (arstn),
    .instr_rdata_o  (instr_rdata),
    .instr_ready_o  (instr_ready),
    .instr_addr_i   (instr_addr),
    .instr_valid_i  (instr_valid),

    .data_rdata_o   (data_rdata),
    .data_ready_o   (data_ready),
    .data_addr_i    (data_addr),
    .data_wdata_i   (data_wdata),
    .data_write_i   (data_write),
    .data_valid_i   (data_valid)
);

initial begin
    clk = 0;
    arstn = 0;
    #1; arstn = 1;

    instr_valid = '0;

    data_valid = '0;
    data_write = '0;

    //$monitor(" Time = %0t, instr_rdata = %0h ", $realtime, instr_rdata);
    $dumpfile("wave.vcd");
    $dumpvars(0,dut);

    // instruction read
    for (integer i = 0; i < 5; i=i+1) begin
        instr_addr    = (i * 4 + 'h10094) >> 2;
        instr_valid = '1; 
        @(posedge instr_ready);
        if (instr_rdata !== dut.instr_mem[instr_addr]) begin
            $display("FAIL instruction: at address %h", data_addr);
            $display("read_data = %h      saved_data = %h", instr_rdata, dut.instr_mem[instr_addr]);
            $finish();
        end
        instr_valid = '0;
        #4;
    end

    // data write + read
    for (integer i = 0; i < 5; i=i+1) begin
        data_addr    = (i * 4) >> 2;
        data_valid = '1;
        data_write = '1;
        data_wdata = $urandom % 1000;
        data_gen_queue.push_back(data_wdata);
        @(posedge data_ready);
        data_valid = '0;

        #4;
        data_valid = '1;
        data_write = '0;
        @(posedge data_ready);
        data_backup = data_gen_queue.pop_back();
        if (data_rdata !== data_backup) begin
            $display("FAIL data: at address %h", data_addr);
            $display("read_data = %h      saved_data = %h", data_rdata, data_backup);
            $finish();
        end
    end

    $display("PASS");
    $finish();
end

always
	#1 clk <= !clk;

endmodule