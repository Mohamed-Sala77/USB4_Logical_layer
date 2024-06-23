class logical_layer_subscriber;
  // This class is used to subscribe to the environment class
  // and get the environment data
elec_layer_tr            elec_sboard_subscriber_tr;
upper_layer_tr           transport_sboard_subscriber_tr;   //this transaction for the subscriber to collect the coverage 
config_transaction       config_sboard_subscriber_tr;
env_cfg_class            env_cfg;
event                    elec_trigger_event; //to trigger the elec_covergroup in the env_subscriber
event                    cfg_trigger_event;  //to trigger the cfg_covergroup in the env_subscriber
event                    up_trigger_event;   //to trigger the up_covergroup in the env_subscriber

 


covergroup elec_layer; 
    coverpoint env_cfg.elec_sboard_subscriber_tr.transaction_type{
        bins none = {3'b000};
        bins LT_fall = {3'b001};
        bins AT_cmd = {3'b010};
        bins AT_rsp = {3'b011};
        //bins LT_fall_wrong = {3'b100};
        //bins AT_cmd_wrong = {3'b101};
        //bins AT_rsp_wrong = {3'b110};
        ///////////transition coverage//////////////
        bins cmd_2_rsp_transition   =(AT_cmd => AT_rsp);
    }
    coverpoint env_cfg.elec_sboard_subscriber_tr.o_sets{
        bins SLOS1 = {4'b1000};
        bins SLOS2 = {4'b1001};
        bins TS1_gen2_3 = {4'b1010};
        bins TS2_gen2_3 = {4'b1011};
        bins TS1_gen4 = {4'b1100};
        bins TS2_gen4 = {4'b1101};
        bins TS3 = {4'b1110};
        bins TS4 = {4'b1111};
        ///////////transition coverage///////////////
        bins gen23_os_transitions= (SLOS1 =>SLOS2 =>TS1_gen2_3 => TS2_gen2_3);
        bins gen4_os_transitions = (TS1_gen4 => TS2_gen4 => TS3 => TS4);
    }
    gen_speed:coverpoint env_cfg.elec_sboard_subscriber_tr.gen_speed{
        bins gen2 = {2'b00};
        bins gen3 = {2'b01};
        bins gen4 = {2'b10};
    }
    lanes:coverpoint env_cfg.elec_sboard_subscriber_tr.lane{
        bins both = {2'b11};
    }
    SB_read_write:coverpoint env_cfg.elec_sboard_subscriber_tr.read_write{
        bins read = {1'b0};
    }

    SB_address:coverpoint env_cfg.elec_sboard_subscriber_tr.address{
        bins SB_address = {8'd78};
        bins dummy_addresses =default;
    }
    SB_Length:coverpoint env_cfg.elec_sboard_subscriber_tr.len{
        bins SB_len = {7'd3};
        bins wrong_len =default;
    }
    /*coverpoint env_cfg.elec_sboard_subscriber_tr.cmd_rsp_data{
        bins SB_cmd_rsp_data_gen23 = {24'h013303};
        bins SB_cmd_rsp_data_gen4 = {24'h053303};
        bins wrong_cmd_rsp_data =default;
    }*/

    coverpoint env_cfg.elec_sboard_subscriber_tr.sbtx{
    bins sbrx_high = {1'b1};
    bins sbrx_low = {1'b0};
    }

      cross gen_speed,lanes;/*{
      bins gen2_both_lanes = {2'b00,2'b11};
      bins gen3_both_lanes = {2'b01,2'b11};
      bins gen4_both_lanes = {2'b10,2'b11};
    };*/
    cross SB_address,SB_read_write,SB_Length;

endgroup



covergroup upper_layer;
      DATA_Lane:coverpoint env_cfg.transport_sboard_subscriber_tr.T_Data{
        bins T_Data_high = {8'hFF};
        bins T_Data_low = {8'h00};
        bins T_Data_mid = {[8'h01:8'hFE]};
      }
      cl0_s:coverpoint env_cfg.transport_sboard_subscriber_tr.cl0_s
      {
        bins cl0_s_high = {1'b1}; 
      }
      ENABLE_RX:coverpoint env_cfg.transport_sboard_subscriber_tr.enable_receive{
        bins enable_receive_high = {1'b1};
      }
     cross cl0_s,DATA_Lane;
     cross cl0_s,ENABLE_RX;
     cross DATA_Lane,ENABLE_RX;

endgroup

covergroup config_space;
   
   c_read:coverpoint env_cfg.config_sboard_subscriber_tr.c_read{
        bins c_read_high = {1'b1};
    }
    c_address:coverpoint env_cfg.config_sboard_subscriber_tr.c_address{
        bins c_address_cfg = {8'd18};
    }
    c_write:coverpoint env_cfg.config_sboard_subscriber_tr.c_write{
        bins c_write_low = {1'b0};
    }
    cross c_read,c_address;
    cross c_read,c_write; 
endgroup

function new(config_transaction config_sboard_subscriber_tr,elec_layer_tr elec_sboard_subscriber_tr,
             upper_layer_tr  transport_sboard_subscriber_tr,env_cfg_class env_cfg,event elec_trigger_event,
             event cfg_trigger_event,event  up_trigger_event);
    // Constructor
    this.elec_sboard_subscriber_tr = elec_sboard_subscriber_tr;
    this.transport_sboard_subscriber_tr = transport_sboard_subscriber_tr;
    this.config_sboard_subscriber_tr = config_sboard_subscriber_tr;
    this.env_cfg = env_cfg;
     elec_layer  = new();
     upper_layer = new();
     config_space = new();
     config_sboard_subscriber_tr= new();
      elec_sboard_subscriber_tr = new();
      transport_sboard_subscriber_tr = new();
    endfunction
 

task run();
  //forever begin
    fork
        begin
          forever begin
         wait(env_cfg.elec_trigger_event ==1)
         env_cfg.elec_trigger_event=0;
         elec_layer.sample();
         $display("[coverage collector]the value of elec_sboard_subscriber_tr %p",env_cfg.elec_sboard_subscriber_tr);
          end
        end

        begin
          forever begin
        wait(env_cfg.up_trigger_event ==1)
        env_cfg.up_trigger_event=0;
        upper_layer.sample();
        $display("[coverage collector]the value of transport_sboard_subscriber_tr  %p",env_cfg.transport_sboard_subscriber_tr);
        end
        end

        begin
          forever begin
        wait(env_cfg.cfg_trigger_event ==1)
        env_cfg.cfg_trigger_event=0;
        config_space.sample();
        $display("[coverage collector]the value of config_sboard_subscriber_tr %p",env_cfg.config_sboard_subscriber_tr);
        //$stop;
        end
        end
    join

 // end
endtask
endclass
