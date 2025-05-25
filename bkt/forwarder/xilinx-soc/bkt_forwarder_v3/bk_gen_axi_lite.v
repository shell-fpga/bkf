//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
//Date        : Thu Oct 20 13:53:17 2022
//Host        : Z490-UD running 64-bit Ubuntu 18.04.6 LTS
//Command     : generate_target bk_gen_axi_lite.bd
//Design      : bk_gen_axi_lite
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bk_gen_axi_lite,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bk_gen_axi_lite,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,da_clkrst_cnt=3,synth_mode=Global}" *) (* HW_HANDOFF = "bk_gen_axi_lite.hwdef" *) 
module bk_gen_axi_lite #(parameter ready_bit = 0)
   (ap_clk,
    ap_rst_n,
    //M BKPcfg
    BkpCfg_Ready_o,
    BkpCfg_DataIndex_o,
    BkpCfg_DataValue_o,
    BK_Status_i,
    interrupt,
    s_axi_control_araddr,
    s_axi_control_arready,
    s_axi_control_arvalid,
    s_axi_control_awaddr,
    s_axi_control_awready,
    s_axi_control_awvalid,
    s_axi_control_bready,
    s_axi_control_bresp,
    s_axi_control_bvalid,
    s_axi_control_rdata,
    s_axi_control_rready,
    s_axi_control_rresp,
    s_axi_control_rvalid,
    s_axi_control_wdata,
    s_axi_control_wready,
    s_axi_control_wstrb,
    s_axi_control_wvalid);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.AP_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.AP_CLK, ASSOCIATED_RESET ap_rst_n, CLK_DOMAIN bk_gen_axi_lite_ap_clk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input ap_clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.AP_RST_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.AP_RST_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input ap_rst_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.INTERRUPT INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.INTERRUPT, PortWidth 1, SENSITIVITY LEVEL_HIGH" *) output interrupt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_control, ADDR_WIDTH 12, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 0, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [11:0]s_axi_control_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output s_axi_control_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input s_axi_control_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input [11:0]s_axi_control_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output s_axi_control_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input s_axi_control_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input s_axi_control_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output [1:0]s_axi_control_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output s_axi_control_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output [31:0]s_axi_control_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input s_axi_control_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output [1:0]s_axi_control_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output s_axi_control_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input [31:0]s_axi_control_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) output s_axi_control_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input [3:0]s_axi_control_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_control " *) input s_axi_control_wvalid;


  output wire BkpCfg_Ready_o;
  output wire [31:0]BkpCfg_DataIndex_o;
  output wire [31:0]BkpCfg_DataValue_o;
  input  wire [31:0]BK_Status_i;

  wire ap_clk_0_1;
  wire ap_rst_n_0_1;
  wire bk_axi_lite_ctrl_0_ap_start_pedge;
  wire bk_axi_lite_ctrl_0_interrupt;
  wire bk_reg_cfg_0_ap_done_o;
  wire [31:0] reg0_line,reg1_line,reg2_line,reg3_line;
 
  wire [11:0]s_axi_control_0_1_ARADDR;
  wire s_axi_control_0_1_ARREADY;
  wire s_axi_control_0_1_ARVALID;
  wire [11:0]s_axi_control_0_1_AWADDR;
  wire s_axi_control_0_1_AWREADY;
  wire s_axi_control_0_1_AWVALID;
  wire s_axi_control_0_1_BREADY;
  wire [1:0]s_axi_control_0_1_BRESP;
  wire s_axi_control_0_1_BVALID;
  wire [31:0]s_axi_control_0_1_RDATA;
  wire s_axi_control_0_1_RREADY;
  wire [1:0]s_axi_control_0_1_RRESP;
  wire s_axi_control_0_1_RVALID;
  wire [31:0]s_axi_control_0_1_WDATA;
  wire s_axi_control_0_1_WREADY;
  wire [3:0]s_axi_control_0_1_WSTRB;
  wire s_axi_control_0_1_WVALID;

  assign ap_clk_0_1 = ap_clk;
  assign ap_rst_n_0_1 = ap_rst_n;
  assign interrupt = bk_axi_lite_ctrl_0_interrupt;
  assign s_axi_control_0_1_ARADDR = s_axi_control_araddr[11:0];
  assign s_axi_control_0_1_ARVALID = s_axi_control_arvalid;
  assign s_axi_control_0_1_AWADDR = s_axi_control_awaddr[11:0];
  assign s_axi_control_0_1_AWVALID = s_axi_control_awvalid;
  assign s_axi_control_0_1_BREADY = s_axi_control_bready;
  assign s_axi_control_0_1_RREADY = s_axi_control_rready;
  assign s_axi_control_0_1_WDATA = s_axi_control_wdata[31:0];
  assign s_axi_control_0_1_WSTRB = s_axi_control_wstrb[3:0];
  assign s_axi_control_0_1_WVALID = s_axi_control_wvalid;
  assign s_axi_control_arready = s_axi_control_0_1_ARREADY;
  assign s_axi_control_awready = s_axi_control_0_1_AWREADY;
  assign s_axi_control_bresp[1:0] = s_axi_control_0_1_BRESP;
  assign s_axi_control_bvalid = s_axi_control_0_1_BVALID;
  assign s_axi_control_rdata[31:0] = s_axi_control_0_1_RDATA;
  assign s_axi_control_rresp[1:0] = s_axi_control_0_1_RRESP;
  assign s_axi_control_rvalid = s_axi_control_0_1_RVALID;
  assign s_axi_control_wready = s_axi_control_0_1_WREADY;
  bk_gen_axi_lite_bk_axi_lite_ctrl_0_0 bk_axi_lite_ctrl_0
       (.ap_clk(ap_clk_0_1),
        .ap_done_i(bk_reg_cfg_0_ap_done_o),
        .ap_rst_n(ap_rst_n_0_1),
        .ap_start_pedge(bk_axi_lite_ctrl_0_ap_start_pedge),
        .interrupt(bk_axi_lite_ctrl_0_interrupt),
        .reg0_o(reg0_line),
        .reg1_o(reg1_line),
        .reg2_o(reg2_line),
        .reg3_i(reg3_line),
        

        .s_axi_control_araddr(s_axi_control_0_1_ARADDR),
        .s_axi_control_arready(s_axi_control_0_1_ARREADY),
        .s_axi_control_arvalid(s_axi_control_0_1_ARVALID),
        .s_axi_control_awaddr(s_axi_control_0_1_AWADDR),
        .s_axi_control_awready(s_axi_control_0_1_AWREADY),
        .s_axi_control_awvalid(s_axi_control_0_1_AWVALID),
        .s_axi_control_bready(s_axi_control_0_1_BREADY),
        .s_axi_control_bresp(s_axi_control_0_1_BRESP),
        .s_axi_control_bvalid(s_axi_control_0_1_BVALID),
        .s_axi_control_rdata(s_axi_control_0_1_RDATA),
        .s_axi_control_rready(s_axi_control_0_1_RREADY),
        .s_axi_control_rresp(s_axi_control_0_1_RRESP),
        .s_axi_control_rvalid(s_axi_control_0_1_RVALID),
        .s_axi_control_wdata(s_axi_control_0_1_WDATA),
        .s_axi_control_wready(s_axi_control_0_1_WREADY),
        .s_axi_control_wstrb(s_axi_control_0_1_WSTRB),
        .s_axi_control_wvalid(s_axi_control_0_1_WVALID));
        
  bk_gen_axi_lite_bk_reg_cfg_0_0 #( .ready_bit(ready_bit)) bk_reg_cfg_0(
        .clk(ap_clk_0_1),
        .rst_n(ap_rst_n_0_1),
        .ap_done_o(bk_reg_cfg_0_ap_done_o),
        .ap_start_pedge(bk_axi_lite_ctrl_0_ap_start_pedge),
        .BkpCfg_Ready_o(BkpCfg_Ready_o),
        .BkpCfg_DataIndex_o(BkpCfg_DataIndex_o),
        .BkpCfg_DataValue_o(BkpCfg_DataValue_o),
        .BK_Status_i(BK_Status_i),
        
        .reg0_i(reg0_line),
        .reg1_i(reg1_line),
        .reg2_i(reg2_line),
        .reg3_o(reg3_line)
        );
        
        
         
endmodule
