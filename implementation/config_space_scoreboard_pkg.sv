	class config_space_scoreboard;

		mailbox #(config_transaction) mb_model, mb_mon;
		config_transaction transaction_model, transaction_mon;

		//Events
		event config_req_received;	// indicates capability and generation read request from DUT


		function new (mailbox #(config_transaction) mb_model, mb_mon, event config_req_received);

			this.mb_mon = mb_mon;
			this.mb_model = mb_model;
			this.config_req_received = config_req_received;
			transaction_model = new();
			transaction_mon = new();

		endfunction : new


		task run;

			forever
			begin
				
				//` we put here get operation first to make scrb block until the model " who know which pahse we in" put tht data 
				mb_model.get(transaction_model) ;
				$display("[CONFIG SCOREBOARD] MODEL Transaction: %p",transaction_model);
				
				mb_mon.get(transaction_mon);
				$display("[CONFIG SCOREBOARD] DUT Transaction: %p",transaction_mon);
				
				
				event_trigger();

				
				 assert(transaction_model.c_read === transaction_mon.c_read) else $error("[CONFIG SCOREBOARD] c_read doesn't match the expected value");
				 assert(transaction_model.c_write === transaction_mon.c_write) else $error("[CONFIG SCOREBOARD] c_write doesn't match the expected value");
				 assert(transaction_model.c_address === transaction_mon.c_address) else $error("[CONFIG SCOREBOARD] c_address doesn't match the expected value");
				 assert(transaction_model.c_data_out === transaction_mon.c_data_out) else $error("[CONFIG SCOREBOARD] c_data_out doesn't match the expected value");

				// assert(	(transaction_model.c_read === transaction_mon.c_read) 		&&
				// 		(transaction_model.c_write === transaction_mon.c_write) 	&&
				// 		(transaction_model.c_address === transaction_mon.c_address)	&&
				// 		(transaction_model.c_data_out === transaction_mon.c_data_out)
				// 		) $display("[CONFIG SCOREBOARD] CORRECT transaction received ");





				
			end

		endtask : run


		task event_trigger;

			if (transaction_mon.c_read)
			begin
				if (transaction_mon.c_address == 'd18 ) // CAPABILITY READ REQUEST
				begin
					-> config_req_received;
				end
			end

		endtask : event_trigger

	endclass : config_space_scoreboard

 