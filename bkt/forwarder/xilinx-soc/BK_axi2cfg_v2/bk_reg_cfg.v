`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/05 13:56:26
// Design Name: 
// Module Name: iic_bk_cfg
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


module bk_reg_cfg #(
    parameter ready_bit = 0
)(  
    // sys interface
    input wire clk,
    input wire rst_n,
    
           //bk_regs interface

	    //ap_ctrl_bus
        input  wire                                    ap_start_pedge      ,
        output wire                                    ap_done_o           ,
        
        //register 
        output wire BkpCfg_Ready_o,
        output wire [31:0] BkpCfg_DataIndex_o,
        output wire [31:0] BkpCfg_DataValue_o,
        input  wire [31:0] BK_Status_i,


        input  wire [31:0] reg0_i,
        input  wire [31:0] reg1_i,
        input  wire [31:0] reg2_i,
        output wire [31:0] reg3_o    
    );
    
	
	localparam ap_cfg_delay = 50000; 

     // cfging done 
    reg ap_cfg_gate;
    always @(posedge clk or negedge rst_n)
    if(!rst_n)
        ap_cfg_gate <= 1'b0;
    else if(ap_start_pedge)
        ap_cfg_gate <= 1'b1;
    else if(cnt0 == ap_cfg_delay-1'd1) 
        ap_cfg_gate <= 1'b0;
    else
        ap_cfg_gate <= ap_cfg_gate;
    
    
    reg [31:0] cnt0;
    always @(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt0 <= 1'd0;
    else if(ap_cfg_gate)
        cnt0 <= cnt0 + 1'd1;
    else
        cnt0 <= 'd0;

    wire data_ready;
    assign data_ready = reg0_i[ready_bit];
    
//    reg data_ready_d1,data_ready_d2;
//    always @(posedge clk or negedge rst_n)
//    if(!rst_n)
//        begin
//            data_ready_d1 <= 'd0;
//            data_ready_d2 <= 'd0;
//        end 
//     else
//        begin
//            data_ready_d1 <= data_ready;
//            data_ready_d2 <= data_ready_d1;
//        end 
    
//   wire data_ready_pedge;
//   assign    data_ready_pedge =   data_ready_d1 & !data_ready_d2;
   
   

   assign BkpCfg_Ready_o = data_ready;
   assign BkpCfg_DataIndex_o = reg1_i;
   assign BkpCfg_DataValue_o = reg2_i;
   
   assign reg3_o =  BK_Status_i;

    wire cfg_done;
    assign cfg_done = (cnt0 == ap_cfg_delay-1'd1)  ? 1'b1 : 1'b0;
    assign ap_done_o =  cfg_done;
    
     
endmodule