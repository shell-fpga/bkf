`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 02:33:48 AM
// Design Name: 
// Module Name: bk_extb1
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

	/*********************************bk_extb1  bk_base:400*********************************************/
	//  ascripiton: shell
	//  type: RTL
    //  function : switch 1 of N bk_status also you can expand more status
	//  update:  2025.3.14
	//  0          bit0          DESR             //extb1_enable
	//  1          bit3-0        led              //4 leds
	//  2          bit23-0       smg              //6 smg  4bit every 1 smg  value can be  0-9       
	//  3          bit31-0       beep_D           //beep  dds D
	//  4          bit0          use_lcdex        //use_lcdex
    //             bk_status                      //bit 4-0 btn value
                                                     
module bk_extb1 #(
    parameter BKP_BASE_index = 400
)
(
    input wire clk,
    input wire rst_n,
    
   
     // S BKP
    input  wire bkt_ready_i,
    input  wire [31:0] bkt_index_i,
    input  wire [31:0] bkt_data_i,

    
    output wire [3:0] led_o,

    input  wire [3:0] btn_i,
    output wire [3:0] btn_xd,
    
    output wire beep_o,
    // smg
    output  ds,
    output  shcp,
    output  stcp,
    output  [5:0] sel_o,
    
    //spi tft screen          
    output      lcd_spi_sclk    ,       // 
    output      lcd_spi_mosi    ,       // 
    output      lcd_spi_cs      ,       //     
    output      lcd_dc          ,       // 
    //output      lcd_blk         ,
    //output      lcd_reset       ,
    
    
    input   wire [15:0] lcd_data,
    output  wire [15:0] x,
    output  wire [15:0] y,
    
    
    output wire [31:0] bk_status
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

reg [3:0] led;
always @(posedge clk)
if(!rst_n)
	led <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 1)
	led <= bk_data[3:0];    

reg [23:0] smg;
always @(posedge clk)
if(!rst_n)
	smg <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 2)
	smg <= bk_data[23:0];    
    
    
reg [31:0] beep_D;
always @(posedge clk)
if(!rst_n)
	beep_D <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 3)
	beep_D <= bk_data;    
        

    
reg use_lcdex;
always @(posedge clk)
if(!rst_n)
	use_lcdex <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 4)
	use_lcdex <= bk_data[0];    
        



//btn 
wire [3:0] btn;
  key_xd_0 u1 (
  .CLK(clk),          // input wire CLK
  .RSTn(rst_n),        // input wire RSTn
  .Pin_In(btn_i[0]),    // input wire Pin_In
  .Pin_Out(btn[0])  // output wire Pin_Out
);

 key_xd_0 u2 (
  .CLK(clk),          // input wire CLK
  .RSTn(rst_n),        // input wire RSTn
  .Pin_In(btn_i[1]),    // input wire Pin_In
  .Pin_Out(btn[1])  // output wire Pin_Out
);
 key_xd_0 u3 (
  .CLK(clk),          // input wire CLK
  .RSTn(rst_n),        // input wire RSTn
  .Pin_In(btn_i[2]),    // input wire Pin_In
  .Pin_Out(btn[2])  // output wire Pin_Out
);
 key_xd_0 u4 (
  .CLK(clk),          // input wire CLK
  .RSTn(rst_n),        // input wire RSTn
  .Pin_In(btn_i[3]),    // input wire Pin_In
  .Pin_Out(btn[3])  // output wire Pin_Out
);

//------------smg--------------
wire    [23:0]  BCD_DATA = {4'h8, 4'h8, 4'h8, 4'h8, 4'h8, 4'h8};//瀵瑰簲鎵╁睍鏉夸笂鐨?6涓暟鐮佺浠庡乏鍒板彸锛?
                                                                //鎯宠閭ｄ釜杈撳嚭鏁板瓧鍑狅紝姝ゅ灏辨敼鎴愭暟瀛楀嚑
wire    [7:0]   seg;
wire    [5:0]   sel_0;

//------------function-------------
BCD2seg_sel inst_BCD2seg_sel(
    .sys_clk      (clk),
    .sys_rst_n    (rst_n),
    .BCD_data ((DESR) ? smg : BCD_DATA),
    .seg      (seg),
    .sel      (sel_0)
);
hc595 inst_hc595(
    .sys_clk   (clk),
    .sys_rst_n (rst_n),
    .seg   (seg),
    .ds    (ds),
    .shcp  (shcp),
    .stcp  (stcp)
);
    


//beep 
//wire beep;
//single_pulse_gen(
//      .clk(clk), 
//      .rst_n(rst_n),
//      .dds_enable(DESR),
//      .D_i(beep_D),
//      .pulse_o(beep) 

//    );
beep csdn_beep(
  .clk          (clk),
  .rst_n        (rst_n),
  .beep_out     (beep)
);

    


// lcd
wire       flush_data_update  ;  //鏇存柊褰撳墠鍧愭爣鐐规樉绀烘暟鎹娇鑳?
reg[15:0]  flush_data         ;  //褰撳墠鍧愭爣鐐规樉绀虹殑鏁版嵁
wire[15:0] flush_addr_width   ;  //褰撳墠鍒锋柊鐨剎鍧愭爣
wire[15:0] flush_addr_height  ;  //褰撳墠鍒锋柊鐨剏鍧愭爣

always@(posedge clk or negedge rst_n) begin
    if( rst_n == 1'b0)
        flush_data <= 16'd0;
    else if( flush_addr_width <= 'd120)
        if( flush_addr_height <= 'd120)
            flush_data <= 16'h1234;
        else
            flush_data <= 16'h07e0;
    else
        if( flush_addr_height <= 'd120)
            flush_data <= 16'habcd;
        else
            flush_data <= 16'h05ff;
end

screen_driver screen_driver_hp(
    .sys_clk            (   clk         ),
    .sys_rst_n          (   rst_n       ),


    //鐢ㄦ埛淇″彿
    .flush_data_update_o  (     flush_data_update   ),  //鏇存柊褰撳墠鍧愭爣鐐规樉绀烘暟鎹娇鑳?
    .flush_data_i         (     (use_lcdex) ? flush_data : lcd_data          ),  //褰撳墠鍧愭爣鐐规樉绀虹殑鏁版嵁
    .flush_addr_width_o   (     flush_addr_width    ),  //褰撳墠鍒锋柊鐨剎鍧愭爣
    .flush_addr_height_o  (     flush_addr_height   ),  //褰撳墠鍒锋柊鐨剏鍧愭爣
    //----

     //spi tft screen   灞忓箷鎺ュ彛          
    .lcd_spi_sclk       (   lcd_spi_sclk    ),           // 灞忓箷spi鏃堕挓鎺ュ彛
    .lcd_spi_mosi       (   lcd_spi_mosi    ),           // 灞忓箷spi鏁版嵁鎺ュ彛
    .lcd_spi_cs         (   lcd_spi_cs      ),           // 灞忓箷spi浣胯兘鎺ュ彛     
    .lcd_dc             (   lcd_dc          ),           // 灞忓箷 鏁版嵁/鍛戒护 鎺ュ彛
    .lcd_reset          (          ),           // 灞忓箷澶嶄綅鎺ュ彛
    .lcd_blk            (            )            // 灞忓箷鑳屽厜鎺ュ彛
);    
    
    
    
assign bk_status = btn; 
    
assign led_o =  led;
assign sel_o =  sel_0;
assign btn_xd = btn;
assign beep_o = (beep_D == 32'd42950 && DESR)?beep:'d0;    

assign lcd_x = flush_addr_width;
assign lcd_y = flush_addr_height;
endmodule
