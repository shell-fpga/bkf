`timescale 1ns / 1ps

module radar_v_motor_ctrl #(
   parameter sys_freq = 100_000_000
)
    (
    input wire clk,
    input wire rst_n,
    
    //cfg info
        
    //sys params
    input wire  data_update,
//    input wire [31:0] horizontal_slip_time,    // this value must bigger than 1 !!!!!
//    input wire [31:0] vertical_slip_times, 
    //h dir params
    //input wire [31:0] h_pwm_freq,
    //input wire [31:0] h_radar_ss_time,     // ms
//	input wire [31:0] h_motor_step_speed,  // 0.2mm / pwm_nums
//	input wire [31:0] h_mini_step_nums,    // mini_step_len = 0.5 * mini_step_nums
	
    // v dir params 
    input wire [31:0] v_pwm_freq,
    input wire [31:0] v_motor_wait_time,  // ms
    input wire [31:0] v_motor_step_scale,  //  0.2mm / pwm_nums
    input wire [31:0] v_mini_step_nums,    //  mini_step_len = 0.2 * mini_step_nums 
     
    input wire force_stop,
    
    input wire vertical_start_i,
    input wire v_sw_dir, // direction
	output wire v_pwm_dir,
    output wire v_pwm_pulse,
        
    output wire event_done
    );
    

    
    localparam v_ctrl_state0 = 3'b001;
    localparam v_ctrl_state1 = 3'b010;
    localparam v_ctrl_state2 = 3'b100;
	
	//debug
//	localparam  delay_1us        =   sys_freq/1000;
//	localparam  delay_wait_nus   =   v_motor_wait_time;   // wait us
	
    localparam  delay_1us        =   sys_freq/1000000;
 

wire [31:0] delay_wait_nus_p;
mult_gen_0 mult0(
  .CLK(clk),  // input wire CLK
  .CE(data_update),
  .A(v_motor_wait_time),      // input wire [15 : 0] A
  .B(1000),      // input wire [15 : 0] B
  
  .P(delay_wait_nus_p)      // output wire [31 : 0] P
);
    
 wire [31:0]  delay_wait_nus;   // wait us
 assign delay_wait_nus = delay_wait_nus_p;
 
 
 wire dvi2_s_axis_divisor_tready,dvi2_s_axis_dividend_tready,dvi2_m_axis_dout_tvalid;  
 wire [63:0] dvi2_m_axis_dout_tdata; 
 div_gen_0 dvi2(
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(data_update),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tready(dvi2_s_axis_divisor_tready),    // output wire s_axis_divisor_tready
  .s_axis_divisor_tdata(v_pwm_freq),      // input wire [31 : 0] s_axis_divisor_tdata
  
  .s_axis_dividend_tvalid(data_update),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tready(dvi2_s_axis_dividend_tready),  // output wire s_axis_dividend_tready
  .s_axis_dividend_tdata(sys_freq),    // input wire [31 : 0] 
  
  .m_axis_dout_tvalid(dvi2_m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dvi2_m_axis_dout_tdata)            // output wire [63 : 0] m_axis_dout_tdata
);
    
 wire [31:0]  cnt0_delay;   // wait us
 assign cnt0_delay = dvi2_m_axis_dout_tdata[63:32];

wire [31:0]  cnt1_delay;
mult_gen_0 mult1 (
  .CLK(clk),  // input wire CLK
  .CE(data_update),
  .A(v_mini_step_nums),      // input wire [15 : 0] A
  .B(v_motor_step_scale),      // input wire [15 : 0] B
  .P(cnt1_delay)      // output wire [31 : 0] P
);

wire [31:0]  cnt2_delay;
mult_gen_0 mult2(
  .CLK(clk),  // input wire CLK
  .CE(data_update),
  .A(delay_1us),      // input wire [15 : 0] A
  .B(delay_wait_nus),      // input wire [15 : 0] B
  .P(cnt2_delay)      // output wire [31 : 0] P
);

    
reg vertical_start_z1;
reg vertical_start_z2;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	begin
		vertical_start_z1 <= 1'b0;
		vertical_start_z2 <= 1'b0;
	end
else
	begin 
		vertical_start_z1 <= vertical_start_i;
		vertical_start_z2 <= vertical_start_z1;
	end 
wire vertical_start_pedge;
assign vertical_start_pedge = vertical_start_z1 & ~vertical_start_z2;


    
    
reg [3:0] v_ctrl_state;
reg sys_gate;
reg cnt0_gate;
reg cnt1_gate;
reg cnt2_gate;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    begin 
        v_ctrl_state <= v_ctrl_state0;
	    sys_gate     <= 1'b0;	
	    cnt0_gate    <= 1'b0;
	    cnt1_gate    <= 1'b0;
	    cnt2_gate    <= 1'b0;
	end
else if (force_stop)  
    begin
        v_ctrl_state <= v_ctrl_state0;
	    sys_gate     <= 1'b0;	
	    cnt0_gate    <= 1'b0;
	    cnt1_gate    <= 1'b0;
	    cnt2_gate    <= 1'b0;
    end   	  
else
    case(v_ctrl_state)
        v_ctrl_state0: 
				begin
					if(vertical_start_pedge)
						begin
							v_ctrl_state <= v_ctrl_state1;
							sys_gate     <= 1'b1;
							cnt0_gate    <= 1'b1;
	                        cnt1_gate    <= 1'b1;
	                        cnt2_gate    <= 1'b0;
						end 
					else
						begin 
							v_ctrl_state <= v_ctrl_state;
							sys_gate     <= 1'b0;
						    cnt0_gate    <= 1'b0;
	                        cnt1_gate    <= 1'b0;
	                        cnt2_gate    <= 1'b0;
						end 
				end 
		v_ctrl_state1: 
			begin
				if(cnt1 == cnt1_delay - 1'd1 && cnt0 == cnt0_delay-1'd1)
						begin
							v_ctrl_state <= v_ctrl_state2;
							sys_gate     <= sys_gate;
							cnt0_gate    <= 1'b0;
	                        cnt1_gate    <= 1'b0;
	                        cnt2_gate    <= 1'b1;
						end 
					else
						begin 
							v_ctrl_state <= v_ctrl_state;
							sys_gate     <= sys_gate;
							cnt0_gate    <= cnt0_gate;
	                        cnt1_gate    <= cnt1_gate;
	                        cnt2_gate    <= cnt2_gate;
				end 
			end 
		v_ctrl_state2: 
			begin
			    if(cnt2 == cnt2_delay - 1'd1)    
			        begin
			            v_ctrl_state <= v_ctrl_state0;
				        sys_gate <= 1'b0;
				        cnt0_gate    <= 1'b0;
	                    cnt1_gate    <= 1'b0;
	                    cnt2_gate    <= 1'b0;
			        end 
			     else
			        begin 
			               v_ctrl_state <= v_ctrl_state;
						   sys_gate     <= sys_gate;
						   cnt0_gate    <= cnt0_gate;
	                       cnt1_gate    <= cnt1_gate;
	                       cnt2_gate    <= cnt2_gate;
			        end   
			end 
		default:
		    begin
				v_ctrl_state <= v_ctrl_state0;
				sys_gate <= 1'b0;
				cnt0_gate    <= 1'b0;
	            cnt1_gate    <= 1'b0;
	            cnt2_gate    <= 1'b0;
			end 
    endcase

reg [31:0] cnt0;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    cnt0 <= 32'd0;
else if(cnt0_gate)
	begin
		if(cnt0 == cnt0_delay - 1'd1)
			cnt0 <= 32'd0;
		else
			cnt0 <= cnt0 + 1'd1;
	end 
else
	cnt0 <= 32'd0;

reg [31:0] cnt1;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	cnt1 <= 32'd0;
else if(cnt1_gate)
	begin 
		if(cnt0 == cnt0_delay-1'd1)
			begin
				if(cnt1 == cnt1_delay-1'd1)
					cnt1<= 32'd0;
				else
					cnt1 <= cnt1 + 1'd1;
			end 
		else
			cnt1 <= cnt1;
	end 
else
	cnt1 <= 32'd0;
	
reg [31:0] cnt2;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	cnt2 <= 32'd0;
else if(cnt2_gate)
	begin 
	   if(cnt2 == cnt2_delay - 1'd1)
			cnt2<= 32'd0;
		else
			cnt2 <= cnt2 + 1'd1;
	end
else
	cnt2 <= 32'd0;  	
	
	
	
reg sys_gate_z1;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	sys_gate_z1 <= 32'd0;
else
	sys_gate_z1 <= sys_gate;

wire pwn_working_gate;
assign pwn_working_gate = cnt1_gate;

reg v_pwm_pulse_p;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	v_pwm_pulse_p <= 1'b0;
else if(pwn_working_gate)
	begin
		if((cnt0 == cnt0_delay-1'd1 || cnt0 == cnt0_delay/2-'d1))
			v_pwm_pulse_p <= ~v_pwm_pulse_p;
		else
			v_pwm_pulse_p <=  v_pwm_pulse_p;
	end 
else
	v_pwm_pulse_p <= 1'b0;
	
	
//reg v_pwm_pulse_p_z1;
//always @(posedge clk or negedge rst_n)
//if(!rst_n)
//	v_pwm_pulse_p_z1 <= 'd0;
//else
//    v_pwm_pulse_p_z1 <= v_pwm_pulse_p;	
	
//wire v_pwm_pulse_p_nedge;
//assign v_pwm_pulse_p_nedge = !v_pwm_pulse_p & v_pwm_pulse_p_z1;
	
wire sys_gate_nedge;
assign sys_gate_nedge = ~sys_gate & sys_gate_z1;

assign event_done = sys_gate_nedge;
assign v_pwm_dir = v_sw_dir;
assign v_pwm_pulse = v_pwm_pulse_p;

endmodule