package UL_agent_pkg;
	
	import UL_generator_pkg::*;
	import UL_monitor_pkg::*;
	import UL_driver_pkg::*;

	import upper_layer_tr_pkg::*;

	class upper_layer_agent;

		

		// virtual interface definition
		virtual upper_layer_if v_if;

		//Agent Components
		upper_layer_generator UL_gen;
		upper_layer_monitor UL_mon;
		upper_layer_driver UL_drv;

		// Mailboxes

		mailbox #(upper_layer_tr) UL_mon_scr; // connects monitor to the scoreboard
		mailbox #(upper_layer_tr) UL_gen_mod; // connects stimulus generator to the reference model
		mailbox #(upper_layer_tr) UL_gen_drv; // connects Stimulus generator to the driver inside the agent

		//Event Signals
		event UL_gen_drv_done;

		// NEW Function
		function new(input virtual upper_layer_if v_if, mailbox #(upper_layer_tr) UL_mon_scr, mailbox #(upper_layer_tr) UL_gen_mod);

			//Interface Connections
			this.v_if = v_if;

			
			// Mailbox connections between The Agent and Environment
			UL_gen_drv = new(); // create handle for the internal driver mailbox
			this.UL_mon_scr = UL_mon_scr;
			this.UL_gen_mod = UL_gen_mod;

			// Agent's Component Handles
			UL_gen = new(UL_gen_mod, UL_gen_drv, UL_gen_drv_done);
			UL_mon = new(v_if, UL_mon_scr);
			UL_drv = new(v_if, UL_gen_drv, UL_gen_drv_done);
		
		endfunction : new



		task run;
			fork
				//UL_gen.run();
				UL_mon.run();
				UL_drv.run();
			join


		endtask : run



	endclass : upper_layer_agent

endpackage : UL_agent_pkg
