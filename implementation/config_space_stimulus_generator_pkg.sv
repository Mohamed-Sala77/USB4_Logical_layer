	class config_space_stimulus_generator;

		config_transaction transaction_stim;
		mailbox #(config_transaction) mb_stim_drv, mb_stim_mod;
		mailbox mb_done;
		bit is_done; // to notify the stimulus generator that the driver finished the request


		//Events
		event usb_received, gen_received;


		function new (mailbox #(config_transaction) mb_stim_drv, mb_stim_mod, mailbox mb_done, event usb_received, gen_received);

			this.mb_stim_drv = mb_stim_drv;
			this.mb_stim_mod = mb_stim_mod;
			this.mb_done = mb_done;
			this.usb_received = usb_received;
			this.gen_received = gen_received;
			transaction_stim = new();

		endfunction : new


		task execute(input string select);
			case (select)
				
				"capability": begin
					transaction_stim.lane_disable = 1'b0;
					transaction_stim.c_data_in = 8'h40;
					//$display("Stim before put");
					$display("[CONFIG GENERATOR] SENDING USB4 capability info");
					mb_stim_drv.put(transaction_stim);
					mb_stim_mod.put(transaction_stim);
					$display("ALIIIIII config: %d: %d",mb_stim_drv.num(), mb_stim_mod.num() );
					//$display("Stim after put");
					@(usb_received);
				end

				"generation": begin
					transaction_stim.lane_disable = 1'b0;
					transaction_stim.c_data_in = 8'h44;
					$display("[CONFIG GENERATOR] SENDING GENERATION SPEED info");
					mb_stim_drv.put(transaction_stim);
					mb_stim_mod.put(transaction_stim);
					@(usb_received); // should be @(gen_received)
				end

			endcase // select

			
		endtask : execute



	endclass : config_space_stimulus_generator
