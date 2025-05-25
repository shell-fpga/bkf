
    /*********************************bk_interface_cfg bk_base:100*********************************************/
    // ascription: cqupt
    // init_cfg_times: 4
    // type: RTL
    // tools: vivado2020.2
    // function :  this module use for send and receive bkp data form bkp interface. 
	// update: 2024.5.12
 	 //  100			bit0			DESR					Enbale  bk_interface_cfg
	 //  101			bit31-0			bkp_send_data			data buf
	 //  102            bit0            read_done               use to clean the data_ready status
	 //  103			xxx				read_offest(1)			use to get read data
	 //  xxx            bit31-0         bk_status(0 1)          //bk_mode0 :  bit0     data_ready
																//bk_mode1 :  bit31-0  bkp_read_data
#define bk_interface_cfg_index 100

enum{
	bk_interface_cfg_DESR,
	bkp_send_data,
	bkp_rd_done,
	bkp_rd_offest,
};



void bk_interface_cfg_init(u32 base_index);
void bkp_send_data(u32 base_index, u32 data);
u32 bkp_read_data(u32 base_index);




 /*********************************bk_interface_cfg bk_base:100*********************************************/
void radar_ctrl_com_init(u32 base_index)
{
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+bk_interface_cfg_DESR,0x00);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+bkp_send_data,0x00);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+bkp_rd_done,0x00);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+bk_interface_cfg_DESR,0x01);
}


void bkp_send_data(u32 base_index, u32 data)
{
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+bkp_send_data,data);
}

u32 bkp_read_data(u32 base_index)
{
    int i;
    u32 bk_status;
    i = 1000;
    set_bk_mode(0);
    bk_status = get_bk_status();
    if(bk_status == 0)
    {
    	return -1;
    }
    else 
    {
    	set_bk_mode(1);
    	set_bkmode1_status_index(base_index + bkp_rd_offest)
    	bk_status = get_bk_status();
    }
    set_bk_mode(0)
    return bk_status;
    
	
}
