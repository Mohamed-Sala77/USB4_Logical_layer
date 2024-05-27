//% this code generated by Ai "github cobilot" ^-^
class up_transport_generator;
    // Mailboxes for module and driver
    mailbox #(upper_layer_tr) ub_gen_mod;
    mailbox #(upper_layer_tr) ub_gen_drv;

    // Interface to the upper layer
    virtual upper_layer_if vif;

    // Event to signal when driving is done
    event drive_done;

    // Transaction object
    upper_layer_tr tr;

    env_cfg_class env_cfg_mem;

    // Constructor
    function new(mailbox mod, mailbox drv, event done ,virtual upper_layer_if vif, env_cfg_class env_cfg_mem);
        // Assign arguments to class members
        this.ub_gen_mod = mod;
        this.ub_gen_drv = drv;
        this.drive_done = done;
        this.vif = vif;
        this.env_cfg_mem = env_cfg_mem;

    endfunction

    // Task to generate stimuli
    task run( input int num);
    env_cfg_mem.data_count=(num);
        repeat (num) begin
            
            // Create a new transaction object
            tr = new();
            
            // Generate random variables for the transaction
            void'(tr.randomize(T_Data)) ;
            void'(tr.randomize(T_Data_1)) ;
            
            
            $display("[UPPER GENERATOR] data sent to lane 0: %0d      at %t", tr.T_Data, $time);
            $display("[UPPER GENERATOR] data sent to lane 1: %0d      at %t ", tr.T_Data_1, $time);
            // Put the transaction into the mailboxes
            ub_gen_mod.put(tr);
            ub_gen_drv.put(tr);

            vif.enable_sending = 1'b1;

            // Wait for drive_done event to be triggered
            @ (drive_done);
        end

                // Disable sending
            vif.enable_sending = 1'b0;
            repeat(2)@(posedge vif.gen4_fsm_clk);
            env_cfg_mem.Data_flag=0;
            $display("[UP_GENERATOR]at time(%0t)env_cfg_mem.Data_flag :%0b",$time,env_cfg_mem.Data_flag);
    endtask


endclass