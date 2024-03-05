
class phase5 extends primary_steps ;

  // Constructor
function new(mailbox #(config_transaction) config_ag_Rx, mailbox #(elec_layer_tr) elec_ag_Rx
                    , mailbox #(elec_layer_tr) elec_ag_Tx , mailbox #(upper_layer_tr) trans_ag_Rx , mailbox #(upper_layer_tr) trans_ag_Tx );
this.config_ag_Rx = config_ag_Rx;
this.elec_ag_Tx = elec_ag_Tx;
this.elec_ag_Rx = elec_ag_Rx;
this.trans_ag_Rx = trans_ag_Rx ;
this.trans_ag_Tx  = trans_ag_Tx ;
endfunction


task elec_to_trans ;
    if (E_transaction.phase == 5) begin
        T_transaction_Tx.T_Data = E_transaction.electrical_to_transport ;
        $display(" T_transaction_Tx = %p" ,T_transaction_Tx);
        trans_ag_Tx.put(T_transaction_Tx);  
        T_transaction_Tx =new();      
    end
    ////$display ("done elec_to_trans");
endtask //elec_to_trans

task trans_to_elec ;
if (E_transaction.phase == 5) begin
    E_transaction.transport_to_electrical = T_transaction_Rx.T_Data ;
    elec_ag_Tx.put(E_transaction);
    E_transaction = new();

end
////$display ("done trans_  to_elec");

endtask //trans_to_elec




task  get_transactions();
elec_ag_Rx.try_get (E_transaction);    
config_ag_Rx.try_get(C_transaction);
trans_ag_Rx.try_get(T_transaction_Rx);
$display ("in phase5 E_transaction = %p",E_transaction);
$display ("in phase5 C_transaction = %p",C_transaction);
$display ("in phase5 T_transaction_Rx = %p",T_transaction_Rx);
    ////$display ("in phase5 C_transaction = %p",C_transaction);
    endtask


// Task to execute the phase
task run_phase5();
    begin 
    create_transactions();
    //$display("create transactions done");
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
            else if (C_transaction.lane_disable && (E_transaction.phase == 5) ) 
            begin       
                $display ("we are in disable case action");
               E_transaction.sbtx  = 0;
               elec_ag_Tx.put(E_transaction) ;
                                   E_transaction = new();

             end
             else if (E_transaction.transaction_type==3'b001 && E_transaction.phase == 5)    // L_T fall  come
             begin
                $display ("we are in LT_fall case action");
                E_transaction.sbtx = 1;         
                elec_ag_Tx.put(E_transaction) ;
                E_transaction = new();

             end
         
         
                // ----------------------- run main task ----------------------

    else
    fork
        elec_to_trans ();
        trans_to_elec ();
    join

 end
endtask   //get_data


endclass //phase5
