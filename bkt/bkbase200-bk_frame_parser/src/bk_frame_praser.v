`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/22 14:43:55
// Design Name: 
// Module Name: bk_frame_praser
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

	/*********************************bk_frame_praser bk_base:200*********************************************/
	 //  ascripiton:  BKPcfg cqupt table.
	 //  type: RTL
	 //  function:  this module can match bkp interface  to send data to anyone of the general extern communication interface. such as spi\iic\uart\can and so on.
	 //  update:  2024.4.12
	 //  0			bit3-0			DESR				
	 //  1			bit31-0			magic_header0		    magic_header0 bytes0-3; this module can  max support 32 bytes magic_header with big_end. 
	 //  2			bit31-0			magic_header1		    magic_header1 bytes4-7; 
	 //  3			bit31-0			magic_header[2]		    magic_header[2] bytes8-11; 
	 //  4			bit31-0			magic_header[3]		    magic_header[3] bytes12-15; 
	 //  5			bit31-0			magic_header[4]		    magic_header[4] bytes16-19; 
	 //  6			bit31-0			magic_header[5]		    magic_header[5] bytes20-23; 
	 //  7			bit31-0			magic_header[6]		    magic_header[6] bytes24-27; 
	 //  8			bit31-0			magic_header[7]		    magic_header[7] bytes28-31; 
	 //  9          bit31-0         length_info             bit31-25 reseved; bit24: inner_legth_en;  bit:23:8  frame_totalleninfo_size; bit7:0 frame_totalleninfo_index;
	 //  10         bit31-0         ex_total_length         when inner_legth_en is 0  this ex value enable
	 //  11			bit31-0         ext_store_size          unity: bytes;extern bram_size
     //             bit31-0         bk_status               pasered_frame_nums.


module bk_frame_praser#(  
            parameter BKT_BASE               = 200,
			parameter bkp_data_width               = 8,     		 // support is 8 16 and 32
			parameter magic_header_size            = 8,     		 // in bytes 1-32
			parameter sys_clk_freq                 = 100_000_000
	)
	(
		input  wire clk,
		input  wire rst_n,
	

		// the bk system port  SBKPcfg
        input wire bkt_ready_i,
        input wire [31:0] bkt_index_i,
        input wire [31:0] bkt_data_i,
			
		input  wire  Bkp_Ready_i,
		input  wire  [bkp_data_width-1:0] Bkp_Data_i,
		output wire  Bkp_Busy_o,
		
		
		// the external ram input and output delay value must obey the () system standard ram configuration 
		output [31:0] dual_ram_waddr,
		output [bkp_data_width-1:0] dual_ram_wdata,
		output [31:0] dual_ram_raddr,
		input  [31:0] dual_ram_rdata,
		output w_en,
		output r_en,
		
		output wire Bks_Start_o,
		output wire [31:0] Bks_Data_o,
		output wire Bks_Last_o,
		
		
		output wire bkp01_ready_o, 
		output wire [7:0] bkp01_data_o,
        output wire [31:0] Bk_Status

    );
	
//************************************************************************
//function called clogb2 that returns an integer which has the
//value of the ceiling of the log base 2.
function integer clogb2(input integer bit_depth);
begin
	for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
		bit_depth = bit_depth>>1;
end
endfunction
//************************************************************************

    /********* gen code start*********/  
reg BKP_rec_ready_z1,BKP_rec_ready_z2;
always @(posedge clk)
if(!rst_n)
    begin
        BKP_rec_ready_z1 <= 1'b0;
        BKP_rec_ready_z2 <= 1'b0;
    end
 else
    begin
        BKP_rec_ready_z1 <= bkt_ready_i;
        BKP_rec_ready_z2 <= BKP_rec_ready_z1;
    end 

wire BKP_ready_pedge;
assign BKP_ready_pedge = BKP_rec_ready_z1 & ~BKP_rec_ready_z2;

wire [31:0] bk_data_index;
assign bk_data_index = bkt_index_i;

wire [31:0] bk_data;
assign bk_data = bkt_data_i;

reg [2:0] bk_mode;
always @(posedge clk)
if(!rst_n)
	bk_mode <= 'd0;
else if(BKP_ready_pedge && bk_data_index == 0)
	bk_mode <= bk_data[3:1];

reg [3:0] DESR;
always @(posedge clk)
if(!rst_n)
	DESR <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE)
	DESR <= bk_data[3:0];

reg [31:0] magic_header [7:0];
always @(posedge clk)
if(!rst_n)
	magic_header[0] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+1)
	magic_header[0] <= bk_data;
else
    magic_header[0] <= magic_header[0];
	

always @(posedge clk)
if(!rst_n)
	magic_header[1] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+2)
	magic_header[1] <= bk_data;
else
    magic_header[1] <= magic_header[1];


always @(posedge clk)
if(!rst_n)
	magic_header[2] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+3)
	magic_header[2] <= bk_data;
else
    magic_header[2] <= magic_header[2];


always @(posedge clk)
if(!rst_n)
	magic_header[3] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+4)
	magic_header[3] <= bk_data;
else
    magic_header[3] <= magic_header[3];


always @(posedge clk)
if(!rst_n)
	magic_header[4] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+5)
	magic_header[4] <= bk_data;
else
    magic_header[4] <= magic_header[4];


always @(posedge clk)
if(!rst_n)
	magic_header[5] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+6)
	magic_header[5] <= bk_data;
else
    magic_header[5] <= magic_header[5];


always @(posedge clk)
if(!rst_n)
	magic_header[6] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+7)
	magic_header[6] <= bk_data;
else
    magic_header[6] <= magic_header[6];


always @(posedge clk)
if(!rst_n)
	magic_header[7] <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE+8)
	magic_header[7] <= bk_data;
else
    magic_header[7] <= magic_header[7];	
	    
reg [31:0] length_info;
always @(posedge clk)
if(!rst_n)
    length_info <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE + 9)
    length_info <= bk_data;
else
	length_info <= length_info;

reg [31:0] ex_total_length;
always @(posedge clk)
if(!rst_n)
    ex_total_length <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE + 10)
    ex_total_length <= bk_data;
else
	ex_total_length <= ex_total_length;


reg [31:0] ext_store_size;
always @(posedge clk)
if(!rst_n)
    ext_store_size <= 'd0;
else if(BKP_ready_pedge && bk_data_index == BKT_BASE + 11)
    ext_store_size <= bk_data;
else
	ext_store_size <= ext_store_size;

    
   /********* gen code start*********/  
   
wire    inner_legth_en;
assign inner_legth_en = length_info[24];
wire [23:0]    frame_totalleninfo_size;
assign frame_totalleninfo_size = length_info[23:8];
wire [7:0]    frame_totalleninfo_index;
assign frame_totalleninfo_index = length_info[7:0];
	
// general param	
localparam cur_tsf_mode = bkp_data_width/8;

localparam tsf_mode0= 8'd1; 
localparam tsf_mode1= 8'd2;
localparam tsf_mode2= 8'd4; 

localparam header_delay_max   = magic_header_size*8/bkp_data_width;

wire [31:0] totallen_offset,totallen_delay_max,all_delay_max,ram_half_addr_inbytes;
assign totallen_offset    = frame_totalleninfo_index - magic_header_size - 1;
assign totallen_delay_max = frame_totalleninfo_size*8/bkp_data_width;
assign all_delay_max      = frame_totalleninfo_size + frame_totalleninfo_index - 1;

//ram param
assign ram_half_addr_inbytes = ext_store_size/2; // 1024/2

// instance state param	
localparam frame_cnt_state0 = 4'b0001;	
localparam frame_cnt_state1 = 4'b0010;	
localparam frame_cnt_state2 = 4'b0100;	
localparam frame_cnt_state4 = 4'b0100;	

			
localparam parse_state0 = 5'b00001;
localparam parse_state1 = 5'b00010;
localparam parse_state2 = 5'b00100;
localparam parse_state3 = 5'b01000;
localparam parse_state4 = 5'b10000;



reg data_ready_gate;
always  @(posedge clk)
if(!rst_n)	
	data_ready_gate <= 1'b0;
else if(Bkp_Ready_i)
	data_ready_gate <= ~data_ready_gate;
else
	data_ready_gate <= data_ready_gate;
	


reg [bkp_data_width-1:0] recdata_z[63:0];
genvar delay_i;
generate
	for(delay_i=0; delay_i<=63; delay_i=delay_i+1)
	begin: loop0
		always @(posedge clk)
		if(!rst_n)
			recdata_z[delay_i] <= 32'd0;
		else if(Bkp_Ready_i)
			begin
				if(delay_i == 0)
					recdata_z[delay_i] <= Bkp_Data_i;
				else 
					recdata_z[delay_i] <= recdata_z[delay_i-1];
			end 				
		else
			recdata_z[delay_i] <= recdata_z[delay_i];	
	end 
endgenerate

reg [3:0] data_rec_ready_z;
genvar readey_delay_i;
generate
	for(readey_delay_i=0; readey_delay_i<=3; readey_delay_i=readey_delay_i+1)
	begin: loop1
		always @(posedge clk)
		if(!rst_n)
			data_rec_ready_z[readey_delay_i] <= 32'd0;
		else if(Bkp_Ready_i)
			begin
				if(readey_delay_i == 0)
					data_rec_ready_z[readey_delay_i] <= 1'b1;
				else
					data_rec_ready_z[readey_delay_i] <= 1'b0;
			end 
		else if(data_rec_ready_z[readey_delay_i-1])
			data_rec_ready_z[readey_delay_i] <= 1'b1;
		else
			data_rec_ready_z[readey_delay_i] <= 1'b0;	
	end 
endgenerate

	
reg [31:0] cur_magic_header [magic_header_size/4-1:0];
genvar magic_index_i;
generate
	for(magic_index_i=0; magic_index_i<=magic_header_size/4-1; magic_index_i=magic_index_i+1)
	begin: loop2
		// pay attion this part need user change by your data format
		always @(posedge clk)
		if(!rst_n)
			cur_magic_header[magic_index_i]  <= 32'd0;
		else 
			case(cur_tsf_mode)
			tsf_mode0:
				cur_magic_header[magic_index_i] <= {recdata_z[all_delay_max-4*magic_index_i-1],recdata_z[all_delay_max-4*magic_index_i-2],recdata_z[all_delay_max-4*magic_index_i-3],recdata_z[all_delay_max-4*magic_index_i-4]};
			tsf_mode2:
				cur_magic_header[magic_index_i] <= {recdata_z[all_delay_max-2*magic_index_i-1],recdata_z[all_delay_max-2*magic_index_i-2]};
			tsf_mode2:
				cur_magic_header[magic_index_i] <= {recdata_z[all_delay_max- magic_index_i-1]};
			endcase
	end	
endgenerate


reg [7:0] cur_in_frame_length [7:0];
genvar totallen_index_i;
generate
	for(totallen_index_i=0; totallen_index_i<=7; totallen_index_i=totallen_index_i+1)
	begin: loop3
		// pay attion this part need user change by your data format
		always @(posedge clk)
		if(!rst_n)
			cur_in_frame_length[totallen_index_i]<= 'd0;
		else if(totallen_index_i <= frame_totalleninfo_size)
		    cur_in_frame_length[totallen_index_i] <= recdata_z[totallen_index_i];
		else
		    cur_in_frame_length[totallen_index_i]  <= 'd0;
		
	end
endgenerate



reg [magic_header_size/4-1:0] magic_header_check;
genvar k;
generate
for(k=0; k<=magic_header_size/4-1; k=k+1)
	begin: loop4
		always@(posedge clk)
		if(!rst_n)
			magic_header_check[k] <= 1'b0;
		else if(DESR == 1'b0)
			magic_header_check[k]  <= 1'b0;
		else if(cur_magic_header[k] == magic_header[k])
			magic_header_check[k]  <= 1'b1;
		else	
			magic_header_check[k]  <= 1'b0;
	end
endgenerate	

wire magic_header_check_isvalue;
assign magic_header_check_isvalue = &magic_header_check;

//edge check	
reg magic_header_check_z1;
reg magic_header_check_z2;
always @(posedge clk)
if(!rst_n)
	begin
		magic_header_check_z1 <= 1'b0;
		magic_header_check_z2 <= 1'b0;
	end 
else
	begin
		magic_header_check_z1 <= magic_header_check_isvalue;
		magic_header_check_z2 <= magic_header_check_z1;
	end 

wire magic_header_check_pedge;
assign magic_header_check_pedge = magic_header_check_z1 & !magic_header_check_z2;

//reg [7:0]gate;
//always @(posedge clk)
//if(!rst_n)
//    gate <= 1'b0;
//else if(magic_header_check_pedge_p)
//    begin
//        if(gate == 'd7)
//            gate <= 'd0;
//        else
//            gate <= gate + 1'd1;
//    end 
    
// wire magic_header_check_pedge;
// assign magic_header_check_pedge = (gate == 'd7) ? magic_header_check_pedge_p : 1'b0;
    
//pay attition: this code need change by your frame data format, default is cur_in_frame_length[31:0]
reg [31:0] cur_frame_length_inbytes;
always @(posedge clk)
if(!rst_n)
	cur_frame_length_inbytes <= 32'd0;
else if(magic_header_check_pedge)
	begin
		if(inner_legth_en)
			cur_frame_length_inbytes <= {cur_in_frame_length[2],cur_in_frame_length[3]}; 
		else
			cur_frame_length_inbytes <= ex_total_length;
	end 
else
	cur_frame_length_inbytes <= cur_frame_length_inbytes;

reg ping_pong_check;
always @(posedge clk)
if(!rst_n)
    ping_pong_check <= 1'b0;
else if(DESR == 1'b0)   
    ping_pong_check <= 1'b0;
else if(magic_header_check_pedge)
    ping_pong_check <= ~ping_pong_check;


wire [31:0] ram_w_ping_init_addr;
assign ram_w_ping_init_addr = 0;
wire [31:0] ram_w_pong_init_addr;
assign ram_w_pong_init_addr = ram_half_addr_inbytes/cur_tsf_mode;


wire [31:0] ram_r_ping_init_addr;
assign ram_r_ping_init_addr = 32'd0;
wire [31:0] ram_r_pong_init_addr;
assign ram_r_pong_init_addr = ram_half_addr_inbytes/4;


reg [4:0]  parse_state;
reg [31:0] data_wr_addr;
reg ram_wr_done;
reg [7:0] header_fill_addr;
always @(posedge clk)
if(!rst_n)	
	begin
		parse_state     <= parse_state0;
		data_wr_addr     <= 32'd0;
		ram_wr_done     <= 1'b0;
		header_fill_addr <= 8'b0;
	end 
else if(DESR == 1'b0)
    begin
		parse_state <= parse_state;
		data_wr_addr <= 32'd0;
		ram_wr_done <= 1'b0;
	end 
else 
    case(parse_state)
	   parse_state0:
		begin
			 if(magic_header_check_pedge)
				begin
					parse_state <= parse_state1;
					data_wr_addr <= 32'd0;
					ram_wr_done <= 1'b0;
				end 
			else
				begin
					parse_state <= parse_state;
					data_wr_addr <= 32'd0;
					ram_wr_done <= 1'b0;
				end 
		end 
	   parse_state1:
		begin
			if(ping_pong_check)
				begin
					parse_state <= parse_state2;
					data_wr_addr <= ram_w_ping_init_addr;
					
				end 
			else
				begin
					parse_state <= parse_state2;
					data_wr_addr <= ram_w_pong_init_addr;
				end 
		end 
	   parse_state2:
		begin
			if(Bkp_Ready_i)
				begin
					if(ping_pong_check)
						begin
							if(data_wr_addr == ram_w_ping_init_addr + cur_frame_length_inbytes/cur_tsf_mode - all_delay_max - 1'd1) 
								begin
									parse_state <= parse_state3;
									data_wr_addr <= 32'd0;
								end 
							else
								begin
									parse_state <= parse_state;
									data_wr_addr <= data_wr_addr + 1'd1;
								end 
						end
					else
						begin
							if(data_wr_addr == ram_w_pong_init_addr + cur_frame_length_inbytes/cur_tsf_mode - all_delay_max - 1'd1) 
								begin
									parse_state <= parse_state3;
									data_wr_addr <= 32'd0;
								end 
							else 
								begin
									parse_state <= parse_state;
									data_wr_addr <= data_wr_addr + 1'd1;
								end 
						end 
				end
		end
	   parse_state3:
		begin
			if(div_cnt == 4'b11)
				begin
					if(header_fill_addr == all_delay_max-1)
						begin
							header_fill_addr <= 8'b0;
							parse_state <= parse_state4;
						end 
					else
						begin
							header_fill_addr <= header_fill_addr + 1'd1;
							parse_state <= parse_state;
						end 	
				end 
				
		end 
	   parse_state4:
		begin
			parse_state <= parse_state0;
			ram_wr_done <= 1'b1;
			data_wr_addr <= 32'b0;
		end 
	default:
		begin
			parse_state <= parse_state0;
			ram_wr_done <= 1'b0;
			data_wr_addr <= 32'd0;
			header_fill_addr <= 8'd0;
		end
endcase

reg [3:0] div_cnt;
always @(posedge clk)
if(!rst_n)
	div_cnt <= 4'd0;
else if(parse_state == parse_state3)
	begin
		if(div_cnt == 4'b11)
			div_cnt <= div_cnt;
		else
			div_cnt <= div_cnt + 1'd1;
	end 
else
	div_cnt <= 4'b0;

wire data_fill_isvalue;
assign data_fill_isvalue = ((parse_state == parse_state3) && (header_fill_addr == 1'b0)) ? 1'b1 : 1'b0;

reg [bkp_data_width-1:0] fill_data [63:0];
genvar fill_i;
generate
	for(fill_i=0; fill_i<=63; fill_i = fill_i + 1)
	begin: loop5
		always @(posedge clk)
		if(!rst_n)
			fill_data[fill_i] <= 32'b0;
		else if(fill_i < all_delay_max)
		  begin
		      if(data_fill_isvalue)
					fill_data[fill_i] <= recdata_z[all_delay_max - fill_i -1];
				else
					fill_data[fill_i] <= fill_data[fill_i]; 
			 end   
		else 
		     fill_data[fill_i] <= 'd0;
	end	
endgenerate

wire [31:0] header_wr_addr_p;
assign header_wr_addr_p = (ping_pong_check == 1'b1) ? ram_w_ping_init_addr + header_fill_addr + cur_frame_length_inbytes/cur_tsf_mode - all_delay_max : ram_w_pong_init_addr + header_fill_addr + cur_frame_length_inbytes/cur_tsf_mode - all_delay_max;
wire [31:0] header_wr_addr_p2;
assign header_wr_addr_p2= (parse_state == parse_state3) ? header_wr_addr_p : 1'b0;

	
reg [31:0] ram_wr_addr;	
always @(posedge clk)
if(!rst_n)
	ram_wr_addr <= 32'b0;
else if(parse_state == parse_state2)
	ram_wr_addr <= data_wr_addr;
else if(parse_state == parse_state3)
	ram_wr_addr <= header_wr_addr_p2;
else
	ram_wr_addr <= 32'd0;
	
reg 	[31:0] ram_wr_addr_z1;
always @(posedge clk)
if(!rst_n)
    begin
            ram_wr_addr_z1 <= 'd0;
    end 
else
    begin
            ram_wr_addr_z1 <= ram_wr_addr;	
    end 

    
reg [31:0] ram_wr_data_p;
always @(posedge clk)
if(!rst_n)
	ram_wr_data_p <= 32'b0;
else if(parse_state == parse_state2)
	ram_wr_data_p <= recdata_z[all_delay_max-1];
else if(parse_state == parse_state3)
    ram_wr_data_p <= fill_data[header_fill_addr];
else
	ram_wr_data_p <= ram_wr_data_p;	
	
reg [31:0] ram_wr_data;	
always @(posedge clk)
if(!rst_n)
    begin
        ram_wr_data    <= 'b0;
    end 
else 
    begin
       ram_wr_data <= ram_wr_data_p;
    end 

reg magic_header_check_pedge_z1,magic_header_check_pedge_z2,magic_header_check_pedge_z3,magic_header_check_pedge_z4;
always @(posedge clk)
if(!rst_n)
    begin
	magic_header_check_pedge_z1 <= 'd0;
	magic_header_check_pedge_z2 <= 'd0;
	magic_header_check_pedge_z3 <= 'd0;
	magic_header_check_pedge_z4 <= 'd0;
	end
else
    begin
        magic_header_check_pedge_z1 <= magic_header_check_pedge;
        magic_header_check_pedge_z2 <= magic_header_check_pedge_z1;
        magic_header_check_pedge_z3 <= magic_header_check_pedge_z2; 
        magic_header_check_pedge_z4 <= magic_header_check_pedge_z3;        
    end 

reg w_en_p;
always @(posedge clk)
if(!rst_n)
	w_en_p <= 1'b0;
else if(magic_header_check_pedge_z4)
	w_en_p <= 1'b1;
else if(ram_wr_done)
	w_en_p <= 1'b0;
else
	w_en_p <= w_en_p;
	
reg r_en_p;
always @(posedge clk)
if(!rst_n)
	r_en_p <= 1'b0;
else if(ram_wr_done)
	r_en_p <= 1'b1;
else if(ram_rd_done)
	r_en_p <= 1'b0;
else
	r_en_p <= r_en_p;

wire pad;
assign pad = (cur_frame_length_inbytes%4 == 0) ? 1'b1 : 1'b0;

wire [31:0] used_frame_length;
assign used_frame_length = (pad == 1'b1) ? cur_frame_length_inbytes/4 - 1 : cur_frame_length_inbytes/4;
reg [31:0] ram_rd_addr;
always @(posedge clk)
if(!rst_n)
    ram_rd_addr <=1'b0;
else if(r_en_p)
    begin
        if(ping_pong_check)
           begin
	           if(ram_rd_addr == ram_r_ping_init_addr + used_frame_length +2)
                   ram_rd_addr <= ram_r_pong_init_addr;
	           else
		          ram_rd_addr <= ram_rd_addr + 1'd1;
		   end  
		else
		   begin
	           if(ram_rd_addr == ram_r_pong_init_addr + used_frame_length+2)
                   ram_rd_addr <= ram_r_ping_init_addr;
	           else
		          ram_rd_addr <= ram_rd_addr + 1'd1;
		   end  
    end
else
   ram_rd_addr <= ram_rd_addr; 

    
wire ram_rd_done;
assign ram_rd_done = (ram_rd_addr == ram_r_ping_init_addr + used_frame_length+2 || 
                    ram_rd_addr == ram_r_pong_init_addr + used_frame_length +2);

    
reg [31:0]ram_rd_addr_z1;
always @(posedge clk)
if(!rst_n)
	ram_rd_addr_z1 <= 32'd0;
else
	ram_rd_addr_z1 <= ram_rd_addr + 1'd1;
	
reg frame_last_p;
always @(posedge clk)
if(!rst_n)
	frame_last_p <= 1'b0;
else if ((r_en == 1'b1))
	begin
		if(ping_pong_check)
			begin
				if(ram_rd_addr ==  used_frame_length)
					frame_last_p <= 1'b1;
				else
					frame_last_p <= 1'b0;
			end 
		else
			begin
				if(ram_rd_addr == ram_half_addr_inbytes/4 + used_frame_length)
					frame_last_p <= 1'b1;
				else
					frame_last_p <= 1'b0;
			end 
	end 
else
	frame_last_p <= 1'b0;
	
reg frame_last_p2;
always @(posedge clk)
if(!rst_n)
	frame_last_p2 <= 1'b0;
else
	frame_last_p2 <= frame_last_p;
	
	
	
reg rd_en_2;
always @(posedge clk)
if(!rst_n)
	rd_en_2 <= 1'b0;
else if(ram_wr_done)
	rd_en_2 <= 1'b1;
else if(ram_rd_done2)
	rd_en_2 <= 1'b0;
else
	rd_en_2 <= rd_en_2;	
	
reg [31:0] rd_rate_cnt;
always @(posedge clk)
if(!rst_n)
	rd_rate_cnt <= 'd0;
else if(rd_en_2)
	begin
		if(rd_rate_cnt == 39999)   // < 115200 bps
			rd_rate_cnt <= 'd0;
		else
			rd_rate_cnt <= rd_rate_cnt + 1'd1;
	end 
else
	rd_rate_cnt <= 'd0;
	
reg [31:0] ram_rd_addr2;
always @(posedge clk)
if(!rst_n)
    ram_rd_addr2 <=1'b0;
else if(rd_en_2)
    begin
    if(rd_rate_cnt == 39999)
     ram_rd_addr2 <= ram_rd_addr2 + 1'd1;
    else
     ram_rd_addr2 <= ram_rd_addr2;
    end 
else  
    begin
    if(ping_pong_check)
        ram_rd_addr2 <= ram_r_ping_init_addr; 
    else 
        ram_rd_addr2 <= ram_r_pong_init_addr;
    end
    



wire ram_rd_done2;
assign ram_rd_done2 = (ram_rd_addr2 == ram_r_ping_init_addr + used_frame_length && (rd_rate_cnt == 39999)|| 
                    ram_rd_addr2 == ram_r_pong_init_addr + used_frame_length && (rd_rate_cnt == 39999));

wire bkp01_ready;
assign bkp01_ready = (rd_rate_cnt == 4999 || rd_rate_cnt == 14999 || rd_rate_cnt == 24999 || rd_rate_cnt == 34999) ? 1'b1 : 1'b0;
	
reg [7:0] bkp01_data;
always @(posedge clk)
if(!rst_n)
    bkp01_data <=1'b0;
else if(rd_en_2)
	begin
		if(rd_rate_cnt == 4990)
			bkp01_data <= dual_ram_rdata[7:0];
		else if(rd_rate_cnt == 14990)
			bkp01_data <= dual_ram_rdata[15:8];
		else if(rd_rate_cnt == 24990)
			bkp01_data <= dual_ram_rdata[23:16];
		else if(rd_rate_cnt == 34990)
			bkp01_data <= dual_ram_rdata[31:24];
		else 
			bkp01_data <= bkp01_data;
	end 
	
	
		// the external ram input and output delay value must obey the () system standard ram configuration 
		assign dual_ram_waddr     = ram_wr_addr_z1;
		assign dual_ram_wdata     = ram_wr_data;
		assign dual_ram_raddr     = ram_rd_addr2;
		//input  [31:0] dual_ram_rdata,
		assign w_en               = w_en_p;
		assign r_en               = rd_en_2;
		
		assign Bks_Start_o      = ((r_en == 1'b1) && ((ram_rd_addr == 32'd2) || (ram_rd_addr == ram_half_addr_inbytes/4+32'd2))) ? 1'b1 : 1'b0;  
		assign Bks_Data_o       = ((r_en == 1'b1)) ? {dual_ram_rdata[7:0],dual_ram_rdata[15:8],dual_ram_rdata[23:16],dual_ram_rdata[31:24]} : 1'b0;  
		assign Bks_Last_o       = ((r_en == 1'b1)) ? frame_last_p2 : 1'b0; 

	    assign Bk_Status         = cur_frame_length_inbytes;
	    
	    assign Bkp_Busy_o       = 1'b0;
		
		assign bkp01_ready_o   = bkp01_ready;
		assign bkp01_data_o    = bkp01_data;
	    

ila_0 i1 (
	.clk(clk), // input wire clk


	.probe0(magic_header_check_pedge), // input wire [0:0]  probe0  
	.probe1({rd_rate_cnt,dual_ram_rdata}), // input wire [63:0]  probe1 
	.probe2({cur_in_frame_length[2],cur_in_frame_length[3]}), // input wire [31:0]  probe2 
	.probe3(ram_rd_addr2), // input wire [31:0]  probe3 
	.probe4(used_frame_length), // input wire [31:0]  probe4 
	.probe5(rd_en_2), // input wire [31:0]  probe5 
	.probe6(bkp01_data), // input wire [31:0]  probe6 
	.probe7(bkp01_ready_o) // input wire [0:0]  probe7
);

endmodule