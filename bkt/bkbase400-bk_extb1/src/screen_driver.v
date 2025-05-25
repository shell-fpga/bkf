`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  FPGA涔嬫梾 ----> ValentineHP
// 
// Create Date: 2023/07/19 19:38:26
// Design Name: 
// Module Name: screen_driver
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


module screen_driver(
    input       sys_clk         ,
    input       sys_rst_n       , 

    //鐢ㄦ埛淇″彿
    output       flush_data_update_o  ,  //鏇存柊褰撳墠鍧愭爣鐐规樉绀烘暟鎹娇鑳�
    input[15:0]  flush_data_i         ,  //褰撳墠鍧愭爣鐐规樉绀虹殑鏁版嵁
    output[15:0] flush_addr_width_o   ,  //褰撳墠鍒锋柊鐨剎鍧愭爣
    output[15:0] flush_addr_height_o  ,  //褰撳墠鍒锋柊鐨剏鍧愭爣
    //----


     //spi tft screen   灞忓箷鎺ュ彛          
    output      lcd_spi_sclk    ,           // 灞忓箷spi鏃堕挓鎺ュ彛
    output      lcd_spi_mosi    ,           // 灞忓箷spi鏁版嵁鎺ュ彛
    output      lcd_spi_cs      ,           // 灞忓箷spi浣胯兘鎺ュ彛     
    output      lcd_dc          ,           // 灞忓箷 鏁版嵁/鍛戒护 鎺ュ彛
    output      lcd_reset       ,           // 灞忓箷澶嶄綅鎺ュ彛
    output      lcd_blk                     // 灞忓箷鑳屽厜鎺ュ彛

);

parameter   SCREEN_WIDTH  = 32'd320;
parameter   SCREEN_HEIGHT = 32'd240;

//灞忓箷鐢ㄦ埛鎺ュ彛
reg[7:0]  spi_screen_flush_data   ;  //灞忓箷鏄剧ず鏁版嵁
wire      spi_screen_flush_updte  ;  //鍍忕礌鐐规暟鎹埛鏂�
wire      spi_screen_flush_fsync  ;  //灞忓箷甯у悓姝�
//------

//闀垮璁℃暟鍣�
reg[15:0]   width_cnt   ;
reg[15:0]   height_cnt  ;

//鏁版嵁鏇存柊
reg         data_update_cnt;


//璺熸柊鏁版嵁瀵勫瓨鍣�
reg[15:0]   flush_data_reg;


assign flush_data_update_o  = (spi_screen_flush_updte == 1'b1 && data_update_cnt == 1'b1) ? 1'b1 : 1'b0;
assign flush_addr_width_o   = width_cnt;
assign flush_addr_height_o  = height_cnt;

always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        data_update_cnt <= 'd0;
    else if( spi_screen_flush_fsync == 1'b1 )
        data_update_cnt <= 'd0;
    else if( spi_screen_flush_updte == 1'b1)
        data_update_cnt <= data_update_cnt + 1'b1;
    else
        data_update_cnt <= data_update_cnt;
end


always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        width_cnt <= 'd0;
    else if( spi_screen_flush_fsync == 1'b1 )
        width_cnt <= 'd0;
    else if( spi_screen_flush_updte == 1'b1 && data_update_cnt == 1'b1)
        if( width_cnt == (SCREEN_WIDTH - 1'b1))
            width_cnt <= 'd0;
        else
            width_cnt <= width_cnt + 1'b1;
    else
        width_cnt <= width_cnt;
end


always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        height_cnt <= 'd0;
    else if( spi_screen_flush_fsync == 1'b1)
        height_cnt <= 'd0;
    else if( width_cnt == (SCREEN_WIDTH - 1'b1) && spi_screen_flush_updte == 1'b1 && data_update_cnt == 1'b1)
        height_cnt <= height_cnt + 1'b1;
    else
        height_cnt <= height_cnt;
end



always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        flush_data_reg = 'd0;
    else if( spi_screen_flush_updte == 1'b1)
        if( data_update_cnt == 1'b0 )
            flush_data_reg = flush_data_i;
        else
            flush_data_reg = flush_data_reg << 8;
    else
        flush_data_reg = flush_data_reg;
end


always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_screen_flush_data <= 'd0;
    else 
        spi_screen_flush_data <= flush_data_reg[15:0];
end


spi_tft_screen_driver spi_tft_screen_driver_hp(
    .sys_clk            (   sys_clk         ),
    .sys_rst_n          (   sys_rst_n       ),


    //鐢ㄦ埛鎺ュ彛
    .spi_screen_flush_data_i   (    spi_screen_flush_data   ),  //灞忓箷鏄剧ず鏁版嵁
    .spi_screen_flush_updte_o  (    spi_screen_flush_updte  ),  //鍍忕礌鐐规暟鎹埛鏂�
    .spi_screen_flush_fsync_o  (    spi_screen_flush_fsync  ),  //灞忓箷甯у悓姝�
    //------


     //spi tft screen   灞忓箷鎺ュ彛          
    .lcd_spi_sclk       (   lcd_spi_sclk    ),           // 灞忓箷spi鏃堕挓鎺ュ彛
    .lcd_spi_mosi       (   lcd_spi_mosi    ),           // 灞忓箷spi鏁版嵁鎺ュ彛
    .lcd_spi_cs         (   lcd_spi_cs      ),           // 灞忓箷spi浣胯兘鎺ュ彛     
    .lcd_dc             (   lcd_dc          ),           // 灞忓箷 鏁版嵁/鍛戒护 鎺ュ彛
    .lcd_reset          (   lcd_reset       ),           // 灞忓箷澶嶄綅鎺ュ彛
    .lcd_blk            (   lcd_blk         )            // 灞忓箷鑳屽厜鎺ュ彛
);
endmodule
