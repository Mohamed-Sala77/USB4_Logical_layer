`timescale 1fs/1fs


//`include "testbench.sv"
//import testbench::*;

//include the transaction classes
`include "elec_layer_tr.svh"
`include "config_space_pkg.sv"
`include "upper_layer_tr.svh"

//include the memory classes
`include "env_cfg_class.sv"

//include the driver classes
`include "elec_layer_driver.svh"
`include "config _driver.sv"
`include "up_driver.sv"

// REFERENCE MODEL
	`include "configuration_space_reference.sv"
	`include "elec_reference.sv"
	`include "upper_reference.sv"
	`include"Reference_model_wrapper.sv"
	/*`include "int_packet.sv"
	`include "R_Mod_extentions.sv"
	`include "my_memory.sv"
	`include "primary_steps.sv"

	`include "phase1.sv"
	`include "phase2.sv"
	`include "phase3.sv"
	`include "phase4.sv"
	`include "phase5.sv"

	`include "ref_model.sv"*/


//include the generator classes
`include "elec_layer_generator.svh"
`include "up_stimulus_generator.sv"
`include "config_generator.sv"

//include the monitor classes
`include "elec_layer_monitor.svh"
`include "up_monitor.sv"
`include "config_monitor.sv"

//include the agent classes
`include "elec_layer_agent.svh"
`include "up_agent.sv"
`include "config_agent.sv"

//include the scoreboard classes
`include "elec_layer_scoreboard.svh"
`include "up_scoreboard.sv"
`include "config_scoreboard.sv"

//include the virtual sequence classes
`include "virtual_sequence.sv"


//include the test environment classes
`include "Env.svh"

//include the test classes
`include "TEST.sv"

//include innterfaces
`include "config_space_if.sv"
`include "upper_layer_if.sv"
`include "electrical_layer_if.sv"





module Ai_top;

	logic SystemClock; logic Rx_Clock;  //
	logic local_clk;
	logic SB_clock;
	logic gen2_lane_clk, gen3_lane_clk, gen4_lane_clk;
	logic gen2_fsm_clk, gen3_fsm_clk, gen4_fsm_clk;
	logic SystemReset;

	parameter Sys_clock_cycle = 1 * 10**6; parameter Rx_clock_cycle = 50;

	parameter [63:0] SB_freq = 1 * 10**6;
	parameter [63:0] freq_9_697 = 9.697 * 10 ** 9;		//9.697 GHz
	parameter [63:0] freq_19_394 = 19.394 * 10 ** 9;	//19.394 GHz
	parameter [63:0] freq_10 = 64'd10 * 10 ** 9;		//10 GHz
	parameter [63:0] freq_20 = 64'd20 * 10 ** 9;		//20 GHz
	parameter [63:0] freq_40 = 40 * 10 ** 9;			//40 GHz
	parameter [63:0] freq_80 = 80 * 10 ** 9;			//80 GHz
	
    //Reset generation
	task reset();
		 SystemReset = 0;
		 #(3*(1/SB_freq)); // 3 cycles of SB clock
		SystemReset = 1;
		
		
	endtask




config_space_if      c_if(SystemClock,gen4_fsm_clk);
electrical_layer_if  e_if(SystemClock,SB_clock,gen2_lane_clk,gen3_lane_clk,gen4_lane_clk);
upper_layer_if       u_if(SystemClock,gen2_fsm_clk,gen3_fsm_clk,gen4_fsm_clk,SystemReset);

	//Clocks' Initialization
	initial begin

		$timeformat(-9 , 2 , " ns", 10);
		
		SystemClock = 0 ;
		Rx_Clock = 0;
		local_clk = 0;
		gen2_lane_clk = 0;
		gen3_lane_clk = 0;
		gen4_lane_clk = 1;
		gen2_fsm_clk = 0;
		gen3_fsm_clk = 0;
		gen4_fsm_clk = 0;
		SB_clock = 0;
		
		//$display("freq_10: %0d", freq_10);
		//$display("period: %0d", ((10**12)/freq_10));
	
	end

	//Instantiate the logical layer
	logical_layer l_layer(
                                    .local_clk(local_clk),
									.sb_clk(SB_clock),
									.rst(SystemReset),
									.lane_disable(c_if.lane_disable),
									.c_read(c_if.c_read),
									.c_write(c_if.c_write), 
									.c_address(c_if.c_address),
									.c_data_in(c_if.c_data_in),
									.c_data_out(c_if.c_data_out),
									.transport_layer_data_in(u_if.transport_layer_data_in),
                                    .transport_layer_data_out(u_if.transport_layer_data_out),
									.lane_0_rx_i(e_if.lane_0_rx),		
									.lane_1_rx_i(e_if.lane_1_rx),
                                    .sbtx(e_if.sbtx),
									// .control_unit_data(0),
									.enable_deser(e_if.data_incoming),
									.sbrx(e_if.sbrx),		
									.lane_0_tx_o(e_if.lane_0_tx),
									.lane_1_tx_o(e_if.lane_1_tx),
									.enable_scr(enable_rs)
);    

/*
								//--for old dut files --//
								//Instantiate the logical layer
logical_layer_no_scr logical_layer (
	.local_clk(local_clk),
	.sb_clk(SB_clock),
	.rst(SystemReset),
	.lane_disable(c_if.lane_disable),
	.sbtx(e_if.sbtx),
	.c_read(c_if.c_read),
	.c_write(c_if.c_write), 
	.c_address(c_if.c_address),
	.c_data_in(c_if.c_data_in),
	.c_data_out(c_if.c_data_out),
	.transport_layer_data_in(u_if.transport_layer_data_in),
	.lane_0_rx_i(e_if.lane_0_rx),		
	.lane_1_rx_i(e_if.lane_1_rx),
	// .control_unit_data(0),
	.data_incoming(e_if.data_incoming),
	.transport_layer_data_out(u_if.transport_layer_data_out),
	.sbrx(e_if.sbrx),		
	.lane_0_tx_o(e_if.lane_0_tx),
	.lane_1_tx_o(e_if.lane_1_tx),
	.enable_scr(enable_rs_dummy)
);

*/


// TEST 
initial begin 
    TEST USB3_test;
    USB3_test = new(e_if, c_if ,u_if); 
    reset();

    //-------main test----------//
    USB3_test.run();

    //-------for test model only ----------//
    //USB3_test.test_model();
end



















	

	always #(Sys_clock_cycle/2) SystemClock = ~SystemClock;

	always #((10**15)/(2*freq_80)) local_clk = ~local_clk;

	always #((10**15)/(2*SB_freq)) SB_clock = ~SB_clock; // sideband clock
	
	always #((10**15)/(2*freq_10)) gen2_lane_clk = ~gen2_lane_clk;
	
	always #((10**15)/(2*freq_20)) gen3_lane_clk = ~gen3_lane_clk;
	
	always #((10**15)/(2*freq_40)) gen4_lane_clk = ~gen4_lane_clk;

	always #((10**15)/(2*freq_9_697)) gen2_fsm_clk = ~gen2_fsm_clk;
	
	always #((10**15)/(2*freq_19_394)) gen3_fsm_clk = ~gen3_fsm_clk;

	always #((10**15)/(2*freq_40)) gen4_fsm_clk = ~gen4_fsm_clk;

	//always #(Rx_clock_cycle/2) Rx_Clock = ~Rx_Clock;

endmodule
