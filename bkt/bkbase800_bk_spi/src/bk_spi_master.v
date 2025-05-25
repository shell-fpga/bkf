`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/22 15��49��
// Design Name: 
// Module Name: bk_spi_master
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
    /*********************************bk_spi bk_base:800*********************************************/
	//  ascripiton: shell
	//  type: RTL
    //  function : this module is standard Motorola SPI Master mode, it can custon define ss nums.
	//  update:  2025.3.12
	//  0          bit0            DESR   					DESR
	//  1          bit1-0          spi_mode                 SPI cp mode bit0:CPOL, bit1:CPHA
	//  2          bit0            spi_rw_mode				rw_mode 0 is write, 1 is read
	//  3          bit31-0         spi_T_1bit               how many sys_clock to send 1 bit data(1/bps)
	//  4          bit7-0          spi_send_buf			    buf to store send_data(1 byte)
	//  5  		   bit7-0          spi_rec_buf(1)           buf to sore  rec_data(1 byte)
	//  6          bit0            spi_start			    start send data whitch is wirtern in send buf 
    //  7          bit7-0          SS_sel					set whitch ss will be used
    //  8          bit1-0          spi_continue_done        bit1: end this commiuncate, bit1: done cur req.
    //  9          bit0            spi_rec_clean            clean the rec_vaild
	//             bit31-0         bk_status                bk_mode0: bit0 spi_busy ��bit1 continue_req, bit2 rec_vaild
	//														bk_mode1: offset 6  rec_buf value



module bk_spi_master#(
		parameter SS_nums = 8,
		parameter BKP_BASE_index= 800,
		//sys cfg
		parameter sys_clk_freq = 100_000_000

	)
	(
		input  wire clk,
		input  wire rst_n,
		// spi  bus
		output wire SCK_o,
		output wire [SS_nums-1 :0]SS_o,
		input  wire MISO,
		output wire MOSI,
		
		// the bk system port  SBKP
		input wire BkpCfg_Ready_i,
		input wire [31:0] BkpCfg_DataIndex_i,
		input wire [31:0] BkpCfg_DataValue_i,
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
        BKP_Ready_z1 <= BkpCfg_Ready_i;
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
assign bk_data_index = BkpCfg_DataIndex_i;

wire [31:0] bk_data;
assign bk_data = BkpCfg_DataValue_i;


reg DESR;
always @(posedge clk)
if(!rst_n)
	DESR <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index)
	DESR <= bk_data[0];
else
	DESR <= DESR;


reg [1:0] spi_mode;
always @(posedge clk)
if(!rst_n)
	spi_mode <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 1 )
	spi_mode <= bk_data[1:0];
else
	spi_mode <= spi_mode;
	
reg rw_mode;
always @(posedge clk)
if(!rst_n)
	rw_mode <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 2 )
	rw_mode <= bk_data[0];
else
	rw_mode <= rw_mode;
	
reg [31:0] spi_T_1bit;
always @(posedge clk)
if(!rst_n)
	spi_T_1bit <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 3 )
	spi_T_1bit <= bk_data;
else
	spi_T_1bit <= spi_T_1bit;
	
reg [7:0] send_buf;
always @(posedge clk)
if(!rst_n)
	send_buf <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 4 )
	send_buf <= bk_data[7:0];
else
	send_buf <= send_buf;
	

reg [7:0] rec_buf;
always @(posedge clk)
if(!rst_n)
	rec_buf <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 5 )
	rec_buf <= bk_data[7:0];
else
	rec_buf <= rec_buf;
	

reg  spi_start;
always @(posedge clk)
if(!rst_n)
	spi_start <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 6 )
	spi_start <= bk_data[0];
else
	spi_start <= spi_start;
		

reg  [7:0] SS_sel;
always @(posedge clk)
if(!rst_n)
	SS_sel <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 7 )
	SS_sel <= bk_data[7:0];
else
	SS_sel <= SS_sel;
	
reg  [1:0] continue_done;
always @(posedge clk)
if(!rst_n)
	continue_done <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 8 )
	continue_done <= bk_data[1:0];
else
	continue_done <= continue_done;	
	
reg  rec_clean;
always @(posedge clk)
if(!rst_n)
	rec_clean <= 'd0;
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 9 )
	rec_clean <= bk_data[0];
else
	rec_clean <= rec_clean;	
			
reg [31:0] bk_status_p;
always @(posedge clk)
if(!rst_n)
	bk_status_p <= 'd0;
else
	case(bk_mode)
		3'd0: begin bk_status_p<= {rec_vaild,continue_req,spi_busy};   end    
		3'd1: 
			  begin 
				if(BKP_Ready && bk_data_index == BKP_BASE_index + 5)
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
else if(BKP_Ready && bk_data_index == BKP_BASE_index + 4)
	bkp_ready <= 1'b1;
else
	bkp_ready <= 1'b0;
	
	
reg spi_start_z1,spi_start_z2;
always @(posedge clk)
if(!rst_n)
	begin
		spi_start_z1 <= 'd0;
		spi_start_z2 <= 'd0;
	end 
else
	begin
		spi_start_z1 <= spi_start;
		spi_start_z2 <= spi_start_z1;
	end 

wire spi_start_pedge;
assign spi_start_pedge = spi_start_z1 & !spi_start_z2;

wire CPOL,CPHA;
assign CPOL = spi_mode[1];
assign CPHA = spi_mode[0];

wire  SCK_p;
wire  SS_p;
wire  MOSI_p;
wire  spi_busy;
wire  [7:0] spi_rec_data;
wire  bkp_ready_read;
wire  continue_req;
spi_master  u1(
		.clk(clk),
		.rst_n(rst_n),
		.DESR(DESR),
		.rw_mode(rw_mode),
		.CPOL(CPOL),
		.CPHA(CPHA),
		.spi_T_1bit(spi_T_1bit),
		.spi_start(spi_start_pedge),
		.continue_done(continue_done),
		.continue_req(continue_req),
		// spi master bus
		.SCK_o(SCK_p),
		.SS_o(SS_p),
		.MISO(MISO),
		.MOSI(MOSI_p),
		
		.bkp_data_i(send_buf),  	  // the data you want to send
		.bkp_ready_i(bkp_ready), 		  // when this is high for at last 1 clk the data will sending 
		.bkp_busy_o(spi_busy),         // when this signal is high level you must keep the data2send_i's value  si statiable
		.bkp_data_o(spi_rec_data),
		.bkp_ready_o(bkp_ready_read)
	);	

reg rec_vaild;
always @(posedge clk)
if(!rst_n)
    rec_vaild <= 1'b0;
else if(rec_clean)
    rec_vaild <= 1'b0;
else if(bkp_ready_read)
    rec_vaild <= 1'b1;
else
    rec_vaild <= rec_vaild; 

    

reg  [7:0] rec_data;
always @(posedge clk)
if(!rst_n)
    rec_data <= 'd0;
 else if(DESR ==1'b0)
    rec_data <= 'd0;
 else if(rec_clean)
    rec_data <= 'b0;
 else if(bkp_ready_read)
    rec_data <= spi_rec_data;
    
reg [31:0] SS;    
genvar i;    
generate 
for(i=0;i<32;i=i+1)
begin:loop1
    always @(posedge clk)
    if(!rst_n)
        SS[i] <= 1'b1;
    else if(i == SS_sel)
        SS[i] <= SS_p;
    else
        SS[i] <= 1'b1;
end
endgenerate    


assign SCK_o = SCK_p;
assign SS_o  = SS[SS_nums-1:0];
assign MOSI  = MOSI_p;

endmodule
