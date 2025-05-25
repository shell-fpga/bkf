//ADD it in bb_driver.h
 	/*********************************BK_GPIO bk_base:600*********************************************/
     // ascription: fwj
	 // type: RTL
	 // function : 
	 // update: 2025.3.11
	 //  0         bit0          DESR             
	 //  1         bit31-0       gpo_mask         out mask
	 //  2         xxx           gpo_value(1)     read offset       
	 //  3         bit31-0       gpo              io_out
        //                           bk_status        bkmode0 : gpi value io_in
        //					    	bkmode1 : 1902  gpo_value
#define BK_GPIO_index           600
enum {
	BK_GPIO_DESR,
	gpo_mask,
	gpo_value,
	gpo,
};
void BK_GPIO_init(u32 base_index);
void set_bk_gpo(u32 base_index, u32 mask, u32 value);
u32  get_bk_gpo(u32 base_index);
u32  get_bk_gpi();



//ADD it in bb_driver.c
 	/*********************************BK_GPIO bk_base:600*********************************************/
void BK_GPIO_init(u32 base_index)
{
	 bk_send_data(BK_AXI_BASE_ADDR,base_index + BK_GPIO_DESR,0X00);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index + BK_GPIO_DESR,0X01);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index + gpo_mask,0xffffffff);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index + gpo,0X00);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index + gpo_mask,0x00);
}



void set_bk_gpo(u32 base_index, u32 mask, u32 value)
{
	bk_send_data(BK_AXI_BASE_ADDR,base_index + gpo_mask,mask);
	bk_send_data(BK_AXI_BASE_ADDR,base_index + gpo,value);
	bk_send_data(BK_AXI_BASE_ADDR,base_index + gpo_mask,0x00);
}


u32 get_bk_gpo(u32 base_index)
{
	u32 bk_status;
	set_bk_mode(1);
	set_bkmode1_status_index(base_index+gpo_value);
	bk_status = get_bk_status();
	return bk_status;
}

u32 get_bk_gpi()
{
	u32 bk_status;
	set_bk_mode(0);
	bk_status = get_bk_status();
	return bk_status;
}

