	class upper_layer_scoreboard;

		//Transaction
		upper_layer_tr UL_tr;
		upper_layer_tr UL_tr_model; // model transaction


		//Mailboxes
		mailbox #(upper_layer_tr) UL_mon_scr; // connects monitor to the scoreboard
		mailbox #(upper_layer_tr) UL_mod_scr; // connects reference model to the scoreboard 

		//NEW Function
		function new(mailbox #(upper_layer_tr) UL_mon_scr, mailbox #(upper_layer_tr) UL_mod_scr);

			// Mailbox connections
			this.UL_mon_scr = UL_mon_scr; // connections between scoreboard and UL Agent's Monitor
			this.UL_mod_scr = UL_mod_scr; // connections between scoreboard and Reference Model
				
			UL_tr_model = new();

		endfunction : new

		task run;
			forever begin
				
				UL_tr = new();

				/*
				if(UL_mod_scr.try_get(UL_tr_model))
					begin
						$display("[UL SCOREBOARD]: MODEL transaction: %p",UL_tr_model);
					end
				*/
				
				UL_mon_scr.get(UL_tr);
				$display("[UL SCOREBOARD]: DUT transaction: %p",UL_tr);

				UL_mod_scr.get(UL_tr_model);
				$display("[UL SCOREBOARD]: MODEL transaction: %p",UL_tr_model);

				

				assert(	UL_tr_model.T_Data === UL_tr.T_Data ) $display("[UL SCOREBOARD] CORRECT transaction received ");
				else $error("[UL SCOREBOARD] Transactions don't match");

				// UL_mod_scr.get(UL_tr_model);
				// $display("[upper_layer_tr]: MODEL transaction: %p",UL_tr_model);

				////////////////////////////////////////////////////////////////////////////////
				//////RECEIVING DATA FROM GENERATOR AND MONITOR FOR EQUIVALENCE CHECKING////////
				////////////////////////////////////////////////////////////////////////////////

				
				
				
				
				
			end
			

		endtask : run
		
	endclass : upper_layer_scoreboard
