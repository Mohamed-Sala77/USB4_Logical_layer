// The up_stimulus_generator class generates stimuli for testing.
class up_stimulus_generator;
    // Mailboxes for module and driver
    mailbox ub_gen_mod;
    mailbox ub_gen_drv;

    // Event to signal when driving is done
    event drive_done;

    // Transaction object
    upper_layer_tr tr;

    // Constructor
    function new(mailbox mod, mailbox drv, event done);
        // Assign arguments to class members
        this.ub_gen_mod = mod;
        this.ub_gen_drv = drv;
        this.drive_done = done;
    endfunction

    // Task to generate stimuli
    task run();
        // Repeat 100 times
        repeat (5) begin
            
            // Create a new transaction object
            tr = new();
            
            // Generate random variables for tr
            // Check if randomization was successful
            if (!tr.randomize()) begin
                $error("Randomization failed");
                return;
            end
            
            // Put the transaction into the mailboxes
            ub_gen_mod.put(tr);
            ub_gen_drv.put(tr);

            // Wait for drive_done event to be triggered
            wait (drive_done.triggered);
        end
    endtask
endclass