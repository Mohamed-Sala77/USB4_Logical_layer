
package elec_monitor_pkg;
	
	import elec_layer_tr_pkg::*;
	import symbols::*;

	class elec_layer_monitor;

		//Transaction
		elec_layer_tr elec_tr;
		elec_layer_tr elec_tr_lane1;
		elec_layer_tr elec_tr_lane0;

		// Interface
		virtual electrical_layer_if v_if;

		// Mailboxes
		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		mailbox #(OS_type) os_received_mon_gen; // connects monitor to the stimulus generator to indicated received ordered sets

		//Events
		event sbtx_high_recieved;

		// Queues to save DUT signals
		bit SB_data_received [$];
		bit lane_0_data_received [$];
		bit lane_1_data_received [$];

		// ordered SETS QUEUES
		bit [1:0] PRTS7_lane0 [$];
		bit [1:0] PRTS7_lane1 [$];
		bit PRTS7_lane0_1bit [$];
		bit PRTS7_lane1_1bit [$];


		bit PRBS11_lane0 [$];
		bit PRBS11_lane1 [$]; 
	

		// variable RESPONSE DATA 
		bit [29:0] Rsp_Data;
		bit[19:0] Tmp_Data; // to help detect LT_FALL, AT_CMND, AT_RSP
		bit [79:0] tmp_AT_cmnd;

		// NEW Function
		function new(input virtual electrical_layer_if v_if, mailbox #(elec_layer_tr) elec_mon_scr, mailbox #(OS_type) os_received_mon_gen, event sbtx_high_recieved);

			//Interface Connections
			this.v_if = v_if;

			// Mailbox connections 
			this.elec_mon_scr = elec_mon_scr; //between (monitor) and (Agent)
			this.os_received_mon_gen = os_received_mon_gen;

			//Event Connections
			this.sbtx_high_recieved = sbtx_high_recieved;

			elec_tr =new();
			elec_tr_lane1 = new();
			elec_tr_lane0 = new();


		endfunction : new

		task run;
			//@(negedge v_if.clk);   // CHECKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK AT TRANSACTIONSSSS OPERATIONS WITHOUT ITT
			//$display("EXPECTED LT_FALL[%b]",{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(LSE_lane0),stop_bit});
			//$display("EXPECTED AT_CMND[%b]",{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(STX_cmd),stop_bit});
			forever begin
				
				//elec_tr =new();
				
				//////////////////////////////////////////////////
				///////GETTING INTERFACE ITEMS TO BE TESTED///////
				//////////////////////////////////////////////////

				@(negedge v_if.clk);
				#1 // needed to detect changes correctly
				////$display("[%0t] lane_0_data_received outside:[%0b]",$time(),v_if.lane_0_rx);
				SB_data_received.push_back(v_if.sbrx); // sbrx for debugging
				lane_0_data_received.push_back(v_if.lane_0_rx); // lane_0_rx for debugging
				lane_1_data_received.push_back(v_if.lane_1_rx); // lane_1_rx for debugging

				// MONITOR DISPLAY FUNCTIONS FOR DEBUGGING
				////$display("[%0t] SB_data_received outside:[%0p]",$time(),SB_data_received);
				////$display("[%0t] lane_0_data_received outside:[%0p]",$time(),lane_0_data_received);
				////$display("[%0t] lane_1_data_received outside:[%0p]",$time(),lane_1_data_received);
				////$display("EXPECTED LT_FALL[%b]",{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(LSE_lane0),stop_bit});




				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////              SIDEBAND RECEIVER                /////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



				// Detecting Transaction types from the first 2 symbols (AT COMMAND/ AT RESPONSE / LT FALL)
				if (SB_data_received.size()==20) // can remove the if condition 
					begin

						////$display("[%0t] SB_data_received inside:[%0p]",$time(),SB_data_received[0:19]);
						foreach (SB_data_received [i]) begin
							Tmp_Data[i] = SB_data_received[i];
						end
						Tmp_Data = reverse_data_20(Tmp_Data);
						////$display("TMP_Data[%b]",Tmp_Data);


						case (Tmp_Data) //(SB_data_received[0:19]) 
							{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(STX_cmd),stop_bit}: // AT command received
							begin
								//$display("AT_cmd DETECTED!!!!!!!!!!!!!!!");
								elec_tr.transaction_type = AT_cmd;
							end
							{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(STX_rsp),stop_bit}: // AT response Received
							begin
								//$display("AT_RESPONSE DETECTED!!!!!!!!!!!!!!!");
								elec_tr.transaction_type = AT_rsp;
							end
							
							{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(LSE_lane0),stop_bit} , 
							{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(LSE_lane1),stop_bit} : // LT_fall received
							begin
								//$display("LT_FALL DETECTED!!!!!!!!!!!!!!!");
								elec_tr.transaction_type = LT_fall; //LT_fall
							end

							default:
							begin
								void'(SB_data_received.pop_front());
							end
						endcase // SB_data_received[19:0]


					end



				// CONFIRMING THE RECEPTION OF THE FULL TRANSACTION to be sent to the SCOREBOARD
				case (elec_tr.transaction_type)

					AT_cmd:
					begin
						// assume no Command_Data for now as no Write operations are to be tested (LIMITATION)
						if(SB_data_received.size() == 80) //  AT Transaction Received
							begin
								if({ << {SB_data_received[71:78]}} != ETX) // STATIC TYPE CASTINGG
								 	begin
								 		$error("Wrong AT Command Received");
								 	end
								 else // case of a correct AT command, assign transaction components
									begin
										//$display("Correct AT Command Received");
										elec_tr.transaction_type = AT_cmd;
										elec_tr.address = { << { SB_data_received[21:28] }}; 
										elec_tr.len =  { << { SB_data_received[31:37] }};
										elec_tr.read_write =  { << { SB_data_received[38] }} ;
										elec_tr.crc_received[15:8] =  { << { SB_data_received[41:48] }};
										elec_tr.crc_received[7:0] =  { << { SB_data_received[51:58] }};

										elec_mon_scr.put(elec_tr);


										repeat(80)
										begin
											void'(SB_data_received.pop_back()); // empty the QUEUE to start receiving the next transaction
										end
										elec_tr = new();
									end
							end
					end


					AT_rsp:
					begin
						if(SB_data_received.size() == 40)
							begin
								elec_tr.len = { << {SB_data_received[31:37]} };
							end

						if(SB_data_received.size() == (80+(elec_tr.len*10))) // FULL AT Response Received // limitation: can't check whether the AT rsp is correct or not due to variable length
						begin
							elec_tr.transaction_type = AT_rsp;
							elec_tr.address = { << {SB_data_received[21:28]} };
							elec_tr.len = { << {SB_data_received[31:37]} };
							elec_tr.read_write = { << {SB_data_received[38]} };

							repeat (40)
							begin
								void'(SB_data_received.pop_front()); // check weather front or back is needed
							end

							for(int i = 0; i<elec_tr.len*10;i++) 
							begin
								////$display("[MONITOR] Rsp_Data function called");
								Rsp_Data[i] = SB_data_received.pop_front();
							end

							////$display("[MONITOR] Rsp_Data [%0h]",Rsp_Data[23:0]);
							elec_tr.cmd_rsp_data[23:0] = {Rsp_Data[8:1],Rsp_Data[18:11],Rsp_Data[28:21]};
							elec_tr.crc_received [15:8] = { << {SB_data_received[1:8]} };
							elec_tr.crc_received [7:0] = { << {SB_data_received[11:18]} };


							elec_mon_scr.put(elec_tr);
							repeat(40)
								begin
									void'(SB_data_received.pop_back()); // empty the QUEUE to start receiving the next transaction
								end
							elec_tr = new();

						end
					end


					LT_fall:
					begin
						if(SB_data_received.size() == 30) // FULL LT Transaction Received
							begin
								////$display("LT_FALL: LSE : %8b",{ << {SB_data_received [11:18] } }); //$display("LT_FALL: LSE : %8b",{ << {SB_data_received [21:28] } });
								// if ({ << {SB_data_received [11:18] } } != ~ { << {SB_data_received [21:28] } } )
								// 	begin
								// 		$error("Wrong LT_fall Received: CLSE is not the complement of LSE"); 
								// 	end
								// else // case of Correct LT_Fall transaction, assign transaction compnents
									begin
										//$display("LT_FALL Transaction Confirmed ");
										elec_mon_scr.put(elec_tr); // send transaction to the scoreboard
										repeat (30)
										begin
											void'(SB_data_received.pop_back()); // empty the QUEUE to start receiving the next transaction
										end
										elec_tr = new();
									end
							end
					end


				endcase




				fork
					
					begin
						
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				/////////////////////////////////                    LANE 0 RECEIVER                ///////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


														//////////////////////////////////////////////////
														//////  GENERATION 4 HEADER DETECTOR  // /////////
														//////////////////////////////////////////////////

				
				if (lane_0_data_received.size() > 27)
					begin
						////$display("[%0t] lane_0_data_received outside:[%0p]",$time(),lane_0_data_received);
						////$display("[%0t] expected ts1 header[%b]",$time(),{CURSOR, 4'h2, ~(4'h2), 8'h0F});
						

						case ( { >> {lane_0_data_received[ $size(lane_0_data_received) - 28 :  $size(lane_0_data_received) - 1 ]} } )
							{CURSOR, 4'h2, ~(4'h2), 8'h0F}: // TS1 GEN4 DETECTED HEADER
							begin
								//$display("[ELEC MONITOR]*******TS1 GEN4 DETECTED ON LANE [0] **********");
								elec_tr.o_sets = TS1_gen4;

								repeat (lane_0_data_received.size() )begin
									void'(lane_0_data_received.pop_back());
								end
							end

							{CURSOR, 4'h4, ~(4'h4), 8'h0F}: // TS2 GEN4 DETECTED HEADER
							begin
								//$display("[ELEC MONITOR]*******TS2 GEN4 DETECTED ON LANE [0] **********");
								elec_tr.o_sets = TS2_gen4;

								repeat (lane_0_data_received.size() )begin
									void'(lane_0_data_received.pop_back());
								end
							end

							{CURSOR, 4'h6, ~(4'h6), 8'h0F}: // TS3 GEN4 DETECTED HEADER
							begin
								//$display("[ELEC MONITOR]*******TS3 GEN4 DETECTED ON LANE [0] **********");
								elec_tr.o_sets = TS3;

								repeat (lane_0_data_received.size() )begin
									void'(lane_0_data_received.pop_back());
								end
							end

							{CURSOR, 4'h8, ~(4'h8), 8'h0F}: // TS4 GEN4 DETECTED HEADER
							begin
								
							end

							// default:
							// begin
							// 	void'(lane_0_data_received.pop_front());
							// end

								
						endcase 



														////////////////////////////////////////////////////////////
														//////  GENERATION 4 ORDERED SET PAYLOAD DETECTOR  /////////
														////////////////////////////////////////////////////////////				
				case (elec_tr.o_sets)
					TS1_gen4:
					begin
						if (lane_0_data_received.size() == 420)
							begin
								////$display("[%0t] lane_0_data_received outside:[%0p]",$time(),lane_0_data_received);
								PRBS11 (420, 11'b11111111111, PRBS11_lane0);
								if (lane_0_data_received != PRBS11_lane0)
									begin
										$error("[ELEC MONITOR] WRONG TS1 RECEIVED ON LANE [0] !!");
									end
								else
									begin
										//$display("[ELEC MONITOR] TS1 RECEIVED CORRECTLY ON LANE [0]  ");
										elec_mon_scr.put(elec_tr);
										os_received_mon_gen.put(TS1_gen4);
										elec_tr = new();
									end
							end
					end

					TS2_gen4:
					begin
						if (lane_0_data_received.size() == 420)
							begin
								////$display("[%0t] lane_0_data_received outside:[%0p]",$time(),lane_0_data_received);
								PRBS7 (420, 14'b01010101010101, PRTS7_lane0);

								foreach (PRTS7_lane0[i]) begin
									PRTS7_lane0_1bit.push_back(PRTS7_lane0[i]); // can't understand how this is correct but okay i guess?
									//PRTS7_lane0_1bit.push_back(PRTS7_lane0[i][1]);
								end

								////$display("PRTS7_lane0_1bit : [%0p]",PRTS7_lane0_1bit);

								if (lane_0_data_received != PRTS7_lane0_1bit)
									begin
										$error("[ELEC MONITOR] WRONG TS2 RECEIVED ON LANE [0] !!");
									end
								else
									begin
										//$display("[ELEC MONITOR] TS2 RECEIVED CORRECTLY ON LANE [0]  ");
										elec_mon_scr.put(elec_tr);
										os_received_mon_gen.put(TS2_gen4);
										elec_tr = new();
									end
							end

						repeat(PRTS7_lane0_1bit.size())
						begin
						 	void'(PRTS7_lane0_1bit.pop_back());
						end
					end

					TS3:
					begin
						if (lane_0_data_received.size() == 420)
							begin
								////$display("[%0t] TS3 lane_0_data_received outside:[%0p]",$time(),lane_0_data_received);
								PRBS7 (420, 14'b01010101010101, PRTS7_lane0);

								foreach (PRTS7_lane0[i]) begin
									PRTS7_lane0_1bit.push_back(PRTS7_lane0[i]); // can't understand how this is correct but okay i guess?
									//PRTS7_lane0_1bit.push_back(PRTS7_lane0[i][1]);
								end

								////$display("PRTS7_lane0_1bit : [%0p]",PRTS7_lane0_1bit);

								if (lane_0_data_received != PRTS7_lane0_1bit)
									begin
										$error("[ELEC MONITOR] WRONG TS3 RECEIVED ON LANE [0] !!");
									end
								else
									begin
										//$display("[ELEC MONITOR] TS3 RECEIVED CORRECTLY ON LANE [0] ");
										elec_mon_scr.put(elec_tr);
										os_received_mon_gen.put(TS3);
										elec_tr = new();
									end
							end

						repeat(PRTS7_lane0_1bit.size())
						begin
							void'(PRTS7_lane0_1bit.pop_back());
						end
					end

					TS4:
					begin
						
					end
					
				endcase

					end

					end
	
					begin
						

				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				/////////////////////////////////                    LANE 1 RECEIVER                ///////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

														//////////////////////////////////////////////////
														//////  GENERATION 4 HEADER DETECTOR  // /////////
														//////////////////////////////////////////////////

				
				if (lane_1_data_received.size() > 27)
					begin
						////$display("[%0t] lane_0_data_received outside:[%0p]",$time(),lane_0_data_received);
						////$display("[%0t] expected ts1 header[%b]",$time(),{CURSOR, 4'h2, ~(4'h2), 8'h0F});
						

						case ( { >> {lane_1_data_received[ $size(lane_1_data_received) - 28 :  $size(lane_1_data_received) - 1 ]} } )
							{CURSOR, 4'h2, ~(4'h2), 8'h0F}: // TS1 GEN4 DETECTED HEADER
							begin
								//$display("[ELEC MONITOR]*******TS1 GEN4 DETECTED ON LANE [1] **********");
								elec_tr_lane1.o_sets = TS1_gen4;

								repeat (lane_1_data_received.size() )begin
									void'(lane_1_data_received.pop_back());
								end
							end

							{CURSOR, 4'h4, ~(4'h4), 8'h0F}: // TS2 GEN4 DETECTED HEADER
							begin
								//$display("[ELEC MONITOR]*******TS2 GEN4 DETECTED ON LANE [1] **********");
								elec_tr_lane1.o_sets = TS2_gen4;

								repeat (lane_1_data_received.size() )begin
									void'(lane_1_data_received.pop_back());
								end
							end

							{CURSOR, 4'h6, ~(4'h6), 8'h0F}: // TS3 GEN4 DETECTED HEADER
							begin
								//$display("[ELEC MONITOR]*******TS3 GEN4 DETECTED ON LANE [1] **********");
								elec_tr_lane1.o_sets = TS3;

								repeat (lane_1_data_received.size() )begin
									void'(lane_1_data_received.pop_back());
								end
							end

							{CURSOR, 4'h8, ~(4'h8), 8'h0F}: // TS4 GEN4 DETECTED HEADER
							begin
								
							end

							// default:
							// begin
							// 	void'(lane_0_data_received.pop_front());
							// end

								
						endcase 

														////////////////////////////////////////////////////////////
														//////  GENERATION 4 ORDERED SET PAYLOAD DETECTOR  /////////
														////////////////////////////////////////////////////////////	
				

						case (elec_tr_lane1.o_sets)

					TS1_gen4:
					begin

						if (lane_1_data_received.size() == 420)
							begin
								
								////$display("[%0t] lane_1_data_received outside:[%0p]",$time(),lane_1_data_received);
								PRBS11 (420, 11'b11111111111, PRBS11_lane1);
								if (lane_1_data_received != PRBS11_lane1)
									begin
										$error("[ELEC MONITOR] WRONG TS1 RECEIVED ON LANE [1] !!");
									end
								else
									begin
										//$display("[ELEC MONITOR] TS1 RECEIVED CORRECTLY ON LANE [1] ");
										elec_mon_scr.put(elec_tr_lane1);
										os_received_mon_gen.put(TS1_gen4);
										elec_tr_lane1 = new();
									end
							end
					end

					TS2_gen4:
					begin
						if (lane_1_data_received.size() == 420)
							begin
								////$display("[%0t] lane_1_data_received outside:[%0p]",$time(),lane_1_data_received);
								PRBS7 (420, 14'b01010101010101, PRTS7_lane1);

								foreach (PRTS7_lane1[i]) begin
									PRTS7_lane1_1bit.push_back(PRTS7_lane1[i]); // can't understand how this is correct but okay i guess?
									//PRTS7_lane0_1bit.push_back(PRTS7_lane0[i][1]);
								end

								////$display("PRTS7_lane1_1bit : [%0p]",PRTS7_lane1_1bit);

								if (lane_1_data_received != PRTS7_lane1_1bit)
									begin
										$error("[ELEC MONITOR] WRONG TS2 RECEIVED ON LANE [1] !!");
									end
								else
									begin
										//$display("[ELEC MONITOR] TS2 RECEIVED CORRECTLY ON LANE [1] ");
										elec_mon_scr.put(elec_tr_lane1);
										os_received_mon_gen.put(TS2_gen4);
										elec_tr_lane1 = new();
									end
							end

						repeat(PRTS7_lane1_1bit.size())
						begin
							void'(PRTS7_lane1_1bit.pop_back());
						end
					end

					TS3:
					begin
						if (lane_1_data_received.size() == 420)
							begin
								////$display("[%0t] lane_1_data_received outside:[%0p]",$time(),lane_1_data_received);
								PRBS7 (420, 14'b01010101010101, PRTS7_lane1);

								foreach (PRTS7_lane1[i]) begin
									PRTS7_lane1_1bit.push_back(PRTS7_lane1[i]); // can't understand how this is correct but okay i guess?
									//PRTS7_lane0_1bit.push_back(PRTS7_lane0[i][1]);
								end

								////$display("PRTS7_lane1_1bit : [%0p]",PRTS7_lane1_1bit);

								if (lane_1_data_received != PRTS7_lane1_1bit)
									begin
										$error("[ELEC MONITOR] WRONG TS3 RECEIVED ON LANE [1] !!");
									end
								else
									begin
										//$display("[ELEC MONITOR] TS3 RECEIVED CORRECTLY  ON LANE [1]");
										elec_mon_scr.put(elec_tr_lane1);
										os_received_mon_gen.put(TS3);
										elec_tr_lane1 = new();
									end
							end


						repeat(PRTS7_lane1_1bit.size())
						begin
							void'(PRTS7_lane1_1bit.pop_back());
						end
					end

					TS4:
					begin
						
					end
					
				endcase


					end


					end
				join








				
				
				
				//////////////////////////////////////////////////
				//TESTED INTEFACE SIGNAL SENT TO THE SCOREBOARD///
				//////////////////////////////////////////////////

				//elec_mon_scr.put(elec_tr);

				if (v_if.sbtx) // sbtx high from DUT
					-> sbtx_high_recieved;
				

			end
			

		endtask : run


		function bit [7:0] reverse_data (input bit[7:0] data);
			bit [7:0] data_reversed; 
			foreach (data[i]) begin
				data_reversed[7-i] = data[i];
			end
			return data_reversed;
		endfunction

		function bit [19:0] reverse_data_20 (input bit[19:0] data);
			bit [19:0] data_reversed; 
			foreach (data[i]) begin
				data_reversed[19-i] = data[i];
			end
			return data_reversed;
		endfunction

	endclass : elec_layer_monitor
endpackage : elec_monitor_pkg

