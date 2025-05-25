	localparam base600_point = 600;
    /*********************************BK_GPIO_v1 bk_base:600*********************************************/
	reg [31:0] bk_index_base600;
	always @(*)
	begin
        if(bk_index_p1 >= base600_point +1  && bk_index_p1 <= base600_point +1)     
            bk_index_base600 <= 600;
        else if(bk_index_p1 >= base600_point +2  && bk_index_p1 <= base600_point + 2)   
            bk_index_base600 <= 601;
		else if(bk_index_p1 >= base600_point +3 && bk_index_p1 <= base600_point + 3)   
            bk_index_base600 <= 602;
		else if(bk_index_p1 >= base600_point +4 && bk_index_p1 <= base600_point + 4)   
            bk_index_base600 <= 603;
        else
            bk_index_base600 <= 'd0;    
	end
	
	reg [31:0] bk_data_base600;
	always @(*)
	begin
        if(bk_index_base600 == 600)           //BK_GPIO_DESR   
			bk_data_base600 <= 1; 
		else if(bk_index_base600 == 601)      //gpo_mask    
            bk_data_base600 <= 32'hffff; 
		else if(bk_index_base600 == 602)     //gpo_value(0)  
			bk_data_base600 <= 0;
		else if(bk_index_base600 == 603)      //gpo    
            bk_data_base600 <= 32'hf0; 
        else
            bk_data_base600 <= 'd0;    
	end			
	