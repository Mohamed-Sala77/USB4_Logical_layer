package UL_scoreboard_pkg;
	
	import upper_layer_tr_pkg::*;

	class upper_layer_scoreboard;

		//Transaction
		upper_layer_tr UL_tr;


		//Mailboxes
		mailbox #(upper_layer_tr) UL_mon_scr; // connects monitor to the scoreboard
		mailbox #(upper_layer_tr) UL_mod_scr; // connects reference model to the scoreboard 

		//NEW Function
		function new(mailbox #(upper_layer_tr) UL_mon_scr, mailbox #(upper_layer_tr) UL_mod_scr);

			// Mailbox connections
			this.UL_mon_scr = UL_mon_scr; // connections between scoreboard and UL Agent's Monitor
			this.UL_mod_scr = UL_mod_scr; // connections between scoreboard and Reference Model
				
		endfunction : new

		task run;
			forever begin
				
				UL_tr = new();
				
				////////////////////////////////////////////////////////////////////////////////
				//////RECEIVING DATA FROM GENERATOR AND MONITOR FOR EQUIVALENCE CHECKING////////
				////////////////////////////////////////////////////////////////////////////////

				//UL_mon_scr.get(UL_tr);
				UL_mod_scr.get(UL_tr);
				$display(" UL_tr from model %p",UL_tr);
				
				//$display("[%0t], UL_tr= [%0d]",$time(),UL_tr.T_Data);
				
				
			end
			

		endtask : run
		
	endclass : upper_layer_scoreboard
endpackage : UL_scoreboard_pkg
