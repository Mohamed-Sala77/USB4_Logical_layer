
	class upper_layer_monitor;

		//Transaction
		upper_layer_tr UL_tr;

		// Interface
		virtual upper_layer_if v_if;

		// Mailboxes
		mailbox #(upper_layer_tr) UL_mon_scr; // connects monitor to the scoreboard



		// NEW Function

		function new(input virtual upper_layer_if v_if, mailbox #(upper_layer_tr) UL_mon_scr);

			//Interface Connections
			this.v_if = v_if;

			// Mailbox connections between (monitor) and (Agent)
			this.UL_mon_scr = UL_mon_scr;
				
		endfunction : new

		task run;
			forever begin
				
				UL_tr =new();
				
				//////////////////////////////////////////////////
				///////GETTING INTERFACE ITEMS TO BE TESTED///////
				//////////////////////////////////////////////////


				wait_negedge(v_if.generation_speed); 
				begin 
					UL_tr.T_Data = v_if.transport_layer_data_out; //transport_layer_data_in for debugging
				end 
				
				
				//////////////////////////////////////////////////
				//TESTED INTEFACE SIGNAL SENT TO THE SCOREBOARD///
				//////////////////////////////////////////////////
				if(v_if.phase == 5)
					begin
						UL_mon_scr.put(UL_tr);	
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
			else 
			begin
				@(negedge v_if.gen4_fsm_clk);
			end

		endtask : wait_negedge


		
	endclass : upper_layer_monitor
