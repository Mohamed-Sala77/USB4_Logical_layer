	class elec_layer_scoreboard;

		//Transaction
		elec_layer_tr elec_tr;
		elec_layer_tr elec_tr_model;

		//Mailboxes
		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		mailbox #(elec_layer_tr) elec_mod_scr; // connects reference model to the scoreboard 
		mailbox #(elec_layer_tr) os_received_mon_gen; // connects scoreboard to the stimulus generator to indicated received ordered sets


		//Events
		event sbtx_high_received;
		event elec_AT_cmd_received;

		//NEW Function
		function new(mailbox #(elec_layer_tr) elec_mon_scr, mailbox #(elec_layer_tr) elec_mod_scr, mailbox #(elec_layer_tr) os_received_mon_gen, event sbtx_high_received, elec_AT_cmd_received);

			// Mailbox connections
			this.elec_mon_scr = elec_mon_scr;				// connections between scoreboard and UL Agent's Monitor
			this.elec_mod_scr = elec_mod_scr;				// connections between scoreboard and Reference Model
			this.os_received_mon_gen = os_received_mon_gen; // connections between scoreboard and sequence

			this.sbtx_high_received = sbtx_high_received; 		//connected between scoreboard and sequence
			this.elec_AT_cmd_received = elec_AT_cmd_received;	//connected between scoreboard and sequence
			elec_tr_model = new();

		endfunction : new

		task run;
			forever begin
				
				elec_tr = new();
			


				elec_mod_scr.get(elec_tr_model);
				$display("[ELEC SCOREBOARD]: MODEL TRANSACTION: %p",elec_tr_model);
					
				elec_mon_scr.get(elec_tr);
				$display("[ELEC SCOREBOARD] Time: %0t   Transaction Received: %p", $time, elec_tr);
				
				event_trigger(); // to trigger the sbtx_high_received event

				//$display("[ELEC SCOREBOARD] DUT transaction: %p",elec_tr);


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

				// case(elec_tr.phase)
				// 	2:
				// 	begin
				// 		assert(	(elec_tr_model.sbtx === elec_tr.sbtx)) $display("[ELEC SCOREBOARD] CORRECT (PHASE 2) SIDEBAND behavior ");
				// 		else $error("[ELEC SCOREBOARD] INCORRECT (PHASE 2) SIDEBAND behavior!!!");
				// 	end

				// 	3:
				// 	begin

				// 		assert(	(elec_tr_model.sbtx === elec_tr.sbtx) 								&&
				// 				(elec_tr_model.transaction_type === elec_tr.transaction_type) 		&&
				// 				(elec_tr_model.read_write === elec_tr.read_write)					&&
				// 				(elec_tr_model.len === elec_tr.len)									&&
				// 				(elec_tr_model.crc_received === elec_tr.crc_received)				&&
				// 				(elec_tr_model.cmd_rsp_data === elec_tr.cmd_rsp_data)				&&
				// 				(elec_tr_model.address === elec_tr.address)							&&
				// 				(elec_tr_model.address === elec_tr.address)							&&
				// 				(elec_tr_model.address === elec_tr.address)							
				// 				) $display("[ELEC SCOREBOARD] CORRECT (PHASE 3) Transaction received ");
				// 		else $error("[ELEC SCOREBOARD] INCORRECT (PHASE 3) Transaction received   !!!");
				// 	end

				// 	4:
				// 	begin
				// 		case (elec_tr.o_sets)

				// 			SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3: // GEN2/ GEN3 CHECKING
				// 			begin
				// 				assert(	(elec_tr_model.sbtx === elec_tr.sbtx) 		&&
				// 						(elec_tr_model.lane === elec_tr.lane) 		&&
				// 						(elec_tr_model.o_sets === elec_tr.o_sets)
				// 						) $display("[ELEC SCOREBOARD] CORRECT (PHASE 4) GEN4 Ordered Set received ");
				// 				else $error("[ELEC SCOREBOARD] INCORRECT (PHASE 4) GEN4 Ordered Set received   !!!");
				// 			end

				// 			TS1_gen4, TS2_gen4, TS3, TS4: // GEN4 CHECKING
				// 			begin
				// 				assert(	(elec_tr_model.sbtx === elec_tr.sbtx) 		&&
				// 						(elec_tr_model.lane === elec_tr.lane) 		&&
				// 						(elec_tr_model.o_sets === elec_tr.o_sets)	&&
				// 						(elec_tr_model.order === elec_tr.order)
				// 						) $display("[ELEC SCOREBOARD] CORRECT (PHASE 4) GEN4 Ordered Set received ");
				// 				else $error("[ELEC SCOREBOARD] INCORRECT (PHASE 4) GEN4 Ordered Set received   !!!");
				// 			end


				// 		endcase
						
				// 	end

				// 	5:
				// 	begin
				// 		assert(	(elec_tr_model.transport_to_electrical === elec_tr.transport_to_electrical)) $display("[ELEC SCOREBOARD] CORRECT (PHASE 5)  behavior ");
				// 	end


				// endcase
				
				
			end
			

		endtask : run


		//Task to trigger an event connected between the scoreboard and the sequence(stimulus generator)
		task event_trigger;	
			if ( (elec_tr.sbtx == 1'b1) && (elec_tr.phase == 3'b010) )
			begin
				-> sbtx_high_received;
			end

			if (elec_tr.transaction_type == AT_cmd)
			begin
				-> elec_AT_cmd_received;
			end

			if (elec_tr.tr_os == ord_set)
			begin
				os_received_mon_gen.put(elec_tr);
			end


		endtask : event_trigger

		
	endclass : elec_layer_scoreboard
