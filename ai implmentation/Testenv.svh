
class env;

        //--------Declare the components -----------//
    // Declare the virtual interface
        virtual electrical_layer_if ELEC_vif;
        virtual config_space_if cfg_if;
        virtual upper_layer_if up_if;

        // Declare the generators
        electrical_layer_generator elec_gen;
        config_generator cfg_gen; 
        up_stimulus_generator up_gen;
        
        // Declare the agents
        electrical_layer_agent elec_agent;
        config_agent cfg_agent;
        ub_agent up_agent;

        // Declare the scoreboards
        elec_scoreboard elec_sboard;
        config_scoreboard cfg_scoreboard ;
        up_scoreboard up_scoreboard ;

        // Declare memory
        env_cfg_class env_cfg_mem;

        virtual_sequence virtual_seq;


         //--------Declare the events -----------//
         
        event elec_gen_driver_done;    //elec_gen with elec_agent(driver)
        event correct_OS;              //elec_gen with elec_agent(monitor)
        event sbtx_transition_high;    //v_sequance with elec_agent(monitor)
        event sbtx_response;           //v_sequance with elec_agent(monitor)
        event recieved_on_elec_sboard; //v_sequance with elec_sboard  
        event cfg_driverDone;
        event cfg_next_stimulus;
        event up_driveDone;
        


        //--------Declare the mailboxes -----------//
        mailbox #(elec_layer_tr) elec_gen_2_driver,
                                 elec_gen_2_model,
                                 elec_gen_2_scoreboard,
                                 elec_monitor_2_Sboard,
                                 elec_model_2_sboard;

        mailbox #(config_transaction) mb_cfg_mon_scr ;
        mailbox #(config_transaction) mb_cfg_drv_gen ;
        mailbox #(config_transaction) mb_cfg_mod_gen ;
        
        mailbox #(upper_layer_tr) mb_up_mon_scr ;
        mailbox #(upper_layer_tr) mb_up_drv_gen ;
        mailbox #(upper_layer_tr) mb_up_mod_gen ;


        //--------Declare the referance model -----------//




        //--------Declare the constructor -----------//
        function new(virtual electrical_layer_if ELEC_vif ,virtual config_space_if cfg_if, virtual upper_layer_if up_if);

        //--------Initialize the interfaces -----------//
            this.ELEC_vif = ELEC_vif;  

        //--------Initialize the mailboxes -----------//
            elec_gen_2_driver = new();
            elec_gen_2_model = new();
            elec_gen_2_scoreboard = new();
            elec_monitor_2_Sboard = new();
            elec_model_2_sboard = new();
            mb_cfg_mon_scr = new();
            mb_cfg_drv_gen = new();
            mb_cfg_mod_gen = new();
            mb_up_mon_scr = new();
            mb_up_drv_gen = new();
            mb_up_mod_gen = new();

        //--------Initialize the ref_model-----------//  

        //--------Initialize the components -----------//
        // memory
        this.env_cfg_mem = new();

        // Agents
        elec_agent =new(ELEC_vif,elec_gen_2_driver,elec_monitor_2_Sboard,elec_gen_driver_done,sbtx_transition_high,correct_OS,sbtx_response,env_cfg_mem);
        cfg_agent = new(cfg_if, mb_cfg_mon_scr, mb_cfg_drv_gen, cfg_driverDone, cfg_next_stimulus, mb_cfg_mod_gen);
        up_agent = new(up_if, mb_up_mon_scr, mb_up_drv_gen, up_driveDone, mb_up_mod_gen);
                      
        //Sequences
        virtual_seq =new(sbtx_transition_high,sbtx_response,recieved_on_elec_sboard);
        cfg_scoreboard = new(mb_cfg_mod_gen, mb_cfg_mon_scr, cfg_next_stimulus);
        up_scoreboard = new(mb_up_mod_gen, mb_up_mon_scr);

        // Scoreboards
        elec_sboard    = new(elec_model_2_sboard,elec_monitor_2_Sboard,elec_gen_2_scoreboard,env_cfg_mem,recieved_on_elec_sboard);
        cfg_scoreboard = new(mb_cfg_mod_gen, mb_cfg_mon_scr, cfg_next_stimulus);
        up_scoreboard  = new(mb_up_mod_gen, mb_up_mon_scr);
        
        // Generators
        elec_gen = new(elec_gen_driver_done,correct_OS,elec_gen_2_driver,elec_gen_2_model,elec_gen_2_scoreboard);
        cfg_gen = new(mb_cfg_drv_gen, mb_cfg_mod_gen, cfg_driverDone, cfg_next_stimulus);
        up_gen = new(mb_up_mod_gen, mb_up_drv_gen, up_driveDone);
        
        // Virtual Sequence connections
        virtual_seq.virtual_elec_gen = elec_gen;


        endfunction: new

        //--------Declare the run task -----------//
        task run();
            fork

            //**********Run the components**********//
                //ELEC_components
                elec_agent.run();
                elec_sboard.run();

                
                // Config components
                cfg_agent.run();
                cfg_scoreboard.run();

                // Upper layer components
                up_agent.run();
                up_scoreboard.run_scr();

                

                //Virtual Sequence
                virtual_seq.run();

                //ref_model

                
            join
        endtask: run

endclass