	class elec_layer_scoreboard;

		//Transaction
		elec_layer_tr elec_tr;
		elec_layer_tr elec_tr_model;

		//Mailboxes
		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		mailbox #(elec_layer_tr) elec_mod_scr; // connects reference model to the scoreboard 

		//NEW Function
		function new(mailbox #(elec_layer_tr) elec_mon_scr, mailbox #(elec_layer_tr) elec_mod_scr);

			// Mailbox connections
			this.elec_mon_scr = elec_mon_scr; // connections between scoreboard and UL Agent's Monitor
			this.elec_mod_scr = elec_mod_scr; // connections between scoreboard and Reference Model
			
			elec_tr_model = new();

		endfunction : new

		task run;
			forever begin
				
				elec_tr = new();
			


				// if(elec_mod_scr.try_get(elec_tr_model))
				// 	begin
				// 		$display("[ELEC SCOREBOARD]: MODEL TRANSACTION: %p",elec_tr_model);
				// 	end

				
			
				elec_mon_scr.get(elec_tr);
				$display("[ELEC SCOREBOARD] Transaction Received ");
				if (elec_tr.transaction_type == AT_cmd || elec_tr.transaction_type == AT_rsp)
					begin
						$display("Transaction type:[%0b]",elec_tr.transaction_type.name());
						$display("Transaction Contents");
						$display("address: [%0h]",elec_tr.address);
						$display("Length: [%0d]",elec_tr.len);
						$display("Read_write: [%0d]",elec_tr.read_write);
						$display("Low CRC: [%0d]",elec_tr.crc_received[15:8]);
						$display("High CRC: [%0d]",elec_tr.crc_received[7:0]);
						$display("DATA_SYMBOLS[%0h]\n",elec_tr.cmd_rsp_data);
					end
				if (elec_tr.transaction_type == LT_fall) begin
						$display("Transaction type:[%0b]\n",elec_tr.transaction_type.name());
				end

				elec_mod_scr.get(elec_tr_model);
				$display("[ELEC SCOREBOARD]: MODEL TRANSACTION: %p",elec_tr_model);
				////////////////////////////////////////////////////////////////////////////////
				//////RECEIVING DATA FROM GENERATOR AND MONITOR FOR EQUIVALENCE CHECKING////////
				////////////////////////////////////////////////////////////////////////////////
				
				// if (elec_tr.o_sets == SLOS1)
				// 	$display("[ELEC SCOREBOARD] SLOS1 RECEIVED");

				// $display("[%0t], elec_tr.AT_transaction = [%0d], elec_tr.ordered_sets = [%0d]",$time(),elec_tr.AT_transaction, elec_tr.ordered_sets);
				
				
			end
			

		endtask : run
		
	endclass : elec_layer_scoreboard
