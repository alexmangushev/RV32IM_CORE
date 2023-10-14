import rv_pkg::*;

module w25q_spi
#(
    parameter COUNTER_WIDTH = 1
)
(
    // Clock, reset
    input   logic               clk_i,
    input   logic               arstn_i,

    // Instruction memory interface
    output  logic               instr_rvalid_o,
    output  logic [XLEN-1:0]    instr_rdata_o,
    input   logic               instr_req_i,
    input   logic [XLEN-1:0]    instr_addr_i,
    
    // SPI interface
    output  logic               spi_mosi,
    input   logic               spi_miso,
    output  logic               spi_sck,
    output  logic               spi_cs,

    // Finish initialization memory
    output  logic               memory_init_finish
);

typedef enum {FSM_INIT, FSM_IDLE, FSM_READ } state_t;
state_t state, next_state;

logic                             spi_ready;             // set to 1 when spi transaction finish
logic                             spi_init;             // set to 1 when spi initialization finish
logic    [71:0]                   spi_buffer;            // buffer for sending data
logic    [6:0]                    spi_counter;        // counter for sending bit
logic    [COUNTER_WIDTH - 1:0]    spi_clk_counter;    // counter for clk


// SPI Receive-transmitt
// And spi_ready signal
always_ff @(negedge spi_sck or posedge spi_init)
    if (spi_init) begin
        spi_ready       <= '0;
        spi_counter     <= '0;

        // Different initialization for send buffer
        if (state == FSM_INIT)
            spi_buffer <= {8'h9F, {3{8'hA5}}, {5{8'h00}}};

        else if (state == FSM_READ)
            spi_buffer <= {8'h0B, instr_addr_i[23:0], {5{8'h00}}};

    end
    else begin
        // receive/transmitt and count bits
        {spi_mosi, spi_buffer}     <= {spi_buffer, spi_miso};
        spi_counter                <= spi_counter + 'd1;

        // Send different count of bit for initialization and read
        if (spi_counter == 'd40 && state == FSM_INIT || 
            spi_counter == 'd72 && state == FSM_READ) 
            spi_ready <= '1;
    end


// SPI clk and cs
always_ff @(posedge clk_i or negedge arstn_i)
    if (!arstn_i) begin
        spi_sck           <= '1;
        spi_clk_counter   <= '0;
        spi_cs            <= '1;
    end 
    else if (state != FSM_IDLE) begin
        if (!spi_clk_counter)
            spi_sck <= !spi_sck;

        spi_clk_counter <= spi_clk_counter + 'd1;
        
        if (!spi_init && !spi_sck) 
            spi_cs <= '0; //After first initialization cycle start change spi_cs
    end
    else begin
        spi_sck            <= '0;        
        spi_clk_counter <= '0;
        spi_cs            <= '1;
    end
            
// Choose next state logic
always_comb
case (state)
    FSM_INIT:
        if (spi_ready)
            next_state = FSM_IDLE;
        else
            next_state = FSM_INIT;
    FSM_IDLE:
        if (!memory_init_finish)
            next_state = FSM_INIT;
        else if (instr_req_i)
            next_state = FSM_READ;
        else
            next_state = FSM_IDLE;
    FSM_READ:
        if (spi_ready)
            next_state = FSM_IDLE;
        else
            next_state = FSM_READ;
    default:
        next_state = FSM_IDLE;
endcase

// Control signals for spi
always_ff @(posedge clk_i or negedge arstn_i) 
    if (!arstn_i) begin
        spi_init            <= '0;
        instr_rvalid_o      <= '0;
        instr_rdata_o       <= '0;
        memory_init_finish  <= '0;
    end
    else 
    case (state)
    FSM_INIT: begin
        spi_init            <= '0;
        instr_rvalid_o      <= '0;
        instr_rdata_o       <= '0; 

        if (spi_ready && !memory_init_finish)
            memory_init_finish <= '1;
    end
    FSM_IDLE: begin
        if (next_state != FSM_IDLE)
            spi_init    <= '1;
        else
            spi_init    <= '0;

        instr_rvalid_o  <= '0;
        instr_rdata_o   <= '0;
    end
    FSM_READ: begin
        spi_init        <= '0;

        if (spi_ready && memory_init_finish) begin
            instr_rvalid_o   <= '1;
            instr_rdata_o    <= spi_buffer[31:0];
        end

    end
    endcase

// Update currernt state logic
always_ff @(posedge clk_i or negedge arstn_i) 
    if (!arstn_i)
        state <= FSM_IDLE;
    else
        state <= next_state;

endmodule
