//////////////////////****scoreboard package****//////////////////////////////
package electrical_layer_scoreboard_pkg;
import electrical_layer_transaction_pkg::*;
import env_cfg_class_pkg::*;
class elec_scoreboard;
 
    elec_layer_tr model_tr,
                  monitor_tr,
                  gen_tr;
    env_cfg_class env_cfg_mem;

    // Mailboxes for module and monitor transactions
    mailbox #(elec_layer_tr) elec_mod_sboard,
                             elec_mon_sboard,
                             ele_generator_sboard;
    
    // Constructor
    function new(mailbox #(elec_layer_tr) elec_mod_sboard ,
                           elec_mon_sboard, ele_generator_sboard,
                           env_cfg_class env_cfg_mem);
        this.elec_mod_sboard = elec_mod_sboard;
        this.elec_mon_sboard = elec_mon_sboard;
        this.ele_generator_sboard  =ele_generator_sboard;
        this.env_cfg_mem=env_cfg_mem;  //check it
    endfunction: new

    // Main task to run the scoreboard
    task run();
        forever begin

         fork
            begin
                elec_mon_sboard.get(model_tr);
                elec_mod_sboard.get(monitor_tr);
                case (monitor_tr.phase)
                3'd0: begin
                    phase1: assert (model_tr.sbtx == monitor_tr.sbtx)
                        else $error("[scoreboard]case sbtx=1 is failed!");
                end
                3'd2:begin                  //check on AT_Cmd transaction 
                   phase2: assert (model_tr.transaction_type == monitor_tr.transaction_type)
                        else $error("[scoreboard]case transaction_type is failed!");
                    assert (model_tr.cmd_rsp_data == monitor_tr.cmd_rsp_data)
                        else $error("[scoreboard]case cmd_rsp_data is failed!");
                    assert (model_tr.crc_received == monitor_tr.crc_received)
                        else $error("[scoreboard]case crc_received is failed!");
                    assert (model_tr.len == monitor_tr.len)
                        else $error("[scoreboard]case len is failed!");
                    assert (model_tr.address == monitor_tr.address)
                        else $error("[scoreboard]case address is failed!");
                    assert (model_tr.read_write == monitor_tr.read_write)
                        else $error("[scoreboard]case read_write is failed!");

                end

                3'd3:begin
                    case(monitor_tr.transaction_type)
                    LT_fall:begin
                        phase3: assert (model_tr.sbtx == monitor_tr.sbtx)
                            else $error("[scoreboard]case sbtx is failed!");
                    end
                    AT_cmd:begin   //wait AT response

                    end
                    AT_rsp:begin  //wait first ordered set depending on the generation
                        
                    end
                    endcase
                end

                3'd4:begin
                end

                3'd6:begin
                end

                endcase

            end

            begin  
                ele_generator_sboard.get(gen_tr);
                env_cfg_mem.phase=ele_drv_sboard.phase;
                env_cfg_mem.transaction_type=ele_drv_sboard.transaction_type;
                env_cfg_mem.gen_speed=ele_drv_sboard.gen_speed;
                env_cfg_mem.o_sets=ele_drv_sboard.o_sets;
                env_cfg_mem.data_income=1;
            end
         join
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