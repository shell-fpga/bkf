`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/12 11:25:22
// Design Name: 
// Module Name: NCO_Gen_v2
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
	/*********************************NCO_Gen bk_base:700*********************************************/
     // ascription: shell
	 // type: IP
	 // function :  Nco gen max support 20 chanels IQdata.
	 // update: 2025.3.11
	 // 0        bit7-0          DESR                       
	 // 1        bit7-0          IF_DDS_scale           	DDS_scale change to left shift to save resources
	 // 2        bit20-0         DDS_CH_enable              0-20 bit contrl 0-9 channel dds , if bit set to 0  DDS out is  0 , else DDS out depend on IF_DDS_D
	 // 3        bit15-0         init_phase                 IQ singal init phase  20 channels (init must cfg 20 times) init cfg 20 times
 	 // 4        bit31-0         IF_DDS_D           		Config  D (20 * 10 ) (cfg must cfg 200 times) init cfg 400 times
 	 // 5        bit   0         D_req_done           		clean req singal 
	 //          bit31-0         bk_status(0)           	D_req
	 
	 
module Nco_Gen #(
    parameter BKP_BASE_INDEX = 700,
    parameter NCO_nums = 20,
    parameter timer_delay = 800000
)(
	input wire clk,
	input wire rst_n,
	
    input  wire                   bkt_ready_i,
    input  wire            [31:0] bkt_index_i,
    input  wire            [31:0] bkt_data_i, 
	
	output wire [31:0] NCO_IQ_o [NCO_nums-1:0],
	input wire Ref_PPS,
	output wire D_Req
    );
	

/*********************     General Part   Start  ***************************/

reg bkt_ready_d1,bkt_ready_d2,bkt_ready_d3;
	always @(posedge clk)
	if(!rst_n)
    begin
        bkt_ready_d1 <= 1'b0;
        bkt_ready_d2 <= 1'b0;
        bkt_ready_d3 <= 1'b0;
    end
 	else
    begin
        bkt_ready_d1 <= bkt_ready_i;
        bkt_ready_d2 <= bkt_ready_d1;
        bkt_ready_d3 <= bkt_ready_d2;
    end 

	wire bk_ready_pedge;
	assign bk_ready_pedge = bkt_ready_d2 & ~bkt_ready_d3;

	reg [31:0] bk_index_d1,bk_index_d2,bk_index_d3;
	always @(posedge clk)
	if(!rst_n)
	   begin
	          bk_index_d1 <= 'd0;
	          bk_index_d2 <= 'd0;
	          bk_index_d3 <= 'd0;
	   end 
	else
	   begin
	          bk_index_d1 <= bkt_index_i;
	          bk_index_d2 <= bk_index_d1;
	          bk_index_d3 <= bk_index_d2;
	   end 

	reg [31:0] bk_data_d1,bk_data_d2,bk_data_d3;
	always @(posedge clk)
	if(!rst_n)
	   begin
	          bk_data_d1 <= 'd0;
	          bk_data_d2 <= 'd0;
	          bk_data_d3 <= 'd0;
	   end 
	else
	   begin
	          bk_data_d1 <= bkt_data_i;
	          bk_data_d2 <= bk_data_d1;
	          bk_data_d3 <= bk_data_d2;
	   end 


	wire [31:0] bk_index;
	assign bk_index = bk_index_d3;
	wire [31:0] bk_data;
	assign bk_data = bk_data_d3;

/********* gen code end*********/
reg DESR;
always @(posedge clk)
if(!rst_n)
	DESR <= 1'b0;
else if(bk_ready_pedge && bk_index == BKP_BASE_INDEX)
	DESR <= bk_data[0];
else
	DESR <= DESR;
	
reg [7:0] DDS_scale;   //  dds vpp is  +-32768/scale
always @(posedge clk)
if(!rst_n)
	DDS_scale <= 1'b0;
else if(bk_ready_pedge && bk_index == BKP_BASE_INDEX+1)
	DDS_scale <= bk_data[7:0];
else
	DDS_scale <= DDS_scale;	
	
reg [NCO_nums-1:0] DDS_CH_enable;   //  
always @(posedge clk)
if(!rst_n)
	DDS_CH_enable <= 1'b0;
else if(bk_ready_pedge && bk_index == BKP_BASE_INDEX+2)
	DDS_CH_enable <= bk_data[NCO_nums-1:0];
else
	DDS_CH_enable <= DDS_CH_enable;		
    
reg [7:0] init_phase_index;
always @(posedge clk)
if(!rst_n)
    init_phase_index <= 'd0;
else if(DESR == 'b0)
    init_phase_index <= 'd0;
else if(bk_ready_pedge  && bk_index == BKP_BASE_INDEX+3)
    begin
        if(init_phase_index == 'd20)
            init_phase_index <= 'd1;
        else
            init_phase_index <= init_phase_index + 1'd1;
    end 
else
    init_phase_index <= init_phase_index;

reg [15:0] init_phase [NCO_nums-1:0];
genvar i;
generate
for(i=0;i < NCO_nums; i= i + 1)
	begin:loop0
		always @(posedge clk)
		if(!rst_n)
			init_phase[i] <= 'd0;
		else if(DESR == 1'b0)
		    init_phase[i] <= 'd0;
		else if((i == init_phase_index-1) && bk_ready_pedge  && bk_index == BKP_BASE_INDEX+3)
			init_phase[i] <= bk_data[15:0];
		else
			init_phase[i] <= init_phase[i];
	end
endgenerate


reg [15:0] D_addr_p;
always @(posedge clk)
if(!rst_n)
    D_addr_p <= 'd0;
else if(bk_index == BKP_BASE_INDEX+4)
    begin
        if(bk_ready_pedge)
            D_addr_p <= D_addr_p + 1'd1; 
        else
            D_addr_p <= D_addr_p;
    end 
else 
    D_addr_p <= 0;
reg  req_done;  
always @(posedge clk)
if(!rst_n)
	req_done <= 1'b0;
else if(bk_ready_pedge && bk_index == BKP_BASE_INDEX+5)
	req_done <= bk_data[0];
else
	req_done <= req_done;	
/*************end generate part**************************/

reg BkpCfg_Ready_pedge_z1;
always @(posedge clk)
if(!rst_n)
    BkpCfg_Ready_pedge_z1 <= 1'b0;
else
    BkpCfg_Ready_pedge_z1 <= bk_ready_pedge;
    
reg BkpCfg_Ready_pedge_z2;
always @(posedge clk)
if(!rst_n)
    BkpCfg_Ready_pedge_z2 <= 1'b0;
else
    BkpCfg_Ready_pedge_z2 <= BkpCfg_Ready_pedge_z1;    


reg [15:0] wr_addr;
always @(posedge clk)
if(!rst_n)
    wr_addr <= 'd0;
else if(DESR==1'b0 || addr_sel == 1'b0)
    wr_addr <= D_addr_p - 1'd1;
else 
    wr_addr <= D_addr_p + 399;
    


reg ref_pps_d1;
always @(posedge clk)
if(!rst_n)
        ref_pps_d1 <= 1'b0;
else
        ref_pps_d1 <= Ref_PPS; 
    
wire  ref_pps_pedge;
assign   ref_pps_pedge = Ref_PPS & ~ref_pps_d1;

reg [2:0] pre_cnt;
always @(posedge clk)
if(!rst_n)
    pre_cnt <= 1'b0;
else if(DESR == 1'b0)
    pre_cnt <= 1'b0;
else if(ref_pps_pedge)
   begin
    if(pre_cnt == 'd2)
        pre_cnt <= pre_cnt;
    else
        pre_cnt <= pre_cnt + 1'd1;
   end 
else
    pre_cnt <= pre_cnt;


reg dds_enable;
always @(posedge clk)
if(!rst_n)
    dds_enable <= 1'b0;
else if(DESR == 1'b0)
    dds_enable <= 1'b0;
else if(ref_pps_pedge && pre_cnt == 'd2)
    dds_enable <= 1'b1;
else
    dds_enable <= dds_enable;

reg dds_enable_d1;
always @(posedge clk)
if(!rst_n)
    dds_enable_d1 <= 'd0;
else
    dds_enable_d1 <= dds_enable;
 

reg [31:0] timer_pluse_cnt;
always @(posedge clk)
if(!rst_n)
    timer_pluse_cnt <= 1'b0;
else if(dds_enable == 1'b0)
     timer_pluse_cnt <= timer_delay - 1'd1;
else if(timer_pluse_cnt == timer_delay - 1'd1)
    timer_pluse_cnt <= 1'b0;
else
    timer_pluse_cnt <= timer_pluse_cnt + 1'd1;
    
wire update_pluse1;
assign update_pluse1 = ((dds_enable == 1'b1) && (timer_pluse_cnt == timer_delay - 'd2)) ? 1'b1 : 1'b0;

wire pre_data_update;
assign  pre_data_update = dds_enable & ~ dds_enable_d1;

wire update_pluse;
assign update_pluse = pre_data_update | update_pluse1;

wire timer_pluse1;
assign timer_pluse1 = ((dds_enable == 1'b1) && (timer_pluse_cnt == timer_delay - 500)) ? 1'b1 : 1'b0;


reg [7:0] update_pluse_cnt;
always @(posedge clk)
if(!rst_n)
    update_pluse_cnt <= 'd0;
else if(DESR == 1'b0)
    update_pluse_cnt <= 'd0;
else if(update_pluse)
    begin
        if(update_pluse_cnt == 'd10)
            update_pluse_cnt <= 'd1;
        else
            update_pluse_cnt <= update_pluse_cnt + 1'd1;
    end 
else
    update_pluse_cnt <= update_pluse_cnt;


reg [7:0] timer_pluse2_cnt;
always @(posedge clk)
if(!rst_n)
    timer_pluse2_cnt <= 1'b0;
else if(DESR== 1'b0)
    timer_pluse2_cnt <= 1'b0;
else if(pre_cnt == 1)
    begin
        if(timer_pluse2_cnt == 200)
         timer_pluse2_cnt <= timer_pluse2_cnt;
        else
         timer_pluse2_cnt <= timer_pluse2_cnt + 1'd1;   
    end 
else
    timer_pluse2_cnt <= 'd0;
     
    
wire timer_pluse2;
assign timer_pluse2 = (timer_pluse2_cnt==100) ?  1'b1 : 1'b0;


wire timer_pluse;
assign timer_pluse = timer_pluse1 | timer_pluse2;

reg [7:0] rd_cnt;
always @(posedge clk)
if(!rst_n)
    rd_cnt <= 'd0;
else if(rd_gate)
    rd_cnt <= rd_cnt + 1'd1;
else
    rd_cnt <= 'd0; 

reg rd_gate;
always @(posedge clk)
if(!rst_n)
    rd_gate <= 1'b0;
else if(timer_pluse)
    rd_gate <= 1'b1;
else if(rd_cnt == 'd19)
    rd_gate <= 1'b0;
 

wire rd_en;
assign rd_en = rd_gate | rd_en_d1 | rd_en_d2;
    
reg rd_en_d1,rd_en_d2;
always @(posedge clk)
if(!rst_n)
    begin
        rd_en_d1 <= 1'b0;
        rd_en_d2 <= 1'b0;
    end 
else
    begin
        rd_en_d1 <= rd_gate;
        rd_en_d2 <= rd_en_d1;
    end 
 
    
reg [15:0] rd_addr_p1;
always @(posedge clk)
if(!rst_n)
    rd_addr_p1 <= 'b0;
else if (DESR == 1'b0)
    rd_addr_p1 <= 'd0;
else if(pre_cnt == 'd0 && ref_pps_pedge)
    rd_addr_p1 <= 'd0;
else if(rd_gate)
    begin
        if(rd_addr_p1 == 'd19)
            rd_addr_p1 <= 'd0;
        else
            rd_addr_p1 <= rd_addr_p1 + 1'd1;
    end 
else
    rd_addr_p1 <= rd_addr_p1;
      

 
reg [15:0] rd_addr_p;
always @(posedge clk)
if(!rst_n)
    rd_addr_p <= 'b0;
else if (DESR == 1'b0)
    rd_addr_p <= 'd0;
else if(pre_cnt == 'd0 && ref_pps_pedge)
    rd_addr_p <= 'd0;
else if(rd_gate)
    begin
        if(rd_addr_p == 'd399)
            rd_addr_p <= 'd0;
        else
            rd_addr_p <= rd_addr_p + 1'd1;
    end 
else
    rd_addr_p <= rd_addr_p;
      

 

wire [15:0] rd_addr; 
assign rd_addr = rd_addr_p; 

reg [15:0] rd_addr_d1,rd_addr_d2;
always @(posedge clk)
if(!rst_n)
    begin
        rd_addr_d1 <= 1'b0;
        rd_addr_d2 <= 1'b0;
    end
else
    begin
        rd_addr_d1 <= rd_addr_p1;
        rd_addr_d2 <= rd_addr_d1;
    end 

// sel = 1   wraddr 400-799
// sel = 0   wraddr 0-399
wire addr_sel;
assign addr_sel = (DESR == 1'b1) ? (rd_addr <=199) ?  1'b1 : 1'b0  : 1'b1;


reg addr_sel_d1;
always @(posedge clk)
if(!rst_n)
    addr_sel_d1 <= 1'b0;
else
    addr_sel_d1 <= addr_sel;
    
reg req;
always @(posedge clk)
if(!rst_n)
    req <= 1'b0;
else if(req_done || DESR == 1'b0)
    req <= 1'b0;
else if(update_pluse_cnt=='d10 && update_pluse)
    req <= 1'b1;
else
    req <= req; 
    

wire wr_en;
assign wr_en = (BkpCfg_Ready_pedge_z2  && bk_index == BKP_BASE_INDEX+4) ? 1'b1 : 1'b0;
wire [63:0] rd_data;
blk_mem_gen_1 u1(
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wr_en),      // input wire [0 : 0] wea
  .addra(wr_addr),  // input wire [9 : 0] addra
  .dina(bk_data),    // input wire [31 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(rd_en),      // input wire enb
  .addrb(rd_addr),  // input wire [8 : 0] addrb
  .doutb({rd_data[31:0],rd_data[63:32]})  // output wire [63 : 0] doutb
);




reg [63:0] D2 [NCO_nums-1 :0];
reg [63:0] D [NCO_nums-1 :0];
genvar k;
generate
for(k=0;k < NCO_nums; k= k + 1)
	begin:loop1
		always @(posedge clk)
		if(!rst_n)
		    D2[k] <= 'd0;
		else if(rd_en_d2)
	       begin
	            if(k == rd_addr_d2)
	                D2[k] <= rd_data;
	            else
	                D2[k] <= D2[k];
	       end 
	    
		
			
        always @(posedge clk)
		if(!rst_n)	
		  D[k] <= 1'b0;
		else if(update_pluse)
		  D[k]	<= 	D2[k];
	end
endgenerate

    
genvar j;
generate
for(j=0;j < NCO_nums; j= j + 1)
	begin:loop2
		 Nco_Single_Gen u1(
							.clk(clk), 
							.rst_n(rst_n),
							.init_phase(init_phase[j]),
							.DDS_CH_enable(DDS_CH_enable[j]),
							.ref_pps_pedge(ref_pps_pedge),
							.DDS_scale(DDS_scale),
							.DDS_enable(dds_enable),
							.D_i(D[j]),
							.DDS_IQ_o(NCO_IQ_o[j])
						);
	end 
endgenerate 
	
assign D_Req  =  req ;



endmodule
