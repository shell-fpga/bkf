module bcd2seg_sel(
    // input
    input               sys_clk,
    input               sys_rst_n,
    input       [23:0]  BCD_data,
    // output
    output reg  [7:0]   seg,
    output reg  [5:0]   sel
);
//------------signals--------------
    // 计数器，用于产生约1khz扫描信号，达到动态显示效果
    reg [15:0] cnt;
    // 被选中的BCD码
    reg [3:0]  BCD_out;
//------------function-------------
    // 计数器
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if(!sys_rst_n)
            cnt <= 0;
        else if(cnt == 16'b1100_0011_0101_0001)
            cnt <= 16'd0;
            else cnt <= cnt + 16'd1;
    end

    // 循环移位寄存器，生成sel
    always @(posedge sys_clk, negedge sys_rst_n) begin
        if(!sys_rst_n)
            sel <= 6'b111110;
        else if(cnt == 16'b1100_0011_0101_0001)//1KHz，0.001s
            sel <= {sel[4:0], sel[5]};//每经过0.001s,共阴极数码管位选发生变化
                else sel <= sel;
    end

    // 根据sel选择一个BCD码
    always @(*) begin
        case(sel)
            6'b111110: BCD_out = BCD_data[3:0];//选择显示BCD_data的最低位数字
            6'b111101: BCD_out = BCD_data[7:4];
            6'b111011: BCD_out = BCD_data[11:8];
            6'b110111: BCD_out = BCD_data[15:12];
            6'b101111: BCD_out = BCD_data[19:16];
            6'b011111: BCD_out = BCD_data[23:20];//选择显示BCD_data的最高位数字
              default: BCD_out = 4'h5;// 默认0
        endcase
    end

    // 根据BCD_out进行数码管译码
    always @(*) begin
        case(BCD_out)
            4'h0   : seg = 8'h03;
            4'h1   : seg = 8'h9f;
            4'h2   : seg = 8'h25;
            4'h3   : seg = 8'h0d;
            4'h4   : seg = 8'h99;
            4'h5   : seg = 8'h49;
            4'h6   : seg = 8'h41;
            4'h7   : seg = 8'h1f;
            4'h8   : seg = 8'h01;
            4'h9   : seg = 8'h09;
            default: seg = 8'h03;// 默认0
        endcase
    end
endmodule
