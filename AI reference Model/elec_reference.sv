class elec_ref_AI;

  elec_layer_tr elec_layer_inst;
  upper_layer_tr upper_layer_inst;

  mailbox #(elec_layer_tr) elec_S;
  mailbox #(elec_layer_tr) elec_G;
  mailbox #(elec_layer_tr) elec_to_upper;
  mailbox #(upper_layer_tr) upper_to_elec;

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

endclass