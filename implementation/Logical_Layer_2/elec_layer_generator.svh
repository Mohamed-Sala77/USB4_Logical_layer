//% ---------------------------- [✓]

package elec_generator_pkg;
	
	import elec_layer_tr_pkg::*;

	class elec_layer_generator;

		int counter = 0;

		// Event Signals
		event elec_gen_drv_done;
		event sbtx_high_recieved;

		//Transaction
		//elec_layer_tr blueprint; // used as an abstraction layer for future error injection 
		elec_layer_tr transaction;
		//upper_layer_tr UL_tr;

		// Mailboxes
		mailbox #(elec_layer_tr) elec_gen_mod; // connects stimulus generator to the reference model
		mailbox #(elec_layer_tr) elec_gen_drv; // connects Stimulus generator to the driver inside the agent
		mailbox #(OS_type) os_received_mon_gen; // connects monitor to the stimulus generator to indicated received ordered sets

		function new( mailbox #(elec_layer_tr) elec_gen_mod, mailbox #(elec_layer_tr) elec_gen_drv, mailbox #(OS_type) os_received_mon_gen, event elec_gen_drv_done, sbtx_high_recieved);

			// Mailbox connections between generator and agent
			this.elec_gen_mod = elec_gen_mod;
			this.elec_gen_drv = elec_gen_drv;

			this.os_received_mon_gen = os_received_mon_gen;

			// Event Signals Connections
			this.elec_gen_drv_done = elec_gen_drv_done;
			this.sbtx_high_recieved = sbtx_high_recieved;

			//Blueprint handle
			//blueprint = new();


			//transaction = new();
				
		endfunction : new
		
/*
		task run;
			

			elec_layer_tr elec_tr;
			forever begin
				
				//////////////////////////////////////////////////
				////////////////INPUT RANDOMIZATION //////////////
				//////////////////////////////////////////////////


				//UL_tr=new;
				assert(blueprint.randomize);
				elec_tr = blueprint.copy();

				//////////////////////////////////////////////////
				////////////////DRIVER ASSIGNMENT/////////////////
				//////////////////////////////////////////////////

				elec_gen_mod.put(elec_tr); // Sending transaction to the Reference Model
				elec_gen_drv.put(elec_tr); // Sending transaction to the Driver
				counter = counter + 1;
				@elec_gen_drv_done; // waiting for event triggering from driver
				

				//////////////////////////////////////////////////
				//////NUMBER OF Iterations TO BE PERFORMED ///////
				//////////////////////////////////////////////////

				if(counter == 20) begin
					//#21 // delay allows time for the final transaction to reach the scoreboard for comparison before exiting the simulation
					$finish;
				end
			end
			

		endtask : run
*/
	
	task sbrx_high;

		transaction = new();
		transaction.sbrx = 1'b1;
		transaction.electrical_to_transport = 0;
		transaction.phase = 3'b010; // phase 2
		elec_gen_drv.put(transaction); // Sending transaction to the Driver
		elec_gen_mod.put(transaction); // Sending transaction to the Reference model

		
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
					transaction.sbrx = 1;
					transaction.cmd_rsp_data = cmd_rsp_data;

					transaction.tr_os = tr; 

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

			// transaction.tr_os = tr; 

			// elec_gen_drv.put(transaction); // Sending transaction to the Driver
			// elec_gen_mod.put(transaction); // Sending transaction to the Reference model

			// @(elec_gen_drv_done);	// To wait for the driver to finish driving the data

	endtask : send_transaction



	task send_ordered_sets(input OS_type OS, input GEN generation);

		// according to the phase, the task determines when to send the ordered set 
		//(each generation needs to receive certain amount of ordered sets before sending the next ordered set)

		int counter = 0;
		OS_type ordered_set;
		int limit;

		transaction = new();
		
		transaction.phase = 4;	
		transaction.sbrx = 1;	
		transaction.o_sets = OS; //type of the ordered set
		transaction.tr_os = ord_set; // indicates whether the driver will send transaction or ordered set // ALIIIIIIIIIII
		transaction.gen_speed = generation; // to indicate the generation
		

		fork 
			begin
				case (OS)
				
				SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3 : 
				begin
					repeat (2) begin
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model

					$display("[GENERATOR] SENDING [%0p]",OS);
					@(elec_gen_drv_done);	// To wait for the driver to finish driving the data		
					$display("[GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);
					
					end
				end

				TS1_gen4, TS2_gen4, TS3, TS4: 
				begin
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model
					$display("[GENERATOR] SENDING [%0p]",OS);
					@(elec_gen_drv_done);	// To wait for the driver to finish driving the data
					$display("[GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);

				end

				default : 
				begin
					
				end

				endcase
			end

			begin // a mailbox from the monitor will signal that an ordered set has been received
				
				case (OS)
				
					SLOS1, SLOS2: begin
						while (counter != 1) // should be (counter != 2)
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(ordered_set);
							if (ordered_set == OS)
							begin
								counter = counter + 1;
								//$display("[ELEC GENERATOR] received [%0p] [%0d] times",ordered_set, counter);	
							end

							else 
							begin
								counter = 0;
							end

						end
						
					end

					TS1_gen2_3: begin

						if(generation == gen3) 
							limit = 16;
						else if (generation == gen2)
							limit = 32;

						while (counter != 1) // should be (counter != limit)
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(ordered_set);
							if ( ordered_set == OS)
							begin
								counter = counter + 1;	
								//$display("[ELEC GENERATOR] received [%0p] [%0d] times",ordered_set, counter);
							end

							else 
							begin
								counter = 0;
							end

						end
					
								
					end

					TS2_gen2_3: begin

						if(generation == "gen3") 
							limit = 8;
						else if (generation == "gen2")
							limit = 16;

						while (counter != 1) // should be (counter != limit)
						begin 
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(ordered_set);
							if ( ordered_set == OS)
							begin
								counter = counter + 1;
								//$display("[ELEC GENERATOR] received [%0p] [%0d] times",ordered_set, counter);
							end

							else 
							begin
								counter = 0;
							end

						end
					end

					TS1_gen4, TS2_gen4, TS3: 
					begin
						while (counter != 1)  // should be 16
							begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							os_received_mon_gen.get(ordered_set);
							if ( ordered_set == OS)
							begin
								counter = counter + 1;
								//$display("[ELEC GENERATOR] received [%0p] [%0d] times",ordered_set, counter);
							end

							else 
							begin
								counter = 0;
							end

						end
					end

					TS4: 
					begin
						while (counter != 16) 
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 	
							os_received_mon_gen.get(ordered_set);
							if ( ordered_set == OS)
							begin
								counter = counter + 1;		
							end

							else 
							begin
								counter = 0;
							end

						end
					end


					default : begin
						
					end

				endcase 
				

			end

		join


	endtask : send_ordered_sets

	task phase1_force ();

		transaction = new(); 
		transaction.phase = 1 ; 
		elec_gen_mod.put(transaction); // Sending transaction to the Reference model 
		
	endtask //phase1_force

 

	endclass : elec_layer_generator
endpackage : elec_generator_pkg

