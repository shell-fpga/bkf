module hc595(
    input sys_clk,
    input sys_rst_n,
    // input
    input [7:0] seg,
    //input [5:0] sel,
    // output
    output  ds,
    output  shcp,
    output  stcp
   // output  oe
);
//------------signals--------------
// 分频计数器
reg [4:0] cnt;
// 并行数据
wire [7:0] out_data = seg;
//------------function-------------
// 分频计数器
always @(posedge sys_clk, negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 0;
    else
        cnt <= cnt + 5'd1;
end
// shcp选择4分频，即12.5M
assign shcp = cnt[1];
// stcp选择32分频，即shcp的8分频，保证8个shcp上升沿对应1个stcp上升沿
assign stcp = cnt[4:1] == 4'b0000;
// 输出串行ds，保证ds在shcp的下降沿变化,用波形图来理解下面这行代码
assign ds = out_data[cnt[4:2]];
endmodule
