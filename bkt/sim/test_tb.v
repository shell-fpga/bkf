`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2023 01:52:11 AM
// Design Name: 
// Module Name: test_tb
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


module test_tb(
	
    );
	
reg clk;
reg rst_n;
//reg start;

initial begin
	clk = 0;
end 

always #5 clk = ~clk;


initial begin
	rst_n =0;
//	start = 0;
	#100 rst_n = 1;
//	#1000 start = 1;
//	#1000 start = 0;
	#1000000 $stop;
end 

test_wrapper t1(
	 .clk(clk),
	 .rst_n(rst_n)
	
//	 .start_i(start)
    );

	
endmodule