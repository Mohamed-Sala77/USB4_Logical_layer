
class elec_scoreboard;
    // Mailboxes for module and monitor transactions
    mailbox #(upper_layer_tr) elec_mod_scr;
    mailbox #(upper_layer_tr) elec_mon_scr;

    // Constructor
    function new(mailbox #(upper_layer_tr) elec_mod_scr , mailbox #(upper_layer_tr) elec_mon_scr);
        this.elec_mod_scr = elec_mod_scr;
        this.elec_mon_scr = elec_mon_scr;
    endfunction

    // Main task to run the scoreboard
    task run();
        elec_layer_tr mod_tr, mon_tr;

        forever begin
            // Get transactions from both mailboxes
            elec_mod_scr.get(mod_tr);
            elec_mon_scr.get(mon_tr);

            // Check if the transactions are the same
            /*
            if (mod_tr == mon_tr) begin
                $display("Right data");
            end else begin
                $display("Wrong data");
            end
            */
        end
    endtask
endclass