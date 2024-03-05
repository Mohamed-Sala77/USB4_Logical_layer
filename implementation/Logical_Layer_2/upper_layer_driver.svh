package UL_driver_pkg;
	
	import upper_layer_tr_pkg::*;

	class upper_layer_driver;

		// Event Signals
		event UL_gen_drv_done;

		//Transaction
		upper_layer_tr UL_tr;

		// Virtual Interface
		virtual upper_layer_if v_if;

		// Mailboxes
		mailbox #(upper_layer_tr) UL_gen_drv; // connects Stimulus generator to the driver inside the agent


		function new(input virtual upper_layer_if v_if, mailbox #(upper_layer_tr) UL_gen_drv, event UL_gen_drv_done);

			//Interface Connections
			this.v_if = v_if;

			// Mailbox connections between (Driver) and (UL Agent)
			this.UL_gen_drv = UL_gen_drv;
			
			// Event Signals Connections
			this.UL_gen_drv_done = UL_gen_drv_done;
				
		endfunction : new

		task run;
			forever begin

				//////////////////////////////////////////////////
				/////RECEIVING TEST STIMULUS FROM generator //////
				//////////////////////////////////////////////////

				UL_tr = new();
				UL_gen_drv.get(UL_tr);
				

				//////////////////////////////////////////////////
				//////////////PIN LEVEL ASSIGNMENT ///////////////
				//////////////////////////////////////////////////

				@(posedge v_if.clk) begin
					v_if.transport_layer_data_in = UL_tr.T_Data;
					-> UL_gen_drv_done; // Triggering Event to notify stimulus generator
				end

			end
			

		endtask : run

		
	endclass : upper_layer_driver
endpackage : UL_driver_pkg