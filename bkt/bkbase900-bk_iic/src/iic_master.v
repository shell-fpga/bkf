`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/07 21:20:50
// Design Name: 
// Module Name: iic_master
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


module iic_master
	(
		input wire clk,
		input wire rst_n,
	
        input  wire DESR,
		output wire write_noack,
		output wire read_noack,
		output wire continue_req,
		input  wire [1:0] continue_done,
		input  wire noack_clear,
		input  wire [31:0] iic_T_1it,
		input  wire rw_mode,
		input  wire iic_start,
		
		input   wire [7:0] bkp_data_i,
		input   wire bkp_ready_i,
		output  wire bkp_busy_o,
		output  wire [7:0] bkp_data_o,
		output  wire bkp_ready_o,
		
		output wire SCL,
		inout  wire SDA
	);
	
	
	localparam iic_state0 = 5'b00001;  //idle
	localparam iic_state1 = 5'b00010;  //start time
	localparam iic_state2 = 5'b00100;  //iic workong time 
	localparam iic_state3 = 5'b01000;  //end time 
	localparam iic_state4 = 5'b10000;  //keep time(only continue_mode)
	
	
	wire [31:0] iic_tcyc_quarter;
	assign iic_tcyc_quarter = iic_T_1it>>2 ;
	
	
	localparam tcyc_start_nums = 3;
	localparam tcyc_working_nums = 36;
	localparam tcyc_end_nums = 3;



	reg [5:0] iic_state;
	reg keep_gate;
	reg working_gate;
	reg start_gate;
	reg end_gate;
	always @(posedge clk)
	if(!rst_n)
		begin
			iic_state <= iic_state0;
			working_gate <= 1'b0;
			start_gate <= 1'b0;
			end_gate <= 1'b0;
			keep_gate<=1'b0;
		end 
	else if(DESR== 1'b0)
		begin
			iic_state <= iic_state0;
			working_gate <= 1'b0;
			start_gate <= 1'b0;
			end_gate <= 1'b0;
			keep_gate<=1'b0;
		end 
	else
		case(iic_state)
			iic_state0:
				begin
				    if(iic_start) 
						begin
							start_gate   <= 1'b1;
							working_gate <= 1'b0;
							end_gate     <= 1'b0;
							keep_gate    <=1'b0;
							iic_state    <= iic_state1;
						end 
					else
						begin
							iic_state    <= iic_state0;
							working_gate <= 1'b0;
							start_gate   <= 1'b0;
							end_gate     <= 1'b0;
							keep_gate    <=1'b0;
						end 
				end 
			iic_state1:
				begin
					if(cnt_start == tcyc_start_nums*iic_tcyc_quarter-1)
						begin
							iic_state    <= iic_state2;
							working_gate <= 1'b1;
							start_gate   <= 1'b0;
							end_gate     <= 1'b0;
							keep_gate    <= 1'b0;
						end 
					else
						begin
							iic_state    <= iic_state;
							working_gate <= working_gate;
							start_gate   <= start_gate;
							end_gate     <= end_gate;
							keep_gate    <= keep_gate;
						end
				end 
			iic_state2:
					if((cnt1 == tcyc_working_nums -1'd1) && (cnt0 == iic_tcyc_quarter-1'd1))
						begin
							if(continue_last_flag)
							begin
								iic_state    <= iic_state3;
								working_gate <= 1'b0;
								start_gate   <= 1'b0;
								end_gate     <= 1'b1;
								keep_gate    <= 1'b0;
							end 
							else if(continue_req == 1'b1)
							begin
								iic_state    <= iic_state4;
								working_gate <= 1'b0;
								start_gate   <= 1'b0;
								end_gate     <= 1'b0;
								keep_gate    <= 1'b1;
							end 
						end 
					else
						begin
							iic_state    <= iic_state;
							working_gate <= working_gate;
							start_gate   <= start_gate;
							end_gate     <= end_gate;
							keep_gate    <= keep_gate;
						end 
			iic_state3:
				begin
					if(cnt_end == tcyc_end_nums * iic_tcyc_quarter - 1)
						begin
							iic_state    <= iic_state0;
							working_gate <= 1'b0;
							start_gate   <= 1'b0;
							end_gate     <= 1'b0;
							keep_gate    <= 1'b0;
						end 
					else
						begin
							iic_state    <= iic_state;
							working_gate <= working_gate;
							start_gate   <= start_gate;
							end_gate     <= end_gate;
							keep_gate    <= keep_gate;
						end 
				end 
			iic_state4:
				begin
					if(continue_req == 1'b0)
						begin
							iic_state    <= iic_state2;
							working_gate <= 1'b1;
							start_gate   <= 1'b0;
							end_gate     <= 1'b0;
							keep_gate    <= 1'b0;
						end 
					else
						begin
							iic_state    <= iic_state;
							working_gate <= working_gate;
							start_gate   <= start_gate;
							end_gate     <= end_gate;
							keep_gate    <= keep_gate;
						end 
				end 
			default:
				begin
					iic_state    <= iic_state0;
					working_gate <= 1'b0;
					start_gate   <= 1'b0;
					end_gate     <= 1'b0;
					keep_gate    <= 1'b0;
				end 
		endcase
	
	reg [31:0] cnt0;
	always @(posedge clk)
	if(!rst_n)
		cnt0 <= 32'd0;
	else if(working_gate)
		begin
			if(cnt0 == iic_tcyc_quarter-1'd1)
				cnt0 <= 32'd0;
			else
				cnt0 <= cnt0 + 1'd1;
		end 
	else
		cnt0 <= 32'd0;
	
	reg [15:0] cnt1;
	always @(posedge clk)
	if(!rst_n)
		cnt1 <= 16'd0;
    else if(working_gate == 1'b0) 
        cnt1 <= 0;
	else if(cnt0 == iic_tcyc_quarter-1'd1)
		begin
			if(cnt1 == tcyc_working_nums -1'd1)
				cnt1 <= 16'd0;
			else
				cnt1 <= cnt1 + 1'd1;
		end 
	else
		cnt1 <= cnt1;

	wire [15:0] cnt1_half;
	assign cnt1_half = (cnt1+1)>>1; 
	
	reg [31:0] cnt_start;
	always @(posedge clk)
	if(!rst_n)
		cnt_start <= 'd0;
	else if(start_gate)
		cnt_start <= cnt_start + 1'd1;
	else
		cnt_start <= 'd0;
		
	reg [31:0] cnt_end;
	always @(posedge clk)
	if(!rst_n)
		cnt_end <= 'd0;
	else if(end_gate)
		cnt_end <= cnt_end + 1'd1;
	else
		cnt_end <= 'd0;
		
reg continue_end_z1,continue_end_z2;
always @(posedge clk)
if(!rst_n)
	begin
		continue_end_z1 <= 1'b0;
		continue_end_z2 <= 1'b0;
	end 
else
	begin
		continue_end_z1 <= continue_done[1];
		continue_end_z2 <= continue_end_z1;
	end 

wire continue_end_pedge;
assign continue_end_pedge = continue_end_z1 & !continue_end_z2;

reg req_done_z1,req_done_z2;
always @(posedge clk)
if(!rst_n)
	begin
		req_done_z1 <= 1'b0;
		req_done_z2 <= 1'b0;
	end 
else
	begin
		req_done_z1 <= continue_done[0];
		req_done_z2 <= req_done_z1;
	end 

wire req_done_pedge;
assign req_done_pedge = req_done_z1 & !req_done_z2;

reg continue_last_flag;
always @(posedge clk)
if(!rst_n)
	continue_last_flag <= 1'b0;
else if(continue_end_pedge)
	continue_last_flag <= 1'b1;
else if(cnt_end == tcyc_end_nums * iic_tcyc_quarter - 1)
	continue_last_flag <= 1'b0;
else
	continue_last_flag <= continue_last_flag;
	
reg cur_rw_mode;
always @(posedge clk)
if(!rst_n)
	cur_rw_mode <= 1'b0;
else if(DESR == 1'b0)
	cur_rw_mode <=1'b0;
else if((cnt1 == 0) && (cnt0 == 1'd1))
	cur_rw_mode <= rw_mode;
else
	cur_rw_mode <= cur_rw_mode;
	
reg continue_req_p;
always @(posedge clk)
if(!rst_n)
	continue_req_p <= 1'b0;
else if(DESR == 1'b0)
	continue_req_p <=1'b0;
else if((cnt1 == 0) && (cnt0 == iic_tcyc_quarter-1'd1))
	continue_req_p <= 1'b1;
else if(req_done_pedge)
	continue_req_p <= 1'b0;
else
	continue_req_p <= continue_req_p;
	/*************************SCL part*****************************/
	wire SCL_start;
	assign SCL_start = (start_gate) ? (cnt_start < (tcyc_start_nums-1)*iic_tcyc_quarter+2) ? 1'b1 : 1'b0 : 1'b0;
	wire SCL_end;
	assign SCL_end   = (end_gate) ? (cnt_end > (tcyc_end_nums-2)*iic_tcyc_quarter-1) ? 1'b1 : 1'b0 : 1'b0;
	
	reg SCL_working;
	always @(posedge clk)
	if(!rst_n)
		SCL_working <= 1'b0;
	else if(working_gate == 1'b1 && cnt1<tcyc_working_nums)
		SCL_working <= cnt1_half[0];
	else
		SCL_working <= 1'b0;
	
	
	/**********************SDA  part***************************/
	wire SDA_start;
	assign SDA_start = (start_gate) ? (cnt_start < (tcyc_start_nums-2)*iic_tcyc_quarter-1) ? 1'b1 : 1'b0 : 1'b0;
	
	wire SDA_end;
	assign SDA_end =  (end_gate) ? (cnt_end   > (tcyc_end_nums-1)*iic_tcyc_quarter-1) ? 1'b1 : 1'b0 : 1'b0;
		/**********************SDA write part***************************/
	reg send_sel;
	always @(posedge clk)
	if(!rst_n)
		send_sel <= 1'b0;
	else if(bkp_ready_i)
		send_sel <= !send_sel;
		
	reg bkp_ready_z1,bkp_ready_z2;
	always @(posedge clk)
	if(!rst_n)
		begin
			bkp_ready_z1 <= 'd0;
			bkp_ready_z2 <= 'd0;
		end
	else
		begin
			bkp_ready_z1 <= bkp_ready_i;
			bkp_ready_z2 <= bkp_ready_z1;
		end 
		
	genvar i;
	reg [7:0] sendbuf [1:0];
	generate 
	for(i=0;i<2;i=i+1)
	begin: loop1
		always @(posedge clk)
		if(!rst_n)
			sendbuf[i] <= 'd0;
		else if(bkp_ready_z2 && i==send_sel)
			sendbuf[i] <= bkp_data_i;
		else 
			sendbuf[i] <= sendbuf[i];
	end 
	endgenerate 

	
reg [6:0] addr_cnt;
always @(posedge clk)
if(!rst_n)
	addr_cnt <= 1'b0;
else if(working_gate == 0)
    addr_cnt <= 1'b0;
else if(cnt1<tcyc_working_nums - 4)
    addr_cnt <=  (cnt1)>>2 ;
else
    addr_cnt <= 'd0;


reg [7:0] send_data;
always @(posedge clk)
if(!rst_n)
	send_data <= 'd0;
else if(working_gate && cnt1==0 && cnt0 == 'd1)
	begin
		if(send_sel == 1'b0)
			send_data = sendbuf[0];
		else
			send_data = sendbuf[1];
	end 
	
	
reg SDA_w;
always @(posedge clk)
if(!rst_n)
	SDA_w <= 1'b0;
else if(cur_rw_mode == 1'b0 && working_gate == 1'b1)
    begin
        if(cnt1<tcyc_working_nums-4)
            SDA_w <= send_data[7-addr_cnt];
        else if(cnt1>=tcyc_working_nums-4 && cnt1<=tcyc_working_nums-2)
            SDA_w <= 1'b1;
    end 
else
	SDA_w <= 1'b0;

	

reg write_noack_p;
always @(posedge clk)
if(!rst_n)
	write_noack_p <= 1'b0;
else if(DESR == 1'b0)
	write_noack_p <= 1'b0;
//	else if(rw_mode == 1'b0 && (cnt1 == tcyc_working_nums-2) && (cnt0 == iic_tcyc_quarter-1'd1))
else if(cur_rw_mode == 1'b0 && (cnt1 == tcyc_working_nums-3) && (cnt0 == iic_tcyc_quarter-1'd1) && SDA==1'b1)
	write_noack_p <= 1'b1;
else if(noack_clear == 1'b1)
	write_noack_p <= 1'b0;
else
	write_noack_p <= write_noack_p;
		
			
wire wr_ack_time;
assign 	wr_ack_time = (cnt1>tcyc_working_nums-5 && cnt1 <= tcyc_working_nums - 1);
			
		/**********************SDA read part***************************/	
reg [7:0] rec_data;
always @(posedge clk)
if(!rst_n) 
	rec_data <= 'd0;
else if(DESR == 1'b0)
    rec_data <= 'd0;
else if(working_gate == 1'b1 && (cnt1<tcyc_working_nums-4) && cur_rw_mode == 1'b1)
begin
		if((SCL_working==1) && (cnt1[0] == 1) && (cnt0 == iic_tcyc_quarter-1'd1 ))
			rec_data <= {rec_data[6:0],SDA};
		else
			rec_data <= rec_data;
	end 
else
	rec_data <= rec_data;
	

wire bkp_ready_r;
assign bkp_ready_r = (cnt1 == tcyc_working_nums -1'd1 && cnt0 == iic_tcyc_quarter-1 && cur_rw_mode == 1'b1);



reg read_noack_p;
always @(posedge clk)
if(!rst_n)
	read_noack_p <= 1'b0;
else if(DESR == 1'b0)
	read_noack_p <= 1'b0;
else if(cur_rw_mode == 1'b1 && (cnt1 == tcyc_working_nums-4) && (cnt0 == iic_tcyc_quarter-1'd1) && SDA==1'b1)
	read_noack_p <= 1'b1;
else if(noack_clear == 1'b1)
	read_noack_p <= 1'b0;
else
	read_noack_p <= read_noack_p;

wire rd_ack_time;
assign  rd_ack_time = (cnt1>tcyc_working_nums-5 && cnt1 <= tcyc_working_nums - 1 );

/*****************************continue_mode param*******************************/	



assign write_noack  = write_noack_p;
assign read_noack   = read_noack_p;
assign continue_req = continue_req_p;

assign bkp_data_o   = rec_data;
assign bkp_ready_o  = bkp_ready_r;

assign bkp_busy_o   =  (iic_state == iic_state0) ? 1'b0 : 1'b1;


wire  scl_p;
assign scl_p = (iic_state == iic_state0) ? 1'b1 : SCL_start | SCL_working | SCL_end ;


wire  sda_p;
assign sda_p = (iic_state == iic_state0) ? 1'b1 : SDA_start | SDA_w | SDA_end ;

wire rd_noack;
assign rd_noack = (rd_ack_time && continue_last_flag) ? 1'b1 : 1'b0;

       
assign SCL = scl_p;
assign SDA = (cur_rw_mode == 1'b0) ? 
						(wr_ack_time) ?  
							    1'bz : sda_p:
						(rd_ack_time || working_gate == 1'b0) ? 
								sda_p | rd_noack : 1'bz; 

	
	
ila_0 debug1 (
	.clk(clk), // input wire clk


	.probe0(SCL), // input wire [0:0]  probe0  
	.probe1(sda_p), // input wire [0:0]  probe1 
	.probe2(cnt0), // input wire [31:0]  probe2 
	.probe3(cnt1), // input wire [31:0]  probe3 
	.probe4(continue_done), // input wire [1:0]  probe4 
	.probe5({SDA,bkp_ready_r,cur_rw_mode,continue_req,continue_last_flag,iic_state}), // input wire [7:0]  probe5
	.probe6(write_noack),
	.probe7({rec_data,send_data}),
    .probe8({sendbuf[0],sendbuf[1]})
);
	
endmodule
