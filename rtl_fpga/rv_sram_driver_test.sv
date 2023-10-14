import rv_pkg::*;

module rv_sram_driver_test
(
    input   logic            CLOCK_50,
    output  logic   [4:0]    LEDR,
    input   logic    [3:0]   KEY,
    input   logic    [7:0]   SW,
    inout   logic    [35:0]  GPIO,
    output  logic    [6:0]   HEX0,
    output  logic    [6:0]   HEX1,
    output  logic    [6:0]   HEX2,
    output  logic    [6:0]   HEX3,
    output  logic    [6:0]   HEX4,
    output  logic    [6:0]   HEX5,
    output  logic    [6:0]   HEX6,
    output  logic    [6:0]   HEX7,

    output  logic   [19:0]   SRAM_ADDR,
    inout   logic   [15:0]   SRAM_DQ,
    output  logic            SRAM_CE_N,
    output  logic            SRAM_OE_N,
    output  logic            SRAM_WE_N,
    output  logic            SRAM_UB_N,
    output  logic            SRAM_LB_N
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

logic [31:0]       hex_show;
logic [55:0]       hex;
logic [15:0]       sram_data_o;

assign SRAM_DQ[7:0]     = SRAM_WE_N ? 'z : sram_data_o[7:0];
assign SRAM_DQ[15:8]    = SRAM_WE_N ? 'z : sram_data_o[15:8];

assign clk              = CLOCK_50;
assign arstn_i          = KEY[0];

assign {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = hex;

logic [3:0] cnt;
typedef enum {FSM_IDLE, FSM_WRITE, FSM_READ} state_t;
state_t state, next_state;

always_ff @(posedge clk or negedge arstn)
    if (!arstn)
        state <= FSM_IDLE;
    else
        state <= next_state;

always_ff @(posedge clk or negedge arstn)
    if (!arstn)
        hex_show <= '0;
    else if (data_rvalid)
        hex_show <= data_rdata;


// Choose next state logic
always_comb
case (state)
    FSM_IDLE:
        /*if (key_r[0] && !KEY[1])
            next_state = FSM_WRITE;
        else if (key_r[1] && !KEY[2])
            next_state = FSM_READ;
        else
            next_state = FSM_IDLE;*/

        if (key_r[0] && !KEY[1])
        case (cnt)
            4'd1:       next_state = FSM_WRITE;
            4'd2:       next_state = FSM_READ;
            4'd3:       next_state = FSM_WRITE;
            4'd4:       next_state = FSM_READ;
            4'd5:       next_state = FSM_WRITE;
            4'd6:       next_state = FSM_READ;
            default:    next_state = FSM_IDLE;
        endcase

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
            data_be         = '0; 
            data_addr       = '0;     
            data_wdata      = '0;
            LEDR            = 'b00001;
        end

        FSM_WRITE: begin
            data_req        = (data_rvalid)? '0 : '1;     
            data_we         = '1; 
            case(cnt)
                4'd4:       data_be = 4'b0011;
                4'd6:       data_be = 4'b0001;
                default:    data_be = 4'b1111;
            endcase
            data_addr       = 'd12;      
            case(cnt)
                4'd4:       data_wdata = 'h00004321;
                4'd6:       data_wdata = 'h00000012;
                default:    data_wdata = 'h12345678;
            endcase
            LEDR            = 'b00010;
        end

        FSM_READ: begin
            data_req        = (data_rvalid)? '0 : '1;        
            data_we         = '0; 
            data_be         = 4'b1111; 
            data_addr       = 'd12;
            data_wdata      = 'h12345678; 
            LEDR            = 'b00100;
        end

        default: begin
            data_req        = '0;     
            data_we         = '0; 
            data_be         = '0; 
            data_addr       = '0;     
            data_wdata      = '0;
            LEDR            = 'b00001;
        end

    endcase
end

rv_sram_driver sram_addr
(
    .clk_i                  ( clk               ),    
    .arstn_i                ( arstn             ),        

    .sram_addr              ( SRAM_ADDR         ),
    .sram_data_i            ( SRAM_DQ           ),    
    .sram_data_o            ( sram_data_o       ),    

    .sram_ce_n              ( SRAM_CE_N         ),
    .sram_oe_n              ( SRAM_OE_N         ),
    .sram_we_n              ( SRAM_WE_N         ),
    .sram_ub_n              ( SRAM_UB_N         ),
    .sram_lb_n              ( SRAM_LB_N         ),

    .data_rvalid_o          ( data_rvalid       ),    
    .data_rdata_o           ( data_rdata        ),    
    .data_req_i             ( data_req          ),
    .data_we_i              ( data_we           ),
    .data_be_i              ( data_be           ),
    .data_addr_i            ( data_addr         ),    
    .data_wdata_i           ( data_wdata        )   

);

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

// Counter
always_ff @ (posedge clk or negedge arstn)
    if (!arstn)
        cnt <= '0;
    else if (key_r[0] && !KEY[1])
        cnt <= cnt + 1'b1;


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