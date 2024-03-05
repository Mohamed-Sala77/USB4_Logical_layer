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

				//$display("scoreboard run");

				if (mb_model.try_get(transaction_model))
					begin
						$display("[CONFIG SCOREBOARD] MODEL Transaction: %p",transaction_model);
					end
				// mb_model.get(transaction_model);
				// $display("[CONFIG SCOREBOARD] MODEL Transaction: %p",transaction_model);

				mb_mon.get(transaction_mon);
				// $display("Ref transaction in scoreboard: 			%p at time: %0t", transaction_model, $time);
				// $display("Dut transaction in scoreboard: 			%p at time: %0t", transaction_mon, $time);

				// assert(transaction_model == transaction_mon);

				// if (transaction_model == transaction_mon)
				// 	$display("Correct Operation at: %0t", $time);
				// else
				// 	$display("Wrong Operation at: %0t", $time);

			end

		endtask : run


	endclass : config_space_scoreboard

