`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: FPGA涔嬫梾 ----> ValentineHP
// 
// Create Date: 2023/07/08 18:20:42
// Design Name: 
// Module Name: spi_tft_screen_driver
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


module spi_tft_screen_driver(
    input       sys_clk         ,
    input       sys_rst_n       ,


    //鐢ㄦ埛鎺ュ彛
    input[7:0]  spi_screen_flush_data_i   ,  //灞忓箷鏄剧ず鏁版嵁
    output      spi_screen_flush_updte_o  ,  //鍍忕礌鐐规暟鎹埛鏂�
    output      spi_screen_flush_fsync_o  ,  //灞忓箷甯у悓姝�
    //------

     //spi tft screen   灞忓箷鎺ュ彛          
    output      lcd_spi_sclk    ,           // 灞忓箷spi鏃堕挓鎺ュ彛
    output      lcd_spi_mosi    ,           // 灞忓箷spi鏁版嵁鎺ュ彛
    output      lcd_spi_cs      ,           // 灞忓箷spi浣胯兘鎺ュ彛     
    output      lcd_dc          ,           // 灞忓箷 鏁版嵁/鍛戒护 鎺ュ彛
    output      lcd_reset       ,           // 灞忓箷澶嶄綅鎺ュ彛
    output      lcd_blk                     // 灞忓箷鑳屽厜鎺ュ彛
);

//灞忓箷灏哄
parameter   SCREEN_WIDTH  = 32'd320;
parameter   SCREEN_HEIGHT = 32'd240;
//灞忓箷鏄剧ず鏂瑰悜
parameter   SCREEN_ORIENT = 2'b00;   
//灞忓箷椹卞姩淇″彿锛岄粯璁�
assign lcd_reset = 1'b1;
assign lcd_blk   = 1'b1;


//鎬绘ā鍧椾俊鍙�
reg             lcd_init_done   ;   //鍒濆鍖栧畬鎴愭爣蹇椾俊鍙�
wire            spi_start      ;
wire            spi_end        ;
wire[7:0]       spi_send_data  ;
wire            spi_send_ack   ;
wire            lcd_dc_i       ;




// 鍒濆鍖栨ā鍧椾俊鍙�
wire            tft_screen_init_req   ;  //鍒濆鍖栬姹�
wire            tft_screen_init_ack   ;  //鍒濆鍖栧畬鎴�  
wire[7:0]       tft_screen_init_data  ;  //鍒濆鍖栨暟鎹�
wire            tft_screen_init_dc    ;  //鍒濆鍖杁c
wire            spi_send_init_req     ;  //spi鍙戦�佹暟鎹姹�
wire            spi_send_init_end     ;  //缁撴潫spi鍙戦��
wire            spi_send_init_ack     ;  //spi涓�涓暟鎹彂閫佸畬鎴�


//鍒锋柊妯″潡

wire tft_screen_flush_req;
wire[7:0] tft_screen_flush_data;
wire tft_screen_flush_dc ;

wire spi_send_flush_req;
wire spi_send_flush_end;
wire spi_send_flush_ack;


assign tft_screen_flush_req = ( lcd_init_done == 1'b1) ? 1'b1 : 1'b0;
assign spi_send_flush_ack  = ( lcd_init_done == 1'b1) ? spi_send_ack : 1'b0;


assign tft_screen_init_req = ~lcd_init_done;
assign spi_send_init_ack   =  ( lcd_init_done == 1'b0) ? spi_send_ack : 1'b0;





assign spi_start        = ( lcd_init_done == 1'b0) ? spi_send_init_req : spi_send_flush_req;
assign spi_end          = ( lcd_init_done == 1'b0) ? spi_send_init_end : spi_send_flush_end;
assign spi_send_data    = ( lcd_init_done == 1'b0) ? tft_screen_init_data : tft_screen_flush_data;
assign lcd_dc_i         = ( lcd_init_done == 1'b0) ? tft_screen_init_dc : tft_screen_flush_dc;


//鍒濆鍖栨槸鍚﹀畬鎴�
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        lcd_init_done <= 1'b0;
    else if( tft_screen_init_ack == 1'b1)
        lcd_init_done <= 1'b1;
    else
        lcd_init_done <= lcd_init_done;
end




spi_tft_screen_flush #(
    .SCREEN_WIDTH(SCREEN_WIDTH),
    .SCREEN_HEIGHT(SCREEN_HEIGHT),
    .Number_Of_Pixels(SCREEN_WIDTH*SCREEN_HEIGHT*'d2)
)spi_tft_screen_flush_hp(
    .sys_clk                (   sys_clk             ),
    .sys_rst_n              (   sys_rst_n           ),


     //鐢ㄦ埛鎺ュ彛
    .spi_screen_flush_data_i   (    spi_screen_flush_data_i ),  //灞忓箷鏄剧ず鏁版嵁
    .spi_screen_flush_updte_o  (    spi_screen_flush_updte_o),  //鍍忕礌鐐规暟鎹埛鏂�
    .spi_screen_flush_fsync_o  (    spi_screen_flush_fsync_o),  //灞忓箷甯у悓姝�
    //------


    .tft_screen_flush_req_i  (  tft_screen_flush_req),  //鍒锋柊璇锋眰
    .tft_screen_flush_data_o (  tft_screen_flush_data),  //鍒锋柊鏁版嵁
    .tft_screen_flush_dc_o   (  tft_screen_flush_dc),  //鍒锋柊dc


    .spi_send_flush_req_o    (  spi_send_flush_req  ),  //spi鍙戦�佹暟鎹姹�
    .spi_send_flush_end_o    (  spi_send_flush_end  ),  //缁撴潫spi鍙戦��
    .spi_send_flush_ack_i    (  spi_send_flush_ack  )   //spi涓�涓暟鎹彂閫佸畬鎴�
);






//鍒濆鍖栨ā鍧�
spi_tft_screen_init  #(
    .SCREEN_WIDTH(SCREEN_WIDTH),
    .SCREEN_HEIGHT(SCREEN_HEIGHT),
    .SCREEN_ORIENT(SCREEN_ORIENT)
) spi_tft_screen_init_hp(
    .sys_clk                (   sys_clk             ),
    .sys_rst_n              (   sys_rst_n           ),


    .tft_screen_init_req_i  (   tft_screen_init_req ),  //鍒濆鍖栬姹�
    .tft_screen_init_ack_o  (   tft_screen_init_ack ),  //鍒濆鍖栧畬鎴�  
    .tft_screen_init_data_o (   tft_screen_init_data),  //鍒濆鍖栨暟鎹�
    .tft_screen_init_dc_o   (   tft_screen_init_dc  ),  //鍒濆鍖杁c


    .spi_send_init_req_o    (   spi_send_init_req   ),  //spi鍙戦�佹暟鎹姹�
    .spi_send_init_end_o    (   spi_send_init_end   ),  //缁撴潫spi鍙戦��
    .spi_send_init_ack_i    (   spi_send_init_ack   )   //spi涓�涓暟鎹彂閫佸畬鎴�
);









spi_master_driver spi_master_driver_hp(
    //绯荤粺鎺ュ彛
    .sys_clk                    (    sys_clk         ),
    .sys_rst_n                  (    sys_rst_n       ),

    //鐢ㄦ埛鎺ュ彛
    .spi_start_i                (   spi_start       ),   // spi寮�濮嬩俊鍙�
    .spi_end_i                  (   spi_end         ),   // spi缁撴潫淇″彿
    .spi_send_data_i            (   spi_send_data   ),   // spi鍙戦�佹暟鎹�
    .spi_send_ack_o             (   spi_send_ack    ),   // spi鍙戦��8bit鏁版嵁瀹屾垚淇″彿
      
    .lcd_dc_i                   (   lcd_dc_i        ),   //鏁版嵁杩樻槸鍛戒护淇″彿杈撳叆
    .lcd_dc                     (   lcd_dc          ),   //鏁版嵁杩樻槸鍛戒护淇″彿杈撳嚭

    //spi  绔彛
    .spi_sclk                   (   lcd_spi_sclk    ),
    .spi_mosi                   (   lcd_spi_mosi    ),
    .spi_cs                     (   lcd_spi_cs      )
);

endmodule
