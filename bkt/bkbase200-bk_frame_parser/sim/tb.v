output wire Bkp_Ready_o,
output wire [7:0] Bkp_Data_o

localparam base200_point = 200
/*********************************bk_frame_praser_v1 bk_base:200*********************************************/	
	reg [31:0] bk_index_base200;
	always @(*)
	begin
             if(bk_index_p1 >= base200_point + 1  && bk_index_p1 <= base200_point +1)  
            bk_index_base200 <= 211;
        else if(bk_index_p1 >= base200_point + 2  && bk_index_p1 <= base200_point +2)  
            bk_index_base200 <= 210;
        else if(bk_index_p1 >= base200_point + 3  && bk_index_p1 <= base200_point +3)  
            bk_index_base200 <= 209;
        else if(bk_index_p1 >= base200_point + 4  && bk_index_p1 <= base200_point +4)  
            bk_index_base200 <= 208;    
        else if(bk_index_p1 >= base200_point + 5  && bk_index_p1 <= base200_point +5)  
            bk_index_base200 <= 207;
        else if(bk_index_p1 >= base200_point + 6  && bk_index_p1 <= base200_point +6)  
            bk_index_base200 <= 206;
        else if(bk_index_p1 >= base200_point + 7  && bk_index_p1 <= base200_point +7)  
            bk_index_base200 <= 205;
        else if(bk_index_p1 >= base200_point + 8  && bk_index_p1 <= base200_point +8)  
            bk_index_base200 <= 204;
        else if(bk_index_p1 >= base200_point + 9  && bk_index_p1 <= base200_point +9)  
            bk_index_base200 <= 203;    
        else if(bk_index_p1 >= base200_point + 10  && bk_index_p1 <= base200_point +10)  
            bk_index_base200 <= 202;
        else if(bk_index_p1 >= base200_point + 11  && bk_index_p1 <= base200_point +11)  
            bk_index_base200 <= 201;
        else if(bk_index_p1 >= base200_point + 12  && bk_index_p1 <= base200_point +12)  
            bk_index_base200 <= 200;
        else
            bk_index_base200 <= 'd0;    
	end
	
	reg [31:0] bk_data_base200;
	always @(*)
	begin
             if(bk_index_base200 == 200)                 //bk_frame_praser_DESR
            bk_data_base200 <= 1;
        else if(bk_index_base200 == 201)                 //magic_header0
            bk_data_base200 <= 'h02010403;
        else if(bk_index_base200 == 202)                 //magic_header1 
            bk_data_base200 <= 'h06050807;
        else if(bk_index_base200 == 203)                 //magic_header2
            bk_data_base200 <= 0;    
        else if(bk_index_base200 == 204)                 //magic_header3
            bk_data_base200 <= 0;    
        else if(bk_index_base200 == 205)                 //magic_header4
            bk_data_base200 <= 0;    
        else if(bk_index_base200 == 206)                 //magic_header5
            bk_data_base200 <= 0;    
        else if(bk_index_base200 == 207)                 //magic_header6
            bk_data_base200 <= 0;    
        else if(bk_index_base200 == 208)                 //magic_header7
            bk_data_base200 <= 0;    
        else if(bk_index_base200 == 209)                 //length_info
            bk_data_base200 <= {7'b0,1'b1,16'd4,8'd13};    
        else if(bk_index_base200 == 210)                 //ex_total_length
            bk_data_base200 <= 0;    
        else if(bk_index_base200 == 211)                 //ext_store_size
            bk_data_base200 <= 4096;    
        else
            bk_data_base200 <= 'd0;    
	end	
	
	reg [31:0] cnt1;
	always @(posedge clk)
	if(!rst_n)
	   cnt1 <= 'd0;
    else if(cnt1 == 'd10)
       cnt1 <=  'd0;
    else
       cnt1 <= cnt1 + 1'd1;
     
    reg [31:0] data_nums;
    always @(posedge clk)
	if(!rst_n)
	   data_nums <= 'd0;
    else if(cnt1 == 'd10)
       begin
            if(data_nums == 'd22)
                data_nums <= 'd1;
            else
                data_nums <= data_nums + 1'd1;
       end 
    else
       data_nums <= data_nums;
       
    reg [7:0] test_data;
    always @(posedge clk)
	if(!rst_n)
	   test_data <= 'd0;
	else
	   case(data_nums)
	              1: test_data <= 8'h02;
	              2: test_data <= 8'h01;
	              3: test_data <= 8'h04;
	              4: test_data <= 8'h03;
	              5: test_data <= 8'h06;
	              6: test_data <= 8'h05;
	              7: test_data <= 8'h08;
	              8: test_data <= 8'h07;
	              9:  test_data <= 8'h04;
	              10: test_data <= 8'h00;
	              11: test_data <= 8'h05;
	              12: test_data <= 8'h03;
	              13: test_data <= 8'd22;
	              14: test_data <= 8'h0;
	              15: test_data <= 8'hb;
	              16: test_data <= 8'hc;
	              default:  test_data <=   data_nums;
	    endcase
	       
	assign Bkp_Ready_o = (cnt1 == 'd5) ? 1'b1 : 1'b0;
	assign Bkp_Data_o  = test_data;
