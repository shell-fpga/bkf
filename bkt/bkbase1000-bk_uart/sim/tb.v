    /***********************************bk_uart bk_base:1000**************************************/
    localparam base100_point = 1000;
    reg [31:0] bk_index_base1000;
    always @(*)
    begin
        if(bk_index_p1 >= base100_point  && bk_index_p1 <= base100_point)     
            bk_index_base1000 <= 1000;
        else if(bk_index_p1 >= base100_point +1  && bk_index_p1 <= base100_point + 1)   
            bk_index_base1000 <= 1001;
        else if(bk_index_p1 >= base100_point +2  && bk_index_p1 <= base100_point + 2)   
            bk_index_base1000 <= 1002;
        else if(bk_index_p1 >= base100_point +3  && bk_index_p1 <= base100_point + 3)   
            bk_index_base1000 <= 1004;
        else if(bk_index_p1 >= base100_point +4  && bk_index_p1 <= base100_point + 4)   
            bk_index_base1000 <= 1005;
		else if(bk_index_p1 >= base100_point +5  && bk_index_p1 <= base100_point + 6)   
            bk_index_base1000 <= 1006;
		else if(bk_index_p1 >= base100_point +7  && bk_index_p1 <= base100_point + 8)   
            bk_index_base1000 <= 1003;
        else
            bk_index_base1000 <= 'd0;    
    end
	
	
    reg [31:0] bk_data_base1000;
    always @(*)
    begin
		if(bk_index_base1000 == 0)			 // bk_mode
			bk_data_base1000 <= 'd0;
        else if(bk_index_base1000 == 1000)     // uart_DESR 
			bk_data_base1000 <= 1'b1;
		else if(bk_index_base1000 == 1001)     // BandRate_bit
			bk_data_base1000 <= 100_000_000/1152000;
		else if(bk_index_base1000 == 1002)     // uart_send_buf
			bk_data_base1000 <= 8'hba;
		else if(bk_index_base1000 == 1003)     // uart_send_start
			begin
				if(bk_index_p1 == base100_point +7)
					bk_data_base1000 <= 1'b1;
				else
					bk_data_base1000 <= 1'b0;
			end 
		else if(bk_index_base1000 == 1004)     // rec_buf(1)
			bk_data_base1000 <= 0;
		else if(bk_index_base1000 == 1005)     // rec_buf(2)
			bk_data_base1000 <= 0;
		else if(bk_index_base1000 == 1006)     // rec_clean
			begin
				if(bk_index_p1 == base100_point +5)
					bk_data_base1000 <= 1'b1;
				else
					bk_data_base1000 <= 1'b0;
			end	
		else
			bk_data_base1000 <= 'd0;
    end        
    
    