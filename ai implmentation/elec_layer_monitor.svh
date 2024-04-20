//logic TS2_gen4; // Add this line to define TS2_gen4
////////////////////////****monitor package****//////////////////////////////
`timescale 1us/1ns
package electrical_layer_monitor_pkg;

	import electrical_layer_transaction_pkg::*;
	import env_cfg_class_pkg::*;                    //import the env_cfg_class package
    //import electrical_layer_driver_pkg::parent;
  ///************ Define the parent class inside electrical_layer_driver_pkg************///
  class parent;
	parameter start_bit = 1'b0;
	parameter stop_bit = 1'b1;

	parameter [7:0] DLE = 8'hFE;	//Data Link Escape (DLE) Symbol – indicates the beginning of a Transaction. 
	parameter [7:0] ETX = 8'h40;	//End of Transaction (ETX) Symbol 

	parameter [7:0] LSE_lane0 = 8'b10000000;	//Lane State Event (LSE) - indicating LT_Fall for lane 0.
	parameter [7:0] LSE_lane1 = 8'b10100000;	//Lane State Event (LSE) - indicating LT_Fall for lane 1.
  parameter [7:0] CLSE_lane0 =~(LSE_lane0);	//Lane State Event (LSE) - indicating LT_Fall for lane 0.
	parameter [7:0] CLSE_lane1 =~(LSE_lane1);	//Lane State Event (LSE) - indicating LT_Fall for lane 1.

	parameter [7:0] STX_cmd = 8'b00000101;		//Start Transaction (STX) Symbol – defines the operation of the Transaction. 
	parameter [7:0] STX_rsp = 8'b00000100;		//Start Transaction (STX) Symbol – defines the operation of the Transaction. 


	//Constants sizes
	parameter TR_HEADER_SIZE = 20; 	// We need the first 20 bits of the transaction received to know the transaction type
	parameter MIN_TR_SIZE = 30;		//The minimum size of any transaction is 30 bits (LT Fall)
	parameter LT_TR_SIZE = 30;		//Size of the LT Transactions (30 bits)

	parameter SLOS_SIZE = 2112; // 66 * 32 = 2112 or 132 * 16 = 2112
  parameter SLOS_SIZE_IN_BYTE=(SLOS_SIZE/8);
	parameter TS_GEN_2_3_SIZE = 64;
	parameter TS_GEN_4_HEADER_SIZE = 28;
	parameter TS16_SIZE = 7168; // Size of 16 back to back TS (448 * 16 = 7168)

	parameter PRBS11_SYMBOL_SIZE = 448; // Size of the PRBS11 symbol

  //timing parameters
  parameter tConnectRx = 25;        //min is 25us
  parameter tDisconnectRx = 1500;   //max is 1000us
  parameter	tDisconnectTx =	100000; //min is 50ms


	//Ordered sets
	parameter [65:0] SLOS1_64 [0:31] = {66'b100100000000101000000100010000101010100100000001101000001110010001,
										66'b101011101011101010001010000101000100100010101101010000110000100111,
										66'b101001011100111001011110111001001010111011000010101110010000101110,
										66'b101001001010011011000111101110110010101011110000001001100001011111,
										66'b100010010001110110101101011000110001110111101101010010110000110011,
										66'b101001111110111100001010011001000111111010110000100011100101011011,
										66'b101000011010110011100011111011011000101101110100110101001111000011,
										66'b101001100110111111111010000000100100000101101000100110010101111110,
										66'b100001000011001010011111000111000110110110111011011010101101100000,
										66'b101101110001110101101101000110110010111011110010101001110000011101,
										66'b101000110101110111000101010110100000011001000011111010011000100111,
										66'b101101011100010001011010101001100000011111000011000110011110111111,
										66'b100010100001110001001101101011110110001001011101011001010001111000,
										66'b101011001101001111110011100001111011001100101111111100100000011101,
										66'b100000110100100111001101110111110101010001000000101010000100000100,
										66'b101010001011000101001110100011101001011010011001100111111111110000,
										66'b100000011000000011110000011001100011111111011000000101110000100101,
										66'b101001011001111001111100111100011110011011001111101111100010100011,
										66'b100100010111001010010111000110010110111110011010001111100101100011,
										66'b101001110110111101011010010001100110101111111000100000110101000111,
										66'b100000101101100100110111101111010010100100110001101111101110100010,
										66'b101010010100000110001000111101010110010000011110100011001001011111,
										66'b100110010001011110101001001000011011010011101100111010111110100010,
										66'b100010010101010110000000011100000011011000011101110011010101111100,
										66'b100001000110001010111101000010010010010110110110011011011111101101,
										66'b100000101100100100111101101110010110101110011000101111110100100001,
										66'b100011010010111100110010011111110111000001010110001000011101010011,
										66'b100100001111001001100111011111110101000001000010001010010101000110,
										66'b100000101111000100100110101101111000110100110111001111010111100100,
										66'b100100111010101110100000101001000100011010101011100000001011000001,
										66'b100011100010111011010010101100110000111111100110000011111100011000,
										66'b100110111100111010011110100111001001110111011101010101010000000000};


	parameter [2111:0] SLOS1_64_1 = {	SLOS1_64[31], SLOS1_64[30], SLOS1_64[29], SLOS1_64[28], SLOS1_64[27], SLOS1_64[26], SLOS1_64[25], SLOS1_64[24], 
										SLOS1_64[23], SLOS1_64[22], SLOS1_64[21], SLOS1_64[20], SLOS1_64[19], SLOS1_64[18], SLOS1_64[17], SLOS1_64[16], 
										SLOS1_64[15], SLOS1_64[14], SLOS1_64[13], SLOS1_64[12], SLOS1_64[11], SLOS1_64[10], SLOS1_64[9], SLOS1_64[8], 
										SLOS1_64[7], SLOS1_64[6], SLOS1_64[5], SLOS1_64[4], SLOS1_64[3], SLOS1_64[2], SLOS1_64[1], SLOS1_64[0]};


	parameter [65:0] SLOS2_64 [0:31] = {66'b101011111111010111111011101111010101011011111110010111110001101110,
										66'b100100010100010101110101111010111011011101010010101111001111011000,
										66'b100110100011000110100001000110110101000100111101010001101111010001,
										66'b100110110101100100111000010001001101010100001111110110011110100000,
										66'b101101101110001001010010100111001110001000010010101101001111001100,
										66'b100110000001000011110101100110111000000101001111011100011010100100,
										66'b100111100101001100011100000100100111010010001011001010110000111100,
										66'b100110011001000000000101111111011011111010010111011001101010000001,
										66'b101110111100110101100000111000111001001001000100100101010010011111,
										66'b100010001110001010010010111001001101000100001101010110001111100010,
										66'b100111001010001000111010101001011111100110111100000101100111011000,
										66'b100010100011101110100101010110011111100000111100111001100001000000,
										66'b101101011110001110110010010100001001110110100010100110101110000111,
										66'b100100110010110000001100011110000100110011010000000011011111100010,
										66'b101111001011011000110010001000001010101110111111010101111011111011,
										66'b100101110100111010110001011100010110100101100110011000000000001111,
										66'b101111100111111100001111100110011100000000100111111010001111011010,
										66'b100110100110000110000011000011100001100100110000010000011101011100,
										66'b101011101000110101101000111001101001000001100101110000011010011100,
										66'b100110001001000010100101101110011001010000000111011111001010111000,
										66'b101111010010011011001000010000101101011011001110010000010001011101,
										66'b100101101011111001110111000010101001101111100001011100110110100000,
										66'b101001101110100001010110110111100100101100010011000101000001011101,
										66'b101101101010101001111111100011111100100111100010001100101010000011,
										66'b101110111001110101000010111101101101101001001001100100100000010010,
										66'b101111010011011011000010010001101001010001100111010000001011011110,
										66'b101100101101000011001101100000001000111110101001110111100010101100,
										66'b101011110000110110011000100000001010111110111101110101101010111001,
										66'b101111010000111011011001010010000111001011001000110000101000011011,
										66'b101011000101010001011111010110111011100101010100011111110100111110,
										66'b101100011101000100101101010011001111000000011001111100000011100111,
										66'b101001000011000101100001011000110110001000100010101010101111111111};


	parameter [2111:0] SLOS2_64_1 = {SLOS2_64[31], SLOS2_64[30], SLOS2_64[29], SLOS2_64[28], SLOS2_64[27], SLOS2_64[26], SLOS2_64[25], SLOS1_64[24], 
										SLOS2_64[23], SLOS2_64[22], SLOS2_64[21], SLOS2_64[20], SLOS2_64[19], SLOS2_64[18], SLOS2_64[17], SLOS2_64[16], 
										SLOS2_64[15], SLOS2_64[14], SLOS2_64[13], SLOS2_64[12], SLOS2_64[11], SLOS2_64[10], SLOS2_64[9], SLOS2_64[8], 
										SLOS2_64[7], SLOS2_64[6], SLOS2_64[5], SLOS2_64[4], SLOS2_64[3], SLOS2_64[2], SLOS2_64[1], SLOS2_64[0]};

	
	parameter [131:0] SLOS1_128 [0:15] = {132'b101001000000001010000001000100001010101001000000011010000011100100011011101011101010001010000101000100100010101101010000110000100111,
											132'b101010010111001110010111101110010010101110110000101011100100001011101001001010011011000111101110110010101011110000001001100001011111,
											132'b101000100100011101101011010110001100011101111011010100101100001100111001111110111100001010011001000111111010110000100011100101011011,
											132'b101010000110101100111000111110110110001011011101001101010011110000111001100110111111111010000000100100000101101000100110010101111110,
											132'b101000010000110010100111110001110001101101101110110110101011011000001101110001110101101101000110110010111011110010101001110000011101,
											132'b101010001101011101110001010101101000000110010000111110100110001001111101011100010001011010101001100000011111000011000110011110111111,
											132'b101000101000011100010011011010111101100010010111010110010100011110001011001101001111110011100001111011001100101111111100100000011101,
											132'b101000001101001001110011011101111101010100010000001010100001000001001010001011000101001110100011101001011010011001100111111111110000,
											132'b101000000110000000111100000110011000111111110110000001011100001001011001011001111001111100111100011110011011001111101111100010100011,
											132'b101001000101110010100101110001100101101111100110100011111001011000111001110110111101011010010001100110101111111000100000110101000111,
											132'b101000001011011001001101111011110100101001001100011011111011101000101010010100000110001000111101010110010000011110100011001001011111,
											132'b101001100100010111101010010010000110110100111011001110101111101000100010010101010110000000011100000011011000011101110011010101111100,
											132'b101000010001100010101111010000100100100101101101100110110111111011010000101100100100111101101110010110101110011000101111110100100001,
											132'b101000110100101111001100100111111101110000010101100010000111010100110100001111001001100111011111110101000001000010001010010101000110,
											132'b101000001011110001001001101011011110001101001101110011110101111001000100111010101110100000101001000100011010101011100000001011000001,
											132'b101000111000101110110100101011001100001111111001100000111111000110000110111100111010011110100111001001110111011101010101010000000000};


	parameter [2111:0] SLOS1_128_1 = {	SLOS1_128[15], SLOS1_128[14], SLOS1_128[13], SLOS1_128[12], SLOS1_128[11], SLOS1_128[10], SLOS1_128[9], SLOS1_128[8], 
										SLOS1_128[7], SLOS1_128[6], SLOS1_128[5], SLOS1_128[4], SLOS1_128[3], SLOS1_128[2], SLOS1_128[1], SLOS1_128[0]};


	parameter [131:0] SLOS2_128 [0:15] = {	132'b101010111111110101111110111011110101010110111111100101111100011011100100010100010101110101111010111011011101010010101111001111011000,
											132'b101001101000110001101000010001101101010001001111010100011011110100010110110101100100111000010001001101010100001111110110011110100000,
											132'b101011011011100010010100101001110011100010000100101011010011110011000110000001000011110101100110111000000101001111011100011010100100,
											132'b101001111001010011000111000001001001110100100010110010101100001111000110011001000000000101111111011011111010010111011001101010000001,
											132'b101011101111001101011000001110001110010010010001001001010100100111110010001110001010010010111001001101000100001101010110001111100010,
											132'b101001110010100010001110101010010111111001101111000001011001110110000010100011101110100101010110011111100000111100111001100001000000,
											132'b101011010111100011101100100101000010011101101000101001101011100001110100110010110000001100011110000100110011010000000011011111100010,
											132'b101011110010110110001100100010000010101011101111110101011110111110110101110100111010110001011100010110100101100110011000000000001111,
											132'b101011111001111111000011111001100111000000001001111110100011110110100110100110000110000011000011100001100100110000010000011101011100,
											132'b101010111010001101011010001110011010010000011001011100000110100111000110001001000010100101101110011001010000000111011111001010111000,
											132'b101011110100100110110010000100001011010110110011100100000100010111010101101011111001110111000010101001101111100001011100110110100000,
											132'b101010011011101000010101101101111001001011000100110001010000010111011101101010101001111111100011111100100111100010001100101010000011,
											132'b101011101110011101010000101111011011011010010010011001001000000100101111010011011011000010010001101001010001100111010000001011011110,
											132'b101011001011010000110011011000000010001111101010011101111000101011001011110000110110011000100000001010111110111101110101101010111001,
											132'b101011110100001110110110010100100001110010110010001100001010000110111011000101010001011111010110111011100101010100011111110100111110,
											132'b101011000111010001001011010100110011110000000110011111000000111001111001000011000101100001011000110110001000100010101010101111111111};


	parameter [2111:0] SLOS2_128_1 = {	SLOS2_128[15], SLOS2_128[14], SLOS2_128[13], SLOS2_128[12], SLOS2_128[11], SLOS2_128[10], SLOS2_128[9], SLOS2_128[8], 
										SLOS2_128[7], SLOS2_128[6], SLOS2_128[5], SLOS2_128[4], SLOS2_128[3], SLOS2_128[2], SLOS2_128[1], SLOS2_128[0] };

 
	//Parameters for TS1 and TS2 symbols for Gen 2 and Gen 3
	parameter [7:0] lane_number_0 = 8'h00,
                  lane_number_1 = 8'h01; // To indicate the lane number (one for lane 0  and one for lane 1)
	parameter [5:0] TSID_TS1 = 6'b100110;  // To indicate TS1
	parameter [5:0] TSID_TS2 = 6'b011001;  // To indicate TS2
	parameter [9:0] SCR = 10'b0011110010;

  //Order sets TS1 and 2 for Gen 2 and 3
  parameter        TS1_gen2_3_lane0= {5'd0,3'd1,lane_number_0,32'd0,TSID_TS1,SCR};
  parameter        TS1_gen2_3_lane1= {5'd0,3'd1,lane_number_1,32'd0,TSID_TS1,SCR};
  parameter        TS2_gen2_3_lane0= {5'd0,3'd1,lane_number_0,32'd0,TSID_TS2,SCR};
  parameter        TS2_gen2_3_lane1= {5'd0,3'd1,lane_number_1,32'd0,TSID_TS2,SCR};


	//Parameters for TS symbols for Gen 4
  parameter        CURSOR = 12'h7E0;
  parameter        indication_TS1=4'h2,
                   indication_TS2=4'h4,
                   indication_TS3=4'h6;
  parameter        indication_TS4=8'hf0;
                  
  parameter        counter_TS1=8'h0f,   //check on sending the counter value from zakaria
                   counter_TS2=8'h0f,
                   counter_TS3=8'h0f;
  parameter        counter_TS4=4'hf;


   //Order sets TS1&2 for Gen4
  parameter [27:0] TS2_gen4={4'd0,counter_TS2,~(indication_TS2),indication_TS2,CURSOR};
  parameter [27:0] TS3_gen4={4'd0,counter_TS3,~(indication_TS3),indication_TS3,CURSOR};

   
	// Seeds for the Pseudo Random Sequences
	parameter [10:0] PRBS11_lane0_seed =11'b11111111111;
	parameter [10:0] PRBS11_lane1_seed =11'b11101110000;


///-------------------------///
//Order sets TS1,2,3,4 for Gen4
parameter [27:0]  HEADER_TS1_GEN4={counter_TS1,~(indication_TS1),indication_TS1,CURSOR};
parameter [27:0]  HEADER_TS2_GEN4={4'd0,counter_TS2,~(indication_TS2),indication_TS2,CURSOR};
parameter [27:0]  HEADER_TS3_GEN4={4'd0,counter_TS3,~(indication_TS3),indication_TS3,CURSOR};
parameter [27:0]  HEADER_TS4_GEN4={4'd0,~(counter_TS4),counter_TS4,indication_TS4,CURSOR};

//TASKS for genetate PRBS11 
    task automatic PRSC11(input bit [10:0] seed, input int size, output bit PRBS11_OUT[$]);
 
        // Declare OLD_D10 and OLD_D8
        bit OLD_D10;
        bit OLD_D8;

        // Declare rig_data and assign seed to it
        bit [10:0] rig_data = seed;

        // For loop with upper limit of iteration equal to the value of size input
        for (int i = 0; i < size; i++)
         begin
            // Push rig_data[10] to PRBS11_OUT
            PRBS11_OUT.push_back(rig_data[10]);

        OLD_D10=rig_data[10];
        OLD_D8=rig_data[8];

        for (int k=10;k>0;k--) begin
                 rig_data[k]=rig_data[k-1];
        end
        rig_data[0]=OLD_D10^OLD_D8;
         end

endtask: PRSC11
 endclass: parent

	class electrical_layer_monitor  extends parent;


	//timing parameters
	parameter	tDisconnectTx =	100000; //min is 50ms
     //to define the generation
	 typedef enum logic [1:0] {gen2, gen3, gen4} GEN;
     typedef enum logic [3:0] {SLOS1 = 4'b1000, SLOS2, TS1_gen2_3, TS2_gen2_3, TS1_gen4, TS2_gen4, TS3, TS4} OS_type;
	 //defind variables
	 logic       trans_to_ele_lane0[$];
	 logic       trans_to_ele_lane1[$];
	 logic [9:0] recieved_transaction_data_symb[$];

	  GEN speed; 	// indicates the generation
	 //declare the events
      event sbtx_transition_high;  // Event to indicate that the monitor recieved sbtx high
	  event correct_OS;  // Event to indicate that the monitor recieved correct ordered set
	  event ready_to_recieved_data;  // Event to indicate that the monitor is ready to recieve data
      event sbtx_response;          // Event to indicate that the monitor recieved sbtx response
	  //event data_income;            
    //declare the transactions
    elec_layer_tr mon_2_Sboard_trans;    // Transaction to be recieved from the generator
	env_cfg_class env_cfg_mem;     // Transaction to be recieved from the scoreboard
    //declare the mailboxes
    mailbox #(env_cfg_class) elec_sboard_2_monitor;  // Mailbox to receive the transaction from the generator
    mailbox #(elec_layer_tr) elec_mon_2_Sboard;   // Mailbox to send transaction to the scoreboard
	mailbox #(GEN)           speed_mailbox;           // Mailbox to send the generation speed to the scoreboard
    //declare varsual interface
    virtual electrical_layer_if ELEC_vif;
    // Constructor
  function new(mailbox #(elec_layer_tr) elec_mon_2_Sboard,virtual electrical_layer_if ELEC_vif
               ,event sbtx_transition_high ,correct_OS,sbtx_response,env_cfg_class env_cfg_mem );
    this.elec_mon_2_Sboard=elec_mon_2_Sboard;
    this.ELEC_vif=ELEC_vif;
    this.sbtx_transition_high=sbtx_transition_high;
	this.correct_OS=correct_OS;
	this.sbtx_response=sbtx_response;
	this.env_cfg_mem =env_cfg_mem;    //check it
  endfunction 


//extern tasks 
         extern task get_transport_data(input GEN speed);
		 extern task run();
		 extern task check_AT_transaction(input  [9:0] q[$],input tr_type trans_type);
         extern task recieved_SLOS1_gen23(input GEN speed);
		 extern task recieved_SLOS2_gen23(input GEN speed);
		 extern task recieved_TS12_gen23(input GEN speed,input OS_type os);
		 //extern task recieved_TS2_gen23(input GEN speed);
		 extern task recieved_TS234_gen4(input OS_type os,bit done_training);
		 extern task recieved_TS1_gen4();
  endclass : electrical_layer_monitor

task electrical_layer_monitor::recieved_TS12_gen23(input GEN speed ,input OS_type os);
logic      			    recieved_TS_lane0[$],
           				recieved_TS_lane1[$];

logic                   correct_TS1_lane0[$],
                        correct_TS1_lane1[$],
						correct_TS2_lane0[$],
                        correct_TS2_lane1[$];

logic     [63:0]        temp_TS_lane0[$],
						temp_TS_lane1[$];


//case to recevied the TS for gen2,3 and check the TS
case (os)
TS1_gen2_3:
begin	//collect data from the two lanes
case(speed)
gen2:begin
	repeat(TS_GEN_2_3_SIZE*32)begin //collect the TS from the two lanes
  recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
  recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
  @(negedge ELEC_vif.gen2_lane_clk);	
  if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
        begin
		   $error("the value of ELEC_vif.sbtx is %0d during send TS1 GEN2",ELEC_vif.sbtx);
		   break;
		end
	end
		   $display("the size of recieved_TS1_gen2 on lane0 is %0d and must be 1024 on lane 0",recieved_TS_lane0.size());

//calculate the correct TS
repeat(32)begin
 foreach(TS1_gen2_3_lane0[i])begin
	 correct_TS1_lane0.push_back(TS1_gen2_3_lane0[i]);
     correct_TS1_lane1.push_back(TS1_gen2_3_lane1[i]);
 end
end
   /* temp_TS_lane0= {32{TS1_gen2_3_lane0}};
	temp_TS_lane1= {32{TS1_gen2_3_lane1}};

     
	correct_TS1_lane0 =  {<<{temp_TS_lane0}};
	correct_TS1_lane1 =  {<<{temp_TS_lane1}};*/

	 //check the recieved TS with the correct TS
	 if(recieved_TS_lane0==correct_TS1_lane0 && recieved_TS_lane1==correct_TS1_lane1)
	 begin	
			 $display("TS1 is correct on gen2");	
			-> correct_OS;   //do that on all first OS on each gen	
      end
	  else
	  $error("TS1 is not correct on gen2");

      //delete the recieved TS
	  recieved_TS_lane0.delete();
	  recieved_TS_lane1.delete();
	
end
    
     //////////////////////////////////////////
gen3:begin
	repeat(TS_GEN_2_3_SIZE*16)begin //collect the TS from the two lanes
    recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
    recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
    @(negedge ELEC_vif.gen3_lane_clk);	
    if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
        begin
		   $error("the value of ELEC_vif.sbtx is %0d during send TS1 GEN3",ELEC_vif.sbtx);
		   break;
		end
	end
		$display("the size of recieved_TS1_gen3 on lane0 is %0d and must be (1024/2) on lane 0",recieved_TS_lane0.size());
		


		//calculate the correct TS
		repeat(16)begin
		foreach(TS1_gen2_3_lane0[i])begin
			correct_TS1_lane0.push_back(TS1_gen2_3_lane0[i]);
			correct_TS1_lane1.push_back(TS1_gen2_3_lane1[i]);
		end
		end


		 //check the recieved TS with the correct TS
	 if(recieved_TS_lane0==correct_TS1_lane0 && recieved_TS_lane1==correct_TS1_lane1)
	 begin	
			 $display("TS1 is correct on gen3");	
			-> correct_OS;   //do that on all first OS on each gen	
	  end
	  else
	  $error("TS1 is not correct on gen3");
	  end

	 
endcase
end
TS2_gen2_3:
begin
	case(speed)
	gen2:begin
		repeat(TS_GEN_2_3_SIZE*16)begin //collect the TS from the two lanes
	recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
	recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
	@(negedge ELEC_vif.gen2_lane_clk);	
	if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
			begin
			$error("the value of ELEC_vif.sbtx is %0d during send TS2 GEN2",ELEC_vif.sbtx);
			break;
			end
		end
			$display("the size of recieved_TS2_gen2 on lane0 is %0d and must be 1024 on lane 0",recieved_TS_lane0.size());


       //calculate the correct TS
		repeat(16)begin
		foreach(TS2_gen2_3_lane0[i])begin
		correct_TS2_lane0.push_back(TS2_gen2_3_lane0[i]);
		correct_TS2_lane1.push_back(TS2_gen2_3_lane1[i]);
		end
		end

		//check the recieved TS with the correct 
		if(recieved_TS_lane0==correct_TS2_lane0 && recieved_TS_lane1==correct_TS2_lane1)
		begin	
			 $display("TS2 is correct on gen2");	
			-> ready_to_recieved_data;   //do that on all first OS on each gen	
		end
		else
		$error("TS2 is not correct on gen2");
		end
	gen3:
	begin
		repeat(TS_GEN_2_3_SIZE*8)begin //collect the TS from the two lanes
		recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
		recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
		@(negedge ELEC_vif.gen3_lane_clk);	
		if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
			begin
			$error("the value of ELEC_vif.sbtx is %0d during send TS2 GEN3",ELEC_vif.sbtx);
			break;
			end
		end
			$display("the size of recieved_TS2_gen3 on lane0 is %0d and must be (512/2) on lane 0",recieved_TS_lane0.size());


			//calculate the correct TS
			repeat(8)begin
			foreach(TS2_gen2_3_lane0[i])begin
			correct_TS2_lane0.push_back(TS2_gen2_3_lane0[i]);
			correct_TS2_lane1.push_back(TS2_gen2_3_lane1[i]);
			end
			end

			//check the recieved TS with the correct	
		if(recieved_TS_lane0==correct_TS2_lane0 && recieved_TS_lane1==correct_TS2_lane1)
		begin	
			 $display("TS2 is correct on gen3");	
			-> ready_to_recieved_data;   //do that on all first OS on each gen	
		end
		else
		$error("TS2 is not correct on gen3");

		end
	endcase
end

endcase
/*
 TS1_gen2_3_lane0= {5'd0,3'd1,lane_number_0,32'd0,TSID_TS1,SCR};
 TS1_gen2_3_lane1= {5'd0,3'd1,lane_number_1,32'd0,TSID_TS1,SCR};
 TS2_gen2_3_lane0= {5'd0,3'd1,lane_number_0,32'd0,TSID_TS2,SCR};
 TS2_gen2_3_lane1= {5'd0,3'd1,lane_number_1,32'd0,TSID_TS2,SCR};*/
endtask:recieved_TS12_gen23


task electrical_layer_monitor::recieved_SLOS2_gen23(input GEN speed);
	int i;
	logic 			      recieved_SLOS2_lane0[$],
						  recieved_SLOS2_lane1[$];
	logic [0:7] 		  SLOS2_total[$];
	logic [2*SLOS_SIZE-1:0] P_SLOS2_lane0,
	                        P_SLOS2_lane1;

	if(speed==gen2) //collect the SLOS from the two lanes
	begin
	repeat(2*SLOS_SIZE)
	begin
		recieved_SLOS2_lane0.push_back(ELEC_vif.lane_0_rx);
		recieved_SLOS2_lane1.push_back(ELEC_vif.lane_1_rx);
		@(negedge ELEC_vif.gen2_lane_clk);
		if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
		begin
		$error("the value of ELEC_vif.sbtx is %0d during send slos2 for GEN2",ELEC_vif.sbtx);
		break;
		end
	end
	$display("the value of recieved_SLOS2_lane0 is %0p for GEN2",recieved_SLOS2_lane0);
	$display("the size of recieved_SLOS2_lane0 is %0d for GEN2",recieved_SLOS2_lane0.size());
	end
	else if(speed==gen3)
	begin
	repeat(2*SLOS_SIZE)	//collect the SLOS from the two lanes
	begin
	recieved_SLOS2_lane0.push_back(ELEC_vif.lane_0_rx);
	recieved_SLOS2_lane1.push_back(ELEC_vif.lane_1_rx);
	@(negedge ELEC_vif.gen3_lane_clk);
	if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)begin
		$error("the value of ELEC_vif.sbtx is %0d during send slos2 for GEN3",ELEC_vif.sbtx);
		break;
	end
	end
	$display("the value of recieved_SLOS2_lane0 is %0p for GEN3",recieved_SLOS2_lane0);
	$display("the size of recieved_SLOS2_lane0 is %0d for GEN3",recieved_SLOS2_lane0.size());
	end

	//convert to packet
		P_SLOS2_lane0={<< {recieved_SLOS2_lane0}};
		P_SLOS2_lane1={<< {recieved_SLOS2_lane1}};
	

	case (speed)
	gen2:begin
	if(P_SLOS2_lane0 ==({2{SLOS2_64_1}}))
	begin
	$display("SLOS2 is correct on gen2");
	-> correct_OS;   //do that on all first OS on each gen
	end
	else	
	$error("SLOS2 is not correct on gen2");
	end
	gen3:begin 
		if(P_SLOS2_lane1 ==({2{SLOS2_128_1}}))
	begin
	$display("SLOS2 is correct on gen3");
	-> correct_OS;   //do that on all first OS on each gen
	end
	else	
	$error("SLOS2 is not correct on gen3");
	end
	endcase
endtask:recieved_SLOS2_gen23

//task to recieved TS for gen4
task electrical_layer_monitor::recieved_TS234_gen4(input OS_type os,bit done_training);

logic 		         	recieved_TS_lane0[$],
					    recieved_TS_lane1[$];
logic                   correct_TS2[$],
                        correct_TS3[$],
						correct_TS4[$],
						temp_correct_TS[$];
logic [27:0]            TS4_gen4;						
bit   [3:0] i;


if(!done_training)begin
	case(os)
	TS2_gen4:
	begin
          repeat(16*TS_GEN_4_HEADER_SIZE)begin //collect the TS from the two lanes
			recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
			recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
			@(negedge ELEC_vif.gen4_lane_clk);
			if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
			begin
			$error("the value of ELEC_vif.sbtx is %0d during send TS_gen4 GEN4",ELEC_vif.sbtx);
			break;
			end
		    end
			$display("the size of recieved_TS2 GEN4 on lane0 is %0d and must be 448 zakaria on lane 0",recieved_TS_lane0.size());

			temp_correct_TS={{16{TS2_gen4}}};
            correct_TS2 ={<<{temp_correct_TS}}; // Ensure TS2_gen4 is defined before this line
     		//correct_TS2_lane1 ={<<{16{recieved_TS_lane1}}};

			if((correct_TS2 ==recieved_TS_lane1)&& (correct_TS2 ==recieved_TS_lane0))begin
			$display("TS2 is correct on gen4");
			-> correct_OS;   //do that on all first OS on each gen
			end
			else
			$error("TS2 is not correct on gen4");
			end

	TS3:
		begin
          repeat(16*TS_GEN_4_HEADER_SIZE)begin //collect the TS from the two lanes
			recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
			recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
			@(negedge ELEC_vif.gen4_lane_clk);
			if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
			begin
			$error("the value of ELEC_vif.sbtx is %0d during send TS_gen4 GEN4",ELEC_vif.sbtx);
			break;
			end
		    end
			$display("the size of recieved_TS2 GEN4 on lane0 is %0d and must be 448 zakaria on lane 0",recieved_TS_lane0.size());

            temp_correct_TS={{16{TS3_gen4}}};
			correct_TS3 ={<<{temp_correct_TS}};

     		//correct_TS2_lane1 ={<<{16{recieved_TS_lane1}}};

			if((correct_TS3 ==recieved_TS_lane1)&& (correct_TS3 ==recieved_TS_lane0))begin
			$display("TS3 is correct on gen4");
			-> correct_OS;   //do that on all first OS on each gen
			end
			else
			$error("TS3 is not correct on gen4");
		end

	
	TS4:
	begin
		
          repeat(16*TS_GEN_4_HEADER_SIZE)
		    begin //collect the TS from the two lanes
			recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
			recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
			@(negedge ELEC_vif.gen4_lane_clk);
			if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
			begin
			$error("the value of ELEC_vif.sbtx is %0d during send TS4_gen4 GEN4",ELEC_vif.sbtx);
			break;
			end
		    end
			$display("the size of recieved_TS2 GEN4 on lane0 is %0d and must be 448 (zakaria) on lane 0",recieved_TS_lane0.size());
            i=0;
			//calculate the correct TS

			repeat(16)
			begin
			TS4_gen4={{4'd0,~(i),i,indication_TS4,CURSOR}} ;
			foreach(TS4_gen4[j])begin
			 correct_TS4.push_back(TS4_gen4[j]);  //check the correct value
			end 
			i++;
			end

			if((correct_TS4 ==recieved_TS_lane1) && (correct_TS4 ==recieved_TS_lane0))
			begin
			$display("TS4 is correct on gen4");
			-> correct_OS;   //do that on all first OS on each gen
			end
			else
			$error("TS4 is not correct on gen4");
		end

	
	endcase

    
end
else
	begin
      $display("training is done for gen4");
	  -> ready_to_recieved_data;
	end

/*
   repeat(16*TS_GEN_4_HEADER_SIZE)	//collect the TS from the two lanes
			begin	
			if((i%2)==0)
			begin
			TS_total_recieved[i]=recieved_TS_lane0[(i/2)];
			end
			else
			begin
			TS_total_recieved[i]=recieved_TS_lane1[(i/2)];
			end
			i++;
			end

foreach(TS_total_recieved[i,j])begin   //to compare the result packets
TS_total[i+j]=TS_total_recieved[i][j];
end*/


	/*if(!done_training)
	begin
		case(os)
		TS2_gen4:
			begin 
			if(TS_total==HEADER_TS2_GEN4) begin
				$display("TS2 is correct on gen4");
				-> correct_OS;   //do that on all first OS on each gen
			end
				else
				$error("TS2 isnot correct on gen4");
			end   
		TS3:
			begin 
			if(TS_total==HEADER_TS3_GEN4) begin
				$display("TS3 is correct on gen4");
				-> correct_OS;   //do that on all first OS on each gen
			end
				else
				$error("TS3 isnot correct on gen4");
			end
		TS4:
			begin 
			if(TS_total==HEADER_TS4_GEN4) begin
				$display("TS4 is correct on gen4");
				-> correct_OS;   //do that on all first OS on each gen
			end
				else
				$error("TS4 isnot correct on gen4");

			end
		endcase
	end
	else if(os==TS4)
	begin
      $display("training is done for gen4");
	  -> ready_to_recieved_data;
	end*/
    
endtask:recieved_TS234_gen4

task  electrical_layer_monitor::recieved_TS1_gen4();
int i;
logic 		                   recieved_TS1_lane0[$]
                               ,recieved_TS1_lane1[$];
//logic 	                   TS1_total_recieved[$];
logic		      		       TS1_total_lane0[$],
                               TS1_total_lane1[$];
logic                          unp_TS1_total_lane0[$],
							   unp_TS1_total_lane1[$];							   
bit                            PRBS11_q_lane0[$],
                               PRBS11_q_lane1[$];

//generate the TS1 for gen4
PRSC11(PRBS11_lane0_seed,16*PRBS11_SYMBOL_SIZE, PRBS11_q_lane0);
PRSC11(PRBS11_lane1_seed,16*PRBS11_SYMBOL_SIZE, PRBS11_q_lane1);
i=0;
TS1_total_lane0.delete();
TS1_total_lane1.delete();
repeat(16)
begin
TS1_total_lane0={TS1_total_lane0,{<< {PRBS11_q_lane0[(i*448)+447:(i*448)+28],HEADER_TS1_GEN4}}};
TS1_total_lane1={TS1_total_lane1,{<< {PRBS11_q_lane1[(i*448)+447:(i*448)+28],HEADER_TS1_GEN4}}};
i++;
end
/////////////////////////////////////

repeat(TS16_SIZE) //collect the TS1 from the two lanes
 begin 
  recieved_TS1_lane0.push_back(ELEC_vif.lane_0_rx);
  recieved_TS1_lane1.push_back(ELEC_vif.lane_1_rx);
  @(negedge ELEC_vif.gen4_lane_clk);
  if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
        begin
		   $display("[ELEC MONITOR]the value of ELEC_vif.sbtx is %0d AND ELEC_vif.enable_rs %0d during send TS1 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
		   break;
		end
 end

    //$display("the value of recieved_TS1_gen4 is %0p",recieved_SLOS1_lane0);
	$display("[ELEC MONITOR]the size of recieved_TS1_gen4 on lane0 is %0d and must be 3584 on lane 0",recieved_TS1_lane0.size());
	$display("[ELEC MONITOR]the size of recieved_TS1_gen4 on lane1 is %0d and must be 3584 on lane 1",recieved_TS1_lane1.size());

if(TS1_total_lane0==recieved_TS1_lane0 && TS1_total_lane1==recieved_TS1_lane1)
begin
$display("[ELEC MONITOR]TS1 is correct on gen4");
-> correct_OS;   //do that on all first OS on each gen
        mon_2_Sboard_trans.gen_speed=gen4;
		mon_2_Sboard_trans.o_sets=TS1_gen4;
		mon_2_Sboard_trans.sbtx='b1;
		mon_2_Sboard_trans.tr_os=ord_set;
		mon_2_Sboard_trans.lane=both;
		elec_mon_2_Sboard.put(mon_2_Sboard_trans);
end
else	
$error("[ELEC MONITOR]TS1 is not correct on gen2");
endtask:recieved_TS1_gen4

//task to recieved SLOS1 for gen2,3
	task  electrical_layer_monitor::recieved_SLOS1_gen23(input GEN speed);  //add check on sbtx=1 all the time of recieved
	int i;
	logic  			      recieved_SLOS1_lane0[$],
						  recieved_SLOS1_lane1[$];  //check the rang is good or flip?
	logic [0:7]		  	  SLOS1_total[$];
	logic [2*SLOS_SIZE-1:0] P_SLOS1_lane0,
	                      P_SLOS1_lane1;

	if(speed==gen2) //collect the SLOS from the two lanes
	begin
	repeat(2*SLOS_SIZE)  
	begin
		recieved_SLOS1_lane0.push_back(ELEC_vif.lane_0_rx);
		recieved_SLOS1_lane1.push_back(ELEC_vif.lane_1_rx);
		@(negedge ELEC_vif.gen2_lane_clk);
		if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)begin
		   $display("[ELEC MONITOR]the value of ELEC_vif.sbtx is %0d AND enable_rs equal %0d during send slos1 for GEN2 ",ELEC_vif.sbtx,ELEC_vif.enable_rs);
		   break;
		end
	end
	//$display("the value of recieved_SLOS1_lane0 is %0p for GEN2",recieved_SLOS1_lane0);
	$display("the size of recieved_SLOS1_lane0 is %0d for GEN2",recieved_SLOS1_lane0.size());
	$display("the size of recieved_SLOS1_lane1 is %0d for GEN2",recieved_SLOS1_lane1.size());
	end
	else if(speed==gen3)
	begin
	repeat(2*SLOS_SIZE)	//collect the SLOS from the two lanes
	begin
	recieved_SLOS1_lane0.push_back(ELEC_vif.lane_0_rx);
	recieved_SLOS1_lane1.push_back(ELEC_vif.lane_1_rx);
	@(negedge ELEC_vif.gen3_lane_clk);
	if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)begin
		$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is %0d during send slos1 for for GEN3",ELEC_vif.sbtx);
		break;
	end
	end
	//$display("the value of recieved_SLOS1_lane0 is %0p for GEN3",recieved_SLOS1_lane0);
	$display("the size of recieved_SLOS1_lane0 is %0d  for GEN3",recieved_SLOS1_lane0.size());
	$display("the size of recieved_SLOS1_lane1 is %0d  for GEN3",recieved_SLOS1_lane1.size());
	end

	foreach(recieved_SLOS1_lane0[i]) //convert to packet
	begin
		P_SLOS1_lane0[i]=recieved_SLOS1_lane0[i];
		P_SLOS1_lane1[i]=recieved_SLOS1_lane1[i];
	end
/*
	repeat(SLOS_SIZE)	//collect the SLOS from the two lanes
	begin	
	if((i%2)==0)
	begin
	SLOS1_total[i]=recieved_SLOS1_lane0[(i/2)];
	end
	else
	begin
	SLOS1_total[i]=recieved_SLOS1_lane1[(i/2)];
	end
	i++;
	end

	foreach(SLOS1_total[i,j]) //convert to packet 
	begin
		P_SLOS1[i+j]=SLOS1_total[i][j];
	end*/


	case (speed)
	gen2:begin
		if((P_SLOS1_lane0==({2{SLOS1_64_1}})) && (P_SLOS1_lane1==({2{SLOS1_64_1}})))	
		begin
		$display("SLOS1 is correct on gen2");
		-> correct_OS;   //do that on all first OS on each gen
		mon_2_Sboard_trans.gen_speed=gen2;
		mon_2_Sboard_trans.o_sets=SLOS1;
		mon_2_Sboard_trans.sbtx='b1;
		mon_2_Sboard_trans.tr_os=ord_set;
		mon_2_Sboard_trans.lane=both;
		elec_mon_2_Sboard.put(mon_2_Sboard_trans);

		end
		else	
		$error("SLOS1 is not correct on gen2");
		end
	gen3:begin 
			if(P_SLOS1_lane0==({2{SLOS2_128_1}}) && P_SLOS1_lane1==({2{SLOS2_128_1}}))
		begin
		//$display("[ELEC MONITOR] SLOS1 is correct on gen3");
		-> correct_OS;   //do that on all first OS on each gen
		mon_2_Sboard_trans.gen_speed=gen3;
		mon_2_Sboard_trans.o_sets=SLOS1;
		mon_2_Sboard_trans.sbtx='b1;
		mon_2_Sboard_trans.tr_os=ord_set;
		mon_2_Sboard_trans.lane=both;
		elec_mon_2_Sboard.put(mon_2_Sboard_trans);
		end
		else	
		$error("SLOS1 is not correct on gen3");
	end
	endcase
	endtask:recieved_SLOS1_gen23

	//task to check the AT transaction
	task electrical_layer_monitor::check_AT_transaction(input  [9:0] q[$],tr_type trans_type);

	case(trans_type)
	AT_cmd:begin
		if(q[0] =={<<{stop_bit,DLE,start_bit}} && q[$-1]=={<<{stop_bit,DLE,start_bit}}
			&& q[1]=={<<{stop_bit,STX_cmd,start_bit}}&&q[$]=={<<{stop_bit,ETX,start_bit}})  //check the data later
			begin
			$display("[ELEC MONITOR]AT_cmd transaction is correct");
			mon_2_Sboard_trans.transaction_type=AT_cmd;
			mon_2_Sboard_trans.read_write=recieved_transaction_data_symb[3][1];

			mon_2_Sboard_trans.crc_received[15:8] = {<<{recieved_transaction_data_symb[5][8:1]}}; //check crc on scoreboard
			mon_2_Sboard_trans.crc_received[7:0] = {<<{recieved_transaction_data_symb[4][8:1]}};
			mon_2_Sboard_trans.address = {<<{recieved_transaction_data_symb[2][8:1]}};
			mon_2_Sboard_trans.len = {<<{recieved_transaction_data_symb[3][8:2]}};
			mon_2_Sboard_trans.phase=3'd3;
			end 
			else
			$error("[ELEC MONITOR]AT_cmd transaction is not correct");
	end
	AT_rsp:begin
		if(q[0] =={<<{stop_bit,DLE,start_bit}} && q[$-1]=={<<{stop_bit,DLE,start_bit}}
			&& q[1]=={<<{stop_bit,STX_rsp,start_bit}} && q[$]=={<<{stop_bit,ETX,start_bit}})  //check the data later
			begin
			$display("[ELEC MONITOR]AT_rsp transaction is correct");
			mon_2_Sboard_trans.transaction_type=AT_rsp;
			mon_2_Sboard_trans.read_write=recieved_transaction_data_symb[3][1];

			mon_2_Sboard_trans.crc_received[15:8] = {<<{recieved_transaction_data_symb[8][8:1]}}; //check crc on scoreboard
			mon_2_Sboard_trans.crc_received[7:0] = {<<{recieved_transaction_data_symb[7][8:1]}};
			mon_2_Sboard_trans.address = {<<{recieved_transaction_data_symb[2][8:1]}};
			mon_2_Sboard_trans.len = {<<{recieved_transaction_data_symb[3][8:2]}};
			mon_2_Sboard_trans.phase=3'd3;  
			mon_2_Sboard_trans.cmd_rsp_data={{<<{q[6][8:1]}},{<<{q[5][8:1]}},{<<{q[4][8:1]}}};
			end
		else
			$error("[ELEC MONITOR]AT_rsp transaction is not correct");
	end
	endcase
    elec_mon_2_Sboard.put(mon_2_Sboard_trans);
	endtask:check_AT_transaction

//task to get the transport data
 task electrical_layer_monitor::get_transport_data(input GEN speed);
                    trans_to_ele_lane0.push_back(ELEC_vif.lane_0_rx);
					trans_to_ele_lane1.push_back(ELEC_vif.lane_1_tx);
					//@(posedge ELEC_vif.gen2_lane_clk)
					if(trans_to_ele_lane0.size()==8)
					begin
						foreach(trans_to_ele_lane0[i])
						begin
                        mon_2_Sboard_trans.transport_to_electrical[i]=trans_to_ele_lane0[i];
						end
						elec_mon_2_Sboard.put(mon_2_Sboard_trans);
						foreach(mon_2_Sboard_trans.transport_to_electrical[i])
						begin
                        mon_2_Sboard_trans.transport_to_electrical[i]=trans_to_ele_lane1[i];
						end
						elec_mon_2_Sboard.put(mon_2_Sboard_trans);
                        trans_to_ele_lane0.delete();
					    trans_to_ele_lane1.delete();
					end
 endtask:get_transport_data

       ////***run task***/////
  task electrical_layer_monitor::run();
     mon_2_Sboard_trans=new();
      
        fork 
          begin  //thread to monitor(sbtx high) 
		  forever 
		  begin
		  @(posedge ELEC_vif.sbtx)
		  //$display("[ELEC_MONITOR] CHECK ON SBRX AND ENABLE_RS AT PHASE 2"); active on simulation
	      wait (ELEC_vif.enable_rs==1'b0 && ELEC_vif.sbrx==1'b0) ;
          #10ns               //to make sure that the sbtx is high not pulse only(must wait 25us after the sbtx is high check the spec)
          if(ELEC_vif.sbtx==1'b1 && ELEC_vif.enable_rs==1'b0 && !ELEC_vif.sbrx)  //last condition in for do body at the second phase only 
		  begin
          ->sbtx_transition_high;  //to indicate to the sequance the sbtx is high "this on sequance ,the first line on the code of the sequance"
		  @(sbtx_response)  //wait for the response from the sequance
		  mon_2_Sboard_trans.phase=3'd0;
		  mon_2_Sboard_trans.sbtx =1'b1;
		  elec_mon_2_Sboard.put(mon_2_Sboard_trans);
		  end
          end
		  end

          begin  //thread to monitor (transaction and disconnect)
		  forever
		   begin
           wait(env_cfg_mem.data_income == 1)
		   env_cfg_mem.data_income=0;
			case (env_cfg_mem.phase)
			3'd2: //wait AT_Cmd transaction with size=8 symbols
			begin
				@(!ELEC_vif.sbtx)  //it will come with sb clk at first posedge clk
				//case
				while(1)begin
				@(negedge ELEC_vif.SB_clock);
				recieved_transaction_data_symb.push_back(ELEC_vif.sbtx);  //check the corectness of the data.......

              if(recieved_transaction_data_symb.size()==8 &&recieved_transaction_data_symb[7]=={<<{1'b1,ETX,1'b0}}) begin
				$display("[ELEC MONITOR]reiceved AT_cmd with size of AT 8 symbols");
			break;
			end
			else if(recieved_transaction_data_symb.size()>8)begin
     			  $error("[ELEC MONITOR]the size of AT transaction is more than 8 symbols");
			end
				end
               check_AT_transaction(recieved_transaction_data_symb,AT_cmd);
               

           end
          3'd3: //wait for order sets 
          begin
            case (env_cfg_mem.transaction_type)
              LT_fall: begin   //wait for LT fall reaction on the dut
                @(negedge ELEC_vif.sbtx)
				#(tDisconnectTx);
				if(!ELEC_vif.lane_0_tx && !ELEC_vif.lane_1_tx && !ELEC_vif.enable_rs)begin
				$display("[ELEC MONITOR] LT fall is correct");
				mon_2_Sboard_trans.sbtx='b0;
				mon_2_Sboard_trans.transport_to_electrical='b0;
				elec_mon_2_Sboard.put(mon_2_Sboard_trans); 
				end
				else
				$error("[ELEC MONITOR] LT fall is not correct");
              end
              AT_cmd: begin //wait AT response then os depend on generation
					@(!ELEC_vif.sbtx)  //it will come with sb clk at first posedge clk
					//case
					while(1)begin
					@(negedge ELEC_vif.SB_clock);
					recieved_transaction_data_symb.push_back(ELEC_vif.sbtx);  //check the corectness of the data.......

				if(recieved_transaction_data_symb.size()==11 &&recieved_transaction_data_symb[10]=={<<{1'b1,ETX,1'b0}}) begin
					$display("[ELEC MONITOR]reiceved AT_rsp with size of AT 11 symbols");
				break;
				end
				else if(recieved_transaction_data_symb.size()>11)begin
					$error("[ELEC MONITOR]the size of AT transaction is more than 11 symbols");
				end
					end
				check_AT_transaction(recieved_transaction_data_symb,AT_rsp);

			 case(env_cfg_mem.gen_speed)  //wait first type of os depend on generation
			  gen2:begin

				@(ELEC_vif.enable_rs);	
               recieved_SLOS1_gen23(gen2);  ///check after part_2 in all cases
			  end
			  gen3:begin
				@(ELEC_vif.enable_rs);	
               recieved_SLOS1_gen23(gen3);
					end
			  gen4:begin
				@(ELEC_vif.enable_rs);
				recieved_TS1_gen4();
				
					end
				endcase
              end
              AT_rsp: begin  //won't recieve any thing  
			end
			endcase
		  end
          3'd4: //wait os accourded to the transaction (last os another thread will recieve)
          begin
			case(env_cfg_mem.gen_speed)
			gen2:begin
				case(env_cfg_mem.o_sets)
				SLOS1:
				begin
				@(ELEC_vif.enable_rs);	
                recieved_SLOS2_gen23(gen2);
				end
				SLOS2:
				begin
					@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen2,TS1_gen2_3);
				end
				TS1_gen2_3:
				begin
					@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen2,TS2_gen2_3);
				end
				TS2_gen2_3:begin
					@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen2,TS2_gen2_3);   //need to modify like GEN4
				end
				
				endcase
			end
			    
			gen3:	begin
			 case(env_cfg_mem.o_sets)
				SLOS1:
				begin
				@(ELEC_vif.enable_rs);	
                 recieved_SLOS2_gen23(gen3);
				end
				SLOS2:
				begin
					@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen3,TS1_gen2_3);
				end
				TS1_gen2_3:
				begin
					@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen3,TS2_gen2_3);
				end
				TS2_gen2_3:begin
					@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen3,TS2_gen2_3);   //need to modify like GEN4
				end
				
				endcase
			end
			gen4:begin 
				case(env_cfg_mem.o_sets)
                  TS1_gen4:begin
					@(ELEC_vif.enable_rs)
					recieved_TS234_gen4(TS2_gen4,0); 
				  end
				  TS2_gen4:begin 
					@(ELEC_vif.enable_rs)
					recieved_TS234_gen4(TS3,0); 
				  end
				  TS3:begin 
					@(ELEC_vif.enable_rs)
					recieved_TS234_gen4(TS4,0); 
				  end
				  TS4:begin 
					@(ELEC_vif.enable_rs)
					recieved_TS234_gen4(TS4,1); 
				  end
			     endcase
				end
			endcase
		  end
		    
          3'd6: //case to disconnect
          begin
			@(negedge ELEC_vif.sbtx)
			#(tDisconnectTx);
			if(!ELEC_vif.sbtx && !ELEC_vif.lane_0_tx && !ELEC_vif.lane_1_tx && !ELEC_vif.enable_rs)
			begin
				$display("DISCONNECT IS SUCCEESS");
				mon_2_Sboard_trans.sbtx='b0;
                mon_2_Sboard_trans.transport_to_electrical='b0;
				elec_mon_2_Sboard.put(mon_2_Sboard_trans);
			end
			else	
			begin
				$display("DISCONNECT IS FAIL");
			end
          end
		  
          endcase 
		  end
          end
		  

          begin  //in case data sent from transport layer to electrical
		  @(ready_to_recieved_data)  //note forget to put it up
		  speed_mailbox.get(speed); 
		  while(ELEC_vif.sbtx)begin
          if(ELEC_vif.enable_rs) //defind event 
          begin
          case(speed)
            gen2: begin
                get_transport_data(speed);
                @(negedge ELEC_vif.gen2_lane_clk);
            end
            gen3: begin
                 get_transport_data(speed);
                @(negedge ELEC_vif.gen3_lane_clk);
            end
            gen4: begin
                 get_transport_data(speed);
                @(negedge ELEC_vif.gen4_lane_clk);
            end
          endcase
            
          
          end
		  end
		  end

        join
      
		 endtask

endpackage : electrical_layer_monitor_pkg




