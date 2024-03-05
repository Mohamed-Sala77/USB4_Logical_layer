
	class elec_layer_generator;

		//Counters to count the number of ordered sets received on each lane
		int counter_lane_0 = 0;
		int counter_lane_1 = 0;
		int counter = 0;

		// Event Signals
		event elec_gen_drv_done;
		event sbtx_high_recieved;

		//Transaction
		elec_layer_tr transaction;
		elec_layer_tr tr_mon; //transaction received from the monitor 
		
		// Mailboxes
		mailbox #(elec_layer_tr) elec_gen_mod; // connects stimulus generator to the reference model
		mailbox #(elec_layer_tr) elec_gen_drv; // connects Stimulus generator to the driver inside the agent
		mailbox #(elec_layer_tr) os_received_mon_gen; // connects monitor to the stimulus generator to indicated received ordered sets

		function new( mailbox #(elec_layer_tr) elec_gen_mod, mailbox #(elec_layer_tr) elec_gen_drv, mailbox #(elec_layer_tr) os_received_mon_gen, event elec_gen_drv_done, sbtx_high_recieved);

			// Mailbox connections between generator and agent
			this.elec_gen_mod = elec_gen_mod;
			this.elec_gen_drv = elec_gen_drv;

			this.os_received_mon_gen = os_received_mon_gen;

			// Event Signals Connections
			this.elec_gen_drv_done = elec_gen_drv_done;
			this.sbtx_high_recieved = sbtx_high_recieved;

			

		endfunction : new
		

	
	task sbrx_high;

		transaction = new();
		transaction.sbrx = 1'b1;
		transaction.electrical_to_transport = 0;
		transaction.phase = 3'b010; // phase 2
		elec_gen_drv.put(transaction); // Sending transaction to the Driver
		elec_gen_mod.put(transaction); // Sending transaction to the Reference model
		$display("[ELEC GENERATOR] SENDING phase 2 SBRX HIGH");
		
		@(sbtx_high_recieved);

	endtask : sbrx_high



	task send_transaction (input tr_type trans_type = None , input int phase = 3, read_write = 0, address = 0, len = 0, cmd_rsp_data = 0);

		// Logical layer transactions is sent by default in phase 3 (except LT fall: any phase)
		transaction = new();

		case (trans_type)
				
				LT_fall: begin //
					transaction.phase = phase;
					transaction.transaction_type = trans_type;
					transaction.tr_os = tr; 
					$display("[ELEC GENERATOR] sending [LT_FALL] Transaction");
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model

					@(elec_gen_drv_done);
				end

				AT_cmd, AT_rsp : begin //AT_cmd, AT_rsp
					transaction.phase = phase;
					transaction.transaction_type = trans_type;
					transaction.read_write = read_write;
					transaction.address = address;
					transaction.len = len;
					transaction.cmd_rsp_data = cmd_rsp_data;

					transaction.tr_os = tr; 
					$display("[ELEC GENERATOR] sending [%0p] Transaction",trans_type);
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model

					@(elec_gen_drv_done);
				end


				/*
				default : begin
					//transaction.phase = phase;
					transaction.transaction_type = AT_cmd;
					transaction.read_write = read_write;
					transaction.address = 0;
					transaction.len = 0;
					transaction.cmd_rsp_data = 0;
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					//@(EVENT from ()!!!!!!!!!!!!!);
				end
				*/
			endcase

			$display("\n");

			// transaction.tr_os = tr; 

			// elec_gen_drv.put(transaction); // Sending transaction to the Driver
			// elec_gen_mod.put(transaction); // Sending transaction to the Reference model

			// @(elec_gen_drv_done);	// To wait for the driver to finish driving the data

	endtask : send_transaction



	task send_ordered_sets(input OS_type OS, input GEN generation);

		// according to the phase, the task determines when to send the ordered set 
		//(each generation needs to receive certain amount of ordered sets before sending the next ordered set)

		int counter_lane_0 = 0;
		int counter_lane_1 = 0;
		OS_type ordered_set;
		int limit;

		transaction = new();
		tr_mon = new();

		
		transaction.phase = 4;
		transaction.o_sets = OS; //type of the ordered set
		transaction.tr_os = ord_set; // indicates whether the driver will send transaction or ordered set // ALIIIIIIIIIII
		transaction.gen_speed = generation; // to indicate the generation
		transaction.sbrx = 1;

		fork 
			begin
				case (OS)
				
				SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3 : 
				begin
					repeat (2) begin
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model

					$display("[ELEC GENERATOR] SENDING [%0p]",OS);
					@(elec_gen_drv_done);	// To wait for the driver to finish driving the data		
					$display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);
					
					end
				end

				TS1_gen4, TS2_gen4, TS3, TS4: 
				begin
					
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model
					$display("[ELEC GENERATOR] SENDING [%0p]",OS);
					@(elec_gen_drv_done);	// To wait for the driver to finish driving the data
					$display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);

				end

				default : 
				begin
					
				end

				endcase
			end

			begin // a mailbox from the monitor will signal that an ordered set has been received
				
				case (OS)
				
					SLOS1, SLOS2: begin
						while ( (counter_lane_0 < 2) || (counter_lane_1 < 2) )  // should be (counter != 2)
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end

							//Storing the time when first SLOS1 was sent to calculate tTrainingError
							if (OS == SLOS1)
							begin
								if (counter_lane_0 == 1)
								begin
									lane_0_tTrainingError_time = $time;
								end

								if (counter_lane_1 == 1)
								begin
									lane_1_tTrainingError_time = $time;
									
								end
							end

						end
						
					end

					TS1_gen2_3: begin

						if(generation == gen3) 
							limit = 16;
						else if (generation == gen2)
							limit = 32;

						while ((counter_lane_0 < 2) || (counter_lane_1 < 2)) // should be (counter != limit)
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end

						end
					
								
					end

					TS2_gen2_3: begin

						if(generation == "gen3") // string should be changed
							limit = 8;
						else if (generation == "gen2")
							limit = 16;

						while ((counter_lane_0 < 2) || (counter_lane_1 < 2)) // should be (counter != limit)
						begin 
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end


							//Checking that the training duration is less than tTrainingError (500us)
							if (counter_lane_0 == 2) //should be == limit
							begin
								assert($time <= (lane_0_tTrainingError_time + tTrainingError) );
							end

							if (counter_lane_1 == 2) //should be == limit
							begin
								assert($time <= (lane_1_tTrainingError_time + tTrainingError) );
							end
							

						end
					end

					TS1_gen4, TS2_gen4, TS3: 
					begin
						while ((counter_lane_0 < 1) || (counter_lane_1 < 1))  // should be 16
							begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end

						end
					end

					TS4: 
					begin
						while ((counter_lane_0 < 1) || (counter_lane_1 < 1))  //should be 16
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 	
							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("Time: %0t, [ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",$time, tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end

						end
					end


					default : begin
						
					end

				endcase 
				

			end

		join

		$display("\n");


	endtask : send_ordered_sets

	task phase_force (input int num);

		transaction = new(); 
		transaction.phase = num ; 
		elec_gen_mod.put(transaction); // Sending transaction to the Reference model 
		
	endtask //phase_force

 

	endclass : elec_layer_generator
