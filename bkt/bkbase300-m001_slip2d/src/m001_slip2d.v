`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/04 22:21:21
// Design Name: 
// Module Name: m001_slip2d
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
   /*********************************m001_slip2d bk_base:300*********************************************/
	//  ascripiton: shell
	//  type: RTL
	//  function:  run in 100M clock this module is used for m001 series.
	//  update:  2025.3.12
	//  0			bit3-0					DESR    		           enable   
	//  1			bit-7-0					radar_pics			       max support 256 pics radar
	//  2			bit31-0					horizontal_slip_times      -
	//  3			bit31-0					vertical_slip_times        -
	//  4			bit31-0					h_pwm_freq 				   HZ
	//  5			bit31-0					h_radar_ss_time            MS
	//  6			bit31-0					h_motor_step_scale         0.2 mm / h_mini_step_nums
	//  7			bit31-0					h_mini_step_nums           -
	//  8			bit31-0					v_pwm_freq				   HZ
	//  9			bit31-0					v_motor_wait_time		   MS
    //  10			bit31-0					v_motor_step_scale         0.2 mm / v_mini_step_nums
	//  11			bit31-0					v_mini_step_nums		   -
    //  12			bit0				    h_sw_dir_init			   0 or 1 only can be change before excute_start
	//  13			bit0					v_sw_dir				   0 or 1 can be change at any time
    //  14			bit0					excute_start			   -
	//  15			bit0					force_stop				   -
	//  16          bit7-0                  extern_ctrl                extern start\swtich\up\dowm\left\right\stop
	 	                                                                //	start       = 8'b00010001;
     	                                                                //	switch      = 8'b00010010;
     	                                                                //	up          = 8'b00010011;
     	                                                                //	down        = 8'b00010100;
     	                                                                //	left        = 8'b00010101;
     	                                                                //	right       = 8'b00010110;
     	                                                                //	stop        = 8'b00100000;
	//            bit0-31                 bk_status			     //
                                                                     //bit3-0  4'b0001  indicate module has work finished; 
                                                                     //bit3-0  4'b0000  indicates module ready to work;
                                                                     //bit7-4  4'b1111  work error
                                                                     //bit7-4  4'b0001  module is working
                                                                     //bit7-4  4'b0000  modue is free 




module m001_slip2d
 #(
        //sys params
		parameter BKP_BASE_index = 300,
        parameter integer sys_freq = 100_000_000
    )
    (
        input wire clk,
        input wire rst_n,
		// S BKP cfg
		input  wire                   bkt_ready_i,
		input  wire            [31:0] bkt_index_i,
		input  wire            [31:0] bkt_data_i,  
		

	    output wire h_dir,
		output wire h_pwm,
		output wire v_dir,
		output wire v_pwm,
    
        output wire radar_ss,
        
        
        output wire [31:0] bk_status
    );
  
localparam  ctrl_state0 = 4'b0001; 
localparam  ctrl_state1 = 4'b0010; 
localparam  ctrl_state2 = 4'b0100; 
localparam  ctrl_state3 = 4'b1000; 

localparam  cnt0_delay =  16'd249;
localparam  cnt1_delay =  16'd249;


	/********* gen code start*********/
    reg BKPcfg_Ready_d1,BKPcfg_Ready_d2;
    always @(posedge clk)
    if(!rst_n)
    begin
        BKPcfg_Ready_d1 <= 1'b0;
        BKPcfg_Ready_d2 <= 1'b0;
    end
     else
    begin
        BKPcfg_Ready_d1 <= bkt_ready_i;
        BKPcfg_Ready_d2 <= BKPcfg_Ready_d1;
    end 

    wire BkpCfg_Ready_pedge;
    assign BkpCfg_Ready_pedge = BKPcfg_Ready_d1 & ~BKPcfg_Ready_d2;

    wire [31:0] bk_data_index;
    assign bk_data_index = bkt_index_i;
    wire [31:0] bk_data;
    assign bk_data = bkt_data_i;

	reg  DESR;
	always @(posedge clk )
    if(!rst_n)
		 DESR <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index)
		 DESR <= bk_data[0];
	else
		 DESR <=  DESR;

	reg [7:0]radar_pics;
	always @(posedge clk )
    if(!rst_n)
		radar_pics <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 1)
		radar_pics <= bk_data[7:0];
	else
		radar_pics <= radar_pics;

	reg [31:0] horizontal_slip_times;
	always @(posedge clk )
    if(!rst_n)
		horizontal_slip_times <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 2)
		horizontal_slip_times <= bk_data;
	else
		horizontal_slip_times <= horizontal_slip_times;

	reg [31:0] vertical_slip_times;
	always @(posedge clk )
    if(!rst_n)
		vertical_slip_times <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 3)
		vertical_slip_times <= bk_data;
	else
		vertical_slip_times <= vertical_slip_times;

	reg [31:0] h_pwm_freq;
	always @(posedge clk )
    if(!rst_n)
		h_pwm_freq <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 4)
		h_pwm_freq <= bk_data;
	else
		h_pwm_freq <= h_pwm_freq;

	reg [31:0] h_radar_ss_time;
	always @(posedge clk )
    if(!rst_n)
		h_radar_ss_time <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 5)
		h_radar_ss_time <= bk_data;
	else
		h_radar_ss_time <= h_radar_ss_time;

	reg [31:0] h_motor_step_scale;
	always @(posedge clk )
    if(!rst_n)
		h_motor_step_scale <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 6)
		h_motor_step_scale <= bk_data;
	else
		h_motor_step_scale <= h_motor_step_scale;

	reg  [31:0] h_mini_step_nums;
	always @(posedge clk )
    if(!rst_n)
		h_mini_step_nums <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 7)
		h_mini_step_nums <= bk_data;
	else
		h_mini_step_nums <= h_mini_step_nums;

	reg [31:0] v_pwm_freq;
	always @(posedge clk )
    if(!rst_n)
		v_pwm_freq <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 8)
		v_pwm_freq <= bk_data;
	else
		v_pwm_freq <= v_pwm_freq;

	reg  [31:0] v_motor_wait_time;
	always @(posedge clk )
    if(!rst_n)
		v_motor_wait_time <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 9)
		v_motor_wait_time <= bk_data;
	else
		v_motor_wait_time <= v_motor_wait_time;

	reg [31:0] v_motor_step_scale;
	always @(posedge clk )
    if(!rst_n)
		v_motor_step_scale <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 10)
		v_motor_step_scale <= bk_data;
	else
		v_motor_step_scale <= v_motor_step_scale;

	reg [31:0] v_mini_step_nums;
	always @(posedge clk )
    if(!rst_n)
		v_mini_step_nums <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 11)
		v_mini_step_nums <= bk_data;
	else
		v_mini_step_nums <= v_mini_step_nums;

	reg h_sw_dir_init;
	always @(posedge clk )
    if(!rst_n)
		h_sw_dir_init <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 12)
		h_sw_dir_init <= bk_data[0];
	else
		h_sw_dir_init <= h_sw_dir_init;

	reg v_sw_dir;
	always @(posedge clk )
    if(!rst_n)
		v_sw_dir <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 13)
		v_sw_dir <= bk_data[0];
	else
		v_sw_dir <= v_sw_dir;		

	reg [1:0] excute_start;
	always @(posedge clk )
    if(!rst_n)
		excute_start <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 14)
		excute_start <= bk_data[0];
	else
		excute_start <= excute_start;

	reg force_stop;
	always @(posedge clk )
    if(!rst_n)
		force_stop <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 15)
		force_stop <= bk_data[0];
	else
		force_stop <= force_stop;		
		

	reg [7:0] extern_ctrl;
	always @(posedge clk )
    if(!rst_n)
		extern_ctrl <= 'd0;
	else if(bkt_ready_i && bk_data_index == BKP_BASE_index + 16)
		extern_ctrl <= bk_data[7:0];
	else
		extern_ctrl <= extern_ctrl;
    
reg ctrl_start_z1;
reg ctrl_start_z2;
always @(posedge clk )
if(!rst_n)
    begin
        ctrl_start_z1 <= 1'b0;
        ctrl_start_z2 <= 1'b0;
    end
    
else
    begin
        ctrl_start_z1 <= excute_start;
        ctrl_start_z2 <= ctrl_start_z1;
    end
    
    
wire ctrl_start_pedge;
assign ctrl_start_pedge = ctrl_start_z1 & ~ctrl_start_z2;


    
reg force_stop_z1;
reg force_stop_z2;
always @(posedge clk )
if(!rst_n)
    begin
        force_stop_z1 <= 1'b0;
        force_stop_z2 <= 1'b0;
    end
    
else
    begin
        force_stop_z1 <= force_stop;
        force_stop_z2 <= force_stop_z1;
    end
    
    
wire force_stop_pedge;
assign force_stop_pedge = force_stop_z1 & ~force_stop_z2;





reg [3:0] ctrl_state;
reg [15:0] vertical_nums;
reg cnt0_gate;
reg cnt1_gate;
reg sys_run;
reg event_done_p;
always @(posedge clk )
if(!rst_n)
   begin
        ctrl_state <= ctrl_state0;   
        cnt0_gate  <= 1'b0;
        cnt1_gate  <= 1'b0;
        sys_run <= 1'b0;
        vertical_nums <= 16'd0;
        event_done_p <= 1'b0;
   end
else if (force_stop_pedge)  
    begin
        ctrl_state <= ctrl_state0;   
        cnt0_gate  <= 1'b0;
        cnt1_gate  <= 1'b0;
        sys_run <= 1'b0;
        vertical_nums <= 16'd0;
        event_done_p <= 1'b0;
    end     
else
    case(ctrl_state)
        ctrl_state0:
            begin 
                if(ctrl_start_pedge)
                    begin
                         if(h_mini_step_nums > 0)
                            begin
                                ctrl_state <= ctrl_state1;   
                                cnt0_gate  <= 1'b1;
                                cnt1_gate  <= 1'b0;
                                sys_run <= 1'b1;
                            end
                          else
                            begin
                                ctrl_state <= ctrl_state;
                            end 
                    end 
                else
                    begin
                         ctrl_state <= ctrl_state;   
                         cnt0_gate  <= 1'b0;
                         cnt1_gate  <= 1'b0;
                    end
            end 
         ctrl_state1:
            begin 
                if(cnt0 == cnt0_delay)
                    begin
                        cnt0_gate <= 1'b0; 
                        ctrl_state <= ctrl_state;   
                    end 
                 else if(h_event_done)
                    begin
                        if(v_mini_step_nums == 0)   // v is not enable
                            begin
                                 ctrl_state <= ctrl_state3;
                                 event_done_p <= 1'b1;
                            end
                        else if(vertical_nums == vertical_slip_times-'d1)
                            begin
                                 cnt1_gate <= 1'b0; 
                                 ctrl_state <= ctrl_state2;
                                 event_done_p <= 1'b0;
                            end
                         else
                            begin
                                 cnt1_gate <= 1'b1; 
                                 ctrl_state <= ctrl_state2;
                                 event_done_p <= 1'b0;
                            end
                    end 
                else
                    begin 
                        ctrl_state <= ctrl_state;   
                    end
            end 
         ctrl_state2:
            begin 
                 if(cnt1 == cnt1_delay)
                    begin
                        cnt1_gate <= 1'b0; 
                        ctrl_state <= ctrl_state;   
                    end 
                 else if(v_event_done)
                    begin
                        if(vertical_nums == vertical_slip_times-'d1)
                            begin 
                                cnt1_gate <= 1'b0; 
                                ctrl_state <= ctrl_state3;   
                                vertical_nums <= 16'd0;
                                event_done_p <= 1'b1;
                            end 
                         else 
                            begin 
                                cnt0_gate <= 1'b1; 
                                ctrl_state <= ctrl_state1;   
                                vertical_nums <= vertical_nums + 1'd1;
                                event_done_p <= 1'b0;
                            end    
                    end 
                else
                    begin 
                        ctrl_state <= ctrl_state;   
                    end
           
            end 
          ctrl_state3:
            begin
                 ctrl_state <= ctrl_state0;
                 vertical_nums  <= 16'd0;   
                 cnt0_gate  <= 1'b0;
                 cnt1_gate  <= 1'b0;
                 sys_run <= 1'b0;
                 event_done_p <= 1'b0;
            end 
          default:
            begin 
                 ctrl_state <= ctrl_state0;
                 vertical_nums  <= 16'd0;   
                 cnt0_gate  <= 1'b0;
                 cnt1_gate  <= 1'b0;
                 sys_run <= 1'b0;
            end 
    endcase
    
reg [15:0] cnt0;
always @(posedge clk )
if(!rst_n)
    cnt0 <= 1'b0;
else if(cnt0_gate)
    cnt0 <= cnt0 + 1'd1;
else
    cnt0 <= 16'd0;
    
reg [15:0] cnt1;
always @(posedge clk )
if(!rst_n)
    cnt1 <= 1'b0;
else if(cnt1_gate)
    cnt1 <= cnt1 + 1'd1;
else
    cnt1 <= 16'd0;   
   
wire h_sw_dir_p;    
assign h_sw_dir_p = (h_sw_dir_init == 1'b0) ? vertical_nums[0] : !vertical_nums[0];


wire horizontal_start;
assign horizontal_start = cnt0_gate;
wire vertical_start;
assign vertical_start = cnt1_gate;


reg cnt2_gate;
always @(posedge clk )
if(!rst_n)
    cnt2_gate <= 1'b0;
else if(bkt_ready_i)
    cnt2_gate <= 1'd1;
else if(cnt2 == 100)
    cnt2_gate <= 1'b0;
else
    cnt2_gate <= cnt2_gate;

reg [7:0] cnt2;
always @(posedge clk )
if(!rst_n)
    cnt2 <= 1'b0;
else if(cnt2_gate)
    cnt2 <= cnt2 + 1'd1;
else
    cnt2 <= 16'd0;

wire data_update;
assign data_update = cnt2_gate;
wire h_pwm_dir,h_pwm_pulse,v_pwm_dir,v_pwm_pulse;
wire h_event_done;
radar_h_motor_ctrl
    u2(
    .clk(clk),
    .rst_n(rst_n),
        //cfg
        .data_update(data_update),
        .h_pwm_freq(h_pwm_freq),
        .h_radar_ss_time(h_radar_ss_time),     // ms
		.h_motor_step_scale(h_motor_step_scale),  //  0.2mm / pwm_nums
		.h_mini_step_nums(h_mini_step_nums),    //  mini_step_len = 0.5 * mini_step_nums
		.horizontal_slip_times(horizontal_slip_times),        //mm
		.radar_npic(radar_pics),
        
    .horizontal_start_i(horizontal_start),
    .h_sw_dir(h_sw_dir_p), // direction
	.h_pwm_dir(h_pwm_dir),
    .h_pwm_pulse(h_pwm_pulse),
    .radar_ss(radar_ss),
    
    
    .force_stop(force_stop),
    .event_done(h_event_done)
    );     
	
wire v_event_done;
radar_v_motor_ctrl
    u3(
    .clk(clk),
    .rst_n(rst_n),
    
        //cfg
       .data_update(data_update),
       .v_pwm_freq(v_pwm_freq),
	   .v_motor_wait_time(v_motor_wait_time),
	   .v_motor_step_scale(v_motor_step_scale),  //  0.5mm / pwm_nums
	   .v_mini_step_nums(v_mini_step_nums),    //  mini_step_len = 0.5 * mini_step_nums
        
    .vertical_start_i(vertical_start),
    .v_sw_dir(v_sw_dir), // direction
	.v_pwm_dir(v_pwm_dir),
    .v_pwm_pulse(v_pwm_pulse),
    
    .force_stop(force_stop),
    .event_done(v_event_done)
    );   
 
reg [3:0] status_p1;
always @(posedge clk )
if(!rst_n)
    status_p1 <= 4'b0;
else if(force_stop == 1'b1)
    status_p1 <= 4'b0;
else if(event_done_p)
    status_p1 <= 4'b1;
else
    status_p1 <= status_p1;

reg BKPcfg_ready_d1,BKPcfg_ready_d2;
always @(posedge clk  )
if(!rst_n)
    begin
        BKPcfg_ready_d1 <= 1'd0;
        BKPcfg_ready_d2 <= 1'd0; 
    end 
 else
    begin
        BKPcfg_ready_d1 <= bkt_ready_i;
        BKPcfg_ready_d2 <= BKPcfg_ready_d1;  
    end  
 
wire  BKPuart_ready;
assign BKPuart_ready = (bk_data_index == BKP_BASE_index + 16) ? BKPcfg_ready_d2 : 1'b0;
wire [7:0]  BKPuart_data;
assign BKPuart_data = extern_ctrl;
wire [3:0] status_p2;
slip2d_ctrl u1(
     .clk(clk),
     .rst_n(rst_n),
  	// S BKP cfg
	.BKPuart_ready_i(BKPuart_ready),
	.BKPuart_data_i(BKPuart_data),

 
     .h_dir_i(h_pwm_dir),
     .h_pwm_i(h_pwm_pulse),
     .v_dir_i(v_pwm_dir),
     .v_pwm_i(v_pwm_pulse),
   
     .h_dir(h_dir),
     .h_pwm(h_pwm),
     .v_dir(v_dir),
     .v_pwm(v_pwm),
    
     .excute_start(excute_start),
     .status(status_p2)
    );
	
assign bk_status = {status_p2,status_p1};  

endmodule
