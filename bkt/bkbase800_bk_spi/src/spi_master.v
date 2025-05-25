`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/12 14:54:18
// Design Name: 
// Module Name: spi_master
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


module spi_master
	(
		input  wire clk,
		input  wire rst_n,
	
		input  wire DESR,
		input  wire rw_mode,
		input  wire CPOL,
		input  wire CPHA,
		input  wire [31:0] spi_T_1bit,
		input  wire spi_start,
		input  wire [1:0] continue_done,
		output wire continue_req,
		//BKP bus
		input  wire [7:0] bkp_data_i,  	              // the data you want to send
		input  wire bkp_ready_i, 		              // when this is high for at last 1 clk the data will sending 
		output wire bkp_busy_o,                        // when this signal is high level you must keep the bkp_data_i's value  si statiable
		output  wire [7:0] bkp_data_o,
		output  wire bkp_ready_o,
		// spi master bus
		output wire SCK_o,
		output wire SS_o,
		input  wire MISO,
		output wire MOSI
    );
//the loacl param 
localparam wr_size_inbits  = 8;

wire [31:0] spi_tcyc_quarter;
assign spi_tcyc_quarter =  spi_T_1bit >>2;

localparam tcyc_start_nums = 1;
localparam tcyc_working_nums = 32;
localparam tcyc_end_nums = 1;

//spi timing mode
localparam mode0 = 2'b00;
localparam mode1 = 2'b01;
localparam mode2 = 2'b10;
localparam mode3 = 2'b11;
//state machine
localparam spi_state0 = 5'b000001;  //idle
localparam spi_state1 = 5'b000010;  //start time
localparam spi_state2 = 5'b000100;  //iic workong time 
localparam spi_state3 = 5'b010000;  //end time 
localparam spi_state4 = 5'b100000;  //keep time(only continue_mode)
	


wire [1:0] spi_timing_mode;
assign spi_timing_mode = {CPOL,CPHA};


reg [5:0] spi_state;
reg keep_gate;
reg working_gate;
reg start_gate;
reg end_gate;
always @(posedge clk)
if(!rst_n)
	begin
		spi_state <= spi_state0;
		working_gate <= 1'b0;
		start_gate <= 1'b0;
		end_gate <= 1'b0;
		keep_gate<=1'b0;
	end 
else if(DESR== 1'b0)
	begin
		spi_state <= spi_state0;
		working_gate <= 1'b0;
		start_gate <= 1'b0;
		end_gate <= 1'b0;
		keep_gate<=1'b0;
	end 
else
	case(spi_state)
		spi_state0:
			begin
			    if(spi_start) 
					begin
						start_gate   <= 1'b1;
						working_gate <= 1'b0;
						end_gate     <= 1'b0;
						keep_gate    <=1'b0;
						spi_state    <= spi_state1;
					end 
				else
					begin
						spi_state    <= spi_state0;
						working_gate <= 1'b0;
						start_gate   <= 1'b0;
						end_gate     <= 1'b0;
						keep_gate    <=1'b0;
					end 
			end 
		spi_state1:
			begin
				if(cnt_start == tcyc_start_nums*spi_tcyc_quarter-1)
					begin
						spi_state    <= spi_state2;
						working_gate <= 1'b1;
						start_gate   <= 1'b0;
						end_gate     <= 1'b0;
						keep_gate    <= 1'b0;
					end 
				else
					begin
						spi_state    <= spi_state;
						working_gate <= working_gate;
						start_gate   <= start_gate;
						end_gate     <= end_gate;
						keep_gate    <= keep_gate;
					end
			end 
		spi_state2:
				if((cnt1 == tcyc_working_nums -1'd1) && (cnt0 == spi_tcyc_quarter-1'd1))
					begin
						if(continue_last_flag)
						begin
							spi_state    <= spi_state3;
							working_gate <= 1'b0;
							start_gate   <= 1'b0;
							end_gate     <= 1'b1;
							keep_gate    <= 1'b0;
						end 
						else if(continue_req == 1'b1)
						begin
							spi_state    <= spi_state4;
							working_gate <= 1'b0;
							start_gate   <= 1'b0;
							end_gate     <= 1'b0;
							keep_gate    <= 1'b1;
						end 
					end 
				else
					begin
						spi_state    <= spi_state;
						working_gate <= working_gate;
						start_gate   <= start_gate;
						end_gate     <= end_gate;
						keep_gate    <= keep_gate;
					end 
		spi_state3:
			begin
				if(cnt_end == tcyc_end_nums * spi_tcyc_quarter - 1)
					begin
						spi_state    <= spi_state0;
						working_gate <= 1'b0;
						start_gate   <= 1'b0;
						end_gate     <= 1'b0;
						keep_gate    <= 1'b0;
					end 
				else
					begin
						spi_state    <= spi_state;
						working_gate <= working_gate;
						start_gate   <= start_gate;
						end_gate     <= end_gate;
						keep_gate    <= keep_gate;
					end 
			end 
		spi_state4:
			begin
				if(continue_req == 1'b0)
					begin
						spi_state    <= spi_state2;
						working_gate <= 1'b1;
						start_gate   <= 1'b0;
						end_gate     <= 1'b0;
						keep_gate    <= 1'b0;
					end 
				else
					begin
						spi_state    <= spi_state;
						working_gate <= working_gate;
						start_gate   <= start_gate;
						end_gate     <= end_gate;
						keep_gate    <= keep_gate;
					end 
			end 
		default:
			begin
				spi_state    <= spi_state0;
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
		if(cnt0 == spi_tcyc_quarter-1'd1)
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
else if(cnt0 == spi_tcyc_quarter-1'd1)
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
else if(cnt_end == tcyc_end_nums * spi_tcyc_quarter - 1)
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
else if((cnt1 == 0) && (cnt0 == spi_tcyc_quarter-1'd1))
	continue_req_p <= 1'b1;
else if(req_done_pedge == 1'b1)
	continue_req_p <= 1'b0;
else
	continue_req_p <= continue_req_p;

/*************************SCL part*****************************/
reg sck_p1;
always @(posedge clk)
if(!rst_n)
	sck_p1 <= 1'b0;
else if(working_gate == 1'b1 && cnt1<tcyc_working_nums)
	sck_p1 <= cnt1_half[0];
else
	sck_p1 <= 1'b0;

reg sck_p2;
always @(posedge clk)
if(!rst_n)
	sck_p2 <= 1'b0;
else
	sck_p2 <= sck_p1;
	
wire 	sck_pedge,sck_nedge;
assign sck_pedge = sck_p1 & !sck_p2;
assign sck_nedge = !sck_p1 & sck_p2;
	
reg sck_p3;
always @(*)
begin
	case(spi_timing_mode)
		mode0,mode1:
			if(working_gate)
				sck_p3 = sck_p1;
			else
				sck_p3 = 1'b0;
		mode2:
			if(working_gate&&(cnt1>'d1))
				sck_p3 = sck_p1;
			else
				sck_p3 = 1'b1;
	   mode3:
			if(working_gate&&(cnt1<tcyc_working_nums-1))
				sck_p3 = sck_p1;
			else
				sck_p3 = 1'b1;
		default:
			if(working_gate)
				sck_p3 = sck_p1;
			else
				sck_p3 = 1'b0;
	endcase
end 
/**********************SS part***************************/
wire ss_p;
assign ss_p = (spi_state == spi_state0) ? 1'b1 : 1'b0;


/**********************MOSI part***************************/
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
else
	begin
		case(spi_timing_mode)
			mode0,mode3:
			if(cnt1 <tcyc_working_nums-1)
				addr_cnt <= (cnt1>=3) ? (cnt1+1)>>2 : 'd0;
			else
			    addr_cnt <=addr_cnt; 
			mode1,mode2:
			if(cnt1 <tcyc_working_nums-1)
				addr_cnt <= (cnt1>=1) ? (cnt1-1)>>2 : 'd0;
			else
			    addr_cnt <=addr_cnt;
			default:
				addr_cnt <= 8'd0;
		endcase
	end 
	

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
	

reg mosi_p;
always @(posedge clk)
if(!rst_n)
	mosi_p <= 1'd0;
else if(working_gate && cur_rw_mode == 1'b0)
	   mosi_p <= send_data[wr_size_inbits  - addr_cnt - 1];
else
	mosi_p <= 1'b0;



/**********************MISO part***************************/
reg [15:0] rec_buf;
always @(posedge clk)
if(!rst_n)
	rec_buf <= 1'b0;
else if(working_gate == 0)
    rec_buf <= 'd0;
else
	begin
		case(spi_timing_mode)
			mode0,mode3:
				if(sck_pedge)
					rec_buf <= {rec_buf[6:0],MISO};
				else
					rec_buf <= rec_buf;
			mode1,mode2:
				if(sck_nedge)
					rec_buf <= {rec_buf[6:0],MISO};
				else
					rec_buf <= rec_buf;
			default:
				rec_buf <= 8'd0;
		endcase
	end 

wire bkp_ready_r;
assign bkp_ready_r = (cnt1 == tcyc_working_nums -1'd1 && cnt0 == spi_tcyc_quarter-1 &&  cur_rw_mode == 1'b1);



//output 
assign SS_o = ss_p;
assign SCK_o= sck_p3;
assign MOSI = mosi_p;


assign bkp_busy_o = !ss_p;
assign bkp_data_o = rec_buf;			   // Read Data, when data is already this output the recivce vlaue and hold a litte time 
assign bkp_ready_o =   bkp_ready_r;

assign continue_req = continue_req_p;

//ila_1 debug2 (
//	.clk(clk), // input wire clk


//	.probe0({continue_done,working_gate, continue_last_flag,sendbuf[0],sendbuf[1],spi_state}), // input wire [31:0]  probe0  
//	.probe1(cnt0), // input wire [31:0]  probe1 
//	.probe2(cnt1), // input wire [31:0]  probe2 
//	.probe3(send_data), // input wire [31:0]  probe3 
//	.probe4(rec_buf), // input wire [31:0]  probe4 
//	.probe5(cur_rw_mode), // input wire [0:0]  probe5 
//	.probe6(continue_req), // input wire [0:0]  probe6 
//	.probe7(MISO), // input wire [0:0]  probe7 
//	.probe8(MOSI), // input wire [0:0]  probe8 
//	.probe9(SCK_o), // input wire [0:0]  probe9 
//	.probe10(ss_p), // input wire [0:0]  probe10 
//	.probe11(bkp_ready_r) // input wire [0:0]  probe11
//);


endmodule
