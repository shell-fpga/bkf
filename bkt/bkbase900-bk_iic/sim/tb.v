	/*********************************bk_iic bk_base:900*********************************************/
    localparam base900_point = 900;
    reg [31:0] bk_index_base900;
    always @(*)
    begin
        if(bk_index_p1 >= base900_point  && bk_index_p1 <= base900_point)     
            bk_index_base900 <= 900;
        else if(bk_index_p1 >= base900_point +1  && bk_index_p1 <= base900_point + 1)   
            bk_index_base900 <= 901;
        else if(bk_index_p1 >= base900_point +2  && bk_index_p1 <= base900_point + 2)   
            bk_index_base900 <= 902;
        else if(bk_index_p1 >= base900_point +3  && bk_index_p1 <= base900_point + 3)   
            bk_index_base900 <= 903;
        else if(bk_index_p1 >= base900_point +4  && bk_index_p1 <= base900_point + 4)   
            bk_index_base900 <= 904;
		else if(bk_index_p1 >= base900_point +5  && bk_index_p1 <= base900_point + 6)   
            bk_index_base900 <= 905; 
		else if(bk_index_p1 >= base900_point +7  && bk_index_p1 <= base900_point + 8)   
            bk_index_base900 <= 906;
        else if(bk_index_p1 >= base900_point +9  && bk_index_p1 <= base900_point + 9)   
            bk_index_base900 <= 907;  
        else if(bk_index_p1 ==  280)
            bk_index_base900 <= 903;  
        else if(bk_index_p1 ==  283 || bk_index_p1 == 284 || bk_index_p1 ==  347 || bk_index_p1 == 348)
            bk_index_base900 <= 907;
        else if(bk_index_p1 ==  314 || bk_index_p1 == 315 || bk_index_p1 ==  404 || bk_index_p1 == 405)
            bk_index_base900 <= 908;
        else
            bk_index_base900 <= 'd0;    
    end
    
    reg [31:0] bk_data_base900;
    always @(*)
    begin
		if(bk_index_base900 == 0)			 // bk_mode
			bk_data_base900 <= 'd0;
        else if(bk_index_base900 == 900)     // DESR
			bk_data_base900 <= 1'b1;
		else if(bk_index_base900 == 901)     // rw_mode
			bk_data_base900 <= 32'd0;
		else if(bk_index_base900 == 902)     // iic_freq
			bk_data_base900 <= 100_000_000/1000_000;
		else if(bk_index_base900 == 903)     // send_buf
		  begin
			if(bk_index_p1 ==  280)
			   bk_data_base900 <= 32'hcd;	
			else
			   bk_data_base900 <= 32'hab; 
		  end
		else if(bk_index_base900 == 904)     // rec_buf
			bk_data_base900 <= 32'd0;
		else if(bk_index_base900 == 905)     // iic_start
			begin
				if(bk_index_p1 == base900_point +5)
					bk_data_base900 <= 1'b1;
				else 
					bk_data_base900 <= 1'b0;
			end
		else if(bk_index_base900 == 906)     // no_ack clear
		    begin
		        if(bk_index_p1 == base900_point +7)
		          bk_data_base900 <= 8'd1;
		        else
		          bk_data_base900 <= 8'd0;
		    end 
		else if(bk_index_base900 == 907)     //continue_done
		    begin
		      if(bk_index_p1 ==  283)
		          bk_data_base900 <= 'b01;
		      else if(bk_index_p1 ==  347)
		          bk_data_base900 <= 'b11;
		      else
		          bk_data_base900 <= 8'd0;
		    end 
		else if(bk_index_base900 == 908)   //rec_clean
		  begin
		  if(bk_index_p1 == 314 || bk_index_p1 ==  404)
		      bk_data_base900 <= 'b1;
		  else
		      bk_data_base900 <= 1'b0;
          end
        else
            bk_data_base900 <= 'd0;    
    end        
    
    
	