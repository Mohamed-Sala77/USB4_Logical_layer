//////////////////////****stimulus gen package****//////////////////////////////
package electrical_layer_generator_pkg;

  import electrical_layer_transaction_pkg::*;   // Import the elec_layer_tr class

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
    mailbox #(elec_layer_tr) elec_gen_2_monitor;  // Mailbox to receive the transaction from the generator

    // Constructor
    function new(event sbrx_transition_high, event elec_gen_driver_done, event sbtx_transition_high, event correct_OS, mailbox #(elec_layer_tr) elec_gen_drv, mailbox #(elec_layer_tr) elec_gen_mod ,elec_gen_2_monitor);
      this.sbrx_transition_high = sbrx_transition_high;
      this.elec_gen_driver_done = elec_gen_driver_done;
      this.sbtx_transition_high = sbtx_transition_high;
      this.correct_OS = correct_OS; // Assign the correct_OS event
      this.elec_gen_drv = elec_gen_drv;
      this.elec_gen_mod = elec_gen_mod;
      this.elec_gen_2_monitor = elec_gen_2_monitor; // Assign the elec_gen_2_monitor mailbox
    endfunction

    // Declare the task as extern
    extern task sbrx_after_sbtx_high();
    extern task send_transaction_2_driver(input tr_type trans_type = None, input bit read_write = 0,input bit [31:0] address = 0,
                                          input bit [31:0] len = 0, input bit [31:0] cmd_rsp_data = 0,input GEN generation = gen2);
    extern task Send_OS(input OS_type OS, input GEN generation);
    extern task send_data(input logic [7:0] data, input GEN gen_speed,input LANE lane);
    extern task Disconnect();
 

  endclass : electrical_layer_generator


         /////*** Define the task outside the class***/////

   task electrical_layer_generator::sbrx_after_sbtx_high();
   // @(sbtx_transition_high); // Blocking with the event sbtx_transition_high (do it on sequance)
    $display("[ELEC GENERATOR] : sbtx is high");
    transaction = new();                    // Construct the transaction
    transaction.sbrx = 1'b1;                // Set transaction.sbrx to 1'b1
    transaction.phase = 3'd2;               // Set transaction.phase to 3'd2
    elec_gen_drv.put(transaction);          // Put the transaction on the elec_gen_drv mailbox
    elec_gen_mod.put(transaction);          // Put the transaction on the elec_gen_mod mailbox
    elec_gen_2_monitor.put(transaction);    // Put the transaction on the elec_gen_2_monitor mailbox
    $display("[ELEC GENERATOR] : sbrx send high");
     @(elec_gen_driver_done);               // Blocking with the event elec_gen_driver_done
    $display("[ELEC GENERATOR] : SENT sbrx is high SUCCESSFULLY");
   endtask


    // Transaction methods
    task electrical_layer_generator::send_transaction_2_driver(input tr_type trans_type = None, input bit read_write = 0, input bit [31:0] address = 0,
                                                      input bit [31:0] len = 0, input bit [31:0] cmd_rsp_data = 0, input GEN generation = gen2);
      transaction = new(); // Instantiate the transaction object using the default constructor
      transaction.phase ='d3;
      transaction.transaction_type = trans_type;
      transaction.tr_os = tr;
      transaction.sbrx = 1;
      transaction.gen_speed = generation;
      case(trans_type)
        AT_cmd, AT_rsp: begin
          transaction.read_write = read_write;
          transaction.address = address;
          transaction.len = len;
          transaction.cmd_rsp_data = cmd_rsp_data;
          $display("[ELEC GENERATOR] sending [%0p] Transaction", trans_type);
        end
        LT_fall: begin
          //transaction.sbrx = 0;  knew it from trans_type
          $display("[ELEC GENERATOR] sending [LT_FALL] Transaction");
        end
      endcase

      elec_gen_drv.put(transaction);       // Sending transaction to the Driver
      elec_gen_mod.put(transaction);       // Sending transaction to the Reference model
      elec_gen_2_monitor.put(transaction); // Put the transaction on the elec_gen_2_monitor mailbox
      @(elec_gen_driver_done);
      $display("[ELEC DRIVER] driver received");
    endtask

     //task to send ordered sets
    task electrical_layer_generator::Send_OS(input OS_type OS, input GEN generation);
      $display("[ELEC GENERATOR] waiting for correct recieved order_sets from type [%0p] ", OS);
      @correct_OS; // Blocking with the correct_OS event
      $display("[ELEC GENERATOR] correct recieved order_sets from type [%0p] ", OS);
      
      repeat (1) begin        
        transaction = new();                 // Instantiate a new transaction object
        transaction.o_sets = OS;             // type of the ordered set
        transaction.tr_os = ord_set;         // indicates whether the driver will send transaction or ordered set
        transaction.gen_speed = generation;  // to indicate the generation
        transaction.sbrx = 1;
	    	transaction.phase ='d4;
        elec_gen_drv.put(transaction);        // Sending transaction to the Driver
        elec_gen_mod.put(transaction);        // Sending transaction to the Reference model
         elec_gen_2_monitor.put(transaction); // Put the transaction on the elec_gen_2_monitor mailbox
        $display("[ELEC GENERATOR] SENDING [%0p]", OS);
        @(elec_gen_driver_done);               // To wait for the driver to finish driving the data
        $display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ", OS);
      end
    endtask

    
    
    task electrical_layer_generator::send_data(input logic [7:0] data, input GEN gen_speed,input LANE lane);  //discuss on the width of the input data later
      transaction = new();                     // Instantiate the transaction object using the default constructor
      transaction.sbrx = 1;
      transaction.phase = 3'd5;                //not real phase but for env only
      transaction.lane = lane;
      transaction.gen_speed = gen_speed;
      transaction.electrical_to_transport = data;
      elec_gen_drv.put(transaction);           // Sending transaction to the Driver
      elec_gen_mod.put(transaction);           // Sending transaction to the Reference model
      elec_gen_2_monitor.put(transaction);     // Put the transaction on the elec_gen_2_monitor mailbox
      @(elec_gen_driver_done);
      $display("[ELEC GENERATOR] data sent");
      endtask: send_data

  
      task electrical_layer_generator::Disconnect();
      transaction = new();                     // Instantiate the transaction object using the default constructor
      transaction.sbrx = 0;
      transaction.phase = 3'd6;                //not real phase but for env only
      elec_gen_drv.put(transaction);           // Sending transaction to the Driver
      elec_gen_mod.put(transaction);           // Sending transaction to the Reference model
      elec_gen_2_monitor.put(transaction);     // Put the transaction on the elec_gen_2_monitor mailbox
      @(elec_gen_driver_done);
      $display("[ELEC GENERATOR] Disconnect order sent to driver");
      endtask: Disconnect
  



endpackage: electrical_layer_generator_pkg






// End of file

/*
module test_electrical_layer_generator;

  import electrical_layer_transaction_pkg::*;
  import electrical_layer_generator_pkg::*;
  
  // Declare events
  event sbrx_transition_high;
  event elec_gen_driver_done;
  event sbtx_transition_high;
  event correct_OS;

  // Declare mailboxes
  mailbox #(elec_layer_tr) elec_gen_drv = new();
  mailbox #(elec_layer_tr) elec_gen_mod = new();

  // Instantiate the electrical_layer_generator
  electrical_layer_generator elec_gen = new(sbrx_transition_high, elec_gen_driver_done, sbtx_transition_high, correct_OS, elec_gen_drv, elec_gen_mod);

    // Call the tasks to test the class
elec_layer_tr received_transaction;

initial begin
  
  fork
  elec_gen.sbrx_after_sbtx_high();
  -> sbtx_transition_high; // To unblock the sbrx_after_sbtx_high task
  begin
  elec_gen_drv.get(received_transaction);
  ->elec_gen_driver_done;  // To unblock the sbrx_after_sbtx_high task
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
  join


fork
  elec_gen.send_transaction(AT_cmd, 3, 0, 32'h0, 32'h0, 32'h0);
  begin
  elec_gen_drv.get(received_transaction);
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
  ->elec_gen_driver_done; // To unblock send_transaction task
join

fork
  elec_gen.Send_OS(OS_type'("OS"), GEN'("gen1"));
  ->correct_OS; // To unblock the Send_OS task
  begin
  elec_gen_drv.get(received_transaction);
  ->elec_gen_driver_done; // To unblock the Send_OS task
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
join

fork
  elec_gen.send_data(10'd99);
  begin
  elec_gen_drv.get(received_transaction);
  ->elec_gen_driver_done; // To unblock the send_data task
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
  
join
  
end

endmodule*/