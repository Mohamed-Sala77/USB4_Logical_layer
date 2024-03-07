	class config_space_scoreboard;

		mailbox #(config_transaction) mb_model, mb_mon;
		config_transaction transaction_model, transaction_mon;


		function new (mailbox #(config_transaction) mb_model, mb_mon);

			this.mb_mon = mb_mon;
			this.mb_model = mb_model;
			transaction_model = new();
			transaction_mon = new();

		endfunction : new


		task run;

			forever
			begin


				if (mb_model.try_get(transaction_model))
					begin
						$display("[CONFIG SCOREBOARD] MODEL Transaction: %p",transaction_model);
					end
				
				mb_mon.get(transaction_mon);
				//$display("[CONFIG SCOREBOARD] DUT Transaction: %p",transaction_mon);
				

				
				// assert(transaction_model.c_read === transaction_mon.c_read) else $error("[CONFIG SCOREBOARD] c_read doesn't match the expected value");
				// assert(transaction_model.c_write === transaction_mon.c_write) else $error("[CONFIG SCOREBOARD] c_write doesn't match the expected value");
				// assert(transaction_model.c_address === transaction_mon.c_address) else $error("[CONFIG SCOREBOARD] c_address doesn't match the expected value");
				// assert(transaction_model.c_data_out === transaction_mon.c_data_out) else $error("[CONFIG SCOREBOARD] c_address doesn't match the expected value");

				// assert(	(transaction_model.c_read === transaction_mon.c_read) 		&&
				// 		(transaction_model.c_write === transaction_mon.c_write) 	&&
				// 		(transaction_model.c_address === transaction_mon.c_address)	&&
				// 		(transaction_model.c_data_out === transaction_mon.c_data_out)
				// 		) $display("[CONFIG SCOREBOARD] CORRECT transaction received ");





				
			end

		endtask : run


	endclass : config_space_scoreboard

