`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/12 11:25:42
// Design Name: 
// Module Name: NCO_single_gen_v1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Nco_Single_Gen(
    input wire clk, 
	input wire rst_n,
	input wire ref_pps_pedge,
	input wire [15:0] init_phase,
	input wire DDS_enable,
	input wire DDS_CH_enable,
	input wire signed [7:0] DDS_scale,
	input wire [63:0] D_i,
	
	
	output wire [31:0] DDS_IQ_o
    );


    reg DDS_CH_enable_d1;
    always @(posedge clk or negedge rst_n)
	if(!rst_n)
        DDS_CH_enable_d1 <= 1'b0;
    else
        DDS_CH_enable_d1 <= DDS_CH_enable;
        	   
    wire DDS_CH_enable_pedge;
    assign DDS_CH_enable_pedge = DDS_CH_enable & ~DDS_CH_enable_d1;
        	   
	reg ref_pps_pedge_d1;
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
	   ref_pps_pedge_d1 <= 1'b0;
	else
	   ref_pps_pedge_d1 <= ref_pps_pedge;
	
	reg shock_time;
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
	   shock_time <= 'd0;
	else if(DDS_CH_enable_pedge)
	   shock_time <= 1'b1;
	else if(ref_pps_pedge_d1)
	   shock_time <= 1'b0;
	else
	   shock_time <= shock_time;

	
    reg [63:0] D;
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		D <= 'd0;
	else if(DDS_enable)
		D <= D_i;
	else
		D <= 'd0;
	
	reg [47:0] cnt0;
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt0 <= 'd0;
	else if(shock_time == 1'b1)
	    cnt0 <= 'd0;
	else
		cnt0 <= cnt0 + D;
		
wire rd_en1;
wire rd_en2;
wire [15:0] rd_addr1;
wire [15:0] rd_addr2;
wire signed [15:0]  rd_data1;
wire signed [15:0]  rd_data2;
blk_mem_gen_0  r1(
  .clka(clk),    // input wire clka
  .ena(rd_en1),      // input wire ena
  .addra(rd_addr1),  // input wire [6 : 0] addra
  .douta(rd_data1),  // output wire [15 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(rd_en2),      // input wire enb
  .addrb(rd_addr2),  // input wire [6 : 0] addrb
  .doutb(rd_data2)  // output wire [15 : 0] doutb
);



wire signed [15:0] data_I_p1;
assign data_I_p1 = rd_data1 >>> DDS_scale;

//div_gen_0 u1 (
//  .aclk(clk),                                      // input wire aclk
//  .s_axis_divisor_tvalid(DDS_enable),    // input wire s_axis_divisor_tvalid
//  .s_axis_divisor_tdata(DDS_scale),      // input wire [15 : 0] s_axis_divisor_tdata
//  .s_axis_dividend_tvalid(DDS_enable),  // input wire s_axis_dividend_tvalid
//  .s_axis_dividend_tdata(rd_data1),    // input wire [15 : 0] s_axis_dividend_tdata
//  .m_axis_dout_tvalid(),          // output wire m_axis_dout_tvalid
//  .m_axis_dout_tdata(data_I_p1)            // output wire [31 : 0] m_axis_dout_tdata
//);

wire signed [15:0] data_Q_p1;
assign data_Q_p1 = rd_data2 >>> DDS_scale;
//div_gen_0  u2 (
//  .aclk(clk),                                      // input wire aclk
//  .s_axis_divisor_tvalid(DDS_enable),    // input wire s_axis_divisor_tvalid
//  .s_axis_divisor_tdata(DDS_scale),      // input wire [15 : 0] s_axis_divisor_tdata
//  .s_axis_dividend_tvalid(DDS_enable),  // input wire s_axis_dividend_tvalid
//  .s_axis_dividend_tdata(rd_data2),    // input wire [15 : 0] s_axis_dividend_tdata
//  .m_axis_dout_tvalid(),          // output wire m_axis_dout_tvalid
//  .m_axis_dout_tdata(data_Q_p1)            // output wire [31 : 0] m_axis_dout_tdata
//);


assign rd_addr1 = cnt0[47:38] + 256 + init_phase;
assign rd_en1 = 1'b1;
	

assign rd_addr2 = cnt0[47:38] + init_phase;
assign rd_en2 = 1'b1;
	
assign DDS_IQ_o = (DDS_CH_enable == 1'b1) ? {data_Q_p1,data_I_p1} : 32'd0;

endmodule