//蜂鸣器
module beep(
  input         clk,
  input         rst_n,
  output    reg    beep_out
);
parameter CLK_CLY=100_000_000;//时钟频率
localparam  H1  =CLK_CLY/523,
            H1_L=CLK_CLY/262,
            H1_H=CLK_CLY/1047,
            H2  =CLK_CLY/587,
            H3  =CLK_CLY/659,
            H4  =CLK_CLY/698,
            H5  =CLK_CLY/784,
            H6  =CLK_CLY/880,
            H7  =CLK_CLY/988;
 
 
parameter TIME_500MS=50_000_000;//0.5秒
 
reg [17:0] cnt0;// 每个音符频率计数器
wire       add_cnt0;
wire       end_cnt0;
 
reg [9:0] cnt1;// 0.5秒内音符周期重复个数
wire       add_cnt1;
wire       end_cnt1;
 
reg  [5:0] cnt2;// 计数音符播放顺序
wire       add_cnt2;
wire       end_cnt2;
reg     [15:0] cnt_max;
 
reg   [17:0]  display;//音符计数器的最大值
//cnt0计数
always @(posedge clk or negedge rst_n)begin 
  if(!rst_n)
    cnt0<=0;
  else if(add_cnt0)begin 
    if(end_cnt0)
      cnt0<=0;
    else
      cnt0<=cnt0+1'b1;
  end
end 
assign add_cnt0=1'b1;
assign end_cnt0=add_cnt0 &&(cnt0==display-1);
 
//cnt1计数
always @(posedge clk or negedge rst_n)begin 
  if(!rst_n)
    cnt1<=0;
  else if(add_cnt1)begin 
    if(end_cnt1)
      cnt1<=0;
    else
      cnt1<=cnt1+1'b1;
  end
end 
assign add_cnt1=end_cnt0;
assign end_cnt1=add_cnt1 &&(cnt1==(TIME_500MS/display-1));
 
//cnt2计数
always @(posedge clk or negedge rst_n)begin 
  if(!rst_n)
    cnt2<=0;
  else if(add_cnt2)begin 
    if(end_cnt2)
      cnt2<=0;
    else
      cnt2<=cnt2+1'b1;
  end
end 
assign add_cnt2=end_cnt1;
assign end_cnt2=add_cnt2 &&(cnt2==50-1);
 
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    display <=H1;
  else begin
    case (cnt2)
       0:display <=H1_L;
       1:display <=H1;
       2:display <=H1;
       3:display <=H3;
 
       4:display <=H5;
       5:display <=H5;
       6:display <=H5;
       7:display <=H5;
       
       8:display <=H6;
       9:display <=H6;
      10:display <=H6;
      11:display <=H1_H;
 
      12:display <=H5;
      13:display <=H5;
      14:display <=H5;
      15:display <=H5;
 
      16:display <=H4;
      17:display <=H4;
      18:display <=H4;
      19:display <=H6;
 
      20:display <=H3;
      21:display <=H3;
      22:display <=H3;
      23:display <=H3;
 
      24:display <=H2;
      25:display <=H2;
      26:display <=H2;
      27:display <=H2;
 
      28:display <=H5;
      29:display <=H5;
      30:display <=H5;
      31:display <=H5;
 
      32:display <=H1;
      33:display <=H1_L;
      34:display <=H1;
      35:display <=H3;
 
      36:display <=H5;
      37:display <=H5;
      38:display <=H5;
      39:display <=H5;
 
      40:display <=H6;
      41:display <=H6;
      42:display <=H6;
      43:display <=H1_H;
 
      44:display <=H5;
      45:display <=H5;
      46:display <=H5;
      47:display <=H5;
 
      40:display <=H4;
      41:display <=H4;
      42:display <=H4;
      43:display <=H6;
 
      44:display <=H3;
      45:display <=H3;
      46:display <=H3;
      47:display <=H3;
      40:display <=H3;
      41:display <=H3;
 
      42:display <=H2;
      43:display <=H2;
      44:display <=H2;
      45:display <=H3;
 
      46:display <=H1;
      47:display <=H1;
      48:display <=H1;
      49:display <=H1;
      default: display <=H1;
    endcase
  end
end
 
//pwm输出
//蜂鸣器pwm
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        beep_out <= 1'b1;
    end
    else if(cnt0 == (display>>3))begin//设置占空比
        beep_out <= 1'b1;
    end
    else if(cnt0==0)begin
        beep_out<= 1'b0;
    end
end
endmodule 