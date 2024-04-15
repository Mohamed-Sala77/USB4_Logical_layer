////////////////////////****agent package****//////////////////////////////
package electrical_layer_agent_pkg;
    import electrical_layer_transaction_pkg::*; // Import the elec_layer_tr class 
    import electrical_layer_monitor_pkg::*;     // Import the electrical_layer_generator class
    import electrical_layer_driver_pkg::*;      // Import the elec_driver class
class electrical_layer_agent;

    // Virtual interface
    virtual electrical_layer_if vif; 

    // Declare the mailboxes
    mailbox #(elec_layer_tr) elec_mon_scr;
    mailbox #(elec_layer_tr) elec_drv_gen;
    mailbox #(elec_layer_tr) elec_mod_gen;

    // Declare the events
    //event driver_start;

    // Declare the components
    electrical_layer_driver drv;     //---------add the name of the driver 
    electrical_layer_monitor mon;    //---------add the name of the MONITOR   
    //generatelectrical_layer_generatoror gen;  //---------add the name of the generator 

    // Constructor
    function new(
        mailbox #(elec_layer_tr) elec_mon_scr, 
        mailbox #(elec_layer_tr) elec_drv_gen, 
        virtual electrical_layer_if vif, 
        mailbox #(elec_layer_tr) elec_mod_gen
    );
        this.elec_mon_scr = elec_mon_scr;
        this.elec_drv_gen = elec_drv_gen;
        this.elec_mod_gen = elec_mod_gen;
        //this.driver_start = driver_start;
        this.vif = vif;

        // Instantiate the components
        drv = new(); //---------add the comp of the driver here ya walid 
        mon = new();              //---------add the comp of the MONITOR  here ya walid 
    endfunction

    // Method to run the components
    task run();
        fork
            drv.run();
            mon.run();
            
        join
    endtask

endclass


endpackage
