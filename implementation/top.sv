`timescale 1fs/1fs

`include "tb_pkg.sv"
import tb_pkg::*;


`include "config_space_if.sv"
`include "electrical_layer_if.sv"
`include "upper_layer_if.sv"


module top;

	parameter Sys_clock_cycle = 1 * 10**6; parameter Rx_clock_cycle = 50;
	parameter [63:0] SB_freq = 1 * 10**6;
	parameter [63:0] freq_1_212 = 1.212 * 10 ** 9;	//1.212 GHz
	parameter [63:0] freq_2_424 = 2.424 * 10 ** 9;	//2.424 GHz
	parameter [63:0] freq_4_95 = 4.95 * 10 ** 9;	//4.95 GHz
	parameter [63:0] freq_10 = 64'd10 * 10 ** 9;	//10 GHz
	parameter [63:0] freq_20 = 64'd20 * 10 ** 9;	//20 GHz
	parameter [63:0] freq_40 = 40 * 10 ** 9;		//40 GHz
	/*
	parameter clock_10G = 100;
	parameter clock_20G = 50;
	parameter clock_40G = 25;
	parameter clock_1_212G = 825;
	parameter clock_2_424G = 825;
	*/
	logic SystemClock; logic Rx_Clock;
	logic SB_clock;
	logic gen2_lane_clk, gen3_lane_clk, gen4_lane_clk;
	logic gen2_fsm_clk, gen3_fsm_clk, gen4_fsm_clk;

	logic SystemReset;


	//Reset generation
	task reset();
		repeat (3) @(posedge SystemClock) SystemReset = 1;
		SystemReset = 0;
		
		
	endtask

	// interfaces 
	upper_layer_if UL_if(SystemClock, gen2_fsm_clk, gen3_fsm_clk, gen4_fsm_clk, SystemReset);
	electrical_layer_if elec_if(SystemClock, SB_clock, gen2_lane_clk, gen3_lane_clk, gen4_lane_clk);
	config_space_if config_if(SystemClock, gen4_fsm_clk);

	//DUT instatiation
	

	//Clocks' Initialization
	initial begin

		SystemClock = 0 ;
		Rx_Clock = 0;
		gen2_lane_clk = 0;
		gen3_lane_clk = 0;
		gen4_lane_clk = 0;
		gen2_fsm_clk = 0;
		gen3_fsm_clk = 0;
		gen4_fsm_clk = 0;
		SB_clock = 0;
		
		//$display("freq_10: %0d", freq_10);
		//$display("period: %0d", ((10**12)/freq_10));
	
	end




	

	always #(Sys_clock_cycle/2) SystemClock = ~SystemClock;

	always #((10**15)/(2*SB_freq)) SB_clock = ~SB_clock; // sideband clock
	
	always #((10**15)/(2*freq_10)) gen2_lane_clk = ~gen2_lane_clk;
	
	always #((10**15)/(2*freq_20)) gen3_lane_clk = ~gen3_lane_clk;
	
	always #((10**15)/(2*freq_40)) gen4_lane_clk = ~gen4_lane_clk;

	always #((10**15)/(2*freq_1_212)) gen2_fsm_clk = ~gen2_fsm_clk;
	
	always #((10**15)/(2*freq_2_424)) gen3_fsm_clk = ~gen3_fsm_clk;

	always #((10**15)/(2*freq_4_95)) gen4_fsm_clk = ~gen4_fsm_clk;

	//always #(Rx_clock_cycle/2) Rx_Clock = ~Rx_Clock;


	// TEST 
	initial begin 
		Testenv t_env;
		t_env = new(UL_if, elec_if, config_if);
		//reset();
		t_env.build();


		t_env.run();
		
	end


	/*
	initial begin
		#(1000) elec_if.sbtx = 1;
		#(1000) elec_if.sbtx = 0;
	end
	initial begin
		#(15000) elec_if.sbtx = 1;
		#(1000) elec_if.sbtx = 0;
	end
	initial begin
		#(22000) elec_if.sbtx = 1;
		#(2000) elec_if.sbtx = 0;
	end
	initial begin
		#(36000) elec_if.sbtx = 1;
		#(2000) elec_if.sbtx = 1;
	end
	*/

	initial begin
		elec_if.sbtx = 0;
		//#(500000000 + tConnectRx - 1000000000) elec_if.sbtx = 1;
		#(500000000 + tConnectRx) elec_if.sbtx = 1;
		/*
		//Testing while the DUT is Host router
		#(500000000 + tConnectRx) elec_if.sbtx = 1;
		#(tConnectRx) elec_if.sbtx = 0;
		#(500000000 + tConnectRx) elec_if.sbtx = 1;
		*/
		
		#(2000) elec_if.sbtx = 1;
	end


endmodule : top
