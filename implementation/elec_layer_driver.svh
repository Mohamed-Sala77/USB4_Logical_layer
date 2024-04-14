	class elec_layer_driver;

		// Event Signals
		event elec_gen_drv_done;

		//data_sent transaction
		elec_layer_tr elec_tr;

		//Data to be sent to the DUT
		bit [9:0] data_sent [$]; 		//The whole transaction to be sent to the DUT 
		bit [7:0] data_symbol [$]; 	//Data symbol inside AT cmd and AT rsp


		//CRC calculations
		bit [7:0] high_crc, low_crc;

		//TS1 and TS2 symbols for Gen 2 and Gen 3
		bit [63:0] TS1_GEN_2_3_lane0, TS1_GEN_2_3_lane1, TS2_GEN_2_3_lane0, TS2_GEN_2_3_lane1; //TS1 and TS2 ordered sets for gen 2 and gen 3
		bit [2:0] lane_bonding_target;
		
		//TS symbols for Gen 4
		bit [27:0] TS;			//TS symbol to be sent //bit [447:0] TS;			
		bit [419:0] PRS;		//Pseudo Random Sequence

		// PSEUDO RANDOM ORDERED SETS
		bit [1:0] PRTS7_lane0 [$];
		bit [1:0] PRTS7_lane1 [$];
		bit PRBS11_lane0 [$];
		bit PRBS11_lane1 [$];  



		bit [3:0] indication;	//Indication field (notifies the adjacent Router about the progress of the Lane Initialization)
		bit [7:0] indication_4;	//same as the previous but for TS4 (8 bits instead of 4 bits)
		bit [7:0] counter;		//Counter field (carries the number of TS sent)
		bit [3:0] counter_4;		//same as the previous but for TS4 (4 bits instead of 8 bits)

		// SYMBOL GENERATION CLASS
		TS_Symbols TS_Symbols;

		// Virtual Interface
		virtual electrical_layer_if v_if;

		// Mailboxes
		mailbox #(elec_layer_tr) elec_gen_drv; // connects Stimulus generator to the driver inside the agent


		function new(input virtual electrical_layer_if v_if, mailbox #(elec_layer_tr) elec_gen_drv, event elec_gen_drv_done);

			//Interface Connections
			this.v_if = v_if;

			// Mailbox connections between (Driver) and (UL Agent)
			this.elec_gen_drv = elec_gen_drv;
			
			// Event Signals Connections
			this.elec_gen_drv_done = elec_gen_drv_done;

			//Constructing the data_sents
			//elec_tr = new();
				
		endfunction : new


		task run;

			TS_Symbols = new();
			TS_Symbols.calculate_TS();

			forever begin

				//////////////////////////////////////////////////
				/////RECEIVING TEST STIMULUS FROM generator //////
				//////////////////////////////////////////////////
				elec_tr = new();
				elec_gen_drv.get(elec_tr);
				v_if.generation_speed = elec_tr.gen_speed; // communicate gen speed to the monitor
				v_if.phase = elec_tr.phase;

				//////////////////////////////////////////////////
				//////////////PIN LEVEL ASSIGNMENT ///////////////
				//////////////////////////////////////////////////


				// phase 3 and 4 triggering signals
				case (elec_tr.tr_os)

					tr: begin // Transaction 

						case (elec_tr.transaction_type)


							LT_fall: begin
								//$display("Driver operation");
								$display("[ELEC DRIVER] Sending LT_FALL");
								// To disable Lane 0
								data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(LSE_lane0), stop_bit }, {start_bit, reverse_data(~(LSE_lane0)), stop_bit}};

								$display("[ELEC DRIVER] LT_Fall lane 0 Data  to be sent: [%0p]",data_sent);
								foreach (data_sent[i,j])
									begin
										@(negedge v_if.SB_clock);
										//$display("[DRIVER] LT fall data sent[%0d]",data_sent[i][j]);
										v_if.sbrx = data_sent[i][j];
									end

								
								// To disable Lane 1
								data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(LSE_lane1) ,stop_bit }, {start_bit, reverse_data(~(LSE_lane1)), stop_bit }};
								//$display("[DRIVER] LT Data sent: [%0p]",data_sent);
								$display("[ELEC DRIVER] LT_Fall lane 1 Data  to be sent: [%0p]",data_sent);
							 	foreach (data_sent[i,j])
							 		begin
							 			@(negedge v_if.SB_clock);
							 			v_if.sbrx = data_sent[i][j];
							 		end

							 	-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);

							end


							AT_cmd: begin
								$display("[ELEC DRIVER] Sending AT_cmd");
								data_symbol = {elec_tr.address, {elec_tr.read_write, elec_tr.len}, elec_tr.cmd_rsp_data};
								$display("data_symbol: %p", data_symbol);
								CRC_generator_Ali(STX_cmd,{elec_tr.address, {elec_tr.len, elec_tr.read_write}}, 3, high_crc, low_crc); // Aliiiiiiiiiiiiiiiiiii
								//crc_calculation(STX_cmd, data_symbol, high_crc, low_crc); // ALIIIIIIIIIIIIIIIIIIIIIIIIII
								//high_crc = 8'b0; low_crc = 8'b0;


								// data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(STX_cmd), stop_bit},
								// 			 {start_bit, reverse_data(elec_tr.address), stop_bit}, 						// data symbol
								// 			 {start_bit, reverse_data({elec_tr.read_write,elec_tr.len}), stop_bit}, 		// data symbol // check order
								// 			 {start_bit, reverse_data(elec_tr.cmd_rsp_data[23:16]), stop_bit}, 				// data symbol
								// 			 {start_bit, reverse_data(elec_tr.cmd_rsp_data[15:8]), stop_bit},				// data symbol 
								// 			 {start_bit, reverse_data(elec_tr.cmd_rsp_data[7:0]), stop_bit}, 			//data symbol
								// 			 {start_bit, reverse_data(low_crc), stop_bit}, {start_bit, reverse_data(high_crc), stop_bit}, // crc bits
								// 			 {start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(ETX), stop_bit}};

								// modified version for debugging			 
								data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(STX_cmd), stop_bit},
											 {start_bit, reverse_data(elec_tr.address), stop_bit}, 						// data symbol
											 {start_bit, reverse_data({elec_tr.len,elec_tr.read_write}), stop_bit}, 		// data symbol // check order // ALIIIIIIIIIIIIIIIIIIIIIIIII
											 {start_bit, reverse_data(low_crc), stop_bit}, {start_bit, reverse_data(high_crc), stop_bit}, // crc bits
											 {start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(ETX), stop_bit}};

								$display("[ELEC DRIVER] Time: %0t   AT_cmd Data to be sent: [%0p]", $time, data_sent);
								//$display("[DRIVER] AT_cmd length to be sent: [%0p]",{ reverse_data({elec_tr.read_write,elec_tr.len})});
								foreach (data_sent[i,j])
									begin
										@(negedge v_if.SB_clock);
								//		$display("[DRIVER] AT_cmd data sent[%0d]",data_sent[i][j]);
										v_if.sbrx = data_sent[i][j];
									end

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);

							end


							AT_rsp: begin

								data_symbol = {elec_tr.address, {elec_tr.len, elec_tr.read_write}, elec_tr.cmd_rsp_data[7:0], elec_tr.cmd_rsp_data[15:8], elec_tr.cmd_rsp_data[23:16]};
								$display("&&&&&&&&&&&&AT RESP DATA SYMBOL %p",data_symbol);

								crc_calculation(STX_rsp, data_symbol, high_crc, low_crc);
								// ALIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII LINE 173
								data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit,reverse_data(STX_rsp), stop_bit},
											 {start_bit, reverse_data(elec_tr.address), stop_bit}, 						// data symbol
											 {start_bit, reverse_data({elec_tr.len,elec_tr.read_write}), stop_bit}, 		// data symbol  ALIIIIIIIIIIIIIIIIIIII
											 {start_bit, reverse_data(elec_tr.cmd_rsp_data[7:0]), stop_bit}, 				// data symbol ALIIIIIIIIIIIIIIIIIIIIIIII
											 {start_bit, reverse_data(elec_tr.cmd_rsp_data[15:8]), stop_bit},				// data symbol ALIIIIIIIIIIIIIIIIIIIIIIIIII
											 {start_bit, reverse_data(elec_tr.cmd_rsp_data[23:16]), stop_bit}, 			//data symbol ALIIIIIIIIIIIIIIIIIIIIIIIIIII
											 {start_bit, reverse_data(low_crc), stop_bit}, {start_bit, reverse_data(high_crc), stop_bit}, // crc bits
											 {start_bit, reverse_data(DLE), stop_bit}, {start_bit,reverse_data(ETX), stop_bit}};

								$display("[ELEC DRIVER] Time: %0t, AT_Rsp Data to be sent: [%0p]",$time, data_sent);
								foreach (data_sent[i,j])
									begin
										@(negedge v_if.SB_clock);
										v_if.sbrx = data_sent[i][j];
									end

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);

							end

						endcase // elec_tr.transaction_type
					end 

					// Each ordered set will be sent on both lanes simultaneously during training	
					ord_set: begin //ordered set 

						case (elec_tr.o_sets)

							SLOS1: begin
								
								$display("[ELEC DRIVER] SLOS1 is being SENT for BOTH LANES");

								if (elec_tr.gen_speed == gen2)
								begin
									$display("[ELEC DRIVER] SLOS1_64 IS being sent");
									foreach (SLOS1_64[i,j])
									begin
										@(negedge v_if.gen2_lane_clk);
										v_if.lane_0_rx = SLOS1_64[i][65 - j];		
										v_if.lane_1_rx = SLOS1_64[i][65 - j];
										//$display("[ELEC DRIVER] SLOS1 BITS: [%0b]",SLOS1_64[i][65 - j]);		
									end
								end	
								

								else if (elec_tr.gen_speed == gen3)
								begin
									
									foreach (SLOS1_128[i,j])
									begin
										@(negedge v_if.gen3_lane_clk);
										v_if.lane_0_rx = SLOS1_128[i][131 - j];		
										v_if.lane_1_rx = SLOS1_128[i][131 - j];		
									end
									
								end

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);
								
							end


							SLOS2: begin

								$display("[ELEC DRIVER] SLOS2 is being SENT for BOTH LANES");

								if (elec_tr.gen_speed == gen2)
								begin
	
									foreach (SLOS2_64[i,j])
									begin
										@(negedge v_if.gen2_lane_clk);
										v_if.lane_0_rx = SLOS2_64[i][65 - j];		
										v_if.lane_1_rx = SLOS2_64[i][65 - j];		
									end
										
								end

								else if (elec_tr.gen_speed == gen3)
								begin
									
									foreach (SLOS2_128[i,j])
									begin
										@(negedge v_if.gen3_lane_clk);
										v_if.lane_0_rx = SLOS2_128[i][131 - j];		
										v_if.lane_1_rx = SLOS2_128[i][131 - j];		
									end
										
								end

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);

							end


							TS1_gen2_3: begin
								
								///////////////////////////////////
								// In case of symmetric link
								lane_bonding_target = 3'b001;
								///////////////////////////////////


								TS1_GEN_2_3_lane0 = {5'b0, lane_bonding_target, lane_number_0, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS1, SCR};
								TS1_GEN_2_3_lane1 = {5'b0, lane_bonding_target, lane_number_1, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS1, SCR};

								$display("[ELEC DRIVER] TS1_GEN2_3 is being SENT for BOTH LANES ");

								foreach (TS1_GEN_2_3_lane0[i])
									begin
										wait_negedge (elec_tr.gen_speed);
										v_if.lane_0_rx = TS1_GEN_2_3_lane0[(TS_GEN_2_3_SIZE - 1) - i];		
										v_if.lane_1_rx = TS1_GEN_2_3_lane1[(TS_GEN_2_3_SIZE - 1) - i];	
										//$display("Element [%0d] in TS1_GEN_2_3_lane0: %0b", i, TS1_GEN_2_3_lane0[i]);	
									end

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);
								
							end


							TS2_gen2_3: begin

								///////////////////////////////////
								// In case of symmetric link
								lane_bonding_target = 3'b001;
								///////////////////////////////////


								TS2_GEN_2_3_lane0 = {5'b0, lane_bonding_target, lane_number_0, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS2, SCR};
								TS2_GEN_2_3_lane1 = {5'b0, lane_bonding_target, lane_number_1, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS2, SCR};

								$display("[ELEC DRIVER] TS2_GEN2_3 is being SENT for BOTH LANES");

								foreach (TS2_GEN_2_3_lane0[i])
									begin
										wait_negedge (elec_tr.gen_speed);
										v_if.lane_0_rx = TS2_GEN_2_3_lane0[(TS_GEN_2_3_SIZE - 1) - i];		
										v_if.lane_1_rx = TS2_GEN_2_3_lane1[(TS_GEN_2_3_SIZE - 1) - i];		
									end

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);

							end


							TS1_gen4: begin

								indication = 4'h2; //Assuming the receiver is ready to receive PAM3 signaling
								counter = 8'h0F;

								//PSUEDO RANDOM SEQUENCES
								PRBS11 (420, PRBS11_lane0_seed, PRBS11_lane0);
								//$display("[ELEC DRIVER]: PRBS11 for lane_0: [%0P]",PRBS11_lane0);

								PRBS11 (420, PRBS11_lane1_seed, PRBS11_lane1);
								//$display("[ELEC DRIVER]: PRBS11 for lane_1: [%0P]",PRBS11_lane1);

								//TS = {CURSOR, indication, ~(indication), counter, PRS};
								TS = {CURSOR, indication, ~(indication), counter};

								$display("[ELEC DRIVER] TS1_gen4 is being SENT for BOTH LANES");

								foreach (TS[i])
									begin
										@(negedge v_if.gen4_lane_clk);
										//$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end


								fork
									begin
										foreach (PRBS11_lane0[i])
											begin
												@(negedge v_if.gen4_lane_clk);
												//$display("[DRIVER] PRBS11_lane0 bits sent[%0b]",PRBS11_lane0[i]);
												v_if.lane_0_rx = PRBS11_lane0[i];			
											end
									end

									begin
										foreach (PRBS11_lane1[i])
											begin
												@(negedge v_if.gen4_lane_clk);
												//$display("[DRIVER] PRBS11_lane1 bits sent[%0b]",PRBS11_lane1[i]);	
												v_if.lane_1_rx = PRBS11_lane1[i];		
											end
									end
									
								join
								

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);	


							end


							TS2_gen4: begin

								indication = 4'h4; //Assuming the receiver finished PAM3 TxFFE negotiation
								counter = 8'h0F;

								///////////////////////////////////
								//PRS = **************************************;
								///////////////////////////////////
								PRTS7 (210, PRTS7_lane0_seed, PRTS7_lane0);
								//$display("[ELEC DRIVER]: PRTS7: [%0P]",PRTS7_lane0);

								PRTS7 (210, PRTS7_lane1_seed, PRTS7_lane1);
								//$display("[ELEC DRIVER]: PRTS7: [%0P]",PRTS7_lane1);

								//TS = {CURSOR, indication, ~(indication), counter, PRS};
								TS = {CURSOR, indication, ~(indication), counter};

								$display("[ELEC DRIVER] TS2_gen4 is being SENT for BOTH LANES ");


								foreach (TS[i])
									begin
										@(negedge v_if.gen4_lane_clk);
										//$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end

								fork
									begin
										foreach (PRTS7_lane0[i,j])
										begin
											@(negedge v_if.gen4_lane_clk);		
											v_if.lane_0_rx = PRTS7_lane0[i][1 - j];		
											//$display("TS2_GEN4 SENT BIT: %B",PRTS7_lane0[i][1 - j]);
										end
									end

									begin
										foreach (PRTS7_lane1[i,j])
										begin
											@(negedge v_if.gen4_lane_clk);
											v_if.lane_1_rx = PRTS7_lane1[i][1 - j];	
											//$display("[ELEC DRIVER] TS2_GEN4 lane 1SENT BIT: %0B",PRTS7_lane1[i][1 - j]);	
										end
									end
								join
								
								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);
									

							end


							TS3: begin

								indication = 4'h6; //Assuming the receiver detected Gen 4 TS3 Headers
								counter = 8'h0F;

								///////////////////////////////////
								//PRS = **************************************;
								///////////////////////////////////
								PRTS7 (210,  PRTS7_lane0_seed, PRTS7_lane0); //should be 210
								//$display("[ELEC DRIVER]: PRTS7 lane0: [%0P]",PRTS7_lane0);

								PRTS7 (210,  PRTS7_lane1_seed, PRTS7_lane1); //should be 210
								//$display("[ELEC DRIVER]: PRTS7 lane1: [%0P]",PRTS7_lane1);

								//TS = {CURSOR, indication, ~(indication), counter, PRS};
								TS = {CURSOR, indication, ~(indication), counter};

								$display("[ELEC DRIVER] TS3 is being SENT for BOTH LANES");

								foreach (TS[i])
									begin
										@(negedge v_if.gen4_lane_clk);
										//$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end

								fork
									begin
										foreach (PRTS7_lane0[i,j])
										begin
											@(negedge v_if.gen4_lane_clk);		
											v_if.lane_0_rx = PRTS7_lane0[i][1 - j];	
											//$display("[ELEC DRIVER] TS3_GEN4 lane 1SENT BIT: %0B",PRTS7_lane1[i][1 - j]);		
										end
									end

									begin
										foreach (PRTS7_lane1[i,j])
										begin
											@(negedge v_if.gen4_lane_clk);
											v_if.lane_1_rx = PRTS7_lane1[i][1 - j];		
										end
									end
								join

								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);

							end


							TS4: begin

								indication_4 = 8'hF0;

								///////////////////////////////////
								counter_4 = 4'h0;
								///////////////////////////////////


								///////////////////////////////////
								//PRS = **************************************;
								///////////////////////////////////
								//PRTS7 (420, 14'b01010101010101, PRTS7_lane0);
								PRTS7 (210,  PRTS7_lane0_seed, PRTS7_lane0);

								//$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane0);

								
								PRTS7 (210,  PRTS7_lane1_seed, PRTS7_lane1);
								//$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane1);



								//TS4 is different from TS1, TS2 and TS3 (bitwise compliment of counter not indication)
								// and the size of the indication field is different	
								//TS = {CURSOR, indication_4, counter, ~(counter), PRS}; 
								
								TS = {CURSOR, indication_4, counter_4, ~(counter_4)}; 


								$display("[ELEC DRIVER] TS4 is being SENT for BOTH LANES");


								foreach (TS[i])
									begin
										@(negedge v_if.gen4_lane_clk);
										//$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end


								fork
									begin
										foreach (PRTS7_lane0[i,j])
										begin
											@(negedge v_if.gen4_lane_clk);		
											v_if.lane_0_rx = PRTS7_lane0[i][1 - j];		
										end
									end

									begin
										foreach (PRTS7_lane1[i,j])
										begin
											@(negedge v_if.gen4_lane_clk);
											v_if.lane_1_rx = PRTS7_lane1[i][1 - j];		
										end
									end
								join
								
								-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
								$display("elec_gen_drv_done at time: %0t", $time);

							end


						endcase // elec_tr.o_sets
					


					end	


				endcase // elec_tr.tr_os

					
				/*
				if ( (elec_tr.tr_os == tr) || (elec_tr.tr_os == ord_set) )
				begin
					-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
					$display("elec_gen_drv_done at time: %0t", $time);
				end
					*/

				//#200  
				// for phase 2 only for now
				case (elec_tr.phase)


					3'b010: begin // phase 2
						@(posedge v_if.SB_clock);
						v_if.sbrx = elec_tr.sbrx;
						v_if.phase = elec_tr.phase;
						sbrx_raised_time = $time;
						#(tConnectRx);
						-> elec_gen_drv_done; // Triggering Event to notify stimulus generator
						$display("elec_gen_drv_done at time: %0t", $time);
					end
					/*
					3'b011: begin // phase 3

					end

					3'b110: begin // phase 4

					end

					3'b101: begin // phase 5

					end

					default: begin

					end
					*/

				endcase // elec_tr.phase
				

				

			end
			

		endtask : run



		task crc_calculation (input bit [7:0] stx, bit [7:0] data_symb[$], output bit [7:0] high_crc_task, low_crc_task);
			
			//***********************************************************
			
			localparam crc_length = 16;
			localparam data_length = 24;


			bit [crc_length-1:0] SEED = 'hFFFF;
			bit [crc_length-1:0] POLY = 'h8005;
			//bit [crc_length-1:0] POLY = 'hA001;

			//bit [data_length-1:0] data_for_crc;
			bit [crc_length-1:0] crc;
			bit crc_last;
			
			//***********************************************************

			bit [47:0] data_for_crc;  
			bit [7:0] temp;

			data_for_crc = {<< 8 { {<<{stx, data_symb}} } };
			$display("data_for_crc: %h", data_for_crc);
			
			crc = SEED;

			foreach (data_for_crc[i])
			begin
				//$display("Data for crc [%0d]: %0b", i, data_for_crc[i]);
				crc_last = crc[crc_length - 1];

				for (int n = crc_length - 1; n > 0; n--)
					begin
						if (POLY[n] == 1)
						begin
							crc [n] = crc [n-1] ^ crc_last ^ data_for_crc[i];
						end

						else
						begin
							crc[n] = crc[n-1];
						end
					end

				crc[0] = data_for_crc[i] ^ crc_last;
			
			end

			$display("Final CRC calculations: %b", crc);

			high_crc_task = {crc[0], crc[1], crc[2], crc[3], crc[4], crc[5], crc[6], crc[7]};
			low_crc_task = {crc[8], crc[9], crc[10], crc[11], crc[12], crc[13], crc[14], crc[15]};
			
			$display("CRC: %b%0b", high_crc_task, low_crc_task);
			$display("CRC_LOW: %h \n CRC_HIGH: %h", low_crc_task, high_crc_task);


		endtask : crc_calculation


		// CLOCK DETERMINATION
		task wait_negedge (input GEN generation);
			if (generation == gen2)
			begin
				@(negedge v_if.gen2_lane_clk);
			end
			else if (generation == gen3)
			begin
				@(negedge v_if.gen3_lane_clk);
			end
			else if (generation == gen4)
			begin
				@(negedge v_if.gen4_lane_clk);
			end
		endtask





		function bit [7:0] reverse_data (input bit[7:0] data);
			bit [7:0] data_reversed; 
			foreach (data[i]) begin
				data_reversed[7-i] = data[i];
			end
			return data_reversed;
		endfunction

















  task CRC_generator_Ali(input [7:0] STX, input [39:0] data_symbol, input [2:0] size, output bit [7:0] high_crc_task, low_crc_task );
    reg [15:0] crc;
    reg [47:0] data;
    integer i;
    bit crc_last;
    localparam POLY = 16'h8005;
    // Initialize CRC
    crc = 16'hFFFF;

    //!!!!!!!!!!!!!!!! PLEASEE NOTE: data_symbol's cmd_rsp_data mafrood ne3ks el input bytes (lel function input bas msh el elec_reference kolo) 3ashan terg3 tet3ks we teb2a least to most significant tanii (24'h033305 badal 24'h053303)
    $display("data_symbol %b",data_symbol);
    data_symbol = data_symbol << 8*(6-size);
    // Concatenate STX and data_symbol
    data = {STX,data_symbol};
    $display("data before: %b",data);
	data = {<<8{{>>{data}}}};
    $display("data after: %b",data);
   
    
	for (i = 0; i < size*8; i = i + 1) begin
    	crc_last = crc[15];
    	for (int n = 15; n > 0; n = n - 1) begin
     		if (POLY[n] == 1'b1) begin
       		crc[n] = crc[n-1] ^ crc_last ^ data[i];
      	end else begin
        	crc[n] = crc[n-1];
      		end
    	end
    	crc[0] = data[i] ^ crc_last;
  	end
	
    
    // Flip CRC
    crc = {<<{crc}};

    // XOR with 0000h
    //crc_received = crc ^ 16'h0000;

    low_crc_task = crc[7:0];
    high_crc_task = crc[15:8];

  endtask





		
	endclass : elec_layer_driver


