`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2022 10:10:31 PM
// Design Name: 
// Module Name: ap_led_example
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


module led_example(
        input  wire                                    ap_clk              ,
        input  wire                                    ap_rst_n            ,         
        //ap_ctrl_bus
        input  wire                                    ap_start_pedge      ,
        output wire                                    ap_done_o           ,
        //bk lite interface
        input wire  [31:0]                             reg0_i              ,
        input wire  [31:0]                             reg1_i              ,
        
        output wire                                    led0                ,
        output wire                                    led1                
    );
    
    
    localparam cnt0_delay = 400_000_000;
    
    reg cnt0_gate;
    always @(posedge ap_clk or negedge ap_rst_n)
    if(!ap_rst_n)
        cnt0_gate <= 1'b0;
    else if(cnt0 == cnt0_delay-1'd1)
        cnt0_gate <= 1'b0;
    else if(ap_start_pedge)
        cnt0_gate <= 1'b1;
    else
        cnt0_gate <= cnt0_gate;
        
    reg [31:0] cnt0;
    always @(posedge ap_clk or negedge ap_rst_n)
    if(!ap_rst_n)
        cnt0 <= 1'b0;
    else if(cnt0_gate)
        cnt0 <= cnt0 + 1'd1;
    else
        cnt0 <= 'd0;
        
        
    
    reg [31:0] reg0_n1;
    always @(posedge ap_clk or negedge ap_rst_n)
    if(!ap_rst_n)
        reg0_n1 <= 1'b0;
    else
        reg0_n1 <= reg0_i;
        
    reg [31:0] reg1_n1;
    always @(posedge ap_clk or negedge ap_rst_n)
    if(!ap_rst_n)
        reg1_n1 <= 1'b0;
    else
        reg1_n1 <= reg1_i;
    
    assign led0 = (cnt0_gate) ? reg0_n1[0] : 1'b0;
    assign led1 = (cnt0_gate) ? reg1_n1[0] : 1'b0;
    
    
    assign ap_done_o = (cnt0 == cnt0_delay-1'd1) ? 1'b1 : 1'b0;
    
endmodule