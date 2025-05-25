`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: FPGA涔嬫梾 ----> ValentineHP
// 
// Create Date: 2023/07/08 18:40:05
// Design Name: 
// Module Name: spi_tft_screen_init
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



//瀵箂pi tft灞忓箷杩涜鍒濆鍖�
module spi_tft_screen_init(
    input           sys_clk                 ,
    input           sys_rst_n               ,


    input           tft_screen_init_req_i   ,  //鍒濆鍖栬姹�
    output          tft_screen_init_ack_o   ,  //鍒濆鍖栧畬鎴�  
    output reg[7:0] tft_screen_init_data_o  ,  //鍒濆鍖栨暟鎹�
    output reg      tft_screen_init_dc_o    ,  //鍒濆鍖杁c

    output          spi_send_init_req_o     ,  //spi鍙戦�佹暟鎹姹�
    output          spi_send_init_end_o     ,  //缁撴潫spi鍙戦��
    input           spi_send_init_ack_i        //spi涓�涓暟鎹彂閫佸畬鎴�
);
parameter   SCREEN_WIDTH  = 16'd320;
parameter   SCREEN_HEIGHT = 16'd240;
parameter   SCREEN_ORIENT = 2'b00;


localparam DELAY_255ms = 32'd255_000;//32'd255_000;  //255ms
localparam DELAY_200us = 32'd10; //200us


localparam  S_IDLE      = 4'b0001;
localparam  S_SEND_DATA = 4'b0010;
localparam  S_DELAY     = 4'b0100;
localparam  S_ACK       = 4'b1000;


reg[4:0]    init_cnt;    //鍒濆鍖栧懡浠�/鏁版嵁璁℃暟
reg[31:0]   delay_cnt;   //寤舵椂璁℃暟
reg[3:0]    state , next_state;



assign tft_screen_init_ack_o = (state == S_ACK) ? 1'b1 : 1'b0;
assign spi_send_init_req_o   = (state == S_SEND_DATA) ? 1'b1 : 1'b0;
assign spi_send_init_end_o   = (state == S_DELAY) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        state <= S_IDLE;
    else
        state <= next_state;
end


always@(*) begin
    case(state)
    S_IDLE:
        if( tft_screen_init_req_i == 1'b1)
            next_state <= S_SEND_DATA;
        else
            next_state <= S_IDLE;
    S_SEND_DATA:
        if( spi_send_init_ack_i == 1'b1)
            next_state <= S_DELAY;
        else
            next_state <= S_SEND_DATA;
    S_DELAY:
        if( init_cnt == 'd19)
            if( delay_cnt == DELAY_255ms)
                next_state <= S_ACK;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd1 )
            if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd2 )
             if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd4 )
              if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd17 )
              if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd18 )
            if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if( delay_cnt == DELAY_200us)
            next_state <= S_SEND_DATA;
        else
            next_state <= S_DELAY;
    S_ACK:
        next_state <= S_IDLE;
    default: next_state = S_IDLE;
    endcase

end




//鍒濆鍖栨暟鎹鏁�
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0) 
        init_cnt <= 'd0;
    else if( spi_send_init_ack_i == 1'b1)
        init_cnt <= init_cnt + 1'b1;
    else
        init_cnt <= init_cnt;
end


//寤舵椂璁℃暟
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        delay_cnt <= 'd0;
    else if( state == S_DELAY)
        delay_cnt <= delay_cnt + 1'b1;
    else
        delay_cnt <= 'd0;
end


//鍛戒护鏁版嵁杈撳嚭
always@(*)begin
    case (init_cnt)
        'd0: begin
            tft_screen_init_data_o  = 8'h01;
            tft_screen_init_dc_o    = 1'b0;
        end
        'd1: begin
            tft_screen_init_data_o  = 8'h11;
            tft_screen_init_dc_o    = 1'b0;
        end
        'd2: begin
            tft_screen_init_data_o  = 8'h3A;
            tft_screen_init_dc_o    = 1'b0;
        end
        'd3: begin
            tft_screen_init_data_o  = 8'h55;
            tft_screen_init_dc_o    = 1'b1;
        end
        'd4: begin
            tft_screen_init_data_o  = 8'h36;
            tft_screen_init_dc_o    = 1'b0;
        end
        'd5: begin
            tft_screen_init_data_o  = 8'h78;
            tft_screen_init_dc_o    = 1'b1;
        end
        'd6: begin
            tft_screen_init_data_o  = 8'h2A;
            tft_screen_init_dc_o    = 1'b0;
        end

        'd7: begin
            tft_screen_init_data_o  = 8'h00;
            tft_screen_init_dc_o    = 1'b1;
        end
        'd8: begin
            tft_screen_init_data_o  = 8'h00;
            tft_screen_init_dc_o    = 1'b1;
        end
        'd9: begin
            tft_screen_init_data_o  = SCREEN_WIDTH[15:8];
            tft_screen_init_dc_o    = 1'b1;
        end
        'd10: begin
            tft_screen_init_data_o  = SCREEN_WIDTH[7:0] - 1'b1;
            tft_screen_init_dc_o    = 1'b1;
        end

        'd11: begin
            tft_screen_init_data_o  = 8'h2B;
            tft_screen_init_dc_o    = 1'b0;
        end

        'd12: begin
            tft_screen_init_data_o  = 8'h00;
            tft_screen_init_dc_o    = 1'b1;
        end
        'd13: begin
            tft_screen_init_data_o  = 8'h00;
            tft_screen_init_dc_o    = 1'b1;
        end
        'd14: begin
            tft_screen_init_data_o  = SCREEN_HEIGHT[15:8];
            tft_screen_init_dc_o    = 1'b1;
        end
        'd15: begin
            tft_screen_init_data_o  = SCREEN_HEIGHT[7:0] - 1'b1;
            tft_screen_init_dc_o    = 1'b1;
        end
        'd16: begin
            tft_screen_init_data_o  = 8'h21;
            tft_screen_init_dc_o    = 1'b0;
        end
        'd17: begin
            tft_screen_init_data_o  = 8'h13;
            tft_screen_init_dc_o    = 1'b0;
        end
        'd18: begin
            tft_screen_init_data_o  = 8'h29;
            tft_screen_init_dc_o    = 1'b0;
        end
        default: begin
            tft_screen_init_data_o  = 8'h01;
            tft_screen_init_dc_o    = 1'b0;
        end
    endcase
end

endmodule
