`timescale 1ns / 1ps

module radar_h_motor_ctrl #(
    parameter sys_freq = 100_000_000
)
    (
    input wire clk,
    input wire rst_n,
    
    
     //sys params
    input wire data_update,
    input wire [31:0] horizontal_slip_times,    // this value must bigger than 1 !!!!!
    //    wire [31:0] vertical_slip_times = 16'd32; 
    //h dir params
    input wire [31:0] h_pwm_freq,
    input wire [31:0] h_radar_ss_time,     // ms
	input wire [31:0] h_motor_step_scale,  // 0.2mm / pwm_nums
	input wire [31:0] h_mini_step_nums,     // mini_step_len = 0.5 * mini_step_nums
	input  wire [7:0]  radar_npic,
    // v dir params 
    //    wire [31:0] v_pwm_freq = 32'd10_000;
    //    wire [31:0] v_motor_wait_time = 32'd2;  // ms
    //    wire [31:0] v_motor_step_speed = 16'd128;  //  0.2mm / pwm_nums
    //    wire [31:0] v_mini_step_nums  = 16'd48;    //  mini_step_len = 0.2 * mini_step_nums  
    
    input wire force_stop,
    
    input wire horizontal_start_i,
    input wire h_sw_dir, // direction
	output wire h_pwm_dir,
    output wire h_pwm_pulse,
    output wire radar_ss,
    
    output wire event_done
    );
    
    
    

    
  
    localparam h_ctrl_state0 = 3'b001;
    localparam h_ctrl_state1 = 3'b010;
    localparam h_ctrl_state2 = 3'b100;
	
    localparam  delay_1us  =   sys_freq/1000000;

	
wire [31:0] delay_wait_nus_p;
mult_gen_0 mult0(
  .CLK(clk),  // input wire CLK
  .CE(data_update),
  .A(h_radar_ss_time),      // input wire [15 : 0] A
  //user for debnug
//  .B(100),      // input wire [15 : 0] B
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
  .s_axis_divisor_tdata(h_pwm_freq),      // input wire [31 : 0] s_axis_divisor_tdata
  
  .s_axis_dividend_tvalid(data_update),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tready(dvi2_s_axis_dividend_tready),  // output wire s_axis_dividend_tready
  .s_axis_dividend_tdata(sys_freq),    // input wire [31 : 0] 
  
  .m_axis_dout_tvalid(dvi2_m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dvi2_m_axis_dout_tdata)            // output wire [63 : 0] m_axis_dout_tdata
);
    
 wire [31:0]  cnt0_delay;   // wait us
 assign cnt0_delay = dvi2_m_axis_dout_tdata[63:32];

wire [31:0]  cnt1_delay_p1;
mult_gen_0 mult1 (
  .CLK(clk),  // input wire CLK
  .CE(data_update),
  .A(h_mini_step_nums),      // input wire [15 : 0] A
  .B(h_motor_step_scale),      // input wire [15 : 0] B
  .P(cnt1_delay_p1)      // output wire [31 : 0] P
);
wire  [31:0] cnt1_delay;
assign cnt1_delay = cnt1_delay_p1 + 1'd1;



wire [31:0]  cnt2_delay;
mult_gen_0 mult2(
  .CLK(clk),  // input wire CLK
  .CE(data_update),
  .A(delay_1us),      // input wire [15 : 0] A
  .B(delay_wait_nus),      // input wire [15 : 0] B
  
  .P(cnt2_delay)      // output wire [31 : 0] P
);

wire [31:0] cnt3_delay;   // 1 is  neccessary  	
assign cnt3_delay       =   horizontal_slip_times+1'd1;
	
reg horizontal_start_z1;
reg horizontal_start_z2;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	begin
		horizontal_start_z1 <= 1'b0;
		horizontal_start_z2 <= 1'b0;
	end
else
	begin 
		horizontal_start_z1 <= horizontal_start_i;
		horizontal_start_z2 <= horizontal_start_z1;
	end 
wire horizontal_start_pedge;
assign horizontal_start_pedge = horizontal_start_z1 & ~horizontal_start_z2;


    
    
reg [3:0] h_ctrl_state;
reg sys_gate;
reg cnt0_gate;
reg cnt1_gate;
reg cnt2_gate;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    begin 
        h_ctrl_state <= h_ctrl_state0;
	    sys_gate     <= 1'b0;	
	    cnt0_gate    <= 1'b0;
	    cnt1_gate    <= 1'b0;
	    cnt2_gate    <= 1'b0;
	end
else if (force_stop)  
    begin
        h_ctrl_state <= h_ctrl_state0;
	    sys_gate     <= 1'b0;	
	    cnt0_gate    <= 1'b0;
	    cnt1_gate    <= 1'b0;
	    cnt2_gate    <= 1'b0;
    end   	 
else
    case(h_ctrl_state)
        h_ctrl_state0: 
				begin
					if(horizontal_start_pedge)
						begin
							h_ctrl_state <= h_ctrl_state1;
							sys_gate     <= 1'b1;
							cnt0_gate    <= 1'b1;
	                        cnt1_gate    <= 1'b1;
	                        cnt2_gate    <= 1'b0;
						end 
					else
						begin 
							h_ctrl_state <= h_ctrl_state;
							sys_gate     <= 1'b0;
						    cnt0_gate    <= 1'b0;
	                        cnt1_gate    <= 1'b0;
	                        cnt2_gate    <= 1'b0;
						end 
				end 
		h_ctrl_state1: 
			begin
				if(cnt1 == cnt1_delay - 1'd1 && cnt0 == cnt0_delay - 1'd1)
						begin
							h_ctrl_state <= h_ctrl_state2;
							sys_gate     <= sys_gate;
							cnt0_gate    <= 1'b0;
	                        cnt1_gate    <= 1'b0;
	                        cnt2_gate    <= 1'b1;
						end 
					else
						begin 
							h_ctrl_state <= h_ctrl_state;
							sys_gate     <= sys_gate;
							cnt0_gate    <= cnt0_gate;
	                        cnt1_gate    <= cnt1_gate;
	                        cnt2_gate    <= cnt2_gate;
				end 
			end 
		h_ctrl_state2: 
			begin
				if(cnt2 == cnt2_delay - 1'd1)
						begin
						    if(cnt3 == cnt3_delay-1'd1)
						      begin 
						          h_ctrl_state <= h_ctrl_state0;
							      sys_gate     <= 1'b0;
							      cnt0_gate    <= 1'b0;
	                              cnt1_gate    <= 1'b0;
	                              cnt2_gate    <= 1'b0;
						      end 
							else
							   begin
							      h_ctrl_state <= h_ctrl_state1;
							      sys_gate     <= sys_gate;
							      cnt0_gate    <= 1'b1;
	                              cnt1_gate    <= 1'b1;
	                              cnt2_gate    <= 1'b0;
							   end 
						end 
					else
						begin 
							h_ctrl_state <= h_ctrl_state;
							sys_gate     <= sys_gate;
							cnt0_gate    <= cnt0_gate;
	                        cnt1_gate    <= cnt1_gate;
	                        cnt2_gate    <= cnt2_gate;
				        end 
			end 
		default:
		    begin
				h_ctrl_state <= h_ctrl_state0;
				sys_gate     <= 1'b0;
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

//reg  cnt2_gate_z1;
//always @(posedge clk or negedge rst_n)
//if(!rst_n)
//    cnt2_gate_z1 <= 1'b0;
//else
//    cnt2_gate_z1 <= cnt2_gate;
    
//wire cnt2_gate_nedge;
//assign 	cnt2_gate_nedge = !cnt2_gate & cnt2_gate_z1;
	
reg [31:0] cnt3;
always @(posedge clk or negedge rst_n)
if(!rst_n)
    cnt3 <= 32'd0;
else if(sys_gate)
    begin
        if(cnt2 == cnt2_delay - 1'd1)
            begin
                if(cnt3 == cnt3_delay -1'd1)
                    cnt3 <= 32'd0;
                else
                    cnt3 <= cnt3 + 1'd1; 
            end 
        else
            cnt3 <= cnt3;
    end 
 else
    cnt3 <= 32'd0;
    	
reg sys_gate_z1;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	sys_gate_z1 <= 32'd0;
else
	sys_gate_z1 <= sys_gate;

wire pwn_working_gate;
assign pwn_working_gate = cnt1_gate;

reg h_pwm_pulse_p;
always @(posedge clk or negedge rst_n)
if(!rst_n)
	h_pwm_pulse_p <= 1'b0;
else if(pwn_working_gate)
	begin
		if((cnt0 == cnt0_delay-1'd1 || cnt0 == cnt0_delay/2-1'd1))
			h_pwm_pulse_p <= ~h_pwm_pulse_p;
		else
			h_pwm_pulse_p <=  h_pwm_pulse_p;
	end 
else
	h_pwm_pulse_p <= 1'b0;
	
//reg h_pwm_pulse_p_z1;
//always @(posedge clk or negedge rst_n)
//if(!rst_n)
//	h_pwm_pulse_p_z1 <= 'd0;
//else
//    h_pwm_pulse_p_z1 <= h_pwm_pulse_p;
    
//wire h_pwm_pulse_p_nedge;
//assign h_pwm_pulse_p_nedge = !h_pwm_pulse_p & h_pwm_pulse_p_z1;
	
wire sys_gate_nedge;
assign sys_gate_nedge = ~sys_gate & sys_gate_z1;

wire [31:0] npic_cnt2_delay;
assign npic_cnt2_delay = (cnt2_delay>>(radar_npic-1));

reg [31:0]  npic_cnt2_bias; 

always@(posedge clk) begin
    if(cnt2 == 0) begin
        npic_cnt2_bias <= 0;
    end
    else begin
        if(npic_cnt2_bias == npic_cnt2_delay - 32'd1) begin
            npic_cnt2_bias <= 0;
        end
        else begin
            npic_cnt2_bias <= npic_cnt2_bias + 32'd1;
        end
    end
end



wire singal_rardar_stop;
assign singal_rardar_stop = (npic_cnt2_bias >= (npic_cnt2_delay>>3)) && (npic_cnt2_bias < (npic_cnt2_delay>>2)) ?  1'b1  : 1'b0;

wire singal_rardar_start;
assign singal_rardar_start = (npic_cnt2_bias >= (npic_cnt2_delay -(npic_cnt2_delay>>2))) && (npic_cnt2_bias < (npic_cnt2_delay -(npic_cnt2_delay>>3))) ?  1'b1  : 1'b0;


wire singal_rardar_ss;
assign singal_rardar_ss = singal_rardar_stop;

wire radar_ss_p;
assign radar_ss_p = singal_rardar_stop | singal_rardar_start;
//assign radar_ss_p = singal_rardar_ss;
wire last_part;
assign last_part = (cnt3 == cnt3_delay-1'd1) ? 1'b1 : 1'b0;
 
assign event_done  = sys_gate_nedge;
assign h_pwm_dir   = h_sw_dir;
assign h_pwm_pulse = h_pwm_pulse_p;
assign radar_ss    = (last_part == 1'b0) ?  radar_ss_p : 1'b0;




endmodule

	
