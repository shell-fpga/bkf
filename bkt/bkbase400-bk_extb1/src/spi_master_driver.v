`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: FPGA涔嬫梾 ----> ValentineHP
// 
// Create Date: 2023/07/08 08:38:50
// Design Name: 
// Module Name: spi_master_driver
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



// //妯″紡0锛欳POL= 0锛孋PHA=0銆係CK涓茶鏃堕挓绾跨┖闂叉槸涓轰綆鐢靛钩锛屾暟鎹湪SCK鏃堕挓鐨勪笂鍗囨部琚噰鏍凤紝鏁版嵁鍦⊿CK鏃堕挓鐨勪笅闄嶆部鍒囨崲
// //妯″紡1锛欳POL= 0锛孋PHA=1銆係CK涓茶鏃堕挓绾跨┖闂叉槸涓轰綆鐢靛钩锛屾暟鎹湪SCK鏃堕挓鐨勪笅闄嶆部琚噰鏍凤紝鏁版嵁鍦⊿CK鏃堕挓鐨勪笂鍗囨部鍒囨崲
// //妯″紡2锛欳POL= 1锛孋PHA=0銆係CK涓茶鏃堕挓绾跨┖闂叉槸涓洪珮鐢靛钩锛屾暟鎹湪SCK鏃堕挓鐨勪笅闄嶆部琚噰鏍凤紝鏁版嵁鍦⊿CK鏃堕挓鐨勪笂鍗囨部鍒囨崲
// //妯″紡3锛欳POL= 1锛孋PHA=1銆係CK涓茶鏃堕挓绾跨┖闂叉槸涓洪珮鐢靛钩锛屾暟鎹湪SCK鏃堕挓鐨勪笂鍗囨部琚噰鏍凤紝鏁版嵁鍦⊿CK鏃堕挓鐨勪笅闄嶆部鍒囨崲




//妯″紡3锛欳POL= 1锛孋PHA=1銆係CK涓茶鏃堕挓绾跨┖闂叉槸涓洪珮鐢靛钩锛屾暟鎹湪SCK鏃堕挓鐨勪笂鍗囨部琚噰鏍凤紝鏁版嵁鍦⊿CK鏃堕挓鐨勪笅闄嶆部鍒囨崲
module spi_master_driver(
    //绯荤粺鎺ュ彛
    input sys_clk                   ,
    input sys_rst_n                 ,

    //鐢ㄦ埛鎺ュ彛
    input           spi_start_i     ,   // spi寮�濮嬩俊鍙�
    input           spi_end_i       ,   // spi缁撴潫淇″彿
    input[7:0]      spi_send_data_i ,   // spi鍙戦�佹暟鎹�
    output          spi_send_ack_o  ,   // spi鍙戦��8bit鏁版嵁瀹屾垚淇″彿
      
    input           lcd_dc_i        ,   //鏁版嵁杩樻槸鍛戒护淇″彿杈撳叆
    output  reg     lcd_dc          ,   //鏁版嵁杩樻槸鍛戒护淇″彿杈撳嚭
    //spi  绔彛
    output  reg     spi_sclk        ,
    output  reg     spi_mosi        ,
    output  reg     spi_cs          
);


reg[7:0] spi_send_data_reg;         //鏁版嵁瀵勫瓨鍣�
reg[3:0] spi_send_data_bit_cnt;     //鏁版嵁鍙戦�乥it璁℃暟鍣�
reg      spi_end_reg;               //spi缁撴潫鏍囧織


assign   spi_send_ack_o = ( spi_send_data_bit_cnt == 'd6 && spi_sclk == 1'b1) ? 1'b1 : 1'b0;


//鍙戦�佹暟鎹紦瀛�
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        spi_send_data_reg <= 'd0;
    else if(spi_send_data_bit_cnt == 'd0)    //8bit鏁版嵁鍙戦�佸畬鎴愬悗锛岀紦瀛樻柊鐨勬暟鎹�
        spi_send_data_reg <= spi_send_data_i;
    else
        spi_send_data_reg <= spi_send_data_reg;
end

//缁撴潫spi鍙戦��
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_end_reg <= 1'b0;
    else if( spi_cs == 1'b1)   //娓呴櫎缁撴潫鏍囧織
        spi_end_reg <= 1'b0;
    else if( spi_end_i == 1'b1)  //缂撳瓨缁撴潫鏍囧織
        spi_end_reg <= 1'b1;
    else
        spi_end_reg <= spi_end_reg;

end

//鏁版嵁鏄懡浠よ繕鏄暟鎹�
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        lcd_dc <= 1'b1;
    else if( spi_start_i == 1'b1)
        lcd_dc <= lcd_dc_i;
    else
        lcd_dc <= lcd_dc;
end

//鐗囬�塻pi
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_cs <= 1'b1;
    else if( spi_end_reg == 1'b1 && spi_send_data_bit_cnt == 'd0)
        spi_cs <= 1'b1;
    else if( spi_start_i == 1'b1 )  
        spi_cs <= 1'b0;
    else
        spi_cs <= spi_cs;
end


//浜х敓spi鏃堕挓
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_sclk <= 1'b1;
    else if( spi_end_reg == 1'b1 && spi_send_data_bit_cnt == 'd0)
        spi_sclk <= spi_sclk;
    else if( spi_cs == 1'b0 )
        spi_sclk <= ~spi_sclk;
    else 
        spi_sclk <= 1'b1;
end


//鏁版嵁鍙戦�乥it鏁板瘎瀛樺櫒
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0) 
        spi_send_data_bit_cnt <= 'd0;
   else if( spi_end_reg == 1'b1 && spi_send_data_bit_cnt == 'd0)
        spi_send_data_bit_cnt <= 'd0;
    else if( spi_cs == 1'b0 && spi_sclk == 1'b0)
        if( spi_send_data_bit_cnt == 'd7)
            spi_send_data_bit_cnt <= 'd0;
        else
            spi_send_data_bit_cnt <= spi_send_data_bit_cnt + 1'b1;
    else if( spi_cs == 1'b0)
        spi_send_data_bit_cnt <= spi_send_data_bit_cnt;
    else
        spi_send_data_bit_cnt <= 'd0;
end

//spi鏁版嵁鍙戦��
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_mosi <= 1'b1;
    else if( spi_cs == 1'b0)
        spi_mosi <= spi_send_data_reg['d7 - spi_send_data_bit_cnt];
    else
        spi_mosi <= spi_mosi;
end

endmodule