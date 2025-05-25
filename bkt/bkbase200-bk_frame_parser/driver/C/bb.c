   /*********************************bk_frame_parser bk_base:200*********************************************/
  		// ascription: cqupt
    	// init_cfg_times: 11
    	// type: RTL
    	// tools: vivado2020.2
    	// function :  this module use for parsing some frame witch had frame length info or fixed frame size with magic header.
   	// update: 2024.5.12
	 //  201			bit31-0			magic_header0		    magic_header0 bytes0-3; this module can  max support 32 bytes magic_header with big_end.
	 //  202			bit31-0			magic_header1		    magic_header1 bytes4-7;
	 //  203			bit31-0			magic_header2		    magic_header2 bytes8-11;
	 //  204			bit31-0			magic_header3		    magic_header3 bytes12-15;
	 //  205			bit31-0			magic_header4		    magic_header4 bytes16-19;
	 //  206			bit31-0			magic_header5		    magic_header5 bytes20-23;
	 //  207			bit31-0			magic_header6		    magic_header6 bytes24-27;
	 //  208			bit31-0			magic_header7		    magic_header7 bytes28-31;
	 //  209            bit31-0         length_info             bit31-25 reseved; bit24: inner_legth_en;  bit:23:8  frame_totalleninfo_size; bit7:0 frame_totalleninfo_index;
	 //  210            bit31-0         ex_total_length         when inner_legth_en is 0  this ex value enable
	 //  211			bit31-0         ext_store_size          unity: bytes;extern bram_size
     //  xxx            bit31-0         bk_status               pasered_frame_nums.
     
     
#define      bk_frame_parser_index 200
     
enum{
	bk_frame_parser_DESR,
	magic_header0,
	magic_header1,
	magic_header2,
	magic_header3,
	magic_header4,
	magic_header5,
	magic_header6,
	magic_header7,
	length_info,
	ex_total_length,
	ext_store_size,
};

void bk_frame_parser_init(u32 base_index);



  /*********************************bk_frame_parser bk_base:200*********************************************/
  
void bk_frame_parser_init(u32 base_index)
{
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header0,0x02010403);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header1,0x06050807);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header2,0);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header3,0);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header4,0);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header5,0);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header6,0);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+magic_header7,0);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+length_info,0x0100040d);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+ex_total_length,0);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+ext_store_size,4096);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+bk_frame_parser_DESR,0x01);
}