	class config_space_agent;

		mailbox #(config_transaction) mb_stim_drv;
		mailbox #(config_transaction) mb_mon_scr;
		mailbox mb_drv_done;

		config_space_driver driver;
		config_space_monitor monitor;

		virtual config_space_if v_config_if;

		//Events
		event usb_received, gen_received;


		function new (virtual config_space_if v_config_if, mailbox #(config_transaction) mb_stim_drv, mailbox #(config_transaction) mb_mon_scr, event usb_received, event gen_received);
			
			this.v_config_if = v_config_if;
			this.mb_stim_drv = mb_stim_drv;
			this.mb_mon_scr = mb_mon_scr;
			this.usb_received = usb_received;
			this.gen_received = gen_received;

		endfunction


		function void build();

			driver = new (mb_stim_drv, mb_drv_done);
			monitor = new (mb_mon_scr, usb_received);

			driver.config_vif = v_config_if;
			monitor.config_vif = v_config_if;
			//$display("Agent build");

		endfunction : build


		task run();

			fork
				//$display("Agent run");
				//stimulus_gen.run();
				driver.run();
				monitor.run();

			join_none

		endtask


	endclass : config_space_agent

