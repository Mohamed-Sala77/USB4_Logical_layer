package UL_monitor_pkg;
	
	import upper_layer_tr_pkg::*;

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


				@(negedge v_if.clk) begin 
					UL_tr.T_Data = v_if.transport_layer_data_in;
				end 
				
				
				//////////////////////////////////////////////////
				//TESTED INTEFACE SIGNAL SENT TO THE SCOREBOARD///
				//////////////////////////////////////////////////

				UL_mon_scr.put(UL_tr);
			end
			

		endtask : run
		
	endclass : upper_layer_monitor
endpackage : UL_monitor_pkg
