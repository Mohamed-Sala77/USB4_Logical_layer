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
	parameter TS_GEN_4_HEADER_SIZE = 32;
	parameter TS16_SIZE = 7168; // Size of 16 back to back TS (448 * 16 = 7168)

	parameter PRBS11_SYMBOL_SIZE = 448; // Size of the PRBS11 symbol

  //timing parameters
  parameter tConnectRx = 25;        //min is 25us
  parameter tDisconnectRx = 1500;   //max is 1000us
  parameter	tDisconnectTx =	100000; //min is 50ms
 
	//Parameters for TS1 and TS2 symbols for Gen 2 and Gen 3
	parameter [7:0] lane_number_0 = 8'h00,
                  lane_number_1 = 8'h01; // To indicate the lane number (one for lane 0  and one for lane 1)
	parameter [5:0] TSID_TS1 = 6'b100110;  // To indicate TS1
	parameter [5:0] TSID_TS2 = 6'b011001;  // To indicate TS2
	parameter [9:0] SCR = 10'b0011110010;

  //Order sets TS1 and 2 for Gen 2 and 3
  //parameter   [63:0]      TS1_gen2_3_lane0= {5'd0,3'd1,lane_number_0,32'd0,TSID_TS1,SCR};//64'h01000000040098f2 ;//
  parameter   [63:0]      TS1_gen2_3_lane1=64'h01010000040098f2;// {5'd0,3'd1,lane_number_1,32'd0,TSID_TS1,SCR};////
  parameter   [63:0]      TS1_gen2_3_lane0=64'h01000000040098f2;
  parameter   [63:0]      TS2_gen2_3_lane0=64'h01000000040064f2 ;//{5'd0,3'd1,lane_number_0,32'd0,TSID_TS2,SCR};//64'h01000000040064f2 ;//
  parameter   [63:0]      TS2_gen2_3_lane1=64'h01010000040064f2 ;//{5'd0,3'd1,lane_number_1,32'd0,TSID_TS2,SCR};//64'h01010000040064f2;//

	//Parameters for TS symbols for Gen 4
  parameter        CURSOR = 12'h07E;
  parameter        indication_TS1=4'h4,
                   indication_TS2=4'h2,
                   indication_TS3=4'h6;
  parameter        indication_TS4=8'h0f;
                  
  parameter        counter_TS1=8'hf0,   //check on sending the counter value from zakaria
                   counter_TS2=8'hf0,
                   counter_TS3=8'hf0;
  parameter        counter_TS4=4'hf;


   //Order sets TS1&2 for Gen4
  /*parameter [27:0] ts2_gen4={4'd0,counter_TS2,~(indication_TS2),indication_TS2,CURSOR};
  parameter [27:0] ts3_gen4={4'd0,counter_TS3,~(indication_TS3),indication_TS3,CURSOR};*/

   
	// Seeds for the Pseudo Random Sequences
	parameter [10:0] PRBS11_lane0_seed =11'b11111111111;
	parameter [10:0] PRBS11_lane1_seed =11'b11101110000;
	parameter [10:0] PRBS11_lanes_seed =11'h400;


///-------------------------///
//Order sets TS1,2,3,4 for Gen4
parameter [27:0]  HEADER_TS1_GEN4={counter_TS1,~(indication_TS1),indication_TS1,CURSOR};
parameter 		  HEADER_TS2_GEN4={4'd0,counter_TS2,~(indication_TS2),indication_TS2,CURSOR};
parameter 		  HEADER_TS3_GEN4={4'd0,counter_TS3,~(indication_TS3),indication_TS3,CURSOR};
parameter 		  HEADER_TS4_GEN4={4'd0,~(counter_TS4),counter_TS4,indication_TS4,CURSOR};

///------------------------///
//parameters
parameter No_TS_GEN4 =16;
int       PRBS_SLOS_SIZE=2058;
parameter NO_SLOS_SYNC_GEN3=16,
          NO_SLOS_SYNC_GEN2=32;


parameter data_width =8 ;