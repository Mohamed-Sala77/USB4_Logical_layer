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
			


				if(elec_mod_scr.try_get(elec_tr_model))
					begin
						$display("[ELEC SCOREBOARD]: MODEL TRANSACTION: %p",elec_tr_model);
					end

				
			
				elec_mon_scr.get(elec_tr);
				$display("[ELEC SCOREBOARD] Time: %0t   Transaction Received: %p", $time, elec_tr);
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
		
	endclass : elec_layer_scoreboard
