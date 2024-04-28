//% this code generated by Ai "github cobilot" ^-^
class up_scoreboard;
  mailbox  #(upper_layer_tr) UL_mod_scr;
  mailbox #(upper_layer_tr) UL_mon_scr;

  upper_layer_tr mod_tr, mon_tr; 

  function new(mailbox #(upper_layer_tr) UL_mod_scr, mailbox #(upper_layer_tr) UL_mon_scr);
    this.UL_mod_scr = UL_mod_scr;
    this.UL_mon_scr = UL_mon_scr;
    mod_tr = new();
    mon_tr = new();

  endfunction: new

  task run_scr();

    forever begin
      UL_mod_scr.get(mod_tr);
      $display("\n[Scoreboard Upper layer From Model] at time (%t) is --> %p", $time, mod_tr.convert2string());
      
      UL_mon_scr.get(mon_tr);
      $display("\n[Scoreboard Upper layer From Dut ]at time (%t) --> %p", $time, mon_tr.convert2string());
      
      
         // Assertion to compare the values from the two mailboxes
      assert (mod_tr.T_Data == mon_tr.T_Data) else $error("Values from the two mailboxes do not match");

        
//! we should add here more assertion if we add more var in monitor (phase , gen_speed)


    end
  endtask: run_scr


//--------for test model only -----------//

 //for model only 
  task run_scr_m();

  forever begin
    UL_mod_scr.get(mod_tr);

    // Display the values from mod_tr 
    $display("------------------------------");
    $display("[Scoreboard Upper layer ]get from Mod_tr: %p",mod_tr);
    

  end
  endtask: run_scr_m
  
endclass: up_scoreboard