//////////////////////****scoreboard package****//////////////////////////////

package electrical_layer_scoreboard_pkg;
import electrical_layer_transaction_pkg::*;
class elec_scoreboard;
    // Mailboxes for module and monitor transactions
    mailbox #(elec_layer_tr) elec_mod_scr;
    mailbox #(elec_layer_tr) elec_mon_scr;

    // Constructor
    function new(mailbox #(elec_layer_tr) elec_mod_scr , mailbox #(elec_layer_tr) elec_mon_scr);
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
endpackage:electrical_layer_scoreboard_pkg 






/*class parent;
function void f1;
$display("hello");
endfunction
virtual function void f2;
$display("hello");
endfunction
endclass

class child extends parent;
function void f1;
$display("hi");
endfunction
function void f2;
$display("hi");
endfunction
endclass  

module x;
parent p=new;
child c=new;

initial 
begin
p.f1;
p.f2;
p=c;
p.f1;
p.f2;
end 
endmodule*/