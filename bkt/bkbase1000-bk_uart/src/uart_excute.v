`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/22 19:59:52
// Design Name: 
// Module Name: Uart_Model
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
module uart_excute#(
					parameter  sys_clk_freq  = 50_000_000
				)
				(
					input wire clk,
					input wire rst_n,
					input wire [31:0] BandRate_bit,
					input  wire [7:0] bkp_data_i,
					input  wire bkp_ready_i,    //before  you  send a data please put it to high for a clock
					output wire bkp_busy_o,   //you can't change bkp_data_i value when this signal is high 
					output wire [7:0] bkp_data_o,
					output  wire bkp_ready_o,   //when this module receive a data it will put this signal for high and then zhe data will output from the data2rec_o
					
					output wire Tx,
					input  wire Rx
				 );
				 
wire [31:0] BandRate_byte;
assign  BandRate_byte = BandRate_bit * 10;
 				 
localparam Tx_state0 = 3'b001;
localparam Tx_state1 = 3'b010;
localparam Tx_state2 = 3'b100;
				 
localparam Rx_state0 = 3'b001;
localparam Rx_state1 = 3'b010;
localparam Rx_state2 = 3'b100;
				 
// send part code	//		

reg [2:0] Status_Tx;  
reg [31:0] BandRate_Tx_Cnt;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	begin
		BandRate_Tx_Cnt <= 32'd0;
		Status_Tx <= Tx_state0;
	end 
else 
	begin
		case(Status_Tx)
			Tx_state0:
					begin
						if(bkp_ready_i == 1'b1)
							begin
								Status_Tx <= Tx_state1;
								BandRate_Tx_Cnt <= 32'd1;
							end 
						else	
							begin
								Status_Tx <= Tx_state0;
								BandRate_Tx_Cnt <= 32'd0;
							end 
					end 
			Tx_state1:
					begin
						if(BandRate_Tx_Cnt == BandRate_byte)
							begin 
								BandRate_Tx_Cnt <= 32'd0;
								Status_Tx <= Tx_state2;
							end 
						else	
							begin
								BandRate_Tx_Cnt <= BandRate_Tx_Cnt + 1'd1;
								Status_Tx <= Tx_state1;
							end 
					end 
			Tx_state2:
					begin
						if(bkp_ready_i == 1'b1)
							Status_Tx <= Tx_state2;    //error situation
						else	
							Status_Tx <= Tx_state0;
					end 
			default:
					Status_Tx <= Tx_state0;
		endcase
	end 



wire uart_tx_pre_value;
assign uart_tx_pre_value  = ((BandRate_Tx_Cnt > BandRate_bit*32'd0) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd1)) ? 1'b1: 1'b0;
wire uart_tx_bit0_value;
assign uart_tx_bit0_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd1) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd2)) ? 1'b1: 1'b0;
wire uart_tx_bit1_value;
assign uart_tx_bit1_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd2) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd3)) ? 1'b1: 1'b0;
wire uart_tx_bit2_value;
assign uart_tx_bit2_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd3) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd4)) ? 1'b1: 1'b0;
wire uart_tx_bit3_value;
assign uart_tx_bit3_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd4) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd5)) ? 1'b1: 1'b0;
wire uart_tx_bit4_value;
assign uart_tx_bit4_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd5) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd6)) ? 1'b1: 1'b0;
wire uart_tx_bit5_value;
assign uart_tx_bit5_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd6) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd7)) ? 1'b1: 1'b0;
wire uart_tx_bit6_value;
assign uart_tx_bit6_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd7) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd8)) ? 1'b1: 1'b0;
wire uart_tx_bit7_value;
assign uart_tx_bit7_value = ((BandRate_Tx_Cnt > BandRate_bit*32'd8) &&(BandRate_Tx_Cnt <= BandRate_bit*32'd9)) ? 1'b1: 1'b0;
wire uart_tx_end_value;
assign uart_tx_end_value =  ((BandRate_Tx_Cnt > BandRate_bit*32'd9) &&(BandRate_Tx_Cnt  <=  BandRate_byte)) ? 1'b1: 1'b0;



reg  [7:0] bkp_data_i_n;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	bkp_data_i_n <= 8'b0;
else
	bkp_data_i_n <= bkp_data_i;
reg Tx_p;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	Tx_p <= 1'b1;
else if(uart_tx_pre_value)
	Tx_p <= 1'b0;
else if(uart_tx_bit0_value)
	Tx_p <= bkp_data_i_n[0];
else if(uart_tx_bit1_value)
	Tx_p <= bkp_data_i_n[1];
else if(uart_tx_bit2_value)
	Tx_p <= bkp_data_i_n[2];
else if(uart_tx_bit3_value)
	Tx_p <= bkp_data_i_n[3];
else if(uart_tx_bit4_value)
	Tx_p <= bkp_data_i_n[4];
else if(uart_tx_bit5_value)
	Tx_p <= bkp_data_i_n[5];
else if(uart_tx_bit6_value)
	Tx_p <= bkp_data_i_n[6];
else if(uart_tx_bit7_value)
	Tx_p <= bkp_data_i_n[7];
else if(uart_tx_end_value)
	Tx_p <= 1'b1;	
else
	Tx_p <= 1'b1;
		
wire  data_in_seding_o_p;
assign data_in_seding_o_p = ((BandRate_Tx_Cnt >0) &&(BandRate_Tx_Cnt <= BandRate_byte)) ? 1'b1 : 1'b0;

assign bkp_busy_o = data_in_seding_o_p;
assign Tx = Tx_p;


//Rx Part Code
reg Rx_n_1;
reg Rx_n_2;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	begin
		Rx_n_1 <= 1'b0;
		Rx_n_2 <= 1'b0;
	end
else
	begin
		Rx_n_1 <= Rx;
		Rx_n_2 <= Rx_n_1;
	end 

wire Rx_n_nedge;
assign Rx_n_nedge = !Rx_n_1 & Rx_n_2;

reg [2:0] Status_Rx;
reg [31:0] BandRate_Rx_Cnt;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	begin
		Status_Rx <= Rx_state0;
		BandRate_Rx_Cnt <= 32'd0;
	end 
else	
	case(Status_Rx)
		Rx_state0:
			begin
				if(Rx_n_nedge)
					begin
						Status_Rx <= Rx_state1;
						BandRate_Rx_Cnt <= 32'd1;
					end 
				else	
					begin
						Status_Rx <= Rx_state0;
						BandRate_Rx_Cnt <= 32'd0;
					end 
			end 
		Rx_state1:
			begin
				if(BandRate_Rx_Cnt == BandRate_byte)
					begin
						BandRate_Rx_Cnt <= 32'd0;
						Status_Rx <= Rx_state2;
					end 
				else
					begin
						BandRate_Rx_Cnt <= BandRate_Rx_Cnt + 1'd1;
						Status_Rx <= Rx_state1;
					end 
			end 
		Rx_state2:
			begin
				if(Rx_n_nedge)
					Status_Rx <= Rx_state2;
				else
					Status_Rx <= Rx_state0; 
			end 
		default:
			Status_Rx <= Rx_state0;
	endcase
	

//wire uart_rx_pre_value;
//assign uart_rx_pre_value  = (BandRate_Rx_Cnt == BandRate_bit*32'd0 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit0_value;
assign uart_rx_bit0_value = (BandRate_Rx_Cnt == BandRate_bit*32'd1 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit1_value;
assign uart_rx_bit1_value = (BandRate_Rx_Cnt == BandRate_bit*32'd2 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit2_value;                                
assign uart_rx_bit2_value = (BandRate_Rx_Cnt == BandRate_bit*32'd3 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit3_value;                                 
assign uart_rx_bit3_value = (BandRate_Rx_Cnt == BandRate_bit*32'd4 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit4_value;                                 
assign uart_rx_bit4_value = (BandRate_Rx_Cnt == BandRate_bit*32'd5 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit5_value;                                
assign uart_rx_bit5_value = (BandRate_Rx_Cnt == BandRate_bit*32'd6 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit6_value;                           
assign uart_rx_bit6_value = (BandRate_Rx_Cnt == BandRate_bit*32'd7 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_bit7_value;                           
assign uart_rx_bit7_value = (BandRate_Rx_Cnt == BandRate_bit*32'd8 + (BandRate_bit/2)) ? 1'b1: 1'b0;
wire uart_rx_end_value;                               
assign uart_rx_end_value =  (BandRate_Rx_Cnt == BandRate_bit*32'd9 + (BandRate_bit/2)) ? 1'b1: 1'b0;

wire Data_Recing;
assign	Data_Recing = (BandRate_Rx_Cnt == 0) ? 1'b0 : 1'b1;


reg [7:0] data2rec_o_n;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	data2rec_o_n <= 8'b0;
else if(Data_Recing == 1'b1)
	begin
		if(uart_rx_bit0_value)
			data2rec_o_n[0] <= Rx_n_1;
		else if(uart_rx_bit1_value)
			data2rec_o_n[1] <= Rx_n_1;
		else if(uart_rx_bit2_value)
			data2rec_o_n[2] <= Rx_n_1;
		else if(uart_rx_bit3_value)
			data2rec_o_n[3] <= Rx_n_1;
		else if(uart_rx_bit4_value)
			data2rec_o_n[4] <= Rx_n_1;
		else if(uart_rx_bit5_value)
			data2rec_o_n[5] <= Rx_n_1;
		else if(uart_rx_bit6_value)
			data2rec_o_n[6] <= Rx_n_1;
		else if(uart_rx_bit7_value)
			data2rec_o_n[7] <= Rx_n_1;
		else 
			data2rec_o_n <= data2rec_o_n;
	end 
else
	data2rec_o_n <= 8'b0;	

assign bkp_data_o       =  data2rec_o_n;
assign bkp_ready_o      =  uart_rx_end_value;
	
	
endmodule 