`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2024 03:23:20 PM
// Design Name: 
// Module Name: BK_Status_SW
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
    /*********************************bk_status_sw bk_base:500*********************************************/
	//  ascripiton: shell
	//  type: RTL
    //  function : switch 1 of N bk_status also you can expand more status
	//  update:  2025.3.12
    //  0        bit0-3          DESR                       
    //  1        bit0            sw                  


module bk_status_sw #(
    parameter BKP_BASE_index =  400
)
(
    input  wire clk,
    input  wire rst_n,
    input  wire                   bkt_ready_i,
    input  wire            [31:0] bkt_index_i,
    input  wire            [31:0] bkt_data_i, 
    
    input  wire [31:0] Bk_Status0_i,
    input  wire [31:0] Bk_Status1_i,
    input  wire [31:0] Bk_Status2_i,
    
    output wire [31:0] Bk_Status
    );
    
      /********* gen code start*********/
reg BKP_rec_ready_z1,BKP_rec_ready_z2;
always @(posedge clk )
if(!rst_n)
    begin
        BKP_rec_ready_z1 <= 1'b0;
        BKP_rec_ready_z2 <= 1'b0;
    end
 else
    begin
        BKP_rec_ready_z1 <= bkt_ready_i;
        BKP_rec_ready_z2 <= BKP_rec_ready_z1;
    end 

wire BKP_rec_ready_pedge;
assign BKP_rec_ready_pedge = BKP_rec_ready_z1 & ~BKP_rec_ready_z2;

    wire [31:0] bk_data_index;
    assign bk_data_index = bkt_index_i;
    wire [31:0] bk_data;
    assign bk_data = bkt_data_i;
    // 0
//    reg [3:0] bk_mode;
//    always @(posedge clk )
//    if(!rst_n)
//        bk_mode <= 'd0;
//    else if(bkt_ready_i && bk_data_index == 0)
//        bk_mode <= bk_data[2:0];
//    else
//        bk_mode <= bk_mode;
    
    // 33
    reg [3:0] DESR;
    always @(posedge clk )
    if(!rst_n)
        DESR <= 'd0;
    else if(BKP_rec_ready_pedge && bk_data_index == BKP_BASE_index)
        DESR <= bk_data[3:0];
    else
        DESR <= DESR;
        
    // 33
    reg  [31:0] status_sw;
    always @(posedge clk )
    if(!rst_n)
        status_sw <= 'd0;
    else if(BKP_rec_ready_pedge && bk_data_index == BKP_BASE_index + 1)
        status_sw <= bk_data;
    else
        status_sw <= status_sw;
        
    reg [31:0] bk_status_p;
    always @(*)
    begin
    case(status_sw)
        0:
            bk_status_p = Bk_Status0_i; 
        1:
            bk_status_p = Bk_Status1_i; 
        2:
            bk_status_p = Bk_Status2_i;
        default:
            bk_status_p = Bk_Status0_i;
     endcase
    end 
    
    assign Bk_Status = bk_status_p;

endmodule