  ///************ Define the electrical_layer_driver************///
 class electrical_layer_driver;

 //declare the events
  event elec_gen_driver_done;  // Event to indicate that the driver has finished sending the transaction

 //declare the transactions
 elec_layer_tr transaction;    // Transaction to be recieved from the generator

 //declare the mailboxes
 mailbox #(elec_layer_tr) elec_drv_gen;  // Mailbox to receive the transaction from the generator

 //declare varsual interface
   virtual electrical_layer_if ELEC_vif;

   env_cfg_class env_cfg_mem;

   //Data to be sent to the transport layer
    bit [7:0] elec_to_trans_lane_0 [$];
	  bit [7:0] elec_to_trans_lane_1 [$];

 // Constructor
function new(event  elec_gen_driver_done,mailbox #(elec_layer_tr) elec_drv_gen,virtual electrical_layer_if ELEC_vif,env_cfg_class env_cfg_mem);
 this.elec_gen_driver_done=elec_gen_driver_done;
 this.elec_drv_gen=elec_drv_gen;
 this.ELEC_vif=ELEC_vif;
 this.env_cfg_mem=env_cfg_mem;
endfunction:new 

 /////////********** Declare the task as extern**********/////////
 //**tasks to send trasactions to the DUT**//
 extern task send_AT_cmd_OR_res_2_DUT(bit read_write = 0,bit [7:0] address = 0,
                                      bit [6:0] len = 0 ,bit [23:0] cmd_rsp_data = 0,
                                      tr_type trans_type = None);
 extern task send_LT_fall_2_DUT();
 extern task CALC_CRC(bit [7:0] data_symb[$], output bit [15:0] CRC_out);
 ///---------------------------///

 //**tasks to send OS to DUT**//
  extern task SLOS1_2_DUT(input GEN gen_speed);
  extern task SLOS2_2_DUT(input GEN gen_speed);
  extern task TS1_gen23_2_DUT(input GEN gen_speed);
  extern task TS2_gen23_2_DUT(input GEN gen_speed);
  extern task TS1_gen4_2_DUT();
  extern task TS2_gen4_2_DUT();
  extern task TS3_2_DUT();
  extern task TS4_2_DUT();
  ///---------------------------///

  ///**tasks to send OS to DUT**//
  extern task  send_data_2_DUT(input logic[15:0] data_2_DUT,input GEN gen_speed);
 ///---------------------------///
 //**tasks to send Disconnect_2_DUT to DUT**//

  extern task Disconnect_2_DUT();
 ///---------------------------///
  extern task run();
  
  ///**add here task to reset the dut**///


endclass:electrical_layer_driver

//Disconnect_2_DUT task
task electrical_layer_driver::Disconnect_2_DUT();
 @(negedge ELEC_vif.SB_clock);
 ELEC_vif.sbrx = 1'b0;
 #(tDisconnectRx);
 //$stop;
 //$display
endtask: Disconnect_2_DUT

// Task to calculate the CRC
task electrical_layer_driver::CALC_CRC(input bit [7:0] data_symb[$], output bit [15:0] CRC_out);

 bit [15:0] crc;
 bit [15:0] poly;
 integer i, j;
 bit [7:0] data;

 // Initialize CRC and polynomial
 crc = 16'hFFFF;
 poly = 16'h8005;

//$display("[ELEC DRIVER at crc] data_symb[1] = %b ",data_symb[1][3:0]);

 // Process each byte in the data
 for (i = 0; i < data_symb.size(); i = i + 1) begin
   data = data_symb[i];

   // Process each bit in the byte
   for (j = 0; j < 8; j = j + 1) begin
     if ((crc[15] ^ data[7]) == 1'b1) begin
       crc = crc << 1;
       crc = crc ^ poly;
     end else begin
       crc = crc << 1;
     end
     data = data << 1;
   end
 end

 // Reflect the CRC result
 CRC_out = {<<{crc}};
 //$display("[ELEC DRIVER at crc] CRC_out = %0h",CRC_out);
 //$stop;
endtask: CALC_CRC

////****tasks to send transactions to the DUT****////
task electrical_layer_driver::send_AT_cmd_OR_res_2_DUT(bit read_write = 0, bit [7:0] address = 0,
                                                    bit [6:0] len = 0 , bit [23:0] cmd_rsp_data = 0,
                                                    tr_type trans_type = None);
bit [7:0] data_symb[$];
bit [7:0] CRC_DATA_Q[$];
bit [7:0] L_CRC,H_CRC;
bit [9:0] send_data_symb[$];
bit [0:9] actual_send_data_symb[$];
bit [7:0] data_rsp[2:0];
bit [7:0] conn;
int i;  //counter

conn={read_write,len};

//choose send command or response
if(trans_type==AT_cmd)
begin
 //data_symb ={<<};
 //CRC_DATA_Q=data_symb[1:$-2];{8'h01,8'h0a,8'h05} 
 data_symb ={<<{conn,address,STX_cmd}};
 CALC_CRC(data_symb,{H_CRC,L_CRC});
 //$display("[ELEC DRIVER] the value of size data_symb ",data_symb.size());
 $display("[ELEC DRIVER]the value of crc is %0h at ATCmd",{H_CRC,L_CRC});

end
else if (trans_type==AT_rsp)
begin
 data_rsp={>>{cmd_rsp_data}};
 data_symb ={<<{data_rsp[2],data_rsp[1],data_rsp[0],conn,address,STX_rsp}};
 //CRC_DATA_Q=
 //CRC_DATA_Q=data_symb[1:$-2];   
 CALC_CRC(data_symb,{H_CRC,L_CRC});
 $display("[ELEC DRIVER]the value of crc is %0h at ATrsp",{H_CRC,L_CRC});

end
//$stop;
/*
$display("[ELEC DEIVER]the size of data_symb is %0d in case (%p)",data_symb.size(),trans_type);
$display("[ELEC DEIVER]the values of data_symb is%p in case (%p)",data_symb,trans_type);
$display("[ELEC DEIVER]CRC_DATA_Q size= %0d", CRC_DATA_Q.size());  */
data_symb.delete();

//choose send command or response
if(trans_type==AT_cmd)
begin
data_symb ={DLE,STX_cmd,address,conn,L_CRC,H_CRC,DLE,ETX}; 
//$display("[ELEC DRIVER] in case at cmd crc[%0h,,%0h]",data_symb[5],data_symb[4]);
end
else if (trans_type==AT_rsp) 
begin
data_symb ={DLE,STX_rsp,address,conn,data_rsp[0],data_rsp[1],data_rsp[2],L_CRC,H_CRC,DLE,ETX};
//$display("[ELEC DRIVER] in case at rsp crc[%0h,,%0h]",data_symb[8],data_symb[7]);   
end
  
 // $display("[ELEC DRIVER] data_symb[%0h]",data_symb[4]);

     // Add start and end bits to each data symbol and store in send_data_symb
     foreach(data_symb[i]) begin
       send_data_symb[i] = {stop_bit, data_symb[i],start_bit};   ///ERROR///
     end
     $display("[ELEC DRIVER] actual_send_data_symb: %p",send_data_symb);
     
     // Send the data symbols to the DUT
     foreach(send_data_symb[i,j]) begin
         @(posedge ELEC_vif.SB_clock);
     // Send bit to DUT
       ELEC_vif.sbrx <= send_data_symb[i][9-j];
    // $display("[ELEC DRIVER] at(%0p)send_data_symb[%0d][%0d]=[%0b]",trans_type,i,9-j,send_data_symb[i][9-j]);
     end
data_symb.delete();
//ELEC_vif.data_incoming <=1;
endtask: send_AT_cmd_OR_res_2_DUT

task electrical_layer_driver::send_LT_fall_2_DUT(); //correct send no need to flip
bit [7:0] data_symb_lane0[3];
bit [9:0] send_data_symb_lane0[3];
bit [7:0] data_symb_lane1[3];
bit [9:0] send_data_symb_lane1[3];
bit       LT_FALL_arr[2][LT_TR_SIZE]; //array of LT_FALL symbols for lane 0 and lane 1
// Generate the LT_Fall symbols for lane 0 and lane 1
data_symb_lane0={DLE,LSE_lane0,CLSE_lane0};
data_symb_lane1={DLE,LSE_lane1,CLSE_lane1};
// Add start and end bits to each data symbol and store in send_data_symb
     foreach(data_symb_lane0[i]) begin
       bit  start = 1'b0;
       bit  stop_bit = 1'b1;
       send_data_symb_lane0[i] = {stop_bit, data_symb_lane0[i], start_bit};
       send_data_symb_lane1[i] = {stop_bit, data_symb_lane1[i], start_bit};
     end

//casting arrays to 2D array
for (int i = 0; i < 3; i++) begin
 for (int j = 0; j < 10; j++) begin
   LT_FALL_arr[0][i*10 + j] = send_data_symb_lane0[i][j];
   LT_FALL_arr[1][i*10 + j] = send_data_symb_lane1[i][j];
 end
end

// Send the LT_FALL symbols to the DUT
foreach(LT_FALL_arr[i,j])
begin
@(posedge ELEC_vif.SB_clock);
 // Send bit to DUT
 ELEC_vif.sbrx <= LT_FALL_arr[i][j];
end
//->elec_gen_driver_done; // Indicate that the driver has finished sending the transaction
endtask: send_LT_fall_2_DUT


/////////////////**********************************(BY HAND CODE)**********************************//////////////////
/////////////////////////////////////////////////////GEN23 OS///////////////////////////////////////////////////////
////****tasks to send os  to the DUT****////
/*task electrical_layer_driver::SLOS1_2_DUT(input GEN gen_speed);  //check it send 2 on each lane or 2 no both lanes 

if(gen_speed ==gen2) begin
   ELEC_vif.data_incoming <=0;
   repeat(2)begin
   foreach (env_cfg_mem.GEN2_Recieved_SLOS1[i])
   begin
     @(negedge ELEC_vif.gen2_lane_clk);
     ELEC_vif.data_incoming <=1;
     ELEC_vif.lane_0_rx <=env_cfg_mem.GEN2_Recieved_SLOS1[i];
     ELEC_vif.lane_1_rx <=env_cfg_mem.GEN2_Recieved_SLOS1[i];
     
   end
   end
 end
else if(gen_speed ==gen3) begin
    ELEC_vif.data_incoming <=0;
   $display("[ELEC DEICER]READY AT SLOS1 TIME(%0t)",$time);
   repeat(2)begin
   foreach (env_cfg_mem.GEN3_Recieved_SLOS1[i])
     begin
       @(negedge ELEC_vif.gen3_lane_clk);
       ELEC_vif.data_incoming <=1; 
       ELEC_vif.lane_0_rx <=env_cfg_mem.GEN3_Recieved_SLOS1[i];
       ELEC_vif.lane_1_rx <=env_cfg_mem.GEN3_Recieved_SLOS1[i];
 end
   end
   // ELEC_vif.data_incoming <=0;
   $display("[ELEC DEICER]finish AT TIME(%0t)",$time);
   
end
//$display("the value ofenv_cfg_mem.GEN3_Recieved_SLOS1;%p",env_cfg_mem.GEN3_Recieved_SLOS1); 
endtask: SLOS1_2_DUT

task electrical_layer_driver::SLOS2_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
ELEC_vif.data_incoming <=0;

repeat(2)begin
foreach (env_cfg_mem.GEN2_Recieved_SLOS2[i])
begin
 @(negedge ELEC_vif.gen2_lane_clk);
  ELEC_vif.data_incoming <=1;
 ELEC_vif.lane_0_rx <=env_cfg_mem.GEN2_Recieved_SLOS2[i];
 ELEC_vif.lane_1_rx <=env_cfg_mem.GEN2_Recieved_SLOS2[i];
end
 end
 end
else if(gen_speed ==gen3) begin
  
  $display("[ELEC DEICER]READY AT SLOS2 TIME(%0t)",$time);
  //ELEC_vif.data_incoming <=1;
  ELEC_vif.data_incoming <=0;
     ELEC_vif.lane_0_rx <='bx;
     ELEC_vif.lane_1_rx <='bx;
  repeat(2)begin
   foreach (env_cfg_mem.GEN3_Recieved_SLOS2[i])
   begin
     @(negedge ELEC_vif.gen3_lane_clk);
     ELEC_vif.data_incoming <=1;
     ELEC_vif.lane_0_rx <=env_cfg_mem.GEN3_Recieved_SLOS2[i];
     ELEC_vif.lane_1_rx <=env_cfg_mem.GEN3_Recieved_SLOS2[i];
   end
 end
end
//$display("[ELEC DRIVER]the value ofenv_cfg_mem.GEN3_Recieved_SLOS2;%p",env_cfg_mem.GEN3_Recieved_SLOS2); 
endtask: SLOS2_2_DUT

task electrical_layer_driver::TS1_gen23_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
 //@(posedge ELEC_vif.gen2_lane_clk);
// ELEC_vif.data_incoming <=0;
    repeat(2)begin
   foreach(env_cfg_mem.TS1_gen23_lane0[i]) begin
     @(negedge ELEC_vif.gen2_lane_clk);
     ELEC_vif.data_incoming <=1;
     ELEC_vif.lane_0_rx <=env_cfg_mem.TS1_gen23_lane0[i];
     ELEC_vif.lane_1_rx <=env_cfg_mem.TS1_gen23_lane1[i];
   end
   end
 end 
else if(gen_speed ==gen3) begin
// @(posedge ELEC_vif.gen3_lane_clk);
 //ELEC_vif.data_incoming <=0;
 $display("[ELEC DRIVER] the size of env_cfg_mem.TS1_gen23_lane0 is %0d",env_cfg_mem.TS1_gen23_lane0.size());
 $display("[ELEC DRIVER] the  env_cfg_mem.TS1_gen23_lane1 is %p",env_cfg_mem.TS1_gen23_lane1);
 repeat(2)begin
 foreach(env_cfg_mem.TS1_gen23_lane0[i]) begin 
 @(negedge ELEC_vif.gen3_lane_clk);
 ELEC_vif.data_incoming <=1;
 ELEC_vif.lane_0_rx <=env_cfg_mem.TS1_gen23_lane0[i];
 ELEC_vif.lane_1_rx <=env_cfg_mem.TS1_gen23_lane1[i];
 end
 end 
 env_cfg_mem.TS1_gen23_lane0.delete();
 env_cfg_mem.TS1_gen23_lane1.delete();
 $display("[ELEC DRIVER]at time(%0t)done",$time);  
 
 
end
endtask: TS1_gen23_2_DUT

task electrical_layer_driver::TS2_gen23_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
//@(posedge ELEC_vif.gen2_lane_clk);
//ELEC_vif.data_incoming <=0;
repeat(2)begin
 foreach(env_cfg_mem.TS2_gen23_lane0[i]) begin
   @(negedge ELEC_vif.gen2_lane_clk);
   ELEC_vif.data_incoming <=1;
   ELEC_vif.lane_0_rx <=env_cfg_mem.TS2_gen23_lane0[i];
   ELEC_vif.lane_1_rx <=env_cfg_mem.TS2_gen23_lane1[i];
 end
end
 end
else if(gen_speed ==gen3) begin
// @(posedge ELEC_vif.gen3_lane_clk);
 //ELEC_vif.data_incoming <=0;
 repeat(2)begin
 foreach(env_cfg_mem.TS2_gen23_lane0[i]) begin 
   ELEC_vif.data_incoming <=1;
 @(negedge ELEC_vif.gen3_lane_clk);
 ELEC_vif.lane_0_rx <=env_cfg_mem.TS2_gen23_lane0[i];
 ELEC_vif.lane_1_rx <=env_cfg_mem.TS2_gen23_lane1[i];
 end
 end
end
//ELEC_vif.data_incoming <=0;
env_cfg_mem.TS2_gen23_lane0.delete();
env_cfg_mem.TS2_gen23_lane1.delete();
endtask: TS2_gen23_2_DUT
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////GEN4 OS////////////////////////////////////////////////////////
task electrical_layer_driver::TS1_gen4_2_DUT();
bit PRBS11_OUT_lane0[$],
   PRBS11_OUT_lane1[$];
logic trancated_PRBS11_OUT_lane0[$],
   trancated_PRBS11_OUT_lane1[$];
logic TS1_Frame_lane0 [$],
   TS1_Frame_lane1 [$],
   temp_q_lane[$];
int i;
/*
i=0;
temp_q_lane={<<{HEADER_TS1_GEN4}};
PRBS11_OUT_lane0.delete();
PRBS11_OUT_lane1.delete();

PRSC11(PRBS11_lane0_seed,(PRBS11_SYMBOL_SIZE),PRBS11_OUT_lane0); //generate PRBS11 
PRSC11(PRBS11_lane1_seed,(PRBS11_SYMBOL_SIZE),PRBS11_OUT_lane1); //generate PRBS11
$display("[ELEC DRIVER] the  PRBS11_OUT_lane0 size is %0d",PRBS11_OUT_lane0.size());
i=0;
repeat(1)begin
foreach(temp_q_lane[j]) begin
TS1_Frame_lane0.push_back(temp_q_lane[j]); //add the header to the TS1_Frame_lane0
TS1_Frame_lane1.push_back(temp_q_lane[j]); //add the header to the TS1_Frame_lane1
end

for(int k=(i*448)+28;k<=((i*448)+447);k++)begin
 TS1_Frame_lane0.push_back(PRBS11_OUT_lane0[k]);
 TS1_Frame_lane1.push_back(PRBS11_OUT_lane1[k]);
end
i++;
end
$display("[ELEC DRIVER] the  TS1_Frame_lane0 is %p",TS1_Frame_lane0);
$display("[ELEC DRIVER] the  TS1_Frame_lane1 is %p",TS1_Frame_lane1);
//$display("[ELEC DRIVER] the  TS1_Frame_lane0 is %p",TS1_Frame_lane0[448:(448+447)]);

//send the TS1 symbols to the DUT
//@(posedge ELEC_vif.gen4_lane_clk)
$display("[elec DRIVER] start sending TS1 symbols to the DUT");
 //reverse_8bits_in_Gen4(TS1_Frame_lane0);
 //reverse_8bits_in_Gen4(TS1_Frame_lane1);
 $display("---------------------------------------------------------------");
$display("[ELEC DRIVER] the size env_cfg_mem.GEN4_recieved_TS1_LANE0 is %0d and value =%p",env_cfg_mem.GEN4_recieved_TS1_LANE0.size(),env_cfg_mem.GEN4_recieved_TS1_LANE0);
$display("[ELEC DRIVER] the size env_cfg_mem.GEN4_recieved_TS1_LANE1f is %0d and value =%p",env_cfg_mem.GEN4_recieved_TS1_LANE1.size(),env_cfg_mem.GEN4_recieved_TS1_LANE1);
 $display("---------------------------------------------------------------");
 //ELEC_vif.data_incoming <=1; 
 @(posedge ELEC_vif.gen4_lane_clk);
 @(posedge ELEC_vif.gen4_lane_clk);
 @(posedge ELEC_vif.gen4_lane_clk);
 @(posedge ELEC_vif.gen4_lane_clk);
 @(posedge ELEC_vif.gen4_lane_clk);
 @(posedge ELEC_vif.gen4_lane_clk);
 ELEC_vif.data_incoming <=1;
 $display("[elec monitor] at(%0t)",$time);

 foreach(env_cfg_mem.GEN4_recieved_TS1_LANE0[i]) begin
 //@(posedge ELEC_vif.gen4_lane_clk);
 @(negedge ELEC_vif.gen4_lane_clk);
 ELEC_vif.lane_0_rx <=env_cfg_mem.GEN4_recieved_TS1_LANE0[i];
 ELEC_vif.lane_1_rx <=env_cfg_mem.GEN4_recieved_TS1_LANE1[i];
 ELEC_vif.data_incoming <=1;
 end
 @(posedge ELEC_vif.gen4_lane_clk);
 //ELEC_vif.data_incoming <=0;
 $display("at time(%0t)[elec DRIVER] doneeeeeeeeeeeeeeeeeeeeeeeeee",$time);
 //$stop;
endtask: TS1_gen4_2_DUT

task electrical_layer_driver::TS2_gen4_2_DUT();
 ELEC_vif.data_incoming <=1;
 foreach(HEADER_TS2_GEN4[i])
 begin
 @(posedge ELEC_vif.gen4_lane_clk)
 ELEC_vif.lane_0_rx <=HEADER_TS2_GEN4[31-i];
 ELEC_vif.lane_1_rx <=HEADER_TS2_GEN4[31-i];
end
$display("[ELEC DRIVER] the value of GEN4_recieved_TS2_LANE0 is:");
foreach(HEADER_TS2_GEN4[l])begin

 $write (HEADER_TS2_GEN4[l]);
end 
 $display;
//ELEC_vif.data_incoming <=0;

endtask: TS2_gen4_2_DUT

task electrical_layer_driver::TS3_2_DUT();

//ELEC_vif.data_incoming <=1;
 foreach(HEADER_TS3_GEN4[i])
 begin
// @(posedge ELEC_vif.gen4_lane_clk)
  @(negedge ELEC_vif.gen4_lane_clk)
 ELEC_vif.lane_0_rx <=HEADER_TS3_GEN4[31-i];
 ELEC_vif.lane_1_rx <=HEADER_TS3_GEN4[31-i];
 ELEC_vif.data_incoming <=1;
end
$display("[ELEC DRIVER] the value of GEN4_recieved_TS3_LANE0 is:");

foreach(HEADER_TS3_GEN4[l])begin

 $write (HEADER_TS3_GEN4[l]);
end 
 $display;

endtask: TS3_2_DUT

task electrical_layer_driver::TS4_2_DUT();

bit		     [3:0]			counter;
logic 		            TS4_gen4[32];
logic 		            correct_TS4[$];
counter=4'd15;

   //calculate the correct TS4
  
 correct_TS4={<<{4'd0,{<<{~(counter)}},{<<{counter}},indication_TS4,CURSOR}};

 foreach(correct_TS4[i])
 begin
// @(posedge ELEC_vif.gen4_lane_clk)
  @(negedge ELEC_vif.gen4_lane_clk)
// ELEC_vif.lane_0_rx <=correct_TS4[$-i];
 //ELEC_vif.lane_1_rx <=correct_TS4[$-i];
 ELEC_vif.lane_0_rx <=correct_TS4[i];
 ELEC_vif.lane_1_rx <=correct_TS4[i];
 ELEC_vif.data_incoming <=1;
end
$display("[ELEC DRIVER] the value of GEN4_recieved_TS4_LANE0 is:");

foreach(correct_TS4[l])begin

 $write (correct_TS4[l]);
end 
 $display;


endtask: TS4_2_DUT*/


/////////////////***********************************(AI CODE)*************************************//////////////////
/////////////////////////////////////////////////////  OS  /////////////////////////////////////////////////////////
////****tasks to send os  to the DUT****////
task electrical_layer_driver::SLOS1_2_DUT(input GEN gen_speed);  //check it send 2 on each lane or 2 no both lanes 

if(gen_speed ==gen2) begin
      ELEC_vif.data_incoming <=0;
      repeat(2)begin
      foreach (env_cfg_mem.GEN2_Recieved_SLOS1[i])
      begin
        @(negedge ELEC_vif.gen2_lane_clk);
        ELEC_vif.data_incoming <=1;
        ELEC_vif.lane_0_rx <=env_cfg_mem.GEN2_Recieved_SLOS1[i];
        ELEC_vif.lane_1_rx <=env_cfg_mem.GEN2_Recieved_SLOS1[i];
        
      end
      end
    end
else if(gen_speed ==gen3) begin
       ELEC_vif.data_incoming <=0;
      $display("[ELEC DEICER]READY AT SLOS1 TIME(%0t)",$time);
      repeat(2)begin
      foreach (env_cfg_mem.GEN3_Recieved_SLOS1[i])
        begin
          @(negedge ELEC_vif.gen3_lane_clk);
          ELEC_vif.data_incoming <=1; 
          ELEC_vif.lane_0_rx <=env_cfg_mem.GEN3_Recieved_SLOS1[i];
          ELEC_vif.lane_1_rx <=env_cfg_mem.GEN3_Recieved_SLOS1[i];
    end
      end
      // ELEC_vif.data_incoming <=0;
      $display("[ELEC DEICER]finish AT TIME(%0t)",$time);
      
end
//$display("the value ofGEN3_Recieved_SLOS1;%p",GEN3_Recieved_SLOS1); 
endtask: SLOS1_2_DUT

task electrical_layer_driver::SLOS2_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
  ELEC_vif.data_incoming <=0;

  repeat(3)begin
   foreach (env_cfg_mem.GEN2_Recieved_SLOS2[i])
   begin
    @(negedge ELEC_vif.gen2_lane_clk);
     ELEC_vif.data_incoming <=1;
    ELEC_vif.lane_0_rx <=env_cfg_mem.GEN2_Recieved_SLOS2[i];
    ELEC_vif.lane_1_rx <=env_cfg_mem.GEN2_Recieved_SLOS2[i];
   end
    end
    end
  else if(gen_speed ==gen3) begin
     
     $display("[ELEC DEICER]READY AT SLOS2 TIME(%0t)",$time);
     //ELEC_vif.data_incoming <=1;
     ELEC_vif.data_incoming <=0;
        ELEC_vif.lane_0_rx <='bx;
        ELEC_vif.lane_1_rx <='bx;
     repeat(5)begin
      foreach (env_cfg_mem.GEN3_Recieved_SLOS2[i])
      begin
        @(negedge ELEC_vif.gen3_lane_clk);
        ELEC_vif.data_incoming <=1;
        ELEC_vif.lane_0_rx <=env_cfg_mem.GEN3_Recieved_SLOS2[i];
        ELEC_vif.lane_1_rx <=env_cfg_mem.GEN3_Recieved_SLOS2[i];
      end
    end
   end
   //$display("[ELEC DRIVER]the value ofGEN3_Recieved_SLOS2;%p",GEN3_Recieved_SLOS2); 
endtask: SLOS2_2_DUT


task electrical_layer_driver::TS1_gen23_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
    //@(posedge ELEC_vif.gen2_lane_clk);
    $display("[ELEC DRIVER] the size of TS1_gen23_lane0 is %0d",env_cfg_mem.TS1_gen23_lane0.size());
    $display("[ELEC DRIVER] the  TS1_gen23_lane1 is %p",env_cfg_mem.TS1_gen23_lane1);
    ELEC_vif.data_incoming <=0;
      repeat(4)begin
      foreach(env_cfg_mem.TS1_gen23_lane0[i]) begin
        @(negedge ELEC_vif.gen2_lane_clk);
        ELEC_vif.data_incoming <=1;
      ELEC_vif.lane_0_rx <=env_cfg_mem.TS1_gen23_lane0[i];
      ELEC_vif.lane_1_rx <=env_cfg_mem.TS1_gen23_lane1[i];
      end
      end
      @(negedge ELEC_vif.gen3_lane_clk);
      @(negedge ELEC_vif.gen3_lane_clk);
    ELEC_vif.lane_0_rx <=0;
    ELEC_vif.lane_1_rx <=0; 
    end 
else if(gen_speed ==gen3) begin
   // @(posedge ELEC_vif.gen3_lane_clk);
    //ELEC_vif.data_incoming <=0;
    $display("[ELEC DRIVER] the size of TS1_gen23_lane0 is %0d",env_cfg_mem.TS1_gen23_lane0.size());
    $display("[ELEC DRIVER] the  TS1_gen23_lane1 is %p",env_cfg_mem.TS1_gen23_lane1);
    repeat(2)begin
    $display("[ELEC DRIVER]at time start send to dut(%0t) done",$time);
    foreach(env_cfg_mem.TS1_gen23_lane0[i]) begin 
    @(negedge ELEC_vif.gen3_lane_clk);
    ELEC_vif.data_incoming <=1;
    ELEC_vif.lane_0_rx <=env_cfg_mem.TS1_gen23_lane0[i];
    ELEC_vif.lane_1_rx <=env_cfg_mem.TS1_gen23_lane1[i];
    end
    end  
    @(negedge ELEC_vif.gen3_lane_clk);
    ELEC_vif.lane_0_rx <=0;
    ELEC_vif.lane_1_rx <=0; 
    
    //env_cfg_mem.TS1_gen23_lane0.delete();
    //env_cfg_mem.TS1_gen23_lane1.delete();
    $display("[ELEC DRIVER]at time(%0t)done",$time);
    
end
endtask: TS1_gen23_2_DUT


task electrical_layer_driver::TS2_gen23_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
   //@(posedge ELEC_vif.gen2_lane_clk);
   //ELEC_vif.data_incoming <=0;
    repeat(1)begin
    foreach(env_cfg_mem.TS2_gen23_lane0[i]) begin
      @(negedge ELEC_vif.gen2_lane_clk);
      ELEC_vif.data_incoming <=1;
    ELEC_vif.lane_0_rx <=env_cfg_mem.TS2_gen23_lane0[i];
    ELEC_vif.lane_1_rx <=env_cfg_mem.TS2_gen23_lane1[i];
    end
    end
    ELEC_vif.lane_0_rx <='b0;
    ELEC_vif.lane_1_rx <='b0;
    end
else if(gen_speed ==gen3) begin
   // @(posedge ELEC_vif.gen3_lane_clk);
    //ELEC_vif.data_incoming <=0;
    repeat(2)begin
    foreach(env_cfg_mem.TS2_gen23_lane0[i]) begin 
      ELEC_vif.data_incoming <=1;
    @(negedge ELEC_vif.gen3_lane_clk);
    ELEC_vif.lane_0_rx <=env_cfg_mem.TS2_gen23_lane0[i];
    ELEC_vif.lane_1_rx <=env_cfg_mem.TS2_gen23_lane1[i];
    end
    end
end
  //ELEC_vif.data_incoming <=0;
  env_cfg_mem.TS2_gen23_lane0.delete();
  env_cfg_mem.TS2_gen23_lane1.delete();
endtask: TS2_gen23_2_DUT

task electrical_layer_driver::TS1_gen4_2_DUT();
bit PRBS11_OUT_lane0[$],
      PRBS11_OUT_lane1[$];
logic trancated_PRBS11_OUT_lane0[$],
      trancated_PRBS11_OUT_lane1[$];
logic TS1_Frame_lane0 [$],
      TS1_Frame_lane1 [$],
      temp_q_lane[$];
int i;
/*
i=0;
temp_q_lane={<<{HEADER_TS1_GEN4}};
PRBS11_OUT_lane0.delete();
PRBS11_OUT_lane1.delete();

PRSC11(PRBS11_lane0_seed,(PRBS11_SYMBOL_SIZE),PRBS11_OUT_lane0); //generate PRBS11 
PRSC11(PRBS11_lane1_seed,(PRBS11_SYMBOL_SIZE),PRBS11_OUT_lane1); //generate PRBS11
$display("[ELEC DRIVER] the  PRBS11_OUT_lane0 size is %0d",PRBS11_OUT_lane0.size());
 i=0;
repeat(1)begin
  foreach(temp_q_lane[j]) begin
  TS1_Frame_lane0.push_back(temp_q_lane[j]); //add the header to the TS1_Frame_lane0
  TS1_Frame_lane1.push_back(temp_q_lane[j]); //add the header to the TS1_Frame_lane1
  end

  for(int k=(i*448)+28;k<=((i*448)+447);k++)begin
		TS1_Frame_lane0.push_back(PRBS11_OUT_lane0[k]);
		TS1_Frame_lane1.push_back(PRBS11_OUT_lane1[k]);
  end
  i++;
end
$display("[ELEC DRIVER] the  TS1_Frame_lane0 is %p",TS1_Frame_lane0);
$display("[ELEC DRIVER] the  TS1_Frame_lane1 is %p",TS1_Frame_lane1);
/*
$display("[ELEC DRIVER] the  TS1_Frame_lane0 is %p",TS1_Frame_lane0[448:(448+447)]);
*/
//send the TS1 symbols to the DUT
//@(posedge ELEC_vif.gen4_lane_clk)
$display("[elec DRIVER] start sending TS1 symbols to the DUT");
    //reverse_8bits_in_Gen4(TS1_Frame_lane0);
    //reverse_8bits_in_Gen4(TS1_Frame_lane1);
    $display("---------------------------------------------------------------");
$display("[ELEC DRIVER] the size env_cfg_mem.GEN4_recieved_TS1_LANE0 is %0d and value =%p",env_cfg_mem.GEN4_recieved_TS1_LANE0.size(),env_cfg_mem.GEN4_recieved_TS1_LANE0);
$display("[ELEC DRIVER] the size env_cfg_mem.GEN4_recieved_TS1_LANE1f is %0d and value =%p",env_cfg_mem.GEN4_recieved_TS1_LANE1.size(),env_cfg_mem.GEN4_recieved_TS1_LANE1);
    $display("---------------------------------------------------------------");
    //ELEC_vif.data_incoming <=1; 
    ELEC_vif.lane_0_rx <='b0;
    ELEC_vif.lane_1_rx <='b0;
    //@(posedge ELEC_vif.gen4_lane_clk);
    //@(posedge ELEC_vif.gen4_lane_clk);
    //@(posedge ELEC_vif.gen4_lane_clk);
    //@(posedge ELEC_vif.gen4_lane_clk);
    //@(posedge ELEC_vif.gen4_lane_clk);
    //ELEC_vif.data_incoming <=0;
    
    $display("[elec monitor] at(%0t)",$time);

    repeat(2)begin
    foreach(env_cfg_mem.GEN4_recieved_TS1_LANE0[i]) begin
    @(posedge ELEC_vif.gen4_lane_clk);
    ELEC_vif.lane_0_rx <=env_cfg_mem.GEN4_recieved_TS1_LANE0[i];
    ELEC_vif.lane_1_rx <=env_cfg_mem.GEN4_recieved_TS1_LANE1[i];
    ELEC_vif.data_incoming <=1;
    end
    end
    @(posedge ELEC_vif.gen4_lane_clk);
    //ELEC_vif.data_incoming <=0;
    $display("at time(%0t)[elec DRIVER] doneeeeeeeeeeeeeeeeeeeeeeeeee",$time);
    
endtask: TS1_gen4_2_DUT
task electrical_layer_driver::TS2_gen4_2_DUT();
   ELEC_vif.data_incoming <=0;

   foreach(HEADER_TS2_GEN4[i])
    begin
	@(negedge ELEC_vif.gen4_lane_clk);
    ELEC_vif.lane_0_rx <=HEADER_TS2_GEN4[31-i];
    ELEC_vif.lane_1_rx <=HEADER_TS2_GEN4[31-i];
	ELEC_vif.data_incoming <=1;
   end

endtask: TS2_gen4_2_DUT

task electrical_layer_driver::TS3_2_DUT();

  ELEC_vif.data_incoming <=0;
    foreach(HEADER_TS3_GEN4[i])
    begin
    @(negedge ELEC_vif.gen4_lane_clk)
    ELEC_vif.lane_0_rx <=HEADER_TS3_GEN4[31-i];
    ELEC_vif.lane_1_rx <=HEADER_TS3_GEN4[31-i];
    ELEC_vif.data_incoming <=1;
   end
   $display("[ELEC DRIVER] the value of GEN4_recieved_TS3_LANE0 is:");

   foreach(HEADER_TS3_GEN4[l])begin

    $write (HEADER_TS3_GEN4[l]);
   end 
    $display;

endtask: TS3_2_DUT

task electrical_layer_driver::TS4_2_DUT();

bit		     [3:0]			counter;
logic 		            TS4_gen4[32];
logic 		            correct_TS4[$];
counter=4'd15;

   //calculate the correct TS4
  
 correct_TS4={<<{4'd0,{<<{~(counter)}},{<<{counter}},indication_TS4,CURSOR}};

 foreach(correct_TS4[i])
 begin
// @(posedge ELEC_vif.gen4_lane_clk)
  @(negedge ELEC_vif.gen4_lane_clk)
// ELEC_vif.lane_0_rx <=correct_TS4[$-i];
 //ELEC_vif.lane_1_rx <=correct_TS4[$-i];
 ELEC_vif.lane_0_rx <=correct_TS4[i];
 ELEC_vif.lane_1_rx <=correct_TS4[i];
 ELEC_vif.data_incoming <=1;
end
$display("[ELEC DRIVER] the value of GEN4_recieved_TS4_LANE0 is:");

foreach(correct_TS4[l])begin

 $write (correct_TS4[l]);
end 
 $display;


endtask: TS4_2_DUT


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//task send data to the DUT
task electrical_layer_driver:: send_data_2_DUT(input logic[15:0] data_2_DUT,
                                            input GEN gen_speed);
   int i=0;                                       
   ELEC_vif.sbrx <=1; 
   ELEC_vif.data_incoming <=1;

   elec_to_trans_lane_0.push_back(data_2_DUT[7:0]);
  elec_to_trans_lane_1.push_back(data_2_DUT[15:8]);
  $display("[ELEC DRIVER] Data to be sent to the transport layer on lane 0 %h",data_2_DUT[7:0]);  
  $display("[ELEC DRIVER] Data to be sent to the transport layer on lane 1 %h",data_2_DUT[15:8]);
  
   case(gen_speed)
     gen2: begin
      if (elec_to_trans_lane_0.size() == 8)
      begin

        $display("[ELEC DRIVER] elec_to_trans_lane_0: %p",elec_to_trans_lane_0);  
        $display("[ELEC DRIVER] elec_to_trans_lane_1: %p", elec_to_trans_lane_1);

        @(negedge ELEC_vif.gen2_lane_clk);
        ELEC_vif.lane_0_rx = 1'b0;
        ELEC_vif.lane_1_rx = 1'b0;

         @(negedge ELEC_vif.gen2_lane_clk);
        ELEC_vif.lane_0_rx = 1'b1;
        ELEC_vif.lane_1_rx = 1'b1;

        
        foreach(elec_to_trans_lane_0[i,j]) begin
          @(negedge ELEC_vif.gen2_lane_clk);

          ELEC_vif.lane_0_rx <=elec_to_trans_lane_0[i][7-j];
          ELEC_vif.lane_1_rx <=elec_to_trans_lane_1[i][7-j];
          //$display("[ELEC DRIVER] elec_to_trans_lane_0[%0d][7-%0d]: %b",i,j,elec_to_trans_lane_0[i][7-j]);  
          //$display("[ELEC DRIVER] elec_to_trans_lane_1[%0d][7-%0d]: %b",i,j,elec_to_trans_lane_1[i][7-j]);
        end

      end

     end

     gen3: begin
      if (elec_to_trans_lane_0.size() == 16)
      begin

        //$stop;
        $display("[ELEC DRIVER] elec_to_trans_lane_0: %p",elec_to_trans_lane_0);  
        $display("[ELEC DRIVER] elec_to_trans_lane_1: %p", elec_to_trans_lane_1);

        @(negedge ELEC_vif.gen3_lane_clk);
        
        //env_cfg_mem.Data_flag = 1; ////////////////////////////////////////////////////////////////

        ELEC_vif.lane_0_rx = 1'b0;
        ELEC_vif.lane_1_rx = 1'b0;

         @(negedge ELEC_vif.gen3_lane_clk);
        ELEC_vif.lane_0_rx = 1'b1;
        ELEC_vif.lane_1_rx = 1'b1;

         @(negedge ELEC_vif.gen3_lane_clk);
        ELEC_vif.lane_0_rx = 1'b0;
        ELEC_vif.lane_1_rx = 1'b0;

         @(negedge ELEC_vif.gen3_lane_clk);
        ELEC_vif.lane_0_rx = 1'b1;
        ELEC_vif.lane_1_rx = 1'b1;
        
        foreach(elec_to_trans_lane_0[i,j]) begin
          @(negedge ELEC_vif.gen3_lane_clk);

          ELEC_vif.lane_0_rx <=elec_to_trans_lane_0[i][7-j];
          ELEC_vif.lane_1_rx <=elec_to_trans_lane_1[i][7-j];
          //$display("[ELEC DRIVER] elec_to_trans_lane_0[%0d][7-%0d]: %b",i,j,elec_to_trans_lane_0[i][7-j]);  
          //$display("[ELEC DRIVER] elec_to_trans_lane_1[%0d][7-%0d]: %b",i,j,elec_to_trans_lane_1[i][7-j]); 

        end

      end
       
     end


     gen4: begin
       repeat(data_width)begin
         @(posedge ELEC_vif.gen4_lane_clk);
        // $display("[ELECTRIC DRIVER] data_2_DUT to lane0 =%d  and to lane1 =%d",data_2_DUT[7:0],data_2_DUT[15:8]);
         //$displayb(data_2_DUT);
         ELEC_vif.lane_0_rx <=data_2_DUT[7-i];
         ELEC_vif.lane_1_rx <=data_2_DUT[15-i];
         //$display("[ELECTRIC DRIVER] the date sent from the electrical to lane0 =%d  and to lane1 =%d",ELEC_vif.lane_0_rx,ELEC_vif.lane_1_rx);
         i++;
       end
        /*case(lane)
         lane_0: begin  
            foreach(data_2_DUT[i]) begin
             ELEC_vif.lane_0_rx <=data_2_DUT[i];
             @(posedge ELEC_vif.gen4_lane_clk);
            end
          end
         lane_1: begin
           foreach(data_2_DUT[i]) begin
             ELEC_vif.lane_1_rx <=data_2_DUT[i];
             @(posedge ELEC_vif.gen4_lane_clk);
           end
         end
       
       endcase*/
     end
   endcase
endtask: send_data_2_DUT
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//task to disconnect the DUT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//task to run the driver
task electrical_layer_driver::run();
 forever
  begin
   // Wait for the transaction from the generator
   elec_drv_gen.get(transaction);
   //$display("[ELEC DRIVER] the value of transaction is %p",transaction); //test
   case(transaction.phase)
   3'b010:begin  //indecate the phase 2 of the transaction
      @(negedge ELEC_vif.SB_clock);
      ELEC_vif.sbrx <=transaction.sbrx;
      #(tConnectRx);          // Wait for the time required for the connection to be established
     end

   3'b011:begin  //indecate the phase 3 of the transaction
case(transaction.transaction_type)
AT_cmd,AT_rsp: begin
 send_AT_cmd_OR_res_2_DUT(transaction.read_write,
                          transaction.address,
                          transaction.len,
                          transaction.cmd_rsp_data,
                          transaction.transaction_type
                         );

           //add explain on gen speed               
end
LT_fall:  begin
 send_LT_fall_2_DUT();
end
default:begin
end
endcase    
   end
   3'b100:begin
    //**stable consant signal on interface during training**// 
   ELEC_vif.sbrx <=1;           //drive sbrx to 1 
   case(transaction.o_sets)
     SLOS1: begin
        SLOS1_2_DUT(transaction.gen_speed);
     end
    SLOS2: begin
       SLOS2_2_DUT(transaction.gen_speed);
     end
     TS1_gen2_3: begin
       TS1_gen23_2_DUT(transaction.gen_speed);
     end
     TS2_gen2_3: begin
       TS2_gen23_2_DUT(transaction.gen_speed);
     end
     TS1_gen4: begin
       TS1_gen4_2_DUT();
     end
     TS2_gen4: begin
       TS2_gen4_2_DUT();
       $display("[ELEC DRIVER] wellllllllllllllooool");
       //$stop;
     end
     TS3: begin
       TS3_2_DUT();
       $display("[ELEC DRIVER] salahhhhhhhhhhhhhhhhh");
     end
     TS4: begin
       TS4_2_DUT(); 
     end
     default: begin
     end
   endcase
    
   end
   3'b101:begin   //added phase represent send data from electrical layer to the DUT
     ELEC_vif.sbrx <=1;           //drive sbrx to 1
     send_data_2_DUT( transaction.electrical_to_transport
                      ,transaction.gen_speed);
   end
   3'b110:begin //added phase to represent disconnect phase (drive sbrx to zero)
     Disconnect_2_DUT();
   end
   default:begin
     // Add your code here for default case
   end
   endcase
   ->elec_gen_driver_done; // Indicate that the driver has finished sending the transaction
   
   end

endtask: run

//endpackage:electrical_layer_driver_pkg
