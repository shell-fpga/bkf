`timescale 1ns / 1ps

module slip2d_ctrl(

    input rst_n,
    input clk,
  
  
  	// S BKP cfg
	input  wire                   BKPuart_ready_i,
	input  wire            [7:0] BKPuart_data_i,

  
    input h_dir_i,
    input h_pwm_i,
    input v_dir_i,
    input v_pwm_i,
   
    output h_dir,
    output h_pwm,
    output v_dir,
    output v_pwm,
    
    input  wire excute_start,
    
    output wire [3:0] status
    
    );
 

	localparam  cnt0_delay       =   sys_freq/pwm_freq;   // 

 
    parameter integer pwm_freq    = 10_000;
    parameter integer sys_freq       =50_000_000;  
    
    localparam start_p         = 8'b00010001;
    localparam switch_p      = 8'b00010010;
    
    localparam up_p             = 8'b00010011;
    localparam down_p        = 8'b00010100;
    localparam left_p            = 8'b00010101;
    localparam right_p         = 8'b00010110;
    
    localparam stop_p           = 8'b00100000;
    
    
    reg switch_r=0;
    reg start_r=0;
    

    
    
    reg h_dir_r;
    reg h_pwm_r;
    reg v_dir_r;
    reg v_pwm_r;
   
    wire h_pwm_w;
    wire v_pwm_w;
    
    wire pwm_r;
    reg pwm_pulse_p;
  
    assign h_pwm_w=   (h_pwm_r) ? pwm_r:1'b0;
    assign v_pwm_w=   (v_pwm_r) ? pwm_r:1'b0;    
 
    assign h_dir=  (switch_r==1'b0) ? h_dir_r:h_dir_i;
    assign v_dir=  (switch_r==1'b0) ? v_dir_r:v_dir_i;   
    assign h_pwm=  (switch_r==1'b0) ? h_pwm_w:h_pwm_i;    
    assign v_pwm=  (switch_r==1'b0) ? v_pwm_w:v_pwm_i;  
    
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
	       begin
		      switch_r <=1'b0;
		      start_r <= 1'b0;
	       end
	    
        else if(BKPuart_ready_i)
            begin 
                case(BKPuart_data_i)
            start_p       : begin
            
                start_r <= 1'b1;
                h_dir_r<=1'b0;
                v_dir_r<=1'b0;
                h_pwm_r <=1'b0;
                v_pwm_r<=1'b0;

            end
            
            switch_p    :   begin
            
                switch_r <=~switch_r;
                h_dir_r<=1'b0;
                v_dir_r<=1'b0;
                h_pwm_r <=1'b0;
                v_pwm_r<=1'b0;
            end
            
            up_p           :    begin               
                h_dir_r<=1'b1;
                h_pwm_r<=1'b1;
            end
            
            down_p      :   begin
                h_dir_r<=1'b0;
                h_pwm_r<=1'b1;
            end
            
            left_p          :   begin
                v_dir_r<=1'b1;
                v_pwm_r<=1'b1;
            end
            
            right_p       : begin
                
                v_dir_r<=1'b0;
                v_pwm_r<=1'b1;
            
            end
            
            stop_p        :   begin
                start_r <= 1'b0;
                v_pwm_r <=1'b0;
                h_pwm_r <=1'b0;
            end
            
            default        :  begin
                v_pwm_r <=1'b0;
                h_pwm_r <=1'b0;
            end
                endcase
            end
        else
            start_r <= 1'b0;

 reg switch_r1;
    always @(posedge clk or negedge rst_n)
        if(!rst_n)  
            switch_r1 <= 1'b0;
        else
            switch_r1 <= switch_r;
            
    wire switch_nedge;
    assign switch_nedge = !switch_r & switch_r1;
    
    

//1m clock
reg [31:0] cnt0;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    cnt0 <= 32'd0;
else 
	begin
		if(cnt0 == cnt0_delay - 1'd1)
			cnt0 <= 32'd0;
		else
			cnt0 <= cnt0 + 1'd1;
	end 


always @(posedge clk or negedge rst_n)
if(!rst_n)begin
	pwm_pulse_p <= 1'b0;
	end
else 
	begin
		if((cnt0 == cnt0_delay-1'd1 || cnt0 == cnt0_delay/2-1'd1))begin
			pwm_pulse_p <= ~pwm_pulse_p;
			end
		else begin
			pwm_pulse_p <=  pwm_pulse_p;
			end
	end 

assign pwm_r = pwm_pulse_p;
        
        

localparam ctrl_state0 = 4'b0001;
localparam ctrl_state1 = 4'b0010;
localparam ctrl_state2 = 4'b0100;
localparam ctrl_state3 = 4'b1000;		
		
reg [4:0] ctrl_state;
reg start_done_p;
reg error_p;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	begin
		ctrl_state <= ctrl_state0;
		start_done_p <= 1'b0;
		error_p <= 1'b0;
	end
else if(excute_start == 1'b0) 
	begin
		ctrl_state <= ctrl_state0;
		start_done_p <= 1'b0;
		error_p <= 1'b0;
	end 
else	
	begin
		case(ctrl_state)
			ctrl_state0:
				begin
					if(start_r && switch_r)
						begin
							ctrl_state <= ctrl_state1;
							start_done_p <= 1'b1;
							error_p <= 1'b0;
						end
					else	
						begin
							ctrl_state <= ctrl_state;
							start_done_p <= 1'b0;
							error_p <= 1'b0;
						end
				end 
			ctrl_state1:
				begin
					if(switch_nedge)
						begin
							ctrl_state <= ctrl_state2;
							start_done_p <= 1'b0;
							error_p <= 1'b1;
						end
					else	
						begin
							ctrl_state <= ctrl_state;
							start_done_p <= 1'b0;
							error_p <= 1'b0;
						end
				end 
			ctrl_state2:
				begin
					ctrl_state <= ctrl_state0;
					start_done_p <= 1'b0;
					error_p <= 1'b0;
				end 
			default:
				begin
					ctrl_state <= ctrl_state0;
					start_done_p <= 1'b0;
					error_p <= 1'b0;
				end 
		endcase
	end 
	
	
reg [3:0] status_p;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    status_p <= 'd0;
else if(error_p)
    status_p <= 4'b1111;
else if(start_done_p)
    status_p <= 4'b1;
else if(stop_p)
    status_p <= 4'b0;
else if(excute_start == 1'b0) 
    status_p <= 1'b0;
else
    status_p <=status_p;
    
assign status = status_p;	

endmodule