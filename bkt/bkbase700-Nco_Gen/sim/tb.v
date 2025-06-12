	/*********************************Nco_Gen bk_base:700*********************************************/
localparam base700_point = 700;


    parameter D0_if   = 64'd323905387276;
	parameter D1_if   = 64'd3239113633268;
	parameter D2_if   = 64'd3239173394401;
	parameter D3_if   = 64'd323905387276;
	parameter D4_if   = 64'd323905387276;
	parameter D5_if   = 64'd323905387276;
	parameter D6_if   = 64'd323905387276;
	parameter D7_if   = 64'd323905387276;
	parameter D8_if   = 64'd323905387276;
	parameter D9_if   = 64'd323905387276;
	

	reg [31:0] bk_index_base700;
	always @(*)
	begin
        if(bk_index_p1 >= base700_point + 1 && bk_index_p1 <= base700_point + 1)     
            bk_index_base700 <= 701;
        else if(bk_index_p1 >= base700_point +2  && bk_index_p1 <= base700_point +2)   
            bk_index_base700 <= 702;
		else if(bk_index_p1 >= base700_point +3  && bk_index_p1 <= base700_point +22)   
            bk_index_base700 <= 703;
		else if(bk_index_p1 >= base700_point +23  && bk_index_p1 <= base700_point +422)   
            bk_index_base700 <= 704;
		else if(bk_index_p1 >= base700_point + 423  && bk_index_p1 <= base700_point +424)   
            bk_index_base700 <= 705;
		else if(bk_index_p1 >= base700_point + 425  && bk_index_p1 <= base700_point +425)   
            bk_index_base700 <= 700;
        else
            bk_index_base700 <= 'd0;    
	end
	
	
wire [31:0] base700_ch_index;
assign base700_ch_index = (bk_index_p1 - base700_point-23) %20;

	
	reg [31:0] bk_data_base700;
	always @(*)
	begin
        if(bk_index_base700 == 700)           //Nco_Gen_DESR   
			bk_data_base700 <= 1; 
        else if(bk_index_base700 == 701)      //Nco_DDS_scale      
            bk_data_base700 <= 1; 
		else if(bk_index_base700 == 702)      //Nco_CH_enable     
            bk_data_base700 <= 'hfffff; 
		else if(bk_index_base700 == 703)     //init_phase
			begin
				bk_data_base700 <= 'd0;
			end 
		else if(bk_index_base700 == 704)      //Nco_DDS_D    
            begin
				case(base700_ch_index)
					0:   bk_data_base700 <= D0_if[63:32]; //CH 0 
					1:   bk_data_base700 <= D0_if[31:0];
					2:   bk_data_base700 <= D1_if[63:32]; //CH 1 
					3:   bk_data_base700 <= D1_if[31:0]; 
					4:   bk_data_base700 <= D2_if[63:32]; //CH 2 
					5:   bk_data_base700 <= D2_if[31:0]; 
					6:   bk_data_base700 <= D3_if[63:32]; //CH 3 
					7:   bk_data_base700 <= D3_if[31:0]; 
					8:   bk_data_base700 <= D4_if[63:32]; //CH 4 
					9:   bk_data_base700 <= D4_if[31:0]; 
					10:  bk_data_base700 <= D5_if[63:32]; //CH 5 
					11:  bk_data_base700 <= D5_if[31:0]; 
					12:  bk_data_base700 <= D6_if[63:32]; //CH 6 
					13:  bk_data_base700 <= D6_if[31:0]; 
					14:  bk_data_base700 <= D7_if[63:32]; //CH 7 
					15:  bk_data_base700 <= D7_if[31:0]; 
					16:  bk_data_base700 <= D8_if[63:32]; //CH 8 
					17:  bk_data_base700 <= D8_if[31:0]; 
					18:  bk_data_base700 <= D9_if[63:32]; //CH 9 
					19:  bk_data_base700 <= D9_if[31:0]; 
					default:  bk_data_base700 <= 'd0;     // other ch  not set 
				endcase
			end
		else if(bk_index_base700 == 705)    //Nco_D_req_done       
			begin
				if(bk_index_p1 == 439)
					bk_data_base700 <= 1'd1;
				else
					bk_data_base700 <= 1'd0;
			end 
        else
            bk_data_base700 <= 'd0;    
	end	
	