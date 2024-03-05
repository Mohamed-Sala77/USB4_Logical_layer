package phase1_pkg;

import elec_layer_tr_pkg::*;
import config_space_pkg::*;
import int_packet_pkg::*;
import primary_steps_pkg::*;
import my_memory::*;


//import extentions_pkg::*;


class phase1 extends primary_steps;

   mem         m_transaction;
   int_packet i_transaction ;
   mailbox #(int_packet) int_ag ;
   mailbox #(mem)    mem_ag   ;      // internal memory agent


  // Constructor
  function new(mailbox #(config_transaction) config_ag_Rx, mailbox #(elec_layer_tr) elec_ag_Rx, mailbox #(elec_layer_tr) elec_ag_Tx 
                      , mailbox  #(config_transaction) config_ag_Tx , mailbox #(mem) mem_ag , mailbox #(int_packet) int_ag);

    this.config_ag_Tx   = config_ag_Tx;
    this.config_ag_Rx = config_ag_Rx;
    this.elec_ag_Tx = elec_ag_Tx;
    this.elec_ag_Rx = elec_ag_Rx;
    this.mem_ag = mem_ag;
    //this.int_ag = int_ag;


    // link with the extentions agent class
    
      i_transaction = new();
      
      
    endfunction

    
    
    // Task to send sb data
    task read_order1;
    begin
      C_transaction.c_address = 8'd5;   //!we should know that from d.team
      C_transaction.c_write = 0 ;   
      C_transaction.c_read = 1;   
      config_ag_Tx.put(C_transaction) ;    // this should go to scoreboard "read case "
      C_transaction = new ();
      E_transaction.sbtx = 0 ;        //? is that should be here 
      elec_ag_Tx.put(E_transaction);
      //$display ("E_transaction = %p",E_transaction);
      //$display ("E_transaction = %p",E_transactio//n);
      

     // assign_sb_data();
    end
  endtask


  task read_order2;
    begin
      C_transaction.c_address = 8'd6;   //!we should know that from d.team
      C_transaction.c_write = 0 ;   
      C_transaction.c_read = 1;   
      config_ag_Tx.put(C_transaction) ;    // this should go to scoreboard "read case "
      C_transaction = new ();
      //$display ("E_transaction = %p",E_transaction);
      //$display ("E_transaction = %p",E_transactio//n);
      

     // assign_sb_data();
    end
  endtask

  // task to get packets
  task  get_packets();
    begin
      config_ag_Rx.get(C_transaction);
      $display ("in phase 1 geted C_transaction = %p",C_transaction);
      elec_ag_Rx.get(E_transaction);  // we should get here since i do peek in the ref model the handle will not be deleted if not so 
      //elec_ag_Rx.get(E_transaction);
      //$display ("done get_packet");
    end
  endtask


  
  /*// task to assign sb data
  task  assign_sb_data();
    begin
      if (E_transaction.phase == 1) begin
        i_transaction.sb_data_in = C_transaction.c_data_in;
        i_transaction.sb_add = E_transaction.address;
        i_transaction.sb_en = 1;
        i_transaction.read_write = 1;           //write cable data in sideband
        end
        i_transaction.mem_gen = 0;       //  sb work as a memory
        int_ag.put(i_transaction) ;
        ////$display ("i_transaction = %p",i_transaction);

        ////$display ("done assign sb data ");
    end
  endtask*/   //* walid don't need that 




  // task to check USB4 data
  task  check_usb4_data ();
    begin
      m_transaction=new();
      // Check the value representing the value of USB4 data
      if (C_transaction.c_data_in == 8'h40) begin   //USB4 data
        m_transaction.usb4 = 1;       //USB4 connection
      end 
      else begin
        m_transaction.usb4 = 0;         //USB4 disconnection
      end
    end
  endtask
  
 task  check_gen4_data ();
    begin

      config_ag_Rx.get(C_transaction);     // get the c_transaction again to check the gen4 data
     
      if (C_transaction.c_data_in == 8'h44) begin   //Gen 4 data
        m_transaction.gen_config = 4;       //gen 4 speed
      end 
      else begin
        m_transaction.gen_config = 0;         
      end
      ////$display ("m_transaction = %p",m_transaction);
      mem_ag.put(m_transaction);     //Put the transaction into memory agent FIFO
      $display ("in model memory ] %p",m_transaction);
      m_transaction = new();
    end
  endtask


  task write_in_config();
    C_transaction.c_data_out = 8'd12;   //!we should know that from d.team
    C_transaction.c_address = 8'd5;   //!we should know that from d.team
    C_transaction.c_write = 1;   
    C_transaction.c_read = 0;   
    config_ag_Tx.put(C_transaction) ;  // this should go to scoreboard
    C_transaction = new ();
    ////$display ("C_transaction = %p",C_transaction);
    //$display ("write config");

    
  endtask


  task run_phase1();
    begin
      create_transactions();
      //$display ("done creat transactions ");
      //write_in_config();    // ! are they need to write in config or not 
      read_order1();
      get_packets();
      check_usb4_data();
      read_order2();
      check_gen4_data ();

    end
  endtask

endclass

endpackage