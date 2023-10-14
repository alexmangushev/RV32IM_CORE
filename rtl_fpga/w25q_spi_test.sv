import rv_pkg::*;

module w25q_spi_test
(
    input   logic           CLOCK_50,
    input   logic    [3:0]  KEY,
    inout   logic    [35:0] GPIO,
    output  logic    [6:0]  HEX0,
    output  logic    [6:0]  HEX1,
    output  logic    [6:0]  HEX2,
    output  logic    [6:0]  HEX3,
    output  logic    [6:0]  HEX4,
    output  logic    [6:0]  HEX5,
    output  logic    [6:0]  HEX6,
    output  logic    [6:0]  HEX7
);

// Clock, reset
logic             clk;
logic             arstn;
logic             arstn_i;
logic             arstn_ff;

// Instruction memory interface
logic             instr_rvalid;
logic [XLEN-1:0]  instr_rdata;
logic             instr_req;
logic [XLEN-1:0]  instr_addr;
    
// SPI interface
logic             spi_mosi;
logic             spi_miso;
logic             spi_sck;
logic             spi_cs;

logic [XLEN-1:0]  instr_rdata_ff;

logic [55:0]      hex;

logic [3:0]       cnt;

typedef enum {FSM_IDLE, FSM_READ} state_t;
state_t state, next_state;

assign clk             = CLOCK_50;
assign GPIO[2:0]       = {spi_mosi, spi_sck, spi_cs};
assign spi_miso        = GPIO[3];
assign arstn_i         = KEY[0];
assign {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = hex;

always_ff @(posedge clk or negedge arstn)
	if (!arstn)
		state <= FSM_IDLE;
	else
		state <= next_state;

always_ff @(posedge clk or negedge arstn)
	if (!arstn)
		instr_rdata_ff <= '0;
	else if (instr_rvalid)
		instr_rdata_ff <= instr_rdata;

// Choose next state logic
always_comb
case (state)
	FSM_IDLE:
		if (key_r[1] && !KEY[2])
			next_state = FSM_READ;
        else
            next_state = FSM_IDLE;

    FSM_READ:
        if (instr_rvalid)
			next_state = FSM_IDLE;
		else
			next_state = FSM_READ;

    default:
        next_state = FSM_IDLE;
endcase

always_comb
case (state)
    FSM_IDLE:
        instr_req        = '0;     

    FSM_READ:
        instr_req        = (instr_rvalid)? '0 : '1;    
        
    default:
        instr_req        = '0;  
endcase


// Address
always_ff @ (posedge clk or negedge arstn)
    if (!arstn)
        instr_addr <= '0;
    else if (key_r[0] && !KEY[1])
        instr_addr <= instr_addr + 'd4;

w25q_spi w25_spi
(
    // Clock, reset
    .clk_i               (clk            ),
    .arstn_i             (arstn          ),

    // Instruction memory interface
    .instr_rvalid_o      (instr_rvalid   ),
    .instr_rdata_o       (instr_rdata    ),
    .instr_req_i         (instr_req      ),
    .instr_addr_i        (instr_addr     ),
    
    // SPI interface
    .spi_mosi            (spi_mosi       ),
    .spi_miso            (spi_miso       ),
    .spi_sck             (spi_sck        ),
    .spi_cs              (spi_cs         )
);

genvar i;
generate
    for (i = 0; i < 8; i++) begin : dr
        seven_digit_driver driver
        (
            .number             (instr_rdata_ff    [(i+1)*4-1:i*4]),
            .seven_digit_data   (hex            [(i+1)*7-1:i*7])
        );
    end
endgenerate

// Get press of key
logic [1:0] key_r;

always_ff @ (posedge clk or negedge arstn_i)
    if (!arstn_i)
        key_r <= '0;
    else
        key_r <= {KEY[2], KEY[1]};

// reset synchronization
always_ff @(posedge clk or negedge arstn_i)
if (!arstn_i)
    {arstn, arstn_ff} <= '0;
else
    {arstn, arstn_ff} <= {arstn_ff, 1'b1};

endmodule