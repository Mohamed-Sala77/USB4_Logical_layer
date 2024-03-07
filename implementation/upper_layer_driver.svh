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
				v_if.phase = UL_tr.phase;
				v_if.generation_speed = UL_tr.gen_speed;

				//////////////////////////////////////////////////
				//////////////PIN LEVEL ASSIGNMENT ///////////////
				//////////////////////////////////////////////////

				wait_negedge(UL_tr.gen_speed); 
				begin
					v_if.transport_layer_data_in = UL_tr.T_Data;
					-> UL_gen_drv_done; // Triggering Event to notify stimulus generator
				end

			end
			

		endtask : run

		task wait_negedge (input GEN generation);
			if (generation == gen2)
			begin
				@(negedge v_if.gen2_fsm_clk);
			end
			else if (generation == gen3)
			begin
				@(negedge v_if.gen3_fsm_clk);
			end
			else if (generation == gen4)
			begin
				@(negedge v_if.gen4_fsm_clk);
			end
		endtask

		
	endclass : upper_layer_driver
