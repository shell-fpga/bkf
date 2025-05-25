localparam base100_point = 100
/*********************************bk_interface_cfg_v1 bk_base:100*********************************************/	
	reg [31:0] bk_index_base100;
	always @(*)
	begin
             if(bk_index_p1 >= base100_point + 1  && bk_index_p1 <= base100_point + 1)
            bk_index_base100 <= 100;
        else if(bk_index_p1 >= base100_point +2  && bk_index_p1 <=  base100_point +2)
            bk_index_base100 <= 102;
        else if(bk_index_p1 >=  base100_point + 3  && bk_index_p1 <= base100_point +3)
            bk_index_base100 <= 101;
        else if(bk_index_p1 >= base100_point + 4  && bk_index_p1 <= base100_point + 4)
            bk_index_base100 <= 103;    
        else
            bk_index_base100 <= 'd0;    
	end
	
	reg [31:0] bk_data_base100;
	always @(*)
	begin
             if(bk_index_base100 == 100)                //bk_interface_cfg DESR
            bk_data_base100 <= 1;
        else if(bk_index_base100 == 101)                //bkp_send_data
            bk_data_base100 <= 8'hff;
        else if(bk_index_base100 == 102)                //read_done
            bk_data_base100 <= 0;
        else if(bk_index_base100 == 103)                //read_offest
            bk_data_base100 <= 0;    
        else
            bk_data_base100 <= 'd0;    
	end
