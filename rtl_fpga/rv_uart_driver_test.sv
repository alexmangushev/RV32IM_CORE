import rv_pkg::*;

module rv_uart_driver_test
(
    input   logic           CLOCK_50,
    input   logic   [3:0]   KEY,
    input   logic   [7:0]   SW,
    inout   logic   [35:0]  GPIO,
    output  logic   [6:0]   HEX0,
    output  logic   [6:0]   HEX1,
    output  logic   [6:0]   HEX2,
    output  logic   [6:0]   HEX3,
    output  logic   [6:0]   HEX4,
    output  logic   [6:0]   HEX5,
    output  logic   [6:0]   HEX6,
    output  logic   [6:0]   HEX7,

    input   logic           UART_RXD,
    output  logic           UART_TXD
);

// Clock, reset
logic              clk;
logic              arstn;
logic              arstn_i;
logic              arstn_ff;

// Data memory interface
logic              data_rvalid;
logic [XLEN-1:0]   data_rdata;
logic              data_req;
logic              data_we;
logic [XLEN/8-1:0] data_be;
logic [XLEN-1:0]   data_addr;
logic [XLEN-1:0]   data_wdata;

logic [55:0]       hex;
logic [31:0]       hex_show;

logic start_tx;
logic start_rx;

assign clk              = CLOCK_50;
assign arstn_i          = KEY[0];

assign data_be         = '0; 
assign data_addr       = ADDRESS_UART;     
//assign data_wdata      = {24'd0, 8'h41};
assign data_wdata      = {24'd0, SW};
assign {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = hex;

typedef enum {FSM_IDLE, FSM_WRITE, FSM_READ} state_t;
state_t state, next_state;

// Choose next state logic
always_comb
case (state)
    FSM_IDLE:
		if (key_r[0] && !KEY[1])
            next_state = FSM_WRITE;
		else if (key_r[1] && !KEY[2])
            next_state = FSM_READ;
        else
            next_state = FSM_IDLE;

    FSM_WRITE:
        if (data_rvalid)
            next_state = FSM_IDLE;
        else
            next_state = FSM_WRITE;

    FSM_READ:
        if (data_rvalid)
            next_state = FSM_IDLE;
        else
            next_state = FSM_READ;

    default:
        next_state = FSM_IDLE;

endcase


always_comb begin
    case (state)
        FSM_IDLE: begin
            data_req        = '0;     
            data_we         = '0; 
        end

        FSM_WRITE: begin
            data_req        = (data_rvalid)? '0 : '1;     
            data_we         = '1; 
        end

        FSM_READ: begin
            data_req        = (data_rvalid)? '0 : '1;        
            data_we         = '0; 
        end

        default: begin
            data_req        = '0;     
            data_we         = '0; 
        end

    endcase
end

rv_uart_driver uart
(
    .clk_i                  ( clk               ),    
    .arstn_i                ( arstn             ),        

    .data_rvalid_o          ( data_rvalid       ),    
    .data_rdata_o           ( data_rdata        ),    
    .data_req_i             ( data_req          ),
    .data_we_i              ( data_we           ),
    .data_be_i              ( data_be           ),
    .data_addr_i            ( data_addr         ),    
    .data_wdata_i           ( data_wdata        ),
    .uart_rx                ( UART_RXD          ),
    .uart_tx                ( UART_TXD          )   

);

// Update currernt state logic
always_ff @(posedge clk or negedge arstn)
    if (!arstn)
        state <= FSM_IDLE;
    else
        state <= next_state;

/*
initial begin
    clk      = '0;
    arstn    = '0;
    start_tx = '0;
    start_rx = '0;
    #3;
	arstn    = '1;
    start_tx = '1;
	@(posedge data_rvalid);
	@(posedge data_rvalid);
	start_tx = '0;
	@(posedge data_rvalid);
	@(posedge data_rvalid);
	start_tx = '1;


end

always
    #1 clk = !clk;
*/

always_ff @(posedge clk or negedge arstn)
    if (!arstn)
        hex_show <= '0;
    else if (data_rvalid)
        hex_show <= data_rdata;

// Generate hex drivers
genvar i;
generate
    for (i = 0; i < 8; i++) begin : dr
        seven_digit_driver driver
        (
            .number             (hex_show    [(i+1)*4-1:i*4]),
            .seven_digit_data   (hex         [(i+1)*7-1:i*7])
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