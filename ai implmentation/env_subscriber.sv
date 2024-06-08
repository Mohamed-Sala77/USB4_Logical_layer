class logical_layer_subscriber;
  // This class is used to subscribe to the environment class
  // and get the environment data
elec_layer_tr            elec_sboard_subscriber_tr;
upper_layer_tr           transport_sboard_subscriber_tr;   //this transaction for the subscriber to collect the coverage 
config_transaction       config_sboard_subscriber_tr;


covergroup elec_layer;
    
endgroup

covergroup upper_layer;
endgroup

covergroup config_space;
endgroup

  function new(config_transaction config_sboard_subscriber_tr,elec_layer_tr elec_sboard_subscriber_tr,upper_layer_tr  transport_sboard_subscriber_tr);
    // Constructor
    this.elec_sboard_subscriber_tr = elec_sboard_subscriber_tr;
    this.transport_sboard_subscriber_tr = transport_sboard_subscriber_tr;
    this.config_sboard_subscriber_tr = config_sboard_subscriber_tr;
    endfunction

task run();
  // Task to run the subscriber
 
endtask
endclass
