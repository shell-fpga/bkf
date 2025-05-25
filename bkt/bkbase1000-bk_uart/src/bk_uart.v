`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/22 19:59:52
// Design Name: 
// Module Name: bk_uart
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
   /*********************************bk_uart bk_base:1000*********************************************/
	 //  ascripiton: shell
	 //  type: RTL
	 //  function :
	 //  update:  2025.3.12
	 //  0          bit0            DESR   					 
	 //  1          bit7-0          BandRate_bit		     how many clocks to send 1bit data
	 //  2          bit7-0          send_buf				 buf to store send_data(1 byte)
	 //  3          bit0            send_start				 start tx
	 //  4 		    bit7-0          rec_buf(1)               buf to sore  rec_data(4 byte)
	 //  5  	    bit7-0          rec_buf(2)               buf to sore  rec_data(4 byte)
	 //  6          bit0       	    rec_clean				 clean the rx_nums    
	 //             bit31-0         bk_status                bk_mode0: bit0 tx_busy   bit3-1 rx_nums    
	 //														 bk_mode1: offset 4  rec_buf low  4 bytes
	 //													   		  	   offset 5  rec_buf high 4 bytes	
	 	

	 
	 module bk_uart#(
		parameter BKP_BASE_index= 1000,
		parameter sys_clk_freq = 100000000
	)
	(
		input  wire clk,
		input  wire rst_n,
		// the bk system port  SBKP
		input  wire bkt_ready_i,
		input  wire [31:0] bkt_index_i,
		input  wire [31:0] bkt_data_i,
		output wire [31:0] bk_status,
						
		output wire Tx,
		input  wire Rx
    );


/********* gen code start*********/
reg BKP_Ready_z1,BKP_Ready_z2;
always @(posedge clk)
if(!rst_n)
    begin
        BKP_Ready_z1 <= 1'b0;
        BKP_Ready_z2 <= 1'b0;
    end
 else
    begin
        BKP_Ready_z1 <= bkt_ready_i;
        BKP_Ready_z2 <= BKP_Ready_z1;
    end 

wire BKP_Ready;
assign BKP_Ready = BKP_Ready_z1 & ~BKP_Ready_z2;
	
reg [2:0] bk_mode;
always @(posedge clk)
if(!rst_n)
	bk_mode <= 'd0;
else if(BKP_Ready && bk_data_index == 0)
	bk_mode <= bk_data[2:0];
	
wire [31:0] bk_data_index;
assign bk_data_index = bkt_index_i;

wire [31:0] bk_data;
assign bk_data = bkt_data_i;


reg DESR;
always @(posedge clk)
if(!rst_n)
	DESR <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index)
	DESR <= bk_data[0];
else
	DESR <= DESR;


reg [31:0] BandRate_bit;
always @(posedge clk)
if(!rst_n)
	BandRate_bit <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 1 )
	BandRate_bit <= bk_data;
else
	BandRate_bit <= BandRate_bit;

reg [7:0] send_buf;
always @(posedge clk)
if(!rst_n)
	send_buf <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 2 )
	send_buf <= bk_data[7:0];
else
	send_buf <= send_buf;
	

reg send_start;
always @(posedge clk)
if(!rst_n)
	send_start <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 3 )
	send_start <= bk_data[0];
else
	send_start <= send_start;

reg rec_clean;
always @(posedge clk)
if(!rst_n)
	rec_clean <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 6 )
	rec_clean <= bk_data[0];
else
	rec_clean <= rec_clean;
	
reg [31:0] bk_status_p;
always @(posedge clk)
if(!rst_n)
	bk_status_p <= 'd0;
else
	case(bk_mode)
		3'd0: begin bk_status_p<= {rx_nums,bkp_busy};   end    
		3'd1: 
			  begin 
				if(BKP_Ready && bk_data_index == BKP_BASE_index + 4)
					bk_status_p <= rec_buf[31:0];
				else if(BKP_Ready && bk_data_index == BKP_BASE_index + 5)
					bk_status_p <= rec_buf[63:32];
				else
					bk_status_p <= bk_status_p;
		      end 
	    3'd2: begin bk_status_p<='d0;   end 
	endcase	
assign bk_status = 	bk_status_p;


reg send_start_z1,send_start_z2;
always @(posedge clk)
if(!rst_n)
	begin
		send_start_z1 <= 'd0;
		send_start_z2 <= 'd0;
	end 
else
	begin
		send_start_z1 <= send_start;
		send_start_z2 <= send_start_z1;
	end 

wire send_start_pedge;
assign send_start_pedge = send_start_z1 & !send_start_z2;


reg rx_clean_z1,rx_clean_z2;
always @(posedge clk)
if(!rst_n)
	begin
		rx_clean_z1 <= 'd0;
		rx_clean_z2 <= 'd0;
	end 
else
	begin
		rx_clean_z1 <= rec_clean;
		rx_clean_z2 <= rx_clean_z1;
	end 

wire rx_clean_pedge;
assign rx_clean_pedge = rx_clean_z1 & !rx_clean_z2;


reg [2:0] rx_nums;
always @(posedge clk)
if(!rst_n)
	rx_nums <= 'd0;
else if(bkp_ready_rx)
	rx_nums <= rx_nums + 1'd1;
else if(rx_clean_pedge)
	rx_nums <= 'd0;
else	
	rx_nums <= rx_nums;

reg [63:0] rec_buf;
always @(posedge clk)
if(!rst_n)
	rec_buf <= 'd0;
else if(rx_clean_pedge)
	rec_buf <= 'd0;
else if(bkp_ready_rx)
	rec_buf <= {rec_buf << 8} | bkp_data_rx;
else
	rec_buf <= rec_buf;


wire bkp_busy;
wire [7:0] bkp_data_rx;
wire bkp_ready_rx;
     uart_excute#(
					.sys_clk_freq(sys_clk_freq)
				)
				u1(
					.clk(clk),
				    .rst_n(rst_n),
					.BandRate_bit(BandRate_bit),
					.bkp_data_i(send_buf),  	              // the data you want to send
					.bkp_ready_i(send_start_pedge), 		              // when this is high for at last 1 clk the data will sending 
					.bkp_busy_o(bkp_busy),                        // when this signal is high level you must keep the bkp_data_i's value  si statiable
		
		
					.bkp_data_o(bkp_data_rx),
					.bkp_ready_o(bkp_ready_rx),
					.Tx(Tx),
					.Rx(Rx)
				 );
				 
				 
endmodule 
		