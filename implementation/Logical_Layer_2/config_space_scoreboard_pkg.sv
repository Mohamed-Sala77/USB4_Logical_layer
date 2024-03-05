//% ---------------------------- [✓]

package config_space_scoreboard_pkg;
import config_space_pkg::*;

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

				mb_model.get(transaction_model);
				$display("config scoreboard run");
				$display("[config scoreboard ] C_read: %0b, C_write: %0b, C_address: %0h, C_data_out: %0h", transaction_model.c_read, transaction_model.c_write, transaction_model.c_address ,transaction_model.c_data_out);
				
				//$stop;
				//mb_mon.get(transaction_mon);

				//$display("Ref transaction in scoreboard: 			%p at time: %0t", transaction_model, $time);
				//$display("Dut transaction in scoreboard: 			%p at time: %0t", transaction_mon, $time);

				/*
				assert(transaction_model == transaction_mon);

				if (transaction_model == transaction_mon)
					$display("Correct Operation at: %0t", $time);
				else
					$display("Wrong Operation at: %0t", $time);
*/			
			

			end

		endtask : run


	endclass : config_space_scoreboard

endpackage

