// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`timescale 1 ns / 1 ps
// Top level of the kernel. Do not modify module name, parameters or ports.
module bk_axi_lite_ctrl #(
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer LP_NUM_EXAMPLES    = 1,
  parameter integer USE_LED_EXAMPLE    = 0
)
(
  // System Signals
  input  wire                                    ap_clk               ,
  input  wire                                    ap_rst_n             ,
  // AXI4-Lite slave interface
  input  wire                                    s_axi_control_awvalid,
  output wire                                    s_axi_control_awready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr ,
  input  wire                                    s_axi_control_wvalid ,
  output wire                                    s_axi_control_wready ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata  ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb  ,
  input  wire                                    s_axi_control_arvalid,
  output wire                                    s_axi_control_arready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr ,
  output wire                                    s_axi_control_rvalid ,
  input  wire                                    s_axi_control_rready ,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata  ,
  output wire [2-1:0]                            s_axi_control_rresp  ,
  output wire                                    s_axi_control_bvalid ,
  input  wire                                    s_axi_control_bready ,
  output wire [2-1:0]                            s_axi_control_bresp  ,
  output wire                                    interrupt            ,

  output wire                                    ap_start_pedge       ,
  input  wire [LP_NUM_EXAMPLES-1:0]              ap_done_i            ,


  output wire                                    led0                 ,
  output wire                                    led1                 ,
//   
      input  wire [31:0]                   reg3_i,
      output wire [31:0]                   reg2_o,
      output wire [31:0]                   reg1_o,
      output wire [31:0]                   reg0_o
);


///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
wire                                ap_start                      ;
wire                                ap_idle                       ;
wire                                ap_done                       ;
wire                                ap_ready                      ;

wire [32-1:0]                       reg0_line                     ;
wire [32-1:0]                       reg1_line                     ;



// AXI4-Lite slave interface
axi_lite_aphs #(
  .C_S_AXI_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH )
)
u1 (
  .ACLK       ( ap_clk                ),
  .ARESET     ( !ap_rst_n             ),
  .ACLK_EN    ( 1'b1                  ),
  .AWVALID    ( s_axi_control_awvalid ),
  .AWREADY    ( s_axi_control_awready ),
  .AWADDR     ( s_axi_control_awaddr  ),
  .WVALID     ( s_axi_control_wvalid  ),
  .WREADY     ( s_axi_control_wready  ),
  .WDATA      ( s_axi_control_wdata   ),
  .WSTRB      ( s_axi_control_wstrb   ),
  .ARVALID    ( s_axi_control_arvalid ),
  .ARREADY    ( s_axi_control_arready ),
  .ARADDR     ( s_axi_control_araddr  ),
  .RVALID     ( s_axi_control_rvalid  ),
  .RREADY     ( s_axi_control_rready  ),
  .RDATA      ( s_axi_control_rdata   ),
  .RRESP      ( s_axi_control_rresp   ),
  .BVALID     ( s_axi_control_bvalid  ),
  .BREADY     ( s_axi_control_bready  ),
  .BRESP      ( s_axi_control_bresp   ),
  .interrupt  ( interrupt             ),
  .ap_start   ( ap_start              ),
  .ap_done    ( ap_done               ),
  .ap_ready   ( ap_ready              ),
  .ap_idle    ( ap_idle               ),
  
  .reg0_o       ( reg0_o                ),
  .reg1_o       ( reg1_o                ),
  .reg2_o       ( reg2_o                ),
  .reg3_i       ( reg3_i                )
);


    
///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
// Large enough for interesting traffic.




///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////

reg                                areset                       = 1'b0;
reg                                ap_start_r                   = 1'b0;
reg                                ap_idle_r                    = 1'b1;
wire [LP_NUM_EXAMPLES-1:0]         ap_done_line                       ;
reg [LP_NUM_EXAMPLES-1:0]          ap_done_r = {LP_NUM_EXAMPLES{1'b0}};
wire                               ap_start_pulse                     ;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
end

// create pulse when ap_start transitions to 1
always @(posedge ap_clk) begin
  begin
    ap_start_r <= ap_start;
  end
end

assign ap_start_pulse = ap_start & ~ap_start_r;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
always @(posedge ap_clk) begin
  if (areset) begin
    ap_idle_r <= 1'b1;
  end
  else begin
    ap_idle_r <= ap_done ? 1'b1 :
      ap_start_pulse ? 1'b0 : ap_idle;
  end
end

assign ap_idle = ap_idle_r;


wire [LP_NUM_EXAMPLES-1:0] ap_done_sw;
assign ap_done_sw = (USE_LED_EXAMPLE == 1) ?  ap_done_line[0] : ap_done_i;

// Done logic
always @(posedge ap_clk) begin
  if (areset) begin
    ap_done_r <= 'b0;
  end
  else begin
    ap_done_r <= (ap_done) ? 'b0 : ap_done_r | ap_done_sw;
  end
end

assign ap_done = &ap_done_r;

// Ready Logic (non-pipelined case)
assign ap_ready = ap_done;    




// this just a internal example which can no use
led_example e0(
      .ap_clk           (ap_clk          ),
      .ap_rst_n         (ap_rst_n        ),         
      .ap_start_pedge   (ap_start_pulse  ),
      .ap_done_o        (ap_done_line[0] ),
      .reg0_i           (reg0_o          ),
      .reg1_i           (reg1_o          ),
      .led0             (led0            ),
      .led1             (led1            )                
    );

assign ap_start_pedge = ap_start_pulse;


endmodule