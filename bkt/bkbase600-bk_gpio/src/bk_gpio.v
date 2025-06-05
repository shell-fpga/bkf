`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2024 02:12:09 PM
// Design Name: 
// Module Name: bk_gpio
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
 /*********************************bk_gpio_v1 bk_base:600*********************************************/
	//  ascripiton: shell
	//  type: RTL
    //  function : 
	//  update:  2025.3.12
	//  0         bit0          DESR             GPIO_enable
	//  1         bit31-0       gpo_mask         out mask
	//  2         bit0          gpo_value(1)     read offset       
	//  3         bit31-0       gpo              io_out
    //            bk_status                      // 0 : gpi value io_in
                                                 // 1 : 1902  gpo_value
module bk_gpio#(
    parameter BKP_BASE_index = 600,
	parameter nums = 5
)(
	input wire clk,
	input wire rst_n,
	// S BKP
    input  wire bkt_ready_i,
    input  wire [31:0] bkt_index_i,
    input  wire [31:0] bkt_data_i,
    output wire [nums-1:0] gp_o,
    input  wire [nums-1:0] gp_i,
    output wire [31:0] Bk_Status
    );
/********* gen code start*********/
	reg BKP_Ready_z1,BKP_Ready_z2;
always @(posedge clk)
if(!rst_n)
    begin
        BKP_Ready_z1 <= 1'b0;
        BKP_Ready_z2 <= 1'b0;
    end
 else
    begin
        BKP_Ready_z1 <= bkt_ready_i;
        BKP_Ready_z2 <= BKP_Ready_z1;
    end 

wire BKP_Ready;
assign BKP_Ready = BKP_Ready_z1 & ~BKP_Ready_z2;

wire [31:0] bk_data_index;
assign bk_data_index = bkt_index_i;

wire [31:0] bk_data;
assign bk_data = bkt_data_i;

reg [2:0] bk_mode;
always @(posedge clk)
if(!rst_n)
	bk_mode <= 'd0;
else if(BKP_Ready && bk_data_index == 0)
	bk_mode <= bk_data[2:0];

reg DESR;
always @(posedge clk)
if(!rst_n)
	DESR <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index)
	DESR <= bk_data[0];

reg [31:0] gpo_mask;
always @(posedge clk)
if(!rst_n)
	gpo_mask <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 1)
	gpo_mask <= bk_data;

reg [31:0] gpo_value_en;
always @(posedge clk)
if(!rst_n)
	gpo_value_en <= 'd0;
else if( bk_data_index == BKP_BASE_index + 2)
    begin
        if(BKP_Ready)
            gpo_value_en <= 1'b1;
        else
            gpo_value_en <= gpo_value_en;
    end  
else
    gpo_value_en <= 1'b0;
	
	  
reg [31:0] gpo;
genvar i;
generate 
    for (i=0;i<32;i=i+1)
    begin: loop1 
        always @(posedge clk)
        if(!rst_n)
	       gpo[i] <= 'd0;
        else if(BKP_Ready && bk_data_index == BKP_BASE_index + 3)
            begin
                if(gpo_mask[i] == 1'b1)
                    gpo[i]  <= bk_data[i];
                else
                    gpo[i]  <= gpo[i];
            end 
        else
            gpo[i] <= gpo[i];
    end 


endgenerate


reg [31:0] bk_status;
always @(posedge clk)
if(!rst_n)
   bk_status <= 'b0;
else if(DESR == 1'b0)   
   bk_status <= 'b0;
else if(bk_mode == 3'b1)
   begin
    if(gpo_value_en)    
        bk_status <= gpo;
    else
        bk_status <= 'b0;
   end 
else if(bk_mode == 3'b0)
   bk_status <= gp_i; 
else
      bk_status <= bk_status;
     	  
assign 	  gp_o = (DESR == 1'b0)   ? 'b0 :  gpo[nums-1:0];
assign    Bk_Status = bk_status;
endmodule
