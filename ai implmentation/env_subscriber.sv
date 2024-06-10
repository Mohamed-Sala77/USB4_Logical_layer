class logical_layer_subscriber;
  // This class is used to subscribe to the environment class
  // and get the environment data
elec_layer_tr            elec_sboard_subscriber_tr;
upper_layer_tr           transport_sboard_subscriber_tr;   //this transaction for the subscriber to collect the coverage 
config_transaction       config_sboard_subscriber_tr;


covergroup elec_layer;
    coverpoint elec_sboard_subscriber_tr.transaction_type{
        bins none = {3'b000};
        bins LT_fall = {3'b001};
        bins AT_cmd = {3'b010};
        bins AT_rsp = {3'b011};
        bins LT_fall_wrong = {3'b100};
        bins AT_cmd_wrong = {3'b101};
        bins AT_rsp_wrong = {3'b110};
    }
    coverpoint elec_sboard_subscriber_tr.o_sets{
        bins SLOS1 = {4'b1000};
        bins SLOS2 = {4'b1001};
        bins TS1_gen2_3 = {4'b1010};
        bins TS2_gen2_3 = {4'b1011};
        bins TS1_gen4 = {4'b1100};
        bins TS2_gen4 = {4'b1101};
        bins TS3 = {4'b1110};
        bins TS4 = {4'b1111};
    }
    coverpoint elec_sboard_subscriber_tr.gen_speed{
        bins gen2 = {2'b00};
        bins gen3 = {2'b01};
        bins gen4 = {2'b10};
    }
    coverpoint elec_sboard_subscriber_tr.lane{
        bins both = {2'b11};
    }
    coverpoint elec_sboard_subscriber_tr.read_write{
        bins read = {1'b0};
    }

    coverpoint elec_sboard_subscriber_tr.address{
        bins SB_address = {8'd78};
        bins dummy_address =default;
    }
    coverpoint elec_sboard_subscriber_tr.len{
        bins SB_len = {7'd3};
        bins wrong_len =default;
    }
    coverpoint elec_sboard_subscriber_tr.cmd_rsp_data{
        bins SB_cmd_rsp_data_gen23 = {24'h013303};
        bins SB_cmd_rsp_data_gen4 = {24'h053303};
        bins wrong_cmd_rsp_data =default;
    }

    coverpoint elec_sboard_subscriber_tr.sbrx{
    bins sbrx_high = {1'b1};
    bins sbrx_low = {1'b0};
    }
    
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
