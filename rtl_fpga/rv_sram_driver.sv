import rv_pkg::*;

module rv_sram_driver
#(
    parameter   SRAM_ADDR_WIDTH = 20,
    parameter   SRAM_DATA_WIDTH = 16
)
(
    // Clock, reset
    input   logic                           clk_i,
    input   logic                           arstn_i,

    // SRAM interface
    output  logic   [SRAM_ADDR_WIDTH-1:0]   sram_addr,
    input   logic   [SRAM_DATA_WIDTH-1:0]   sram_data_i,
    output  logic   [SRAM_DATA_WIDTH-1:0]   sram_data_o,

    output  logic                           sram_ce_n,  //  chip enable
    output  logic                           sram_oe_n,  //  output enable
    output  logic                           sram_we_n,  //  write enable
    output  logic                           sram_ub_n,  //  lpper-byte Control (I/O8-I/O15
    output  logic                           sram_lb_n,  //  lower-byte Control (I/O0-I/O7) 
    
    
    // Data memory interface
    output  logic                           data_rvalid_o,
    output  logic [XLEN-1:0]                data_rdata_o,
    input   logic                           data_req_i,
    input   logic                           data_we_i,
    input   logic [XLEN/8-1:0]              data_be_i,
    input   logic [XLEN-1:0]                data_addr_i,
    input   logic [XLEN-1:0]                data_wdata_i
);

// max memory delay - 20 ns

//Mode              WE    CE    OE    LB    UB  I/O0-I/O7   I/O8-I/O15  
//Not Selected      X     H     X     X     X     High-Z     High-Z        
//Output Disabled   H     L     H     X     X     High-Z     High-Z        
//                  X     L     X     H     H     High-Z     High-Z
//     Read         H     L     L     L     H     Dout       High-Z      
//                  H     L     L     H     L     High-Z     Dout
//                  H     L     L     L     L     Dout       Dout
//     Write        L     L     X     L     H     Din        High-Z      
//                  L     L     X     H     L     High-Z     Din
//                  L     L     X     L     L     Din        Din


typedef enum logic [2:0] 
{
    FSM_IDLE, FSM_WRITE_U, FSM_WRITE_L, FSM_READ_U, FSM_READ_L 
} state_t;

state_t state, next_state;

// for read transaction
// prepare_u == 0, set address, prepare_u == 1, read upper values into register

// for write transaction
// prepare_u == 0, unselect memory for working burst mode
// prepare_u == 1, select memory and write upper part of data
logic    prepare_u; 
// prepare_u == 0, set address, prepare_u == 1, read lower values into register
logic     prepare_l;


// Choose next state logic
always_comb
case (state)
    FSM_IDLE:
        if (data_req_i && data_we_i)
            next_state = FSM_WRITE_L;
        else if (data_req_i && ~data_we_i)
            next_state = FSM_READ_L;
        else
            next_state = FSM_IDLE;

    FSM_WRITE_L:
        if (data_be_i & 4'b1100) //if we want to write upper part
            next_state = FSM_WRITE_U;
        else
            next_state = FSM_IDLE;

    FSM_WRITE_U:
        if (prepare_u)
            next_state = FSM_IDLE;
        else
            next_state = FSM_WRITE_U;

    FSM_READ_L:
        if (prepare_l)
            next_state = FSM_READ_U;
        else
            next_state = FSM_READ_L;
    
    FSM_READ_U:
        if (prepare_u)
            next_state = FSM_IDLE;
        else
            next_state = FSM_READ_U;
        
    default:
        next_state = FSM_IDLE;
endcase

// Control signals for memory
always_ff @(posedge clk_i or negedge arstn_i) 
    if (!arstn_i) begin
        sram_ce_n       <= '0;
        sram_oe_n       <= '1;
        sram_we_n       <= '1;
        sram_ub_n       <= '1;
        sram_lb_n       <= '1;

        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
        prepare_u       <= '0;
        prepare_l       <= '0;
    end
    else 
    case (state)
    FSM_IDLE: begin
        sram_ce_n       <= '0;
        sram_oe_n       <= '1;
        sram_we_n       <= '1;
        sram_ub_n       <= '1;
        sram_lb_n       <= '1;
        
        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
        prepare_u       <= '0;
        prepare_l       <= '0;
    end
    FSM_WRITE_L: begin
        sram_ce_n       <= '0;
        sram_oe_n       <= '0;
        sram_we_n       <= '0;
        sram_ub_n       <= ~data_be_i[1];
        sram_lb_n       <= ~data_be_i[0];

        sram_addr       <= data_addr_i >> 1;
        sram_data_o     <= data_wdata_i[XLEN/2-1:0];
        if (next_state == FSM_IDLE)
            data_rvalid_o    <= '1;

    end
    FSM_WRITE_U: begin
        if (prepare_u) begin
            sram_ce_n   <= '0;
            sram_oe_n   <= '0;
            sram_we_n   <= '0;
            sram_ub_n   <= ~data_be_i[3];
            sram_lb_n   <= ~data_be_i[2];

            sram_addr   <= (data_addr_i >> 1) + 1'b1;
            sram_data_o <= data_wdata_i[XLEN-1:XLEN/2];

            if (next_state == FSM_IDLE)
            data_rvalid_o    <= '1;
        end
        else begin
            sram_ub_n   <= '1;
            sram_lb_n   <= '1;
            prepare_u   <= '1;
        end
        
    end        
    FSM_READ_L: begin
        sram_ce_n                   <= '0;
        sram_oe_n                   <= '0;
        sram_we_n                   <= '1;
        sram_ub_n                   <= '0;
        sram_lb_n                   <= '0;

        sram_addr                   <= data_addr_i >> 1;
        data_rdata_o[XLEN/2-1:0]    <= sram_data_i;
        data_rvalid_o               <= '0;

        prepare_l                   <= '1;
    end
    FSM_READ_U: begin

            sram_ce_n                   <= '0;
            sram_oe_n                   <= '0;
            sram_we_n                   <= '1;
            sram_ub_n                   <= '0;
            sram_lb_n                   <= '0;

            sram_addr                   <= (data_addr_i >> 1) + 1'b1;
            data_rdata_o[XLEN-1:XLEN/2] <= sram_data_i;
            data_rvalid_o               <= '1;

            prepare_u                   <= '1;
    end
    endcase


// Update currernt state logic
always_ff @(posedge clk_i or negedge arstn_i) 
    if (!arstn_i)
        state <= FSM_IDLE;
    else
        state <= next_state;

endmodule
