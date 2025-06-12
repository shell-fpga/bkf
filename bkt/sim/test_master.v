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

module test_master (
	input wire clk,
	input wire rst_n,
	
	// the bk system port  MBKP
     
    output  wire                   bkt_ready_o,
    output  wire            [31:0] bkt_index_o,
    output  wire            [31:0] bkt_data_o

);
	
	localparam index_max = 4500; // base 
	localparam cnt0_delay = 20;
	

    reg [63:0]cnt_delay;
    always @(posedge clk)
	if(!rst_n)
	   cnt_delay <= 1'b0;
	else if(cnt_delay == 64'd4710)
	   cnt_delay <= cnt_delay;
	else
	   cnt_delay <= cnt_delay + 1'd1;
	   
	
	wire start;
	assign start =    (cnt_delay == 64'd4710) ? 1'b1 : 1'b0;
	
	
	reg start_z1 ,start_z2;
	always @(posedge clk)
	if(!rst_n)
	   begin
	       start_z1 <= 'd0;
	       start_z2 <= 'd0;
	   end 
	else
	   begin
	       start_z1 <= start;
	       start_z2 <= start_z1;
	   end 
	   
	 wire start_pedge;
	 assign   start_pedge = start_z1 & !start_z2;
 
    reg [31:0] cnt0;
    always @(posedge clk)
	if(!rst_n)
	   cnt0 <= 'd0;
	else if(cnt0 == cnt0_delay - 1'd1)
	   cnt0 <= 1'b0;
	else
	   cnt0 <= cnt0 + 1'd1;
	   
    
	reg cnt1_gate;
	always @(posedge clk)
	if(!rst_n)
		cnt1_gate <= 1'd0;
    else if(start_pedge)
        cnt1_gate <= 1'b1;
	else if(cnt0 == cnt0_delay - 1'd1)
	   begin
	       if(cnt1 == index_max)
	           cnt1_gate <= 1'b0;
	       else
	           cnt1_gate <= cnt1_gate;
	   end 
	else
		cnt1_gate <= cnt1_gate;
		
	reg [31:0] cnt1;
	always @(posedge clk)
	if(!rst_n)
		cnt1 <= 'd0;
    else if(cnt1_gate == 1'b0)
        cnt1 <= 'd0;
	else if(cnt0 == cnt0_delay - 1'd1)
		cnt1 <= cnt1 + 1'd1;
	else
		cnt1 <= cnt1;
  
    
	
	wire [31:0] bk_index_p1;	
	assign bk_index_p1 = cnt1 + 1;

	/*************************************************************************/
	// add tb.v  at here
	
	
	/*************************************************************************/
	//combine part
	assign bkt_ready_o = ((cnt1_gate == 1'b1) && (cnt0 >= 'd15)) ?  1'b1 : 1'b0;
    assign bkt_index_o = bk_index_base700;
    assign bkt_data_o  = bk_data_base700;
    
    
    endmodule
