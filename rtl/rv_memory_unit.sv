import rv_pkg::*;
module rv_memory_unit
(
	// Clock, reset
  	input  	logic            	clk_i,
	input  	logic            	arstn_i,

	// instruction
	output  logic [ILEN-1:0]	instr_rdata_o,
	output  logic           	instr_ready_o,
	input   logic [XLEN-1:0]	instr_addr_i,
	input	logic				instr_valid_i,

	// data
	output  logic [XLEN-1:0]	data_rdata_o,
	output  logic           	data_ready_o,
	input   logic [XLEN-1:0]	data_addr_i,
	input   logic [XLEN-1:0]	data_wdata_i,
	input	logic 				data_write_i,
	input	logic				data_valid_i
);

	localparam instruction_latency = 4;
	localparam data_write_latency = 4;
	localparam data_read_latency = 4;

	logic [XLEN-1:0] instr_mem 	[0:2 ** MEM_LEN-1];
	logic [XLEN-1:0] data_mem 	[0:2 ** MEM_LEN-1];

	initial begin
		$readmemh("/home/mango/RV32IM_CORE/program/mem.v", instr_mem);
	end


	//--------------------------------
	//			instruction
	//--------------------------------

	logic 		instr_busy;
	logic [5:0] instr_busy_cnt;

	always_ff @(posedge clk_i or negedge arstn_i) begin
		if (!arstn_i) begin
			instr_busy 		<= '0;
			instr_busy_cnt 	<= '0;
			instr_ready_o	<= '0;
		end 
		else begin
			if (!instr_busy && instr_valid_i) begin
				instr_busy 		<= '1;
			end

			if (instr_busy)
				instr_busy_cnt <= instr_busy_cnt + 'd1;
			else
				instr_busy_cnt 	<= '0;
			
			if (instr_busy_cnt == instruction_latency) begin
				instr_busy 		<= '0;
				instr_ready_o	<= '1;
				instr_rdata_o	<= instr_mem[instr_addr_i];
			end
			else begin
				instr_ready_o	<= '0;
			end
			
		end
		
	end

	//--------------------------------
	//				data
	//--------------------------------
	logic 		data_busy;
	logic [5:0] data_busy_cnt;
	always_ff @(posedge clk_i or negedge arstn_i) begin
		if (!arstn_i) begin
			data_busy 		<= '0;
			data_busy_cnt 	<= '0;
			data_ready_o	<= '0;			
		end
		else begin
			if (!data_busy && data_valid_i) begin
				data_busy 		<= '1;
			end

			if (data_busy)
				data_busy_cnt <= data_busy_cnt + 'd1;
			else
				data_busy_cnt 	<= '0;

			// write data
			if (data_write_i) begin
				if (data_busy_cnt == data_write_latency) begin
					data_busy 				<= '0;
					data_ready_o			<= '1;
					data_mem[data_addr_i] 	<= data_wdata_i;
				end
				else begin
					data_ready_o	<= '0;
				end				
			end 
			// read data
			else begin
				if (data_busy_cnt == data_read_latency) begin
					data_busy 		<= '0;
					data_ready_o	<= '1;
					data_rdata_o	<= data_mem[data_addr_i];
				end
				else begin
					data_ready_o	<= '0;
				end
			end
		end
	end

endmodule