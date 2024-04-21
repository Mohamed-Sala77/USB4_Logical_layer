////////////////////////****agent package****//////////////////////////////
package electrical_layer_agent_pkg;
    import electrical_layer_transaction_pkg::*; // Import the elec_layer_tr class 
    import electrical_layer_monitor_pkg::*;     // Import the electrical_layer_generator class
    import electrical_layer_driver_pkg::*;      // Import the elec_driver class
    import env_cfg_class_pkg::*;                // Import the env_cfg_class class
class electrical_layer_agent;

    ///**** Virtual interface declaration****///
    virtual electrical_layer_if vif; 

    ///**** mailbox declaration****///
      mailbox #(elec_layer_tr) elec_mon_2_Sboard;
      mailbox #(elec_layer_tr) elec_drv_gen;
    //mailbox #(elec_layer_tr) elec_mod_gen;
    
    ///**** memory declaration****///
    env_cfg_class env_cfg_mem;
    ///**** events declaration****///
     event elec_gen_driver_done;
     event sbtx_transition_high;
     event correct_OS;
     event sbtx_response;

    // Declare the components
    electrical_layer_driver driver;     
    electrical_layer_monitor monitor;    

    // Constructor
    function new(virtual electrical_layer_if vif,mailbox #(elec_layer_tr) elec_drv_gen,elec_mon_2_Sboard
                ,event elec_gen_driver_done,sbtx_transition_high,correct_OS,sbtx_response, 
                env_cfg_class env_cfg_mem);
        this.vif = vif;
        this.elec_drv_gen = elec_drv_gen;
        this.elec_gen_driver_done = elec_gen_driver_done;
        this.elec_mon_2_Sboard = elec_mon_2_Sboard;
        this.sbtx_transition_high = sbtx_transition_high;
        this.correct_OS = correct_OS;
        this.sbtx_response = sbtx_response;
        this.env_cfg_mem = env_cfg_mem;
        // handle the components
        driver = new(elec_gen_driver_done, elec_drv_gen, vif); 
        monitor = new(elec_mon_2_Sboard,vif, sbtx_transition_high, correct_OS,
                      sbtx_response, env_cfg_mem);              
    endfunction: new

    // Method to run the components
    task run();
        fork
            driver.run();
            monitor.run();
            
        join
    endtask: run

endclass


endpackage
