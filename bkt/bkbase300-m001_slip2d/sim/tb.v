
localparam base300_point = 300
 /*********************************m001_slip2d bk_base:300*********************************************/
	reg [31:0] bk_index_base300;
	always @(*)
	begin
        if(bk_index_p1 >= base300_point + 1  && bk_index_p1 <= base300_point +1)  
            bk_index_base300 <= 300;
        else if(bk_index_p1 >= base300_point + 2  && bk_index_p1 <= base300_point +2)  
            bk_index_base300 <= 301;
        else if(bk_index_p1 >= base300_point + 3  && bk_index_p1 <= base300_point +3)  
            bk_index_base300 <= 302;
        else if(bk_index_p1 >= base300_point + 4  && bk_index_p1 <= base300_point +4)  
            bk_index_base300 <= 303;    
        else if(bk_index_p1 >= base300_point + 5  && bk_index_p1 <= base300_point +5)  
            bk_index_base300 <= 304;
        else if(bk_index_p1 >= base300_point + 6  && bk_index_p1 <= base300_point +6)  
            bk_index_base300 <= 305;
        else if(bk_index_p1 >= base300_point + 7  && bk_index_p1 <= base300_point +7)  
            bk_index_base300 <= 306;
        else if(bk_index_p1 >= base300_point + 8  && bk_index_p1 <= base300_point +8)  
            bk_index_base300 <= 307;
        else if(bk_index_p1 >= base300_point + 9  && bk_index_p1 <= base300_point +9)  
            bk_index_base300 <= 308;    
        else if(bk_index_p1 >= base300_point + 10  && bk_index_p1 <= base300_point +10)  
            bk_index_base300 <= 309;
        else if(bk_index_p1 >= base300_point + 11  && bk_index_p1 <= base300_point +11)  
            bk_index_base300 <= 310;
        else if(bk_index_p1 >= base300_point + 12  && bk_index_p1 <= base300_point +12)  
            bk_index_base300 <= 311;
        else if(bk_index_p1 >= base300_point + 13  && bk_index_p1 <= base300_point +13)  
            bk_index_base300 <= 312;    
        else if(bk_index_p1 >= base300_point + 14  && bk_index_p1 <= base300_point +14)  
            bk_index_base300 <= 313;
        else if(bk_index_p1 >= base300_point + 15  && bk_index_p1 <= base300_point +16)  
            bk_index_base300 <= 314;
        else if(bk_index_p1 >= base300_point + 17  && bk_index_p1 <= base300_point +17)  
            bk_index_base300 <= 315;
        else if(bk_index_p1 >= base300_point + 18 && bk_index_p1 <= base300_point  +18)  
            bk_index_base300 <= 316;
        else
            bk_index_base300 <= 'd0;    
	end
	
	reg [31:0] bk_data_base300;
	always @(*)
	begin
             if(bk_index_base300 == 300)                 //slip2d_DESR
            bk_data_base300 <= 1;
        else if(bk_index_base300 == 301)                 //radar_pics
            bk_data_base300 <= 1;
        else if(bk_index_base300 == 302)                 //horizontal_slip_times 
            bk_data_base300 <= 4;
        else if(bk_index_base300 == 303)                 //vertical_slip_times
            bk_data_base300 <= 4;    
        else if(bk_index_base300 == 304)                 //h_pwm_freq
            bk_data_base300 <= 100000;    
        else if(bk_index_base300 == 305)                 //h_radar_ss_time
            bk_data_base300 <= 4;    
        else if(bk_index_base300 == 306)                 //h_motor_step_scale
            bk_data_base300 <= 128;    
        else if(bk_index_base300 == 307)                 //h_mini_step_nums
            bk_data_base300 <= 8;    
        else if(bk_index_base300 == 308)                 //v_pwm_freq
            bk_data_base300 <= 100000;    
        else if(bk_index_base300 == 309)                 //v_motor_wait_time
            bk_data_base300 <= 4;    
        else if(bk_index_base300 == 310)                 //v_motor_step_scale
            bk_data_base300 <= 128;    
        else if(bk_index_base300 == 311)                 //v_mini_step_nums
            bk_data_base300 <= 6;    
        else if(bk_index_base300 == 312)                 //h_sw_dir_init
            bk_data_base300 <= 1;    
        else if(bk_index_base300 == 313)                 //v_sw_dir
            bk_data_base300 <= 0;    
        else if(bk_index_base300 == 314)                 //excute_start
            begin
                if(bk_index_p1 == base300_point + 15)
                    bk_data_base300 <= 1
                else if((bk_index_p1 == base300_point + 16)
                    bk_data_base300 <= 0

            end 
        else if(bk_index_base300 == 315)                 //force_stop
            bk_data_base300 <= 0;   
        else if(bk_index_base300 == 316)                 //extern_ctrl
            bk_data_base300 <= 8'b00010010; 
        else
            bk_data_base300 <= 'd0;    
	end	