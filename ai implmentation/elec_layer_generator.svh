/////////////////////****stimulus gen package****//////////////////////////////
package electrical_layer_generator_pkg;

  import electrical_layer_transaction_pkg::*; // Import the elec_layer_tr class

  class electrical_layer_generator;

    // Declare events
    event sbrx_transition_high;
    event elec_gen_driver_done;
    event sbtx_transition_high;
    event correct_OS; // New event

    // Declare transactions
    elec_layer_tr transaction;
    elec_layer_tr tr_mon;

    // Declare mailboxes of type elec_layer_tr
    mailbox #(elec_layer_tr) elec_gen_drv;
    mailbox #(elec_layer_tr) elec_gen_mod;

    // Constructor
    function new(event sbrx_transition_high, event elec_gen_driver_done, event sbtx_transition_high, event correct_OS, mailbox #(elec_layer_tr) elec_gen_drv, mailbox #(elec_layer_tr) elec_gen_mod);
      this.sbrx_transition_high = sbrx_transition_high;
      this.elec_gen_driver_done = elec_gen_driver_done;
      this.sbtx_transition_high = sbtx_transition_high;
      this.correct_OS = correct_OS; // Assign the correct_OS event
      this.elec_gen_drv = elec_gen_drv;
      this.elec_gen_mod = elec_gen_mod;
    endfunction

    // New task
    task sbrx_after_sbtx_high();
      @sbtx_transition_high; // Blocking with the event sbtx_transition_high
      $display("[ELEC_STIM_GEN ] : sbtx is high");
      transaction = new(); // Construct the transaction
      transaction.sbrx = 1'b1; // Set transaction.sbrx to 1'b1
      transaction.phase = 3'b010; // Set transaction.phase to 3'b010
      elec_gen_drv.put(transaction); // Put the transaction on the elec_gen_drv mailbox
      elec_gen_mod.put(transaction); // Put the transaction on the elec_gen_mod mailbox
      $display("[ELEC_STIM_GEN ] : sbrx send high");
    endtask

    // Transaction methods
    task send_transaction(input tr_type trans_type = None, input int phase = 3, input bit read_write = 0, input bit [31:0] address = 0, input bit [31:0] len = 0, input bit [31:0] cmd_rsp_data = 0);
      transaction = new(); // Instantiate the transaction object using the default constructor
      transaction.phase = phase;
      transaction.transaction_type = trans_type;
      transaction.tr_os = tr;

      // Add your case statement here
      case(trans_type)
        AT_cmd, AT_rsp: begin
          transaction.read_write = read_write;
          transaction.address = address;
          transaction.len = len;
          transaction.cmd_rsp_data = cmd_rsp_data;
          $display("[ELEC GENERATOR] sending [%0p] Transaction", trans_type);
        end
        LT_fall: begin
          //transaction.sbrx = 0;
          $display("[ELEC GENERATOR] sending [LT_FALL] Transaction");
        end
      endcase

      elec_gen_drv.put(transaction); // Sending transaction to the Driver
      elec_gen_mod.put(transaction); // Sending transaction to the Reference model

      @(elec_gen_driver_done);
      $display("[ELEC DRIVER] driver received");
    endtask

    // New task
    task Send_OS(input OS_type OS, input GEN generation);
      $display("[ELEC GENERATOR] waiting for correct recieved order_sets from type [%0p] ", OS);
      @correct_OS; // Blocking with the correct_OS event
      $display("[ELEC GENERATOR] correct recieved order_sets from type [%0p] ", OS);
      
      repeat (2) begin
        transaction = new(); // Instantiate a new transaction object
        transaction.o_sets = OS; // type of the ordered set
        transaction.tr_os = ord_set; // indicates whether the driver will send transaction or ordered set
        transaction.gen_speed = generation; // to indicate the generation
        transaction.sbrx = 1;
	    	transaction.phase ='d4;
        elec_gen_drv.put(transaction); // Sending transaction to the Driver
        elec_gen_mod.put(transaction); // Sending transaction to the Reference model
        $display("[ELEC GENERATOR] SENDING [%0p]", OS);
        @(elec_gen_driver_done); // To wait for the driver to finish driving the data
        $display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ", OS);
      end
    endtask

  endclass

endpackage

