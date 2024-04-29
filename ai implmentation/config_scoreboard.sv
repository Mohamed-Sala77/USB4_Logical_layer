class config_scoreboard;
    // Mailboxes for receiving transactions
    mailbox #(config_transaction) ref_mbox;
    mailbox #(config_transaction) mon_mbox;

    config_transaction ref_trans;
    config_transaction mon_trans;

    event next_stimulus;

    // Constructor
    function new(mailbox #(config_transaction) ref_mbox, mailbox #(config_transaction) mon_mbox , event next_stimulus);
        this.ref_mbox = ref_mbox;
        this.mon_mbox = mon_mbox;
        this.next_stimulus = next_stimulus;
        ref_trans = new();
        mon_trans = new();

    endfunction

    // Task to compare transactions
    task run();
        forever begin
            // Get transactions from both mailboxes
            get_transactions();

            // Check for specific condition and trigger event
            check_condition();

            // Compare the transactions
            compare_and_assert();
        end
    endtask


//--------for test model only -----------//

    task run_m();
    forever begin
        // Get transactions from both mailboxes
        get_transactions_m();
    end
    endtask














    // Function to get transactions from both mailboxes
    task get_transactions();
    
        //    ref_mbox.get(ref_trans);
        //   $display("[Config Scoreboard From Model] at time (%t) --> : %p", $time, ref_trans.convert2string() );
    
          mon_mbox.get(mon_trans);
          $display("\n[Config Scoreboard From Dut] at time (%t) is --> %p", $time ,mon_trans.convert2string());
           
       
    endtask

    task get_transactions_m();
    ref_mbox.get(ref_trans);
    $display("\n[Config Scoreboard] received at time (%0t) data of --> %p", $time, ref_trans );
    endtask

    // Function to check for specific condition and trigger event
    task check_condition();
        if ((mon_trans.c_address == 'd18) && (mon_trans.c_read))
            ->next_stimulus;
    endtask

    // Function to compare transactions and assert
    task compare_and_assert();
        //Detailed assertions 
        assert(ref_trans.c_read === mon_trans.c_read) else $display("[CONFIG SCOREBOARD] c_read doesn't match the expected value");
        assert(ref_trans.c_write === mon_trans.c_write) else $display("[CONFIG SCOREBOARD] c_write doesn't match the expected value");
        assert(ref_trans.c_address === mon_trans.c_address) else $display("[CONFIG SCOREBOARD] c_address doesn't match the expected value");
        assert(ref_trans.c_data_out === mon_trans.c_data_out) else $display("[CONFIG SCOREBOARD] c_data_out doesn't match the expected value");

        /*// General assertion
        assert (compare_transactions(ref_trans, mon_trans)) 
         else  $display("[Config Scoreboard] Mismatch" );*/
    endtask

    // Function to compare two transactions
    function bit compare_transactions(config_transaction ref_trans, config_transaction mon_trans);
        return (   (ref_trans.c_read == mon_trans.c_read) &&
                      (ref_trans.c_write == mon_trans.c_write) &&
                      (ref_trans.c_address == mon_trans.c_address) &&
                      (ref_trans.c_data_out == mon_trans.c_data_out)  );
    endfunction
endclass