   /*********************************m001_slip2d bk_base:300*********************************************/
	  // ascription: cqupt
      // type: rtl 
	  // version: vivado 2022.1
	  // descrtiption: run in 100M clock this module is used for m001 series
	  // 300			bit3-0					DESR    		           enable   
	  // 301			bit-7-0					radar_pics			       max support 256 pics radar
	  // 302			bit31-0					horizontal_slip_times      -
	  // 303			bit31-0					vertical_slip_times        -
	  // 304			bit31-0					h_pwm_freq 				   HZ
	  // 305			bit31-0					h_radar_ss_time            MS
	  // 306			bit31-0					h_motor_step_scale         0.2 mm / h_mini_step_nums
	  // 307			bit31-0					h_mini_step_nums           -
	  // 308			bit31-0					v_pwm_freq				   HZ
	  // 309			bit31-0					v_motor_wait_time		   MS
	  // 310			bit31-0					v_motor_step_scale         0.2 mm / v_mini_step_nums
	  // 311			bit31-0					v_mini_step_nums		   -
	  // 312			bit0				    h_sw_dir_init			   0 or 1 only can be change before excute_start
	  // 313			bit0					v_sw_dir				   0 or 1 can be change at any time
	  // 314			bit0					excute_start			   -
	  // 315			bit0					force_stop				   -
	  // 316            bit7-0                  extern_ctrl                extern start\swtich\up\dowm\left\right\stop
	 	                                                                //	start       = 8'b00010001;
     	                                                                //	switch      = 8'b00010010;
     	                                                                //	up          = 8'b00010011;
     	                                                                //	down        = 8'b00010100;
     	                                                                //	left        = 8'b00010101;
     	                                                                //	right       = 8'b00010110;
     	                                                                //	stop        = 8'b00100000;
	  // xxx        bit0-31                 bk_status			     //
                                                                     //bit3-0  4'b0001  indicate module has work finished; 
                                                                     //bit3-0  4'b0000  indicates module ready to work;
                                                                     //bit7-4  4'b1111  work error
                                                                     //bit7-4  4'b0001  module is working
                                                                     //bit7-4  4'b0000  modue is free 

#define     m001_slip2d_index 200
#define     ExtStart        0b00010001
#define     ExtSwitch       0b00010010
#define     ExtUp           0b00010011
#define     ExtDown         0b00010100
#define     ExtLeft         0b00010101
#define     ExtRight        0b00010110
#define     ExtStop         0b00100000

enum{
	m001_slip2d_DESR,
	radar_pics,
	horizontal_slip_times,
	vertical_slip_times,
	h_pwm_freq,
	h_radar_ss_time,
	h_motor_step_scale,
	h_mini_step_nums,
	v_pwm_freq,
	v_motor_wait_time,
	v_motor_step_scale,
	v_mini_step_nums,
	h_sw_dir_init,
	v_sw_dir,
	excute_start,
	force_stop,
	extern_ctrl,
};


void m001_slip2d_init(u32 base_index);
void m001_slip2d_start(u32 base_index);
void slip2d_excute_stop(u32 base_index);

 /*********************************m001_slip2d bk_base:300*********************************************/
 void m001_slip2d_init(u32 base_index)
 {
    int v_init_dir = 1;
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + radar_pics,1);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + horizontal_slip_times,8);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + vertical_slip_times,1);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + h_pwm_freq,24000);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + h_radar_ss_time,100);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + h_motor_step_scale,128);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + h_mini_step_nums,96);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + v_pwm_freq,24000);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + v_motor_wait_time,200);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + v_motor_step_scale,128);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + v_mini_step_nums,12);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + h_sw_dir_init,1);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + v_sw_dir,v_init_dir);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + excute_start,0);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + force_stop,0);
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + m001_slip2d_DESR,0);
	bk_send_data(BK_AXI_BASE_ADDR,base_index + extern_ctrl,0);
 }    


  void m001_slip2d_start(u32 base_index)
 {
 	bk_send_data(BK_AXI_BASE_ADDR,base_index + slip2d_DESR,1);
 	print("wait collect\n\r");
    bk_send_data(BK_AXI_BASE_ADDR,base_index+extern_ctrl,ExtSwitch);     // set sw is extern;
 }




 void slip2d_excute_stop(u32 base_index)
 {
 	bk_send_data(BK_AXI_BASE_ADDR,base_index+excute_start,0);     // ctrl_start stop
 }
