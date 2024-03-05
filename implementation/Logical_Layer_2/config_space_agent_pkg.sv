//% ---------------------------- [✓]

package config_space_agent_pkg;

import config_space_pkg::*;
import config_space_stimulus_generator_pkg::*;
import config_space_driver_pkg::*;
import config_space_monitor_pkg::*;

	

	class config_space_agent;

		mailbox #(config_transaction) mb_stim_drv, mb_stim_mod;
		mailbox #(config_transaction) mb_mon_scr;
		mailbox mb_drv_done;

		config_space_stimulus_generator stimulus_gen;
		config_space_driver driver;
		config_space_monitor monitor;

		virtual config_space_if v_config_if;

		//Events
		event usb_received, gen_received;


		function new (virtual config_space_if v_config_if, mailbox #(config_transaction) mb_stim_mod, mailbox #(config_transaction) mb_mon_scr);
			
			this.v_config_if = v_config_if;
			this.mb_stim_mod = mb_stim_mod;
			this.mb_mon_scr = mb_mon_scr;

		endfunction


		function void build();

			mb_stim_drv = new();
			mb_drv_done = new();

			stimulus_gen = new (mb_stim_drv, mb_stim_mod, mb_drv_done, usb_received, gen_received);
			driver = new (mb_stim_drv, mb_drv_done);
			monitor = new (mb_mon_scr, usb_received);

			driver.config_vif = v_config_if;
			monitor.config_vif = v_config_if;
			//$display("Config Agent build");

		endfunction : build


		task run();

			fork
				$display("Config Agent run");
				//stimulus_gen.run();
				driver.run();
				monitor.run();

			join_none

		endtask


	endclass : config_space_agent


endpackage

