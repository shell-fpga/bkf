
	/*********************************NCO_Gen bk_base:700*********************************************/
     // ascription: shell
	 // type: IP
	 // function :  Nco gen max support 20 chanels IQdata.
	 // update: 2025.6.11
	 // 0        bit7-0          DESR
	 // 1        bit7-0          IF_DDS_scale           	DDS_scale change to left shift to save resources
	 // 2        bit20-0         DDS_CH_enable              0-20 bit contrl 0-9 channel dds , if bit set to 0  DDS out is  0 , else DDS out depend on IF_DDS_D
	 // 3        bit15-0         init_phase                 IQ singal init phase  20 channels (init must cfg 20 times) init cfg 20 times
 	 // 4        bit31-0         IF_DDS_D           		Config  D (20 * 10 ) (cfg must cfg 200 times) init cfg 400 times
 	 // 5        bit   0         D_req_done           		clean req singal
	 //          bit31-0         bk_status               	bit0:D_req

#define NCO_Gen_index   700


enum{
	Nco_Gen_DESR,
	Nco_DDS_scale,
	Nco_CH_enable,
	init_phase,
	Nco_D,
	Nco_D_req_done,
};


void NCO_Gen_init(u32 base_index, u64 D[20], u32 mask);
int update_nco_D(u32 base_index, s64 IF_D[20] ,u64 carry_D);




	/*********************************NCO_Gen bk_base:700*********************************************/
void NCO_Gen_init(u32 base_index, u64 D[20], u32 mask)
 {
 	 int i;
	 u64 D_h32[20]={0};u32 D_l32[20]={0};


	 for(i=0;i<20;i++)
	 {
		 D_h32[i] = upper_32_bits(D[i]);
		 D_l32[i] = lower_32_bits(D[i]);
	 }


 	 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_Gen_DESR,0x00);

 	 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D_req_done,0x00);
 	 for(i=0; i< 20; i ++)
 	 {
 		 bk_send_data(BK_AXI_BASE_ADDR,base_index + init_phase,20*i);
 	 }
 	 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_DDS_scale,4);
#ifdef Linux
	 pthread_mutex_lock(&mutex_fpga);
#endif
 	 for(i=0; i< 400; i ++)
 	 {
 		 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D,D_h32[i%20]);
 		 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D,D_l32[i%20]);
 	 }
#ifdef Linux
	 pthread_mutex_unlock(&mutex_fpga);
#endif
 	 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_CH_enable,mask);
 	 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_Gen_DESR,0x01);
 	 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D_req_done,0x01);
 	 bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D_req_done,0x00);
 }


/* update_nco_D ----------------------------------------
* update_nco_D every 100ms,contain 10*10ms parameters of all the 20 sats
* args   :
* return :
*-----------------------------------------------------------------------------*/

int update_nco_D(u32 base_index, s64 Dop[20] ,u64 carry_D)
{
	int i=0;
	u32 IF_D_h32[20]={0};u32 IF_D_l32[20]={0};
	u64 IF_D[20];
	#if 1
	for(i=0;i<20;i++)
	{
		IF_D[i] = carry_D+Dop[i];
		IF_D_h32[i] = upper_32_bits(IF_D[i]);
		IF_D_l32[i] = lower_32_bits(IF_D[i]);
	}
#ifdef Linux
	 pthread_mutex_lock(&mutex_fpga);
#endif
	for(i=0; i < 200; i++)
	{
		bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D,IF_D_h32[i%20]);
		bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D,IF_D_l32[i%20]);
	}
#ifdef Linux
	 pthread_mutex_unlock(&mutex_fpga);
#endif
	#endif
	bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D_req_done,0x01);
	bk_send_data(BK_AXI_BASE_ADDR,base_index + Nco_D_req_done,0x00);
	return 0;
}
