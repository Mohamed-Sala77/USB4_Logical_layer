class virtual_sequence;

////***stimulus generation declaration***////
    electrical_layer_generator virtual_elec_gen;
    config_generator virtual_cfg_gen; 
    up_transport_generator virtual_up_gen;


    env_cfg_class cfg_class;
    virtual upper_layer_if vif ;

////***event declaration***////
    /*event sbtx_transition_high,  //connect with elec_monitor
      sbtx_response;  //connect with elec_scoreboard to indecate recieve transaction*/

function new(env_cfg_class cfg_class ,virtual upper_layer_if vif);
    this.cfg_class=cfg_class;
    this.vif=vif;
endfunction: new





///////////////////////////////////////////////////////////
/////////////////////////Run Function//////////////////////
///////////////////////////////////////////////////////////
task run(input string scenario,input GEN speed, input int num);

case (scenario)

   "normal" :                           normal(speed, num);
   "EarlyCommand" :               early_command(speed, num);
   "LT_fall" :                            LT_fall_test( speed, num);
   "SBRX_LOW" :                      SBRX_LOW( speed, num);
    default:                              normal( speed, num);

endcase



endtask
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////







task normal (input GEN speed, input int num);
case (speed)
gen4: run_gen4(num,speed);
gen3: run_gen3(num,speed);
gen2: run_gen2(num,speed);
default: run_default(num,speed);
 endcase
endtask 




task early_command(input GEN speed, input int num);
case (speed)
    gen4: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");

          // sending  early at command 
          virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,gen4);


          run_phase2(gen4);
          run_phase3(gen4, 24'h053303);
          run_phase4(gen4, TS1_gen4, TS2_gen4, TS3, TS4);
          run_phase5(gen4, num);
          $stop;
     end
     gen3: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");

          // sending  early at command 
          virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,gen4);

          run_phase2(gen3);
          run_phase3(gen3, 24'h013303);
          run_phase4(gen3, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);
          run_phase5(gen3, num);
          $stop;
     end
     gen2: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");

          // sending  early at command 
          virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,gen4);

          run_phase2(gen2);
          run_phase3(gen2, 24'h011303);
          run_phase4(gen2, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);
          run_phase5(gen2, num);
          $stop;
     end
     default: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");

          // sending  early at command 
          virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,gen4);

          run_phase2(gen4);
          run_phase3(gen4, 24'h053303);
          run_phase4(gen4, TS1_gen4, TS2_gen4, TS3, TS4);
          run_phase5(gen4, num);
          $stop;
     end
endcase

    endtask 





task LT_fall_test(input GEN speed, input int num);

case (speed)
    gen4: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");



          run_phase2(gen4);
          run_phase3(gen4, 24'h053303);
          run_phase4(gen4, TS1_gen4, TS2_gen4, TS3, TS4);
          run_phase5(gen4, num);
          virtual_elec_gen.send_transaction_2_driver(LT_fall);  

          $stop;
     end
     gen3: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");


          run_phase2(gen3);
          run_phase3(gen3, 24'h013303);
          run_phase4(gen3, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);
          run_phase5(gen3, num);
          virtual_elec_gen.send_transaction_2_driver(LT_fall);  

          $stop;
     end
     gen2: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");


          run_phase2(gen2);
          run_phase3(gen2, 24'h011303);
          run_phase4(gen2, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);
          run_phase5(gen2, num);
          virtual_elec_gen.send_transaction_2_driver(LT_fall);  

          $stop;
     end
     default: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");


          run_phase2(gen4);
          run_phase3(gen4, 24'h053303);
          run_phase4(gen4, TS1_gen4, TS2_gen4, TS3, TS4);
          run_phase5(gen4, num);
          virtual_elec_gen.send_transaction_2_driver(LT_fall);  

          $stop;
     end
endcase

    endtask 



    
task SBRX_LOW (input GEN speed, input int num);

case (speed)
    gen4: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");



          run_phase2(gen4);
          run_phase3(gen4, 24'h053303);
          run_phase4(gen4, TS1_gen4, TS2_gen4, TS3, TS4);
          run_phase5(gen4, num);
          virtual_elec_gen.Disconnect();
          #(tDisconnectRx);
          //$stop;
          //run_phase5(gen4, num);

          run_phase2(gen4);
          run_phase3(gen4, 24'h053303);
          run_phase4(gen4, TS1_gen4, TS2_gen4, TS3, TS4);
          run_phase5(gen4, num);
          //$stop;
     end
     gen3: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");


          run_phase2(gen3);
          run_phase3(gen3, 24'h013303);
          run_phase4(gen3, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);
          run_phase5(gen3, num);
            virtual_elec_gen.Disconnect();
          $stop;
     end
     gen2: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");


          run_phase2(gen2);
          run_phase3(gen2, 24'h011303);
          run_phase4(gen2, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);
          run_phase5(gen2, num);
            virtual_elec_gen.Disconnect();
          $stop;
     end
     default: begin
          virtual_cfg_gen.generate_stimulus();
          $display("[virtual_sequence]:waiting for sbtx_transition_high event");


          run_phase2(gen4);
          run_phase3(gen4, 24'h053303);
          run_phase4(gen4, TS1_gen4, TS2_gen4, TS3, TS4);
          run_phase5(gen4, num);
            virtual_elec_gen.Disconnect();
          $stop;
     end
endcase

    endtask 



    





task run_gen4(input int num, input GEN speed);
        // Phase 1
        virtual_cfg_gen.generate_stimulus();
        $display("[virtual_sequence]:waiting for sbtx_transition_high event");

        // Phase 2
        run_phase2(speed);

        // Phase 3
        run_phase3(speed, 24'h053303);

        // Phase 4
        run_phase4(speed, TS1_gen4, TS2_gen4, TS3, TS4);

        // Phase 5
        run_phase5(speed, num);

        //disconnect


        //$stop;

    endtask

task run_gen3(input int num, input GEN speed);
        // Phase 1
        virtual_cfg_gen.generate_stimulus();
        $display("[virtual_sequence]:waiting for sbtx_transition_high event");

        // Phase 2
        run_phase2(speed);

        // Phase 3
        run_phase3(speed, 24'h013303);

        // Phase 4
        run_phase4(speed, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);

        // Phase 5
        run_phase5(speed, num);

        //$stop;
endtask

task run_gen2(input int num, input GEN speed);
        // Phase 1
        virtual_cfg_gen.generate_stimulus();
        $display("[virtual_sequence]:waiting for sbtx_transition_high event");

        // Phase 2
        run_phase2(speed);

        // Phase 3
        run_phase3(speed, 24'h011303);

        // Phase 4
        run_phase4(speed, SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3);

        // Phase 5
        run_phase5(speed, num);

        //$stop;
endtask

task run_default(input int num, input GEN speed);
        // Phase 1
        virtual_cfg_gen.generate_stimulus();
        $display("[virtual_sequence]:waiting for sbtx_transition_high event");

        // Phase 2
        run_phase2(speed);

        // Phase 3
        run_phase3(speed, 24'h053303);

        // Phase 4
        run_phase4(speed, TS1_gen4, TS2_gen4, TS3, TS4);

        // Phase 5
        run_phase5(speed, num);

        $stop;
endtask







/////////////////////////pahse 2////////////////////////
 task run_phase2(input GEN speed);

  virtual_elec_gen.wake_up(2,speed);
  wait(cfg_class.recieved_on_elec_sboard ==1); // wait first AT_cmd from dut to trigger
  cfg_class.recieved_on_elec_sboard =0;
 virtual_elec_gen.sbrx_after_sbtx_high; // Call the sbrx_after_sbtx_high task
  
endtask



/////////////////////////pahse 3////////////////////////
task run_phase3(input GEN speed, input int cmd);

virtual_elec_gen.wake_up(3,speed);

wait(cfg_class.recieved_on_elec_sboard ==1); // wait first AT_cmd fro dut to trigger
cfg_class.recieved_on_elec_sboard =0;
//virtual_elec_gen.wake_up(3);
virtual_elec_gen.send_transaction_2_driver(AT_rsp,0,8'd78,7'd3,cmd,speed);  
virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,speed);

endtask


/////////////////////////phase 4////////////////////////
task run_phase4(input GEN speed, input OS_type os1, input OS_type os2, input OS_type os3, input OS_type os4);

    wait(cfg_class.recieved_on_elec_sboard ==1);  //  wait AT_rsp from dut to trigger 
    cfg_class.recieved_on_elec_sboard =0;
    //$display("[virtual_sequence]:waittttttttttttttttttttttttttttttttttttttt");

    //@(recieved_on_elec_sboard); // Blocking with the event recieved_on_elec_sboard
    //virtual_elec_gen.wake_up(4,speed);
    virtual_elec_gen.Send_OS(os1,speed);
    virtual_elec_gen.Send_OS(os2,speed);
    virtual_elec_gen.Send_OS(os3,speed);
    virtual_elec_gen.Send_OS(os4,speed);

endtask




/////////////////////////pahse 5////////////////////////
task run_phase5(input GEN speed, input int num);

//$display("[virtual_sequence]:waiting for cl0_s event");
@(vif.cl0_s);         // transport is ready to send and recieve data  
//$display("[virtual_sequence]:cl0_s event triggered");

if(speed ==gen4)begin


//****** sending from electrical to transport layer*******//

fork

begin
  virtual_elec_gen.send_data(speed,num);
end

begin
    // start receiving data on the transport layer
    vif.enable_receive = 1'b1;
end

join
  
 repeat(1) @(negedge  vif.gen4_fsm_clk);

  vif.enable_receive = 1'b0;      // disable the monitor to stop receiving data from transport_data_out

//repeat(32) @(negedge  vif.gen4_fsm_clk);
////////////////////////////////////////////////////////////////
 //**** sending from transport to electrical layer****//
    // start sending data from the transport layer
   /* vif.enable_sending = 1'b1;
    $display("[virtual_sequence]:enable_sending data from transport layer");
     // Send data num times
        virtual_up_gen.run(num);
        @(negedge  vif.gen4_fsm_clk);*/

end
else begin
  //**** sending from transport to electrical layer****//
    // start sending data from the transport layer
    vif.enable_sending = 1'b1;
    $display("[virtual_sequence]:enable_sending data from transport layer");
     // Send data num times
        virtual_up_gen.run(num);
        @(negedge  vif.gen4_fsm_clk);
     end

endtask




endclass