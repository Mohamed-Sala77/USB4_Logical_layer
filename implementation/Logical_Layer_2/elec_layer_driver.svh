
package elec_driver_pkg;
	
	import elec_layer_tr_pkg::*;
	import symbols::*;


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
			forever begin

				//////////////////////////////////////////////////
				/////RECEIVING TEST STIMULUS FROM generator //////
				//////////////////////////////////////////////////
				elec_tr = new();
				elec_gen_drv.get(elec_tr);
				

				//////////////////////////////////////////////////
				//////////////PIN LEVEL ASSIGNMENT ///////////////
				//////////////////////////////////////////////////


				// phase 3 and 4 triggering signals
				case (elec_tr.tr_os)

					tr: begin // Transaction 

						case (elec_tr.transaction_type)


							LT_fall: begin
								////$display("Driver operation");
								////$display("[DRIVER] Sending LT_FALL");
								// To disable Lane 0
								data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(LSE_lane0), stop_bit }, {start_bit, reverse_data(~(LSE_lane0)), stop_bit}};

								////$display("[DRIVER] LT_Fall lane 0 Data  to be sent: [%0p]",data_sent);
								foreach (data_sent[i,j])
									begin
										@(negedge v_if.clk);
										////$display("[DRIVER] LT fall data sent[%0d]",data_sent[i][j]);
										v_if.sbrx = data_sent[i][j];
									end

								
								// To disable Lane 1
								data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(LSE_lane1) ,stop_bit }, {start_bit, reverse_data(~(LSE_lane1)), stop_bit }};
								////$display("[DRIVER] LT Data sent: [%0p]",data_sent);
								////$display("[DRIVER] LT_Fall lane 1 Data  to be sent: [%0p]",data_sent);
							 	foreach (data_sent[i,j])
							 		begin
							 			@(negedge v_if.clk);
							 			v_if.sbrx = data_sent[i][j];
							 		end

							end


							AT_cmd: begin
								//$display("[DRIVER] Sending AT_cmd");
								data_symbol = {elec_tr.address, elec_tr.len, elec_tr.read_write, elec_tr.cmd_rsp_data};

								crc_calculation(STX_cmd, data_symbol, high_crc, low_crc);
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
											 {start_bit, reverse_data({elec_tr.read_write,elec_tr.len}), stop_bit}, 		// data symbol // check order
											 {start_bit, reverse_data(low_crc), stop_bit}, {start_bit, reverse_data(high_crc), stop_bit}, // crc bits
											 {start_bit, reverse_data(DLE), stop_bit}, {start_bit, reverse_data(ETX), stop_bit}};

								//$display("[DRIVER] AT_cmd Data to be sent: [%0p]",data_sent);
								////$display("[DRIVER] AT_cmd length to be sent: [%0p]",{ reverse_data({elec_tr.read_write,elec_tr.len})});
								foreach (data_sent[i,j])
									begin
										@(negedge v_if.clk);
								//		//$display("[DRIVER] AT_cmd data sent[%0d]",data_sent[i][j]);
										v_if.sbrx = data_sent[i][j];
									end
							end


							AT_rsp: begin

								data_symbol = {elec_tr.address, elec_tr.len, elec_tr.read_write, elec_tr.cmd_rsp_data};

								crc_calculation(STX_rsp, data_symbol, high_crc, low_crc);

								data_sent = {{start_bit, reverse_data(DLE), stop_bit}, {start_bit,reverse_data(STX_rsp), stop_bit},
											 {start_bit, reverse_data(elec_tr.address), stop_bit}, 						// data symbol
											 {start_bit, reverse_data({elec_tr.read_write,elec_tr.len}), stop_bit}, 		// data symbol
											 {start_bit, reverse_data(elec_tr.cmd_rsp_data[23:16]), stop_bit}, 				// data symbol
											 {start_bit, reverse_data(elec_tr.cmd_rsp_data[15:8]), stop_bit},				// data symbol 
											 {start_bit, reverse_data(elec_tr.cmd_rsp_data[7:0]), stop_bit}, 			//data symbol
											 {start_bit, reverse_data(low_crc), stop_bit}, {start_bit, reverse_data(high_crc), stop_bit}, // crc bits
											 {start_bit, reverse_data(DLE), stop_bit}, {start_bit,reverse_data(ETX), stop_bit}};

								foreach (data_sent[i,j])
									begin
										@(negedge v_if.clk);
										v_if.sbrx = data_sent[i][j];
									end
							end

						endcase // elec_tr.transaction_type
					end 

					// Each ordered set will be sent on both lanes simultaneously during training	
					ord_set: begin //ordered set 

						case (elec_tr.o_sets)

							SLOS1: begin
								
								//$display("[ELEC DRIVER] SLOS1 is being SENT for BOTH LANES");

								if (elec_tr.gen_speed == gen2)
								begin
									//$display("[DRIVER] SLOS1_64 IS being sent");
									foreach (SLOS1_64[i,j])
									begin
										@(negedge v_if.clk);
										v_if.lane_0_rx = SLOS1_64[i][65 - j];		
										v_if.lane_1_rx = SLOS1_64[i][65 - j];
										//$display("SLOS1 BITS: [%0b]",SLOS1_64[i][65 - j]);		
									end
								end	
								

								else if (elec_tr.gen_speed == gen3)
								begin
									
									foreach (SLOS1_128[i,j])
									begin
										@(negedge v_if.clk);
										v_if.lane_0_rx = SLOS1_128[i][131 - j];		
										v_if.lane_1_rx = SLOS1_128[i][131 - j];		
									end
									
								end


								
							end


							SLOS2: begin

								//$display("[ELEC DRIVER] SLOS2 is being SENT for BOTH LANES");

								if (elec_tr.gen_speed == gen2)
								begin
	
									foreach (SLOS2_64[i,j])
									begin
										@(negedge v_if.clk);
										v_if.lane_0_rx = SLOS2_64[i][65 - j];		
										v_if.lane_1_rx = SLOS2_64[i][65 - j];		
									end
										
								end

								else if (elec_tr.gen_speed == gen3)
								begin
									
									foreach (SLOS2_128[i,j])
									begin
										@(negedge v_if.clk);
										v_if.lane_0_rx = SLOS2_128[i][131 - j];		
										v_if.lane_1_rx = SLOS2_128[i][131 - j];		
									end
										
								end

								

							end


							TS1_gen2_3: begin
								
								///////////////////////////////////
								// In case of symmetric link
								lane_bonding_target = 3'b001;
								///////////////////////////////////


								TS1_GEN_2_3_lane0 = {5'b0, lane_bonding_target, lane_number_0, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS1, SCR};
								TS1_GEN_2_3_lane1 = {5'b0, lane_bonding_target, lane_number_1, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS1, SCR};

								//$display("[ELEC DRIVER] TS1_GEN2_3 is being SENT for BOTH LANES ");

								foreach (TS1_GEN_2_3_lane0[i])
									begin
										@(negedge v_if.clk);
										v_if.lane_0_rx = TS1_GEN_2_3_lane0[i];		
										v_if.lane_1_rx = TS1_GEN_2_3_lane1[i];		
									end

								
							end


							TS2_gen2_3: begin

								///////////////////////////////////
								// In case of symmetric link
								lane_bonding_target = 3'b001;
								///////////////////////////////////


								TS2_GEN_2_3_lane0 = {5'b0, lane_bonding_target, lane_number_0, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS2, SCR};
								TS2_GEN_2_3_lane1 = {5'b0, lane_bonding_target, lane_number_1, 16'b0, 3'b0, lane_bonding_target, 10'b0, TSID_TS2, SCR};

								//$display("[ELEC DRIVER] TS2_GEN2_3 is being SENT for BOTH LANES");

								foreach (TS2_GEN_2_3_lane0[i])
									begin
										@(negedge v_if.clk);
										v_if.lane_0_rx = TS2_GEN_2_3_lane0[i];		
										v_if.lane_1_rx = TS2_GEN_2_3_lane1[i];		
									end

								


							end


							TS1_gen4: begin

								indication = 4'h2; //Assuming the receiver is ready to receive PAM3 signaling
								counter = 8'h0F;

								//PSUEDO RANDOM SEQUENCES
								PRBS11 (420, 11'b11111111111, PRBS11_lane0);
								////$display("[DRIVER]: PRBS11 for lane_0: [%0P]",PRBS11_lane0);

								PRBS11 (420, 11'b11101110000, PRBS11_lane1);
								////$display("[DRIVER]: PRBS11 for lane_1: [%0P]",PRBS11_lane1);

								//TS = {CURSOR, indication, ~(indication), counter, PRS};
								TS = {CURSOR, indication, ~(indication), counter};

								//$display("[ELEC DRIVER] TS1_gen4 is being SENT for BOTH LANES");

								foreach (TS[i])
									begin
										@(negedge v_if.clk);
										////$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end


								fork
									begin
										foreach (PRBS11_lane0[i])
											begin
												@(negedge v_if.clk);
												////$display("[DRIVER] PRBS11_lane0 bits sent[%0b]",PRBS11_lane0[i]);
												v_if.lane_0_rx = PRBS11_lane0[i];			
											end
									end

									begin
										foreach (PRBS11_lane1[i])
											begin
												@(negedge v_if.clk);
												////$display("[DRIVER] PRBS11_lane1 bits sent[%0b]",PRBS11_lane1[i]);	
												v_if.lane_1_rx = PRBS11_lane1[i];		
											end
									end
									
								join
								

								


							end


							TS2_gen4: begin

								indication = 4'h4; //Assuming the receiver finished PAM3 TxFFE negotiation
								counter = 8'h0F;

								///////////////////////////////////
								//PRS = **************************************;
								///////////////////////////////////
								PRBS7 (420, 14'b01010101010101, PRTS7_lane0);
								////$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane0);

								PRBS7 (420, 14'b00_01_10_00_10_01_00, PRTS7_lane1);
								////$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane0);

								//TS = {CURSOR, indication, ~(indication), counter, PRS};
								TS = {CURSOR, indication, ~(indication), counter};

								//$display("[ELEC DRIVER] TS2_gen4 is being SENT for BOTH LANES ");


								foreach (TS[i])
									begin
										@(negedge v_if.clk);
										////$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end

								fork
									begin
										foreach (PRTS7_lane0[i])
										begin
											@(negedge v_if.clk);		
											v_if.lane_0_rx = PRTS7_lane0[i];		
										end
									end

									begin
										foreach (PRTS7_lane1[i])
										begin
											@(negedge v_if.clk);
											v_if.lane_1_rx = PRTS7_lane1[i];		
										end
									end
								join
								

									

							end


							TS3: begin

								indication = 4'h6; //Assuming the receiver detected Gen 4 TS3 Headers
								counter = 8'h0F;

								///////////////////////////////////
								//PRS = **************************************;
								///////////////////////////////////
								PRBS7 (420, 14'b01010101010101, PRTS7_lane0);
								////$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane0);

								PRBS7 (420, 14'b00_01_10_00_10_01_00, PRTS7_lane1);
								////$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane0);

								//TS = {CURSOR, indication, ~(indication), counter, PRS};
								TS = {CURSOR, indication, ~(indication), counter};

								//$display("[ELEC DRIVER] TS3 is being SENT for BOTH LANES");

								foreach (TS[i])
									begin
										@(negedge v_if.clk);
										////$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end

								fork
									begin
										foreach (PRTS7_lane0[i])
										begin
											@(negedge v_if.clk);		
											v_if.lane_0_rx = PRTS7_lane0[i];		
										end
									end

									begin
										foreach (PRTS7_lane1[i])
										begin
											@(negedge v_if.clk);
											v_if.lane_1_rx = PRTS7_lane1[i];		
										end
									end
								join

								


							end


							TS4: begin

								indication_4 = 8'hF0;

								///////////////////////////////////
								counter = 8'h0F;
								///////////////////////////////////


								///////////////////////////////////
								//PRS = **************************************;
								///////////////////////////////////
								PRBS7 (420, 14'b01010101010101, PRTS7_lane0);
								////$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane0);

								PRBS7 (420, 14'b00_01_10_00_10_01_00, PRTS7_lane1);
								////$display("[DRIVER]: PRTS7: [%0P]",PRTS7_lane1);



								//TS4 is different from TS1, TS2 and TS3 (bitwise compliment of counter not indication)
								// and the size of the indication field is different	
								//TS = {CURSOR, indication_4, counter, ~(counter), PRS}; 
								
								TS = {CURSOR, indication_4, counter, ~(counter)}; 


								//$display("[ELEC DRIVER] TS4 is being SENT for BOTH LANES");


								foreach (TS[i])
									begin
										@(negedge v_if.clk);
										////$display("[DRIVER] Header bits sent:[%0b]",TS[i]);
										v_if.lane_0_rx = TS[i];		
										v_if.lane_1_rx = TS[i];		
									end


								fork
									begin
										foreach (PRTS7_lane0[i])
									begin
										@(negedge v_if.clk);		
										v_if.lane_1_rx = PRTS7_lane1[i];		
									end
									end

									begin
										foreach (PRTS7_lane1[i])
									begin
										@(negedge v_if.clk);
										v_if.lane_1_rx = PRTS7_lane1[i];		
									end
									end
								join
								

							end


						endcase // elec_tr.o_sets
					


					end	


				endcase // elec_tr.tr_os

					


				-> elec_gen_drv_done; // Triggering Event to notify stimulus generator


					


				//#200  
				// for phase 2 only for now
				case (elec_tr.phase)


					3'b010: begin // phase 2
						@(posedge v_if.clk);
						v_if.sbrx = 1;
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

			localparam data_length = 16;
			bit [15:0] SEED = 16'hFFFF;
			bit [15:0] POLY = 16'h8005;
			bit [15:0] crc;

			bit data_for_crc [$];  

			data_for_crc = {stx, data_symb [2], data_symb[1], data_symb[0]};

			//data_for_crc = {stx};

			// data_for_crc = {};

			// foreach (data_symb[i]) 
			// begin
			// 	data_for_crc = {data_symb[i], data_for_crc};	
			// end

			// data_for_crc = {stx, data_for_crc};	

			crc = SEED;
			data_for_crc.reverse();
			foreach (data_for_crc[i])
			begin
				for (int n = 0; n < data_length-1; n = n+1)
					begin
						if (POLY[n] == 1)
							crc [n] = crc [n+1] ^ (data_for_crc[i] ^ crc [0]);
						else
							crc[n] = crc[n+1];
					end
				crc[data_length-1] = (data_for_crc[i] ^ crc [0]);
			end
			
			high_crc_task = {crc[0], crc[1], crc[2], crc[3], crc[4], crc[5], crc[6], crc[7]};
			low_crc_task = {crc[8], crc[9], crc[10], crc[11], crc[12], crc[13], crc[14], crc[15]};


		endtask : crc_calculation


		function bit [7:0] reverse_data (input bit[7:0] data);
			bit [7:0] data_reversed; 
			foreach (data[i]) begin
				data_reversed[7-i] = data[i];
			end
			return data_reversed;
		endfunction


		// task PRBS11 (input int size ,input bit [10:0] seed, output bit PRBS11_INTERNAL [$]);

		// 	//bit PRBS11_INTERNAL [$];
		// 	bit [10:0] internal_reg = seed;
		// 	bit internal_bit10; bit internal_bit8;
		
		// 	while (PRBS11_INTERNAL.size() != size)
		// 	begin


		// 		PRBS11_INTERNAL.push_back(internal_reg[10]);
		// 		internal_bit8 = internal_reg[8]; 
		// 		internal_bit10 = internal_reg[10];


		// 		internal_reg[10] = internal_reg[9];
		// 		internal_reg[9] = internal_reg[8];
		// 		internal_reg[8] = internal_reg[7];
		// 		internal_reg[7] = internal_reg[6];
		// 		internal_reg[6] = internal_reg[5];
		// 		internal_reg[5] = internal_reg[4];
		// 		internal_reg[4] = internal_reg[3];
		// 		internal_reg[3] = internal_reg[2];
		// 		internal_reg[2] = internal_reg[1];
		// 		internal_reg[1] = internal_reg[0];
		// 		internal_reg[0] =  internal_bit8 ^ internal_bit10;

				
				

		// 	end

		// 	////$display("PRBS_INTERNAL11 : [%0p]",PRBS11_INTERNAL);

		// endtask

		// function bit[1:0] GF3 (input [1:0] A, input string op,input [1:0] B);
		// 	case (op)
		// 		"+":
		// 		begin
		// 			case({A,B})
		// 				4'b00_00, 4'b01_10 , 4'b10_01:
		// 				begin
		// 					GF3 = 2'b00;
		// 				end

		// 				4'b00_01, 4'b01_00, 4'b10_10:
		// 				begin
		// 					GF3 = 2'b01;
		// 				end

		// 				4'b00_10, 4'b10_00, 4'b01_01:
		// 				begin
		// 					GF3 = 2'b10;
		// 				end
		// 			endcase
		// 		end

		// 		"*":
		// 		begin
		// 			case({A,B})
		// 				4'b00_00 ,4'b00_01, 4'b00_10, 4'b01_00, 4'b10_00:
		// 				begin
		// 					GF3 = 2'b00;
		// 				end

		// 				4'b01_01, 4'b10_10:
		// 				begin
		// 					GF3 = 2'b01;
		// 				end

		// 				4'b10_01, 4'b01_10:
		// 				begin
		// 					GF3 = 2'b10;
		// 				end
		// 			endcase
		// 		end

		// 	endcase
		// endfunction : GF3


		// task PRBS7 (input int size, input bit[13:0] seed, output bit[1:0] PRBS7_INTERNAL [$] );

		// 	//bit [1:0] PRBS7_INTERNAL [$];
		// 	bit [13:0] internal_reg = seed;
		// 	bit [1:0] internal_trit2; bit[1:0] internal_trit7;

		// 	while (PRBS7_INTERNAL.size() != size)
		// 	begin


		// 		PRBS7_INTERNAL.push_back(internal_reg[13:12]);
		// 		internal_trit2 = internal_reg[3:2]; 
		// 		internal_trit7 = GF3(2'b10,"*",internal_reg[13:12]);


		// 		internal_reg[13:12] = internal_reg[11:10];
		// 		internal_reg[11:10] = internal_reg[9:8];
		// 		internal_reg[9:8] = internal_reg[7:6];
		// 		internal_reg[7:6] = internal_reg[5:4];
		// 		internal_reg[5:4] = internal_reg[3:2];
		// 		internal_reg[3:2] = internal_reg[1:0];
				
		// 		internal_reg[1:0] =  GF3( internal_trit2,"+", internal_trit7);

		// 	end

		// 	////$display("PRBS7_INTERNAL : [%0p]",PRBS7_INTERNAL);

		// endtask



		
	endclass : elec_layer_driver


endpackage : elec_driver_pkg
