module top;

	import env_pkg::*;
	
	parameter Sys_clock_cycle = 100; parameter Rx_clock_cycle = 50;
	logic SystemClock; logic Rx_Clock;
	logic SystemReset;


	//Reset generation
	task reset();
		repeat (3) @(posedge SystemClock) SystemReset = 1;
		SystemReset = 0;
	endtask

	// interfaces 
	upper_layer_if UL_if(SystemClock, Rx_Clock, SystemReset);
	electrical_layer_if elec_if(SystemClock);
	config_space_if config_if(SystemClock);

	//DUT instatiation
	

	//Clock generation
	initial begin
		SystemClock = 0 ;

		forever begin
			#(Sys_clock_cycle/2) SystemClock = ~SystemClock;
		end
	end

	initial begin
		Rx_Clock = 0 ;

		forever begin
			#(Rx_clock_cycle/2) Rx_Clock = ~Rx_Clock;
		end
	end





	// TEST 
	initial begin 
		Testenv t_env;
		t_env = new(UL_if, elec_if, config_if);
		reset();
		t_env.build();


		t_env.run();
		
	end



	// initial begin
	// 	#(1000) elec_if.sbtx = 1;
	// 	#(1000) elec_if.sbtx = 0;
	// end
	// initial begin
	// 	#(15000) elec_if.sbtx = 1;
	// 	#(1000) elec_if.sbtx = 0;
	// end
	// initial begin
	// 	#(22000) elec_if.sbtx = 1;
	// 	#(2000) elec_if.sbtx = 0;
	// end
	// initial begin
	// 	#(36000) elec_if.sbtx = 1;
	// end
	
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
		#(2000) elec_if.sbtx = 0;
	end

endmodule : top
