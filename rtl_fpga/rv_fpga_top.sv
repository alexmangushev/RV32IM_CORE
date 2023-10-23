import rv_pkg::*;

module rv_fpga_top
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

    output  logic   [19:0]  SRAM_ADDR,
    inout   logic   [15:0]  SRAM_DQ,
    output  logic           SRAM_CE_N,
    output  logic           SRAM_OE_N,
    output  logic           SRAM_WE_N,
    output  logic           SRAM_UB_N,
    output  logic           SRAM_LB_N,

    input   logic           UART_RXD,
    output  logic           UART_TXD,

    output  logic           UART_CTS

);

// Indicator
logic [55:0]        hex;

// Clock, reset
logic               clk;
logic               clk_pll;
logic               arstn;
logic               arstn_i;
logic               arstn_ff;

// SPI interface
logic               spi_mosi;
logic               spi_miso;
logic               spi_sck;
logic               spi_cs;

logic [15:0]        sram_data_o;

logic               key;

logic [XLEN-1:0]    boot_addr;

//assign clk       = CLOCK_50;
assign arstn_i   = KEY[0];
assign boot_addr = 'h1018c;

assign {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = hex;

assign SRAM_DQ[7:0]     = SRAM_WE_N ? 'z : sram_data_o[7:0];
assign SRAM_DQ[15:8]    = SRAM_WE_N ? 'z : sram_data_o[15:8];

assign GPIO[2:0]        = {spi_mosi, spi_sck, spi_cs};
assign spi_miso         = GPIO[3];

assign key              = KEY[1];

assign GPIO[4] = UART_TXD;


global pll_clk
(
    .in  (CLOCK_50),
    .out (clk)
);

rv_fpga_soc soc
(

    .clk_i              ( clk           ),
    .arstn_i            ( arstn         ),

    .boot_addr_i        ( boot_addr     ),

    .spi_mosi           ( spi_mosi      ),
    .spi_miso           ( spi_miso      ),
    .spi_sck            ( spi_sck       ),
    .spi_cs             ( spi_cs        ),

    .sram_addr          ( SRAM_ADDR     ),
    .sram_data_i        ( SRAM_DQ       ),
    .sram_data_o        ( sram_data_o   ),

    .sram_ce_n          ( SRAM_CE_N     ),      
    .sram_oe_n          ( SRAM_OE_N     ),      
    .sram_we_n          ( SRAM_WE_N     ),      
    .sram_ub_n          ( SRAM_UB_N     ),
    .sram_lb_n          ( SRAM_LB_N     ),

    .hex                ( hex           ),

    .key                ( key           ),

    .uart_rx            ( UART_RXD      ),
    .uart_tx            ( UART_TXD      )

);

// reset synchronization
always_ff @(posedge clk or negedge arstn_i)
if (!arstn_i)
    {arstn, arstn_ff} <= '0;
else
    {arstn, arstn_ff} <= {arstn_ff, 1'b1};

endmodule