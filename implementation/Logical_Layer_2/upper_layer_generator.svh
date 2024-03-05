//% ---------------------------- [✓]

package UL_generator_pkg;
	
	import upper_layer_tr_pkg::*;

	class upper_layer_generator;

		int counter = 0;

		// Event Signals
		event UL_gen_drv_done;

		//Transaction
		upper_layer_tr blueprint; // used as an abstraction layer for future error injection 
		//upper_layer_tr UL_tr;

		// Mailboxes
		mailbox #(upper_layer_tr) UL_gen_mod; // connects stimulus generator to the reference model
		mailbox #(upper_layer_tr) UL_gen_drv; // connects Stimulus generator to the driver inside the agent

		function new(mailbox #(upper_layer_tr) UL_gen_mod, mailbox #(upper_layer_tr) UL_gen_drv, event UL_gen_drv_done);

			// Mailbox connections between generator and agent
			this.UL_gen_mod = UL_gen_mod;
			this.UL_gen_drv = UL_gen_drv;

			// Event Signals Connections
			this.UL_gen_drv_done = UL_gen_drv_done;

			//Blueprint handle
			blueprint = new();
				
		endfunction : new
		

		task run;
			

			upper_layer_tr UL_tr;
			//forever begin
				
				//////////////////////////////////////////////////
				////////////////INPUT RANDOMIZATION //////////////
				//////////////////////////////////////////////////


				//UL_tr=new;
				assert(blueprint.randomize);
				UL_tr = blueprint.copy();

				//////////////////////////////////////////////////
				////////////////DRIVER ASSIGNMENT/////////////////
				//////////////////////////////////////////////////

				UL_gen_mod.put(UL_tr); // Sending transaction to the Reference Model
				UL_gen_drv.put(UL_tr); // Sending transaction to the Driver
				counter = counter + 1;
				@UL_gen_drv_done; // waiting for event triggering from driver
				

				//////////////////////////////////////////////////
				//////NUMBER OF Iterations TO BE PERFORMED ///////
				//////////////////////////////////////////////////

				/*if(counter == 20) begin
					
					$stop;
				end*/
			//end
			

		endtask : run

		
	endclass : upper_layer_generator
endpackage : UL_generator_pkg
