class env;

        //--------Declare the components -----------//
    // Declare the virtual interface
        virtual electrical_layer_if ELEC_vif;
        virtual config_space_if cfg_if;
        virtual upper_layer_if up_if;

        // Declare the generators
        electrical_layer_generator elec_gen;
        config_generator cfg_gen; 
        up_transport_generator up_gen;
        
        // Declare the agents
        electrical_layer_agent elec_agent;
        config_agent cfg_agent;
        up_transport_agent up_agent;

        // Declare the scoreboards
        elec_scoreboard elec_sboard;
        config_scoreboard cfg_scoreboard ;
        up_transport_scoreboard up_scoreboard ;

        //Declare the subscriber to collect the coverage
        logical_layer_subscriber env_subscriber;

        // Declare memory
        env_cfg_class env_cfg_mem;

        virtual_sequence virtual_seq;

        //////// Declare the scoreboards transaction to coverage class //////////
        elec_layer_tr                elec_sboard_subscriber_tr;
        upper_layer_tr               transport_sboard_subscriber_tr;   //this transaction for the subscriber to collect the coverage 
        config_transaction           config_sboard_subscriber_tr;

         //--------Declare the events -----------//
         
        event                    elec_gen_driver_done;    //elec_gen with elec_agent(driver)
        event                    correct_OS;              //elec_gen with elec_agent(monitor) 
        event                    cfg_driverDone;
        event                    cfg_next_stimulus;
        event                    up_driveDone;
        event                    elec_trigger_event; //to trigger the elec_covergroup in the env_subscriber
        event                    cfg_trigger_event;  //to trigger the cfg_covergroup in the env_subscriber
        event                    up_trigger_event;   //to trigger the up_covergroup in the env_subscriber
        


        //--------Declare the mailboxes -----------//
        mailbox #(elec_layer_tr) elec_gen_2_driver,
                                 elec_gen_2_model,
                                 elec_gen_2_scoreboard,
                                 elec_monitor_2_Sboard,
                                 elec_model_2_sboard;

        mailbox #(config_transaction) cfg_mon_scr ;
        mailbox #(config_transaction) cfg_mod_scr ;
        mailbox #(config_transaction) cfg_drv_gen ;
        mailbox #(config_transaction) cfg_mod_gen ;
        
       mailbox #(upper_layer_tr) up_mon_scr ;
       mailbox #(upper_layer_tr) up_mod_scr ;
       mailbox #(upper_layer_tr) up_drv_gen ;
       mailbox #(upper_layer_tr) up_mod_gen ;


        //--------Declare the referance model -----------//
        reference_model_AI model ;



        //--------Declare the constructor -----------//
        function new(virtual electrical_layer_if ELEC_vif ,virtual config_space_if cfg_if, virtual upper_layer_if up_if);

        //--------Initialize the interfaces -----------//
            this.ELEC_vif = ELEC_vif; 
            this.cfg_if = cfg_if;
            this.up_if=up_if;

        //--------Initialize the mailboxes -----------//
            elec_gen_2_driver = new();
            elec_gen_2_model = new();
            elec_gen_2_scoreboard = new();
            elec_monitor_2_Sboard = new();
            elec_model_2_sboard = new();
            cfg_mon_scr = new();
            cfg_drv_gen = new();
            cfg_mod_gen = new();
            up_mon_scr = new();
             up_drv_gen = new();
             up_mod_gen = new();
             up_mod_scr = new();
            cfg_mod_scr =new();

        //--------Initialize the ref_model-----------//  
           model  =new( up_mod_scr, up_mod_gen, elec_model_2_sboard, elec_gen_2_model, cfg_mod_scr, cfg_mod_gen);

        //--------Initialize the components -----------//
        // memory
        this.env_cfg_mem = new();

        // Agents
        elec_agent =new(ELEC_vif,elec_gen_2_driver,elec_monitor_2_Sboard,elec_gen_driver_done,correct_OS,env_cfg_mem);
        cfg_agent = new(cfg_if, cfg_mon_scr, cfg_drv_gen, cfg_driverDone);
        up_agent = new(up_if, up_mon_scr, up_drv_gen, up_driveDone, env_cfg_mem);
                      
        //Sequences
        virtual_seq =new(env_cfg_mem,up_if);

        // Scoreboards
        elec_sboard    = new(elec_model_2_sboard,elec_monitor_2_Sboard,elec_gen_2_scoreboard,
                             env_cfg_mem,elec_sboard_subscriber_tr,elec_trigger_event);
        cfg_scoreboard = new(cfg_mod_scr, cfg_mon_scr, cfg_next_stimulus,env_cfg_mem,config_sboard_subscriber_tr,cfg_trigger_event);
        up_scoreboard  = new(up_mod_scr, up_mon_scr,transport_sboard_subscriber_tr,env_cfg_mem,up_trigger_event);
        
        // Generators
        elec_gen = new(elec_gen_driver_done,correct_OS,elec_gen_2_driver,elec_gen_2_model,elec_gen_2_scoreboard,env_cfg_mem);
        cfg_gen = new(cfg_drv_gen, cfg_mod_gen, cfg_driverDone, cfg_next_stimulus);
        up_gen = new(up_mod_gen, up_drv_gen, up_driveDone, up_if, env_cfg_mem);

       // Subscriber
        env_subscriber = new(config_sboard_subscriber_tr,elec_sboard_subscriber_tr,transport_sboard_subscriber_tr,env_cfg_mem,
                             elec_trigger_event,cfg_trigger_event,up_trigger_event);

        
        // Virtual Sequence connections
        virtual_seq.virtual_elec_gen = elec_gen;
        virtual_seq.virtual_cfg_gen = cfg_gen;
        virtual_seq.virtual_up_gen = up_gen;



        endfunction: new

       




        // for compare the performance of the dut with the model
        task run(input string scenario, input GEN speed = gen4, input int num=16);
            fork

            //**********Run the components**********//
                //ELEC_components
                elec_agent.run();
                elec_sboard.run();

                
                // Config components
                cfg_agent.run();
                cfg_scoreboard.run();

                // Upper layer components
                up_agent.run(speed,num);
                up_scoreboard.run_scr();

                

                //Virtual Sequence
                virtual_seq.run(scenario,speed,num);

                //ref_model
                model.run();


                //env_subscriber
                env_subscriber.run;
                
            join
        endtask 


        

endclass