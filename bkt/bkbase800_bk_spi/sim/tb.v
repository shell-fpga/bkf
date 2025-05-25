    /******************************bk_spi bk_base:800*******************************************/
    localparam base800_point = 800;
    reg [31:0] bk_index_base800;
    always @(*)
    begin
        if(bk_index_p1 >= base800_point  && bk_index_p1 <= base800_point)     
            bk_index_base800 <= 800;
        else if(bk_index_p1 >= base800_point +1  && bk_index_p1 <= base800_point + 1)   
            bk_index_base800 <= 801;
        else if(bk_index_p1 >= base800_point +2  && bk_index_p1 <= base800_point + 2)   
            bk_index_base800 <= 802;
        else if(bk_index_p1 >= base800_point +3  && bk_index_p1 <= base800_point + 3)   
            bk_index_base800 <= 803;
        else if(bk_index_p1 >= base800_point +4  && bk_index_p1 <= base800_point + 4)   
            bk_index_base800 <= 804;
		else if(bk_index_p1 >= base800_point +5  && bk_index_p1 <= base800_point + 5)   
            bk_index_base800 <= 805;
		else if(bk_index_p1 >= base800_point +6  && bk_index_p1 <= base800_point + 6)   
            bk_index_base800 <= 807;
        else if(bk_index_p1 >= base800_point +7  && bk_index_p1 <= base800_point + 8)   
            bk_index_base800 <= 806;
        else if(bk_index_p1 >= base800_point +9  && bk_index_p1 <= base800_point + 10)   
            bk_index_base800 <= 806;
        else if(bk_index_p1 == 150)
            bk_index_base800 <= 804;    
        else if(bk_index_p1 == 161 || bk_index_p1==162 || bk_index_p1== 269 || bk_index_p1 == 270)
            bk_index_base800 <= 808;
        else if(bk_index_p1 == 193 || bk_index_p1==194 || bk_index_p1== 318 || bk_index_p1 == 319)
            bk_index_base800 <= 809;
        else
            bk_index_base800 <= 'd0;    
    end
    
    reg [31:0] bk_data_base800;
    always @(*)
    begin
		if(bk_index_base800 == 0)			 // bk_mode
			bk_data_base800 <= 'd0;
        else if(bk_index_base800 == 800)     // DESR
			bk_data_base800 <= 1'b1;
		else if(bk_index_base800 == 801)     // spi_mode
			bk_data_base800 <= 2'b11;
		else if(bk_index_base800 == 802)     // rw_mode
			bk_data_base800 <= 32'd1;
		else if(bk_index_base800 == 803)     // spi_T_1bit
			bk_data_base800 <= 100_000_000/1000000;
		else if(bk_index_base800 == 804)     // send_buf
		  begin
		      if(bk_index_p1 == 150)
		          bk_data_base800 <= 32'hcd;
		      else
		          bk_data_base800 <= 32'hab;
		  end 
		else if(bk_index_base800 == 805)     // rec_buf
			bk_data_base800 <= 32'd0;
		else if(bk_index_base800 == 806)     // spi_start
			begin
				if(bk_index_p1 == base800_point +7)
					bk_data_base800 <= 1'b1;
				else if(bk_index_p1 == base800_point +8)
					bk_data_base800 <= 1'b0;
			end
		else if(bk_index_base800 == 807)     // SS_sel
			bk_data_base800 <= 8'b01;
		else if(bk_index_base800 == 808)      //continue_done
		  begin
		      if(bk_index_p1 == base800_point +9 || bk_index_p1 == 161)
		          bk_data_base800 <= 'b01;
		      else if(bk_index_p1 == 269)
		          bk_data_base800 <= 'b11;
		      else
		          bk_data_base800 <= 'b00;
		  end 
	   else if(bk_index_base800 == 809)   //rec_clean
		  begin
		  if(bk_index_p1 == 193 || bk_index_p1 ==  318)
		      bk_data_base900 <= 'b1;
		  else
		      bk_data_base900 <= 1'b0;
          end
        else
            bk_data_base800 <= 'd0;    
    end        
        