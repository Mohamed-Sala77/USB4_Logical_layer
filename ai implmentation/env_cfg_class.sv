class env_cfg_class;
bit [2:0]   phase;
OS_type     o_sets; 
GEN         gen_speed;
tr_type     transaction_type;
bit         data_income; 
bit  [1:0]  ready_phase2; 
bit         correct_OS;
bit         recieved_on_elec_sboard;  //for recieving on elec scoreboard
bit         done;
bit         Data_flag;    //flag to indecate the data send from transport to electrical layer  
int         data_count;  //indicate the number of samples send from transport to electrical layer
bit         elec_trigger_event; //to trigger the elec_covergroup in the env_subscriber
bit        cfg_trigger_event;  //to trigger the cfg_covergroup in the env_subscriber
bit         up_trigger_event;   //to trigger the up_covergroup in the env_subscriber

//--------Declare transactions -----------//
elec_layer_tr            elec_sboard_subscriber_tr;
upper_layer_tr           transport_sboard_subscriber_tr;   //this transaction for the subscriber to collect the coverage 
config_transaction       config_sboard_subscriber_tr;
//this queue is used to store the data from the ELEC_monitor to the ELEC_driver to reduce write the same code on driver and monitor to send and recieve data
static logic GEN4_recieved_TS1_LANE0[$];
static logic GEN4_recieved_TS1_LANE1[$];
static logic GEN3_Recieved_SLOS1[$];
static logic GEN2_Recieved_SLOS1[$];
static logic GEN3_Recieved_SLOS2[$];
static logic GEN2_Recieved_SLOS2[$];
static logic TS1_gen23_lane0[$];
static logic TS1_gen23_lane1[$];
static logic TS2_gen23_lane0[$];
static logic TS2_gen23_lane1[$];
endclass: env_cfg_class

