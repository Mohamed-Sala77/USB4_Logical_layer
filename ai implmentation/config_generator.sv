// This class generates configuration transactions and puts them into two mailboxes.
class config_generator;
    // Mailboxes for driver and model
    mailbox #(config_transaction) mb_gen_drv;
    mailbox #(config_transaction) mb_gen_mod;

    // Events to synchronize with driver and monitor
    event driver_done;
    event scr_mon_done;

    // Transaction object
    config_transaction transaction;

    // Constructor
    function new(mailbox #(config_transaction) mb_drv, mailbox #(config_transaction) mb_mod, event driver_done , event scr_mon_done);
        // Initialize mailboxes and events
        this.mb_gen_drv = mb_drv;
        this.mb_gen_mod = mb_mod;
        this.driver_done = driver_done;
        this.scr_mon_done = scr_mon_done;
    endfunction

    // This task generates stimulus for the driver and model.
    task generate_stimulus();
        forever begin
            // Wait for scr_mon_done event
            @(scr_mon_done);

            // Create a new transaction and set its variables
            transaction = new();
            transaction.c_data_in = 32'h00200040; // Set c_data_in
            transaction.lane_disable = 0; // Set lane_disable

            // Display a message for debugging
            $display ("[Config generator ] send at time (%0t) usb4 data", $time);

            // Put the transaction into the mailboxes
            mb_gen_drv.put(transaction);
            mb_gen_mod.put(transaction);

            // Wait for driver_done event
            @(driver_done);
        end
    endtask
endclass