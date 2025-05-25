//ADD it in bb_driver.h
	/*********************************bk_status_sw bk_base:500*********************************************/
	 // ascription: fwj
	 // type: RTL
	 // function : switch 1 of N bk_status 
	 // update: 2025.3.11
	 //  0        bit3-0          DESR                 	 
     //  1        bit0            sw              	          0 is status 0 , 1 is status 1  
#define bk_status_sw_index  900
#define Version_Status 			   BK_status0
enum
{
	status_sw_DESR,
	status_sw,
};
void subsys_init(u32 base_index);
void SubSystemChoose(u32 subsys);


//ADD it in bb_driver.c
	/*********************************bk_status_sw bk_base:500*********************************************/
void subsys_init(u32 base_index)
{
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+status_sw_DESR,0x00);
	 bk_send_data(BK_AXI_BASE_ADDR,base_index+status_sw_DESR,0x01);
}

void SubSystemChoose(u32 subsys)
{
	bk_send_data(BK_AXI_BASE_ADDR,BK_Status_SW_index,subsys);

}
