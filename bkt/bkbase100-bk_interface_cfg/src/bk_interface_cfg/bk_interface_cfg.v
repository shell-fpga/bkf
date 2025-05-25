`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: shell_yue
// 
// Create Date: 04/12/2024 10:34:39 AM
// Design Name: 
// Module Name: bk_interface_cfg
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

/*****************************************************************************************************************/
/*************************************** Variables Definitions **************************************************/
/*****************************************************************************************************************/
	/** Index        Vaild bits     	 Name       	     	     Desrciption **/
    /*********************************bk_interface_cfg bkt_base:100*********************************************/
	 //  ascripiton: shell
	 //  type: IP_xilinx22.1
	 //  function:  this module can match bkp interface  to send data to anyone of the general extern communication interface. need bkp interface in bki folder.
	 //  update:  2025.3.12
	 //  0		 bit0		  DESR				    
	 //  1		 bit31-0		  bkp_send_data		 data buf
	 //  2          bit0            read_done               use to clean the data_ready status 
	 //  3			    		  read_offest(1)		 use to get read data
	 //             bit31-0         bk_status(0 1)          bk_mode0 :  bit0    data_ready  bit1 send busy  
	 //											  bk_mode1 :  bit31-0 bkp_read_data


module bk_interface_cfg#(
    parameter BKT_BASE = 100,
    parameter bkp_data_with  = 8
)
(
    input wire clk,
    input wire rst_n,
    
	// the bk system port  SBKPcfg
    input wire bkt_ready_i,
    input wire [31:0] bkt_index_i,
    input wire [31:0] bkt_data_i,
	
	// the bk system port  MBKP   
    output wire Bkp_Ready_o,
    output wire [bkp_data_with-1:0] Bkp_Data_o,
    input wire  Bkp_Busy_i,
    // he bk system port  SBKP   
    input wire   Bkp_Ready_i,
    input wire  [bkp_data_with-1:0] Bkp_Data_i,
    output wire  Bkp_Busy_o,
    
    
    
    output wire [31:0] bk_status
    );
    
    
    /********* gen code start*********/  
reg bkt_ready_z1,bkt_ready_z2;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    begin
        bkt_ready_z1 <= 1'b0;
        bkt_ready_z2 <= 1'b0;
    end
 else
    begin
        bkt_ready_z1 <= bkt_ready_i;
        bkt_ready_z2 <= bkt_ready_z1;
    end 

wire bkt_ready_pedge;
assign bkt_ready_pedge = bkt_ready_z1 & ~bkt_ready_z2;

wire [31:0] bkt_index;
assign bkt_index = bkt_index_i;

wire [31:0] bkt_value;
assign bkt_value = bkt_data_i;

reg [2:0] bk_mode;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	bk_mode <= 'd0;
else if(bkt_ready_pedge && bkt_index == 0)
	bk_mode <= bkt_value[3:1];

reg [3:0] DESR;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	DESR <= 'd0;
else if(bkt_ready_pedge && bkt_index == BKT_BASE)
	DESR <= bkt_value[3:0];

reg [31:0] bkp_send_data;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	bkp_send_data <= 'd0;
else if(bkt_ready_pedge && bkt_index == BKT_BASE+1)
	bkp_send_data <= bkt_value;
	
reg  read_done;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	read_done <= 'd0;
else if(bkt_ready_pedge && bkt_index == BKT_BASE+2)
	read_done <= bkt_value[0];
	


reg [31:0] bk_status_p;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    bk_status_p <= 'b0;
else if(DESR == 'd0)
    bk_status_p <= 'b0;
else if(bk_mode == 3'd1)
    begin
        if(bkt_ready_pedge && bkt_index == BKT_BASE + 3)
            bk_status_p <= bkp_read_data;
    end 
 else
    bk_status_p <= {Bkp_Busy_i,data_ready};
    
  assign  bk_status =  bk_status_p;
   /********* gen code start*********/  
   
   reg Bkp_Ready;
   always @(posedge clk or negedge rst_n)
   if(!rst_n)
        Bkp_Ready <= 1'b0;
   else if(DESR == 'b0  || Bkp_Busy_o == 1'b1)
        Bkp_Ready <= 1'b0;
   else if(bkt_index == BKT_BASE+1)
        Bkp_Ready <= bkt_ready_pedge;
   else
        Bkp_Ready <= 1'b0;
   
   assign  Bkp_Ready_o = Bkp_Ready;
   assign  Bkp_Data_o =  bkp_send_data;


   reg data_ready;
   always @(posedge clk or negedge rst_n)
   if(!rst_n)
        data_ready <= 1'b0;
   else if(DESR == 'b0 || read_done == 1'b1)
        data_ready <= 1'b0;
   else if(Bkp_Ready_i)
        data_ready <= 1'b1;
   else
        data_ready <= data_ready;
        
   reg [bkp_data_with-1:0] bkp_read_data;  
   always @(posedge clk or negedge rst_n)
   if(!rst_n)
        bkp_read_data <= 'b0;
   else if(DESR == 'b0)
        bkp_read_data <= 'b0;
   else if(Bkp_Ready_i)
        bkp_read_data <= 1'b1;
   else
        bkp_read_data <= Bkp_Data_i;
   
   
   assign Bkp_Busy_o = 1'b0;
   
endmodule
