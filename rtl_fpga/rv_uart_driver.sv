import rv_pkg::*;

module rv_uart_driver
#(
    parameter clk_i_freq        = 50_000_000,
    parameter uart_baud_rate    = 9600
)
(

    // Clock, reset
    input   logic                           clk_i,
    input   logic                           arstn_i,

    // Data memory interface
    output  logic                           data_rvalid_o,
    output  logic [XLEN-1:0]                data_rdata_o,
    input   logic                           data_req_i,
    input   logic                           data_we_i,
    input   logic [XLEN/8-1:0]              data_be_i,
    input   logic [XLEN-1:0]                data_addr_i,
    input   logic [XLEN-1:0]                data_wdata_i,

    input   logic                           uart_rx,
    output  logic                           uart_tx

);

// max count value for uart strob
localparam uart_cnt_max = clk_i_freq / uart_baud_rate;

typedef enum logic [2:0] 
{
    FSM_IDLE, FSM_WRITE_INIT, FSM_WRITE, FSM_READ 
} state_t;

state_t state, next_state;

logic                           uart_tx_finish;
logic                           uart_rx_finish;

logic                           uart_rx_start;

logic [$clog2(uart_cnt_max):0]  uart_tx_cnt;
logic [$clog2(uart_cnt_max):0]  uart_rx_cnt;

logic [3:0]                     uart_tx_bit_cnt;
logic [3:0]                     uart_rx_bit_cnt;

logic                           uart_tx_strob;
logic                           uart_rx_strob;

logic [9:0]                     uart_tx_buffer;
logic [8:0]                     uart_rx_buffer;

logic                           uart_rx_buffer_clear;  //1 - buffer clear, 0 - buffer has data


assign uart_tx          = uart_tx_buffer[0];
assign uart_tx_finish   = (uart_tx_bit_cnt == 4'd10);
assign uart_rx_finish   = (uart_rx_bit_cnt == 4'd9);  

// Module answer
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
    end
    else
    case (state)
    FSM_IDLE: begin
        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
    end
    FSM_WRITE: begin
        if (next_state == FSM_IDLE)
            data_rvalid_o    <= '1;

        data_rdata_o    <= '0;
    end

    FSM_READ: begin
        if (next_state == FSM_IDLE)
            data_rvalid_o    <= '1;

        data_rdata_o    <= uart_rx_buffer[8:1];
    end 

    default: begin
        data_rvalid_o   <= '0;
        data_rdata_o    <= '0;
    end

    endcase
    

// Choose next state logic
always_comb
case (state)
    FSM_IDLE: 
        if (data_req_i && data_we_i && data_addr_i == ADDRESS_UART)
            next_state = FSM_WRITE_INIT;
        else if (data_req_i && ~data_we_i && data_addr_i == ADDRESS_UART)
            next_state = FSM_READ;
        else
            next_state = FSM_IDLE;

    FSM_WRITE_INIT:
        next_state = FSM_WRITE;

    FSM_WRITE:
        if (uart_tx_finish)
            next_state = FSM_IDLE;
        else
            next_state = FSM_WRITE;

    FSM_READ:
        if (uart_rx_finish && !uart_rx_buffer_clear)
            next_state = FSM_IDLE;
        else
            next_state = FSM_READ;

endcase

// TX strobe generation
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        uart_tx_cnt     <= '0;
        uart_tx_strob   <= '0;
    end
    else if (state == FSM_WRITE_INIT) begin
        uart_tx_cnt     <= '0;
        uart_tx_strob   <= '0;
    end
    else if (uart_tx_cnt == uart_cnt_max) begin
        uart_tx_cnt     <= '0;
        uart_tx_strob   <= '1;
    end
    else begin
        uart_tx_cnt     <= uart_tx_cnt + 1'b1;
        uart_tx_strob   <= '0;
    end

// TX send data
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        uart_tx_buffer  <= '1;
        uart_tx_bit_cnt <= '0;
    end
    else if (state == FSM_IDLE) begin
        uart_tx_buffer  <= '1;
        uart_tx_bit_cnt <= '0;
    end
    else if (state == FSM_WRITE_INIT) begin
        uart_tx_buffer  <= { 1'b1, data_wdata_i[7:0], 1'b0};
        uart_tx_bit_cnt <= '0;
    end
    else if (state == FSM_WRITE && uart_tx_strob) begin
        uart_tx_buffer  <= { 1'b1, uart_tx_buffer[9:1] };
        uart_tx_bit_cnt <= uart_tx_bit_cnt + 1'b1;
    end


// Update currernt state logic
always_ff @(posedge clk_i or negedge arstn_i) 
    if (!arstn_i)
        state <= FSM_IDLE;
    else
        state <= next_state;

// -------------------- RX ----------------------

// pause for half period on start


//Get posedge uart_rx
logic uart_rx_r;

always_ff @ (posedge clk_i or negedge arstn_i)
    if (!arstn_i)
        uart_rx_r <= '1;
    else
        uart_rx_r <= uart_rx;


// RX get data
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        uart_rx_buffer  <= '0;
        uart_rx_bit_cnt <= '0;
    end
    else if (!uart_rx_start && uart_rx_r && !uart_rx) begin //uart start bit
        uart_rx_buffer  <= '0;
        uart_rx_bit_cnt <= '0;
    end
    else if (uart_rx_start && uart_rx_strob) begin
        uart_rx_buffer  <= { uart_rx, uart_rx_buffer[8:1] };
        uart_rx_bit_cnt <= uart_rx_bit_cnt + 1'b1;
    end


// set when need to wait half of period for rx synchronization
logic   half_wait;

// RX strobe generation
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        uart_rx_cnt     <= '0;
        uart_rx_strob   <= '0;
        uart_rx_start   <= '0;
        half_wait       <= '1;
    end
    else if (!uart_rx_start && uart_rx_r && !uart_rx) begin // prepare for receive when come uart start bit
        uart_rx_cnt     <= '0;
        uart_rx_strob   <= '0;
        uart_rx_start   <= '1;
        half_wait       <= '1;
    end
    else if (uart_rx_start && uart_rx_cnt == uart_cnt_max / 2 && half_wait) begin //pulse for half period
        uart_rx_cnt     <= '0;
        uart_rx_strob   <= '1;
        half_wait       <= '0;
    end
    else if (uart_rx_start && uart_rx_cnt == uart_cnt_max) begin // pulse for all period
        uart_rx_cnt     <= '0;
        uart_rx_strob   <= '1;
        if (uart_rx_finish)
            uart_rx_start   <= '0;
    end
    else begin
        uart_rx_cnt     <= uart_rx_cnt + 1'b1;
        uart_rx_strob   <= '0;
        if (uart_rx_finish)
            uart_rx_start   <= '0;
    end

// RX save data flag
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i)
        uart_rx_buffer_clear <= '1;
    else if (uart_rx_finish && state == FSM_READ)
        uart_rx_buffer_clear <= '1;
    else if (uart_rx_start)
        uart_rx_buffer_clear <= '0;

endmodule