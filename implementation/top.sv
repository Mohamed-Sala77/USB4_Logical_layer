`timescale 1fs/1fs

`include "tb_pkg.sv"
import tb_pkg::*;


`include "config_space_if.sv"
`include "electrical_layer_if.sv"
`include "upper_layer_if.sv"


module top;

	parameter Sys_clock_cycle = 1 * 10**6; parameter Rx_clock_cycle = 50;

	parameter [63:0] SB_freq = 1 * 10**6;
	parameter [63:0] freq_19_394 = 19.394 * 10 ** 9;	//19.394 GHz
	parameter [63:0] freq_38_788 = 38.788 * 10 ** 9;	//38.788 GHz
	parameter [63:0] freq_10 = 64'd10 * 10 ** 9;		//10 GHz
	parameter [63:0] freq_20 = 64'd20 * 10 ** 9;		//20 GHz
	parameter [63:0] freq_40 = 40 * 10 ** 9;			//40 GHz
	parameter [63:0] freq_80 = 80 * 10 ** 9;			//80 GHz

	/*
	parameter clock_10G = 100;
	parameter clock_20G = 50;
	parameter clock_40G = 25;
	parameter clock_1_212G = 825;
	parameter clock_2_424G = 825;
	*/
	logic SystemClock; logic Rx_Clock;
	logic local_clk;
	logic SB_clock;
	logic gen2_lane_clk, gen3_lane_clk, gen4_lane_clk;
	logic gen2_fsm_clk, gen3_fsm_clk, gen4_fsm_clk;
	logic SystemReset;

	logic enable_rs_dummy;


	//Reset generation
	task reset();
		repeat (3) @(posedge SB_clock) SystemReset = 0;
		SystemReset = 1;
		
		
	endtask

	// interfaces 
	upper_layer_if UL_if(SystemClock, gen2_fsm_clk, gen3_fsm_clk, gen4_fsm_clk, SystemReset);
	electrical_layer_if elec_if(SystemClock, SB_clock, gen2_lane_clk, gen3_lane_clk, gen4_lane_clk);
	config_space_if config_if(SystemClock, gen4_fsm_clk);

	//DUT instatiation
	logical_layer logical_layer (
									.local_clk(local_clk),
									.sb_clk(SB_clock),
									.rst(SystemReset),
									.lane_disable(config_if.lane_disable),
									.sbtx(elec_if.sbtx),
									.c_read_write(config_if.c_read), // needs to be changed by design team
									.c_address(config_if.c_address),
									.c_data_in(config_if.c_data_in), // needs to be changed by design team
									.c_data_out(config_if.c_data_out),
									.transport_layer_data_in(UL_if.transport_layer_data_in),
									.lane_0_rx_i(elec_if.lane_0_rx),		
									.lane_1_rx_i(elec_if.lane_1_rx),
									.control_unit_data(0),
									.data_incoming(1),
									.transport_layer_data_out(UL_if.transport_layer_data_out),
									.sbrx(elec_if.sbrx),		
									.lane_0_tx_o(elec_if.lane_0_tx),
									.lane_1_tx_o(elec_if.lane_1_tx),
									.enable_rs(enable_rs_dummy)
								);

	//Clocks' Initialization
	initial begin

		SystemClock = 0 ;
		Rx_Clock = 0;
		local_clk = 0;
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

	always #((10**15)/(2*freq_80)) local_clk = ~local_clk;

	always #((10**15)/(2*SB_freq)) SB_clock = ~SB_clock; // sideband clock
	
	always #((10**15)/(2*freq_10)) gen2_lane_clk = ~gen2_lane_clk;
	
	always #((10**15)/(2*freq_20)) gen3_lane_clk = ~gen3_lane_clk;
	
	always #((10**15)/(2*freq_40)) gen4_lane_clk = ~gen4_lane_clk;

	always #((10**15)/(2*freq_19_394)) gen2_fsm_clk = ~gen2_fsm_clk;
	
	always #((10**15)/(2*freq_38_788)) gen3_fsm_clk = ~gen3_fsm_clk;

	always #((10**15)/(2*freq_80)) gen4_fsm_clk = ~gen4_fsm_clk;

	//always #(Rx_clock_cycle/2) Rx_Clock = ~Rx_Clock;


	// TEST 
	initial begin 
		Testenv t_env;
		t_env = new(UL_if, elec_if, config_if);
		reset();
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
		//elec_if.sbtx = 0;
		//#(500000000 + tConnectRx - 1000000000) elec_if.sbtx = 1;
		//#(500000000 + tConnectRx) elec_if.sbtx = 1;
		/*
		//Testing while the DUT is Host router
		#(500000000 + tConnectRx) elec_if.sbtx = 1;
		#(tConnectRx) elec_if.sbtx = 0;
		#(500000000 + tConnectRx) elec_if.sbtx = 1;
		*/
		
		//#(2000) elec_if.sbtx = 1;
	end


endmodule : top
