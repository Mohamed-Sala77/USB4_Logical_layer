class elec_ref_AI;

  elec_layer_tr elec_layer_inst;
  upper_layer_tr upper_layer_inst;

  mailbox #(elec_layer_tr) elec_S;
  mailbox #(elec_layer_tr) elec_G;
  mailbox #(elec_layer_tr) elec_to_upper;
  mailbox #(upper_layer_tr) upper_to_elec;

  // Variables to track the number of times each ordered set has been sent
  int sent_SLOS1 = 0;
  int sent_SLOS2 = 0;
  int sent_TS1_gen4 = 0;
  int sent_TS2_gen4 = 0;
  int sent_TS3 = 0;
  int sent_TS4 = 0;

  // Variable to track the order
  int order_counter = -1;

  // Queue to store the last two received ordered sets
  OS_type received_ordered_sets[$];

  // Queue to store all received ordered sets for checking
  OS_type received_ordered_sets_for_checking[$];

  // FSM states for each generation
  typedef enum {SLOS1_STATE, SLOS2_STATE, TS1_gen2_gen3_STATE, TS2_gen2_gen3_STATE, TRAINING_DONE_GEN2_GEN3} gen2_gen3_fsm_state;
  gen2_gen3_fsm_state gen2_gen3_fsm;
  typedef enum {TS1_gen4_STATE, TS2_gen4_STATE, TS3_STATE, TS4_STATE, TRAINING_DONE_GEN4} gen4_fsm_state;
  gen4_fsm_state gen4_fsm;

  function new(mailbox #(elec_layer_tr) elec_S, mailbox #(elec_layer_tr) elec_G, mailbox #(elec_layer_tr) elec_to_upper, mailbox #(upper_layer_tr) upper_to_elec);
    this.elec_S = elec_S;
    this.elec_G = elec_G;
    this.elec_to_upper = elec_to_upper;
    this.upper_to_elec = upper_to_elec;
  endfunction

  task run;
    forever begin
      fork : thread
        // Thread 1
        begin
          elec_layer_inst = new();

          elec_G.get(elec_layer_inst);

          case (elec_layer_inst.phase)

            2: begin
                // Assign sbtx to 1
                elec_layer_inst.sbtx = 1;

                // Put elec_layer_inst in elec_S mailbox
                elec_S.put(elec_layer_inst);

                // Create a new instance for elec_layer_inst
                elec_layer_inst = new;
            end

            3: begin
                
                elec_layer_inst.tr_os = tr;
                elec_layer_inst.transaction_type = AT_cmd;
                elec_layer_inst.address = 78;
                elec_layer_inst.len = 3;
                elec_layer_inst.read_write = 0;
                elec_layer_inst.crc_received = 0;
                elec_layer_inst.cmd_rsp_data = 0;
                elec_S.put(elec_layer_inst);
                elec_layer_inst = new();
                elec_G.get(elec_layer_inst);
                
                if (elec_layer_inst.tr_os == tr && elec_layer_inst.transaction_type == AT_cmd && elec_layer_inst.address == 78 && elec_layer_inst.len == 3 && elec_layer_inst.read_write == 0) 
                begin
                    elec_layer_inst.tr_os = tr;
                    elec_layer_inst.transaction_type = AT_rsp;
                    elec_layer_inst.address = 78;
                    elec_layer_inst.len = 3;
                    elec_layer_inst.read_write = 0;
                    elec_layer_inst.crc_received = 0;
                    elec_layer_inst.cmd_rsp_data = 24'h053303; // WRONG INPUT FROM ME (6'h053303) should be 24'h053303

                    elec_S.put(elec_layer_inst);
                    elec_layer_inst = new();
                end
            end

            4: begin
                if (elec_layer_inst.tr_os != ord_set) begin
                    $display("Error: tr_os is not ord_set");
                end else begin
                    case (elec_layer_inst.gen_speed)
                        gen2: begin
                      
                            gen2_gen3_fsm_state prev_gen2_gen3_fsm = gen2_gen3_fsm;
                            $display("[ELEC REF] Inside GEN 2");
                            case (gen2_gen3_fsm)
                                SLOS1_STATE: begin
                                    if (sent_SLOS1 < 2 || !received_two_consecutive_ordered_sets(SLOS1)) begin
                                        elec_layer_inst.o_sets = SLOS1;
                                        sent_SLOS1++;
                                        $display("[ELEC REF] Inside SLOS1_STATE in GEN 2");
                                        $display("[ELEC REF] Order counter = %0D",order_counter);

                                    end else begin
                                        gen2_gen3_fsm = SLOS2_STATE;
                                        //$display("[ELEC REF] Order counter = %0D",order_counter);

                                    end
                                end
                                SLOS2_STATE: begin
                                    if (sent_SLOS2 < 2 || !received_two_consecutive_ordered_sets(SLOS2)) begin
                                        elec_layer_inst.o_sets = SLOS2;
                                        sent_SLOS2++;
                                    end else begin
                                        gen2_gen3_fsm = TS1_gen2_gen3_STATE;
                                    end
                                end
                                TS1_gen2_gen3_STATE: begin
                                    if (sent_TS1_gen4 < 32 || !received_two_consecutive_ordered_sets(TS1_gen4)) begin
                                        elec_layer_inst.o_sets = TS1_gen4;
                                        sent_TS1_gen4++;
                                    end else begin
                                        gen2_gen3_fsm = TS2_gen2_gen3_STATE;
                                    end
                                end
                                TS2_gen2_gen3_STATE: begin
                                    if (sent_TS2_gen4 < 16 || !received_two_consecutive_ordered_sets(TS2_gen4)) begin
                                        elec_layer_inst.o_sets = TS2_gen4;
                                        sent_TS2_gen4++;
                                    end else begin
                                        gen2_gen3_fsm = TRAINING_DONE_GEN2_GEN3;
                                    end
                                end
                                TRAINING_DONE_GEN2_GEN3: begin
                                    // Training is done for gen2
                                end
                            endcase
                            if (prev_gen2_gen3_fsm != gen2_gen3_fsm) begin
                                order_counter = 0;
                                $display("[ELEC REF] Order counter inside if prev != : %0D",order_counter);

                            end
                        end
                        gen3: begin
                            gen2_gen3_fsm_state prev_gen2_gen3_fsm = gen2_gen3_fsm;
                            case (gen2_gen3_fsm)
                                SLOS1_STATE: begin
                                    if (sent_SLOS1 < 2 || !received_two_consecutive_ordered_sets(SLOS1)) begin
                                        elec_layer_inst.o_sets = SLOS1;
                                        sent_SLOS1++;
                                    end else begin
                                        gen2_gen3_fsm = SLOS2_STATE;
                                    end
                                end
                                SLOS2_STATE: begin
                                    if (sent_SLOS2 < 2 || !received_two_consecutive_ordered_sets(SLOS2)) begin
                                        elec_layer_inst.o_sets = SLOS2;
                                        sent_SLOS2++;
                                    end else begin
                                        gen2_gen3_fsm = TS1_gen2_gen3_STATE;
                                    end
                                end
                                TS1_gen2_gen3_STATE: begin
                                    if (sent_TS1_gen4 < 16 || !received_two_consecutive_ordered_sets(TS1_gen4)) begin
                                        elec_layer_inst.o_sets = TS1_gen4;
                                        sent_TS1_gen4++;
                                    end else begin
                                        gen2_gen3_fsm = TS2_gen2_gen3_STATE;
                                    end
                                end
                                TS2_gen2_gen3_STATE: begin
                                    if (sent_TS2_gen4 < 8 || !received_two_consecutive_ordered_sets(TS2_gen4)) begin
                                        elec_layer_inst.o_sets = TS2_gen4;
                                        sent_TS2_gen4++;
                                    end else begin
                                        gen2_gen3_fsm = TRAINING_DONE_GEN2_GEN3;
                                    end
                                end
                                TRAINING_DONE_GEN2_GEN3: begin
                                    // Training is done for gen3
                                end
                            endcase
                            if (prev_gen2_gen3_fsm != gen2_gen3_fsm) begin
                                order_counter = 0;
                            end
                        end
                        gen4: begin
                            gen4_fsm_state prev_gen4_fsm = gen4_fsm;
                            case (gen4_fsm)
                                TS1_gen4_STATE: begin
                                    if (sent_TS1_gen4 < 16 || !(has_received_ordered_set(TS1_gen4) || has_received_ordered_set(TS2_gen4))) begin
                                        elec_layer_inst.o_sets = TS1_gen4;
                                        sent_TS1_gen4++;
                                    end else begin
                                        gen4_fsm = TS2_gen4_STATE;
                                    end
                                end
                                TS2_gen4_STATE: begin
                                    if (sent_TS2_gen4 < 16 || !(has_received_ordered_set(TS2_gen4) || has_received_ordered_set(TS3))) begin
                                        elec_layer_inst.o_sets = TS2_gen4;
                                        sent_TS2_gen4++;
                                    end else begin
                                        gen4_fsm = TS3_STATE;
                                    end
                                end
                                TS3_STATE: begin
                                    if (sent_TS3 < 16 || !(has_received_ordered_set(TS3) || has_received_ordered_set(TS4))) begin
                                        elec_layer_inst.o_sets = TS3;
                                        sent_TS3++;
                                    end else begin
                                        gen4_fsm = TS4_STATE;
                                    end
                                end
                                TS4_STATE: begin
                                    if (sent_TS4 < 16) begin
                                        elec_layer_inst.o_sets = TS4;
                                        sent_TS4++;
                                    end else begin
                                        gen4_fsm = TRAINING_DONE_GEN4;
                                    end
                                end
                                TRAINING_DONE_GEN4: begin
                                    // Training is done for gen4
                                end
                            endcase
                            if (prev_gen4_fsm != gen4_fsm) begin
                                order_counter = 0;
                            end
                        end
                    endcase
                end
                // Update order
                if (elec_layer_inst.o_sets == TS1_gen4 || elec_layer_inst.o_sets == TS2_gen4 || elec_layer_inst.o_sets == TS3) begin
                    order_counter = 'h0F;
                end else if (order_counter < 15) begin
                    order_counter++;
                end
                
                $display("[ELEC REF] Order counter after Update ordere = %0D",order_counter);

                elec_layer_inst.order = order_counter;

                // Put elec_layer_inst in the mailbox
                elec_S.put(elec_layer_inst);
                $display("[ELEC REF] DATA SENT to electrical layer generator: %p",elec_layer_inst);
                elec_layer_inst = new(); //////////////////

            end

            5: begin
                  $display("DATA OBTAINED from electrical layer");
                  $display("electrical_to_transport = %0D, phase = %0D",elec_layer_inst.electrical_to_transport, elec_layer_inst.phase);
                  elec_to_upper.put(elec_layer_inst);
               end
              

          endcase
        end
        // Thread 2
        begin
          elec_layer_inst = new();
          upper_layer_inst = new();
          upper_to_elec.get(upper_layer_inst);
          if (upper_layer_inst.phase == 5) begin
            elec_layer_inst.transport_to_electrical = upper_layer_inst.T_Data;
            elec_S.put(elec_layer_inst);
          end
        end
      join_any
    end
  endtask

  

  // Function to update the queues when a new ordered set is received
  function void update_received_ordered_sets(OS_type new_ordered_set);
      // Add the new ordered set to the queue
      received_ordered_sets.push_back(new_ordered_set);

      // If the received_ordered_sets queue has more than two elements, remove the oldest one
      if (received_ordered_sets.size() > 2) begin
          received_ordered_sets.pop_front();
      end
  endfunction

  // Function to check if an ordered set has been received at least once
  function bit has_received_ordered_set(OS_type ordered_set);
      // Iterate over the received_ordered_sets_for_checking queue
      foreach (received_ordered_sets_for_checking[i]) begin
          // If the ordered set is found, return 1
          if (received_ordered_sets_for_checking[i] == ordered_set) begin
              return 1;
          end
      end

      // If the ordered set is not found, return 0
      return 0;
  endfunction

  // Function to check if an ordered set has been received twice consecutively
  function bit received_two_consecutive_ordered_sets(OS_type ordered_set);
      // If the queue has less than two elements, return 0
      if (received_ordered_sets.size() < 2) begin
          return 0;
      end

      // If the last two elements in the queue are the same as the ordered set, return 1
      if (received_ordered_sets[received_ordered_sets.size()-1] == ordered_set && received_ordered_sets[received_ordered_sets.size()-2] == ordered_set) begin
          return 1;
      end

      // Otherwise, return 0
      return 0;
  endfunction

endclass