
package elec_agent_pkg;
	
	import elec_generator_pkg::*;
	import elec_monitor_pkg::*;
	import elec_driver_pkg::*;

	import elec_layer_tr_pkg::*;

	class elec_layer_agent;

		

		// virtual interface definition
		virtual electrical_layer_if v_if;

		//Agent Components
		elec_layer_generator elec_gen;
		elec_layer_monitor elec_mon;
		elec_layer_driver elec_drv;

		// Mailboxes

		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		mailbox #(elec_layer_tr) elec_gen_mod; // connects stimulus generator to the reference model
		mailbox #(elec_layer_tr) elec_gen_drv; // connects Stimulus generator to the driver inside the agent
		mailbox #(OS_type) os_received_mon_gen; // connects monitor to the stimulus generator to indicated received ordered sets

		//Event Signals
		event elec_gen_drv_done;
		event sbtx_high_recieved; // to identify phase 2 completion (sbtx high received)

		// NEW Function
		function new(input virtual electrical_layer_if v_if, mailbox #(elec_layer_tr) elec_mon_scr, mailbox #(elec_layer_tr) elec_gen_mod);

			//Interface Connections
			this.v_if = v_if;

			
			// Mailbox connections between The Agent and Environment
			elec_gen_drv = new(); // create handle for the internal driver mailbox
			os_received_mon_gen = new();
			this.elec_mon_scr = elec_mon_scr;
			this.elec_gen_mod = elec_gen_mod;

			// Agent's Component Handles
			elec_gen = new( elec_gen_mod, elec_gen_drv, os_received_mon_gen, elec_gen_drv_done, sbtx_high_recieved);
			elec_mon = new(v_if, elec_mon_scr, os_received_mon_gen, sbtx_high_recieved);
			elec_drv = new(v_if, elec_gen_drv, elec_gen_drv_done);
		
		endfunction : new



		task run;
			fork
				//elec_gen.run();
				elec_mon.run();
				elec_drv.run();
			join


		endtask : run



	endclass : elec_layer_agent

endpackage : elec_agent_pkg

