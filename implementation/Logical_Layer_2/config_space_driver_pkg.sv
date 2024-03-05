//% ---------------------------- [✓]

package config_space_driver_pkg;
import config_space_pkg::*;

	class config_space_driver;

		config_transaction transaction_drv;
		mailbox #(config_transaction) mb_drv;
		mailbox mb_done;
		virtual config_space_if config_vif;


		function new (mailbox #(config_transaction) mb_drv, mailbox mb_done);

			this.mb_drv = mb_drv;
			this.mb_done = mb_done;
			transaction_drv = new();

		endfunction : new


		task run;

			forever
			begin
				//$display("Driver run");

				mb_drv.get(transaction_drv);
				//$display("driver wait");
				//mb_done.put (1'b0);

				@(posedge config_vif.clk);
				config_vif.lane_disable = transaction_drv.lane_disable;
				config_vif.c_data_in = transaction_drv.c_data_in;

				//@(negedge config_vif.clk);
				//mb_done.put(1'b1);

			end

		endtask : run


	endclass : config_space_driver

endpackage

