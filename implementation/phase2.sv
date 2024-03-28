  class phase2 extends primary_steps ;

  mem         m_transaction;
  mailbox #(mem)    mem_ag ;      // internal memory agent

  //if we add commented lines this line should be written in the main code  :  mailbox #(mem) mem_ag = new() ;

    function new(mailbox #(elec_layer_tr) elec_ag_Tx, mailbox #(config_transaction) config_ag_Rx
                         , mailbox  #(elec_layer_tr)  elec_ag_Rx , mailbox #(mem) mem_ag );
      this.elec_ag_Tx = elec_ag_Tx;
      this.elec_ag_Rx = elec_ag_Rx;
      this.config_ag_Rx = config_ag_Rx;
      this.mem_ag = mem_ag;
    endfunction

    task  get_transactions();
    //$display ("in phase2 get_transactions");
    elec_ag_Rx.get(E_transaction); 
    $display ("in phase 2 E_transaction = %p",E_transaction);
        //mem_ag.get(m_transaction);     //get the transaction from memory agent FIFO
        //$display ("m_transaction = %p",m_transaction);
endtask



    // task to get elec transaction from the mailbox
   /* task  get_elec_transaction();
      elec_ag_Rx.get(E_transaction);
    endtask

    // task to check phase and sbrx
   task  check_phase();
      if (E_transaction.sbrx == 1 && E_transaction.phase == 2) 
      begin
      m_transaction.phase = 3'd3;
      mem_ag.put(m_transaction);
      end
    endtask*/

    // sbrx task now calls the smaller tasks
    task run_phase2();
      begin
        create_transactions();
        //$display("create transactions done");
        //m_transaction=new ();
        get_transactions();
        
        //if (m_transaction.usb4 && m_transaction.gen_config)
        E_transaction.sbtx = 1;     // we can go throuhg phase 1 
        //else 
        //E_transaction.sbtx = 0;     // we can't go throuhg phase 1 

        elec_ag_Tx.put(E_transaction);
        $display ("E_transaction in phase 2 sent to scorbourd = %p",E_transaction);
        E_transaction = new();
        //get_elec_transaction();
        //check_phase();
      end
    endtask

  endclass

