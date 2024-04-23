
class virtual_sequence;

////***stimulus generation declaration***////
    electrical_layer_generator virtual_elec_gen;
    config_generator virtual_cfg_gen; 
    up_stimulus_generator virtual_up_gen;

////***event declaration***////
    event sbtx_transition_high,  //connect with elec_monitor
      sbtx_response,
      recieved_on_elec_sboard;  //connect with elec_scoreboard to indecate recieve transaction

function new(event sbtx_transition_high,sbtx_response,recieved_on_elec_sboard);
    this.sbtx_transition_high = sbtx_transition_high;
    this.sbtx_response = sbtx_response;
    this.recieved_on_elec_sboard=recieved_on_elec_sboard;
endfunction: new
task run;

    ///phase 1///
    virtual_cfg_gen.generate_stimulus() ;

   ///phase 2///
   @(sbtx_transition_high); // Blocking with the event sbtx_transition_high 
   ->sbtx_response;
   virtual_elec_gen.sbrx_after_sbtx_high; // Call the sbrx_after_sbtx_high task
   ///phase 3///
    @(recieved_on_elec_sboard); // wait first AT_cmd fro dut to trigger 
    virtual_elec_gen.send_transaction_2_driver(AT_rsp,0,8'd78,7'd3,24'h053303,gen4);  
	virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,gen4); 
    @(recieved_on_elec_sboard); //  wait AT_rsp fro dut to trigger 

   ///phase 4///
   // @(recieved_on_elec_sboard); // Blocking with the event recieved_on_elec_sboard
    virtual_elec_gen.Send_OS(TS1_gen4,gen4);
    virtual_elec_gen.Send_OS(TS2_gen4,gen4);
    virtual_elec_gen.Send_OS(TS3,gen4);
    virtual_elec_gen.Send_OS(TS4,gen4);

    ///phase 5///
    virtual_up_gen.run();
    virtual_elec_gen.send_data(8'hFF,gen4,lane1);


    $stop; // Stop the simulation


endtask: run      


endclass: virtual_sequence