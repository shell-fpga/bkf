`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2024 05:28:22 PM
// Design Name: 
// Module Name: test_master
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_master(
	input wire clk,
	input wire rst_n,
	
	// the bk system port  MBKP
    output wire BkpCfg_Ready_o,
    output wire [31:0] BkpCfg_DataIndex_o,  
    output wire [31:0] BkpCfg_DataValue_o  

);
	
	localparam index_max = 4500; // base 
	localparam cnt0_delay = 10*index_max;
	

	
	reg cnt0_gate;
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt0_gate <= 1'd1;
	else if(cnt0 == cnt0_delay - 1'd1)
		cnt0_gate <= 1'b0;
	else
		cnt0_gate <= cnt0_gate;
		
	reg [31:0] cnt0;
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
		cnt0 <= 'd0;
	else if(cnt0_gate)
		cnt0 <= cnt0 + 1'd1;
	else
		cnt0 <= 'd0;

	
	wire [31:0] bk_index_p1;	
	assign bk_index_p1 = cnt0 /10 + 1;

	/*************************************************************************/
	//add tb.v at here
	/*************************************************************************/
	//combine part
	assign BkpCfg_Ready_o = ((cnt0 +5)%10 == 'd0) ?  1'b1 : 1'b0;
    assign BkpCfg_DataIndex_o = 
    assign BkpCfg_DataValue_o = 
    
    
    endmodule
