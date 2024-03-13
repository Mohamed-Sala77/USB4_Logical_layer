
class phase4 extends primary_steps ;
mailbox #(mem)    mem_ag ;      // internal memory agent
mem        m_transaction;   // memory transaction


typedef enum logic [2:0]  {n_TS1,n_TS2,n_TS3,n_TS4,n_SLOS1,n_SLOS2,n_done} next_ord ;  // represent the next order set will be transmited
enum {right , wrong} status ;  // represent the status of the order sets 
next_ord   next_order ;

parameter        SLOS1   = 4'b1000,
                        SLOS2   = 4'b1001,
                        TS1_G2 = 4'b1010,
                        TS2_G2 = 4'b1011,
                        TS1_G4 = 4'b1100,
                        TS2_G4 = 4'b1101,
                        TS3_G4 = 4'b1110,
                        TS4_G4 = 4'b1111;

    function new(mailbox #(elec_layer_tr) elec_ag_Rx , mailbox #(elec_layer_tr) elec_ag_Tx
                         , mailbox #(mem) mem_ag , mailbox #(config_transaction) config_ag_Rx);
      this.elec_ag_Rx = elec_ag_Rx;
      this.elec_ag_Tx = elec_ag_Tx;
      this.mem_ag = mem_ag;
      this.config_ag_Rx= config_ag_Rx;

      m_transaction = new();

    endfunction

    
    task  os_g4();
    begin
        $display("we are in os_g4");
        next_order = n_TS1 ;          
        status  = wrong; 
        while (status != right)
        begin
            elec_ag_Rx.get (E_transaction);
            gen4_OS();
            


        end
    end
    endtask  //os_g4

    task  os_g2_3();
    begin
        //$display("we are in os_g2_3");
        next_order = n_SLOS1 ;         
        status  = wrong; 
        while (status != right)
        begin
            elec_ag_Rx.get (E_transaction);
            gen2_3_OS();
           //#1;  
        end
    end
endtask


task  gen4_OS();
        begin
            $display("we are in gen4_OS");
            if(E_transaction.phase==4) begin    // double check in phase in case of any actions 
                if (next_order == n_TS1) 
                    send_packet(TS1_G4, n_TS2);
                else if ((E_transaction.o_sets==TS1_G4 )&&(next_order == n_TS2)) 
                    send_packet(TS2_G4, n_TS3);
                else if ((E_transaction.o_sets==TS2_G4 )&&(next_order == n_TS3)) 
                    send_packet(TS3_G4, n_TS4);
                 else if ((E_transaction.o_sets==TS3_G4 )&&(next_order == n_TS4)) 
                     send_packet(TS4_G4, n_done);
                else if ((E_transaction.o_sets==TS4_G4 )&&(next_order == n_done)) 
                    begin
                    status=right ;
                    $display ("\n \n ⁂ ⁂ ⁂ ⁂ training phase done ⁂ ⁂ ⁂ \n \n");
                    end
                else 
                    begin
                    next_order = n_TS1;                
                    status  = wrong; 
                    end            
                                        
                end
        end
endtask
                            
            task  gen2_3_OS();
            begin
            //$display("we are in gen2_3_OS");
            if(E_transaction.phase==4) begin
                if (next_order == n_SLOS1) 
                    send_packet(SLOS1, n_SLOS2);
                 else if ((E_transaction.o_sets ==SLOS1 )&&(next_order == n_SLOS2)) 
                    send_packet(SLOS2, n_TS1);
                 else if ((E_transaction.o_sets ==SLOS2 )&&(next_order == n_TS1)) 
                    send_packet(TS1_G2, n_TS2);
                 else if ((E_transaction.o_sets ==TS1_G2 )&&(next_order == n_TS2)) 
                    send_packet(TS2_G2, n_done);
                 else if ((E_transaction.o_sets ==TS2_G2 )&&(next_order == n_done)) 
                    begin
                    status=right ;
                    $display ("done training phase");
                    end
                 else
                    begin
                    next_order = n_SLOS1;
                    status  = wrong; 
                    end
                
            end
        end
    endtask

    task send_SLOS1(input bit [3:0] packet);
    begin
        repeat(2) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_SLOS2(input bit [3:0] packet);
    begin
        repeat(2) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_G2_TS1_G2(input bit [3:0] packet);
    begin
        repeat(32) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_G2_TS2_G2(input bit [3:0] packet);
    begin
        repeat(32) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_G3_TS1_G2(input bit [3:0] packet);
    begin
        repeat(16) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_G3_TS2_G2(input bit [3:0] packet);
    begin
        repeat(16) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_TS1_G4(input bit [3:0] packet);
    begin
        repeat(16) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_TS2_G4(input bit [3:0] packet);
    begin
        repeat(16) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_TS3_G4(input bit [3:0] packet);
    begin
        repeat(16) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask

    task send_TS4_G4(input bit [3:0] packet);
    begin
        repeat(16) begin
            $cast (E_transaction.o_sets , packet);
            elec_ag_Tx.put(E_transaction);
            E_transaction = new();
        end
    end
    endtask
    

    task send_packet(input bit [3:0] packet, input next_ord next);
    begin
        case (m_transaction.gen)
            2: begin
                case (packet)
                    SLOS1: send_SLOS1(packet);              // send SLOS1 packet 2 times
                    SLOS2: send_SLOS2(packet);             // send SLOS2 packet 2 times
                    TS1_G2: send_G2_TS1_G2(packet);  // send TS1_G2 packet 32 times
                    TS2_G2: send_G2_TS2_G2(packet); // send TS2_G2 packet 32 times
                endcase
            end
            3: begin
                case (packet)
                    SLOS1: send_SLOS1(packet);               // send SLOS1 packet 2 times
                    SLOS2: send_SLOS2(packet);              // send SLOS2 packet 2 times
                    TS1_G2: send_G3_TS1_G2(packet);   // send TS1_G2 packet 16 times
                    TS2_G2: send_G3_TS2_G2(packet);  // send TS2_G2 packet 16 times
                endcase
            end
            4: begin
                case (packet)
                    TS1_G4: send_TS1_G4(packet);
                    TS2_G4: send_TS2_G4(packet);
                    TS3_G4: send_TS3_G4(packet);
                    TS4_G4: send_TS4_G4(packet);
                endcase
            end
        endcase
        next_order = next;
    end
    endtask

    task  get_transactions();
         elec_ag_Rx.peek (E_transaction);    // peek instead of get to avoid the loss of the transaction when get in os_g4()
        //$display("done get E_transaction ");
         config_ag_Rx.try_get(C_transaction);
        $display ("in phase4 C_transaction = %p",C_transaction);
        $display ("in phase4 E_transaction = %p",E_transaction);
        mem_ag.try_get(m_transaction); 
        m_transaction.gen = 4;   // ! this line should be deleted
        $display ("we are in gen %d",m_transaction.gen);
endtask
    
    
    task run_phase4 () ;
    begin            

        create_transactions();
        //$display("done create transaction",);
        get_transactions();


        // ----------------------- handle actions ----------------------
        if(!E_transaction.sbrx)      
                begin
                 // E_transaction.phase = 1;         //! should we go to phase 1 or 2 
                    $display ("we are in sbrx =0 case action");
                  E_transaction.sbtx = 0;         
                  elec_ag_Tx.put(E_transaction) ;
                    E_transaction = new();
                    
                end
                else if (C_transaction.lane_disable && (E_transaction.phase == 4) ) 
                begin       
                    $display ("we are in disable case action");
                   E_transaction.sbtx  = 0;
                   elec_ag_Tx.put(E_transaction) ;
                    E_transaction = new();

                 end

         // ----------------------- run main task ----------------------

                else if (E_transaction.phase==4 )   // we are in phase 4 
                        begin
                            
                    if ( m_transaction.gen == 4)       // we are gen 4 send in order (TS1->TS2 ->TS3-> TS4 )
                          begin
                           //$display("if cond ");
                           os_g4() ; 
                          end
                          else if( m_transaction.gen == 2  ||  m_transaction.gen == 3)  // we are gen 2 or 3 send in order (SLOS1->SLOS2 ->TS1-> TS2 )
                          begin
                           //$display("if cond ");
                          os_g2_3() ; 
                          end
                          //$display ("we are in after if  ");
                         /* else 
                          begin
                              //! ???????? from ali and karim 
                          end*/
                         end
    end   
    endtask 

endclass //phase 4
    
