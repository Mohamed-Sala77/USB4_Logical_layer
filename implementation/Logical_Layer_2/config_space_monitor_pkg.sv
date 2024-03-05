//% ---------------------------- [✓]

package config_space_monitor_pkg;
import config_space_pkg::*;

	class config_space_monitor;

		config_transaction transaction_mon;
		mailbox #(config_transaction) mb_mon;
		virtual config_space_if config_vif;

		//Events
		event usb_received;

		function new (mailbox #(config_transaction) mb_mon, event usb_received);

			this.mb_mon = mb_mon;
			this.usb_received = usb_received;
			transaction_mon = new();

		endfunction : new


		task run;
			@(negedge config_vif.clk);
			forever
			begin
				
				//$display("Monitor run");

				@(negedge config_vif.clk);

				

				transaction_mon.c_read = config_vif.c_read;
				transaction_mon.c_write = config_vif.c_write;
				//transaction_mon.c_address = config_vif.c_address;
				transaction_mon.c_data_out = config_vif.c_data_out;
				//#600;
				mb_mon.put(transaction_mon);
//////////////////////////////////////For Environment Testing ONLYYY///////////////////////////////////////////////
				transaction_mon.c_address = 4;
				if (transaction_mon.c_address == 'd4)
					 -> usb_received;
				if (transaction_mon.c_data_out == 8'h44)
					 -> usb_received;

			end

		endtask : run


	endclass : config_space_monitor

endpackage

