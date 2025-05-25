`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/24 09:40:51
// Design Name: 
// Module Name: bk_iic_master
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
   /*********************************bk_iic bk_base:900*********************************************/
	 //  ascripiton: shell
	 //  type: RTL
	 //  function : this module is standard IIC interface, it can  define single mode or contiune mode.
	 //  update:  2025.3.12
	 //  0          bit0            DESR   					 
	 //  1          bit0            iic_rw_mode				 rw_mode 0 is write, 1 is read
	 //  2          bit31-0         iic_T_1it                how many sys_clock to send 1 bit data(1/bps)
	 //  3          bit7-0          iic_send_buf			 buf to store send_data(1 byte)
	 //  4		    bit7-0          iic_rec_buf(1)           buf to sore  rec_data(1 byte)
	 //  5          bit0            iic_start			     start send data whitch is wirtern in send buf
     //  6          bit0            noack_clear				 clear the noack warning form bk mode0
	 //  7          bit1-0          iic_continue_done		 bit1: done this commiuncate, continue_mode will stop when this bit is setted.
	 //  8          bit0            iic_rec_clean            clean the rec_vaild
	 //                                                      bit0: done continue_req;Needing send new data to send buf before set is index only used in contiune mode.
	 //             bit31-0         bk_status                bk_mode0: bit0 iic_busy; bit1 write_noack; bit2 read noack; bit3 continue_req.
	 //														 bk_mode1: offset 6  rec_buf value

module bk_iic_master #(
		parameter BKP_BASE_index= 900
	)
	(
		input  wire clk,
		input  wire rst_n,
		 //iic bus
		output wire SCL,
		inout  wire SDA,
	
	   // the bk system port  SBKP
		input  wire bkt_ready_i,
		input  wire [31:0] bkt_index_i,
		input  wire [31:0] bkt_data_i,
		output wire [31:0] bk_status
	
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


reg rw_mode;
always @(posedge clk)
if(!rst_n)
	rw_mode <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 1 )
	rw_mode <= bk_data[0];
else
	rw_mode <= rw_mode;
	
reg [31:0] iic_T_1it;
always @(posedge clk)
if(!rst_n)
	iic_T_1it <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 2 )
	iic_T_1it <= bk_data;
else
	iic_T_1it <= iic_T_1it;
	
reg [7:0] send_buf;
always @(posedge clk)
if(!rst_n)
	send_buf <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 3 )
	send_buf <= bk_data[7:0];
else
	send_buf <= send_buf;
	

reg [7:0] rec_buf;
always @(posedge clk)
if(!rst_n)
	rec_buf <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 4 )
	rec_buf <= bk_data[7:0];
else
	rec_buf <= rec_buf;
	

reg  iic_start;
always @(posedge clk)
if(!rst_n)
	iic_start <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 5 )
	iic_start <= bk_data[0];
else
	iic_start <= iic_start;
		

reg  noack_clear;
always @(posedge clk)
if(!rst_n)
	noack_clear <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 6 )
	noack_clear <= bk_data[0];
else
	noack_clear <= noack_clear;

reg  [1:0] continue_done;
always @(posedge clk)
if(!rst_n)
	continue_done <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 7 )
	continue_done <= bk_data[1:0];
else
	continue_done <= continue_done;
	
reg  rec_clean;
always @(posedge clk)
if(!rst_n)
	rec_clean <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 8 )
	rec_clean <= bk_data[0];
else
	rec_clean <= rec_clean;			
wire write_noack;
wire read_noack;	
wire continue_req_p;	
reg [7:0]  rec_data;	
reg [31:0] bk_status_p;
always @(posedge clk)
if(!rst_n)
	bk_status_p <= 'd0;
else
	case(bk_mode)
		3'd0: begin bk_status_p<= {rec_vaild,continue_req_p,read_noack,write_noack,iic_busy};   end    
		3'd1: 
			  begin 
				if(BKP_Ready && bk_data_index == BKP_BASE_index + 4)
					bk_status_p <= rec_data;
				else
					bk_status_p <= bk_status_p;
		      end 
	    3'd2: begin bk_status_p<='d0;   end 
	endcase	
assign bk_status = 	bk_status_p;
/*******************end genrel part************************/	
reg bkp_ready;
always @(posedge clk)
if(!rst_n)
	bkp_ready <= 1'b0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 3)
	bkp_ready <= 1'b1;
else
	bkp_ready <= 1'b0;

reg iic_start_z1,iic_start_z2;
always @(posedge clk)
if(!rst_n)
	begin
		iic_start_z1 <= 'd0;
		iic_start_z2 <= 'd0;
	end 
else
	begin
		iic_start_z1 <= iic_start;
		iic_start_z2 <= iic_start_z1;
	end 

wire iic_start_pedge;
assign iic_start_pedge = iic_start_z1 & !iic_start_z2;

reg rec_vaild;
always @(posedge clk)
if(!rst_n)
    rec_vaild <= 1'b0;
else if(rec_clean)
    rec_vaild <= 1'b0;
else if(bkp_ready_r)
    rec_vaild <= 1'b1;
else
    rec_vaild <= rec_vaild; 

    
always @(posedge clk)
if(!rst_n)
    rec_data <= 'd0;
 else if(DESR ==1'b0)
    rec_data <= 'd0;
 else if(rec_clean)
    rec_data <= 'b0;
 else if(bkp_ready_r)
    rec_data <= bkp_data_r;
    

	
wire iic_busy;
wire bkp_ready_r;
wire [7:0] bkp_data_r;
iic_master	u1(
		  .clk(clk),
		  .rst_n(rst_n),
          .DESR(DESR),
		  .write_noack(write_noack),
		  .read_noack(read_noack),
		  .continue_req(continue_req_p),
		  .continue_done(continue_done),
		  .noack_clear(noack_clear),
		  .iic_T_1it(iic_T_1it),
		  .rw_mode(rw_mode),
		  .iic_start(iic_start_pedge),
		  .bkp_data_i(send_buf),  	            
		  .bkp_ready_i(bkp_ready), 		              
		  .bkp_busy_o(iic_busy),               
		  .bkp_data_o(bkp_data_r),
		  .bkp_ready_o(bkp_ready_r),
		
		  .SCL(SCL),
		  .SDA(SDA)
	);
	
	
	
ila_1 debug3 (
	.clk(clk), // input wire clk


	.probe0(rec_clean), // input wire [0:0]  probe0  
	.probe1(bkp_ready_r), // input wire [0:0]  probe1 
	.probe2(bkp_data_r), // input wire [31:0]  probe2 
	.probe3(bk_status_p), // input wire [31:0]  probe3 
	.probe4(rec_vaild), // input wire [1:0]  probe4 
	.probe5(rec_data)
);



endmodule

