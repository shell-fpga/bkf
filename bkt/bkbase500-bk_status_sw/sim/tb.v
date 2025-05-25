localparam base500_point = 500;
	/*********************************bk_status_sw bk_base:500*********************************************/
	reg [31:0] bk_index_base500;
	always @(*)
	begin
        if(bk_index_p1 >=  base400_point+1  && bk_index_p1 <= base400_point + 1)     
            bk_index_base500 <= 501;
        else if(bk_index_p1 >= base400_point+2  && bk_index_p1 <= base400_point + 2)   
            bk_index_base500 <= 500;
        else
            bk_index_base500 <= 'd0;    
	end
	
	reg [31:0] bk_data_base500;
	always @(*)
	begin
             if(bk_index_base500 == 500)              // bk_status_sw   DESR
            bk_data_base500 <= 1;
        else if(bk_index_base500 == 501)              //sw
            bk_data_base500 <= 0; 
        else
            bk_data_base500 <= 'd0;    
	end	