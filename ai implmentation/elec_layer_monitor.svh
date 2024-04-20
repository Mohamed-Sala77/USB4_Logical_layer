//logic TS2_gen4; // Add this line to define TS2_gen4
////////////////////////****monitor package****//////////////////////////////
`timescale 1us/1ns
package electrical_layer_monitor_pkg;

	import electrical_layer_transaction_pkg::*;
	import env_cfg_class_pkg::*;                    //import the env_cfg_class package
    import electrical_layer_driver_pkg::parent;

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
		 extern task check_AT_transaction(input  [9:0] q[$]);
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

//PRBS11_SYMBOL_SIZE
//TS16_SIZE
//Generate 16TS OS
//HEADER_TS1_GEN4
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
////////////
////covert from packed to unpacked////
/*foreach(TS1_total_lane0[i,j])
begin
unp_TS1_total_lane0[i]=TS1_total_lane0[i][j];
unp_TS1_total_lane1[i]=TS1_total_lane1[i][j];
end*/
/////////////////////////////////////

repeat(TS16_SIZE) //collect the TS1 from the two lanes
 begin 
  recieved_TS1_lane0.push_back(ELEC_vif.lane_0_rx);
  recieved_TS1_lane1.push_back(ELEC_vif.lane_1_rx);
  @(negedge ELEC_vif.gen4_lane_clk);
  if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
        begin
		   $display("the value of ELEC_vif.sbtx is %0d during send TS1 GEN4",ELEC_vif.sbtx);
		   break;
		end
 end

    //$display("the value of recieved_TS1_gen4 is %0p",recieved_SLOS1_lane0);
	$display("the size of recieved_TS1_gen4 on lane0 is %0d and must be 3584 on lane 0",recieved_TS1_lane0.size());
/*
repeat(TS16_SIZE)	//collect the TS1 from the two lanes
begin	
if((i%2)==0)
begin
TS1_total_recieved[i]=recieved_TS1_lane0[(i/2)];
end
else
begin
TS1_total_recieved[i]=recieved_TS1_lane1[(i/2)];
end
i++;
end

foreach(TS1_total_recieved[i,j]) //convert to packet 
P_TS1[i+j]=TS1_total_recieved[i][j];
*/



if(TS1_total_lane0==recieved_TS1_lane0 && TS1_total_lane1==recieved_TS1_lane1)
begin
$display("TS1 is correct on gen4");
-> correct_OS;   //do that on all first OS on each gen
end
else	
$error("TS1 is not correct on gen2");
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
		   $display("the value of ELEC_vif.sbtx is %0d during send slos1 for GEN2",ELEC_vif.sbtx);
		   break;
		end
	end
	$display("the value of recieved_SLOS1_lane0 is %0p for GEN2",recieved_SLOS1_lane0);
	$display("the size of recieved_SLOS1_lane0 is %0d for GEN2",recieved_SLOS1_lane0.size());
	end
	else if(speed==gen3)
	begin
	repeat(2*SLOS_SIZE)	//collect the SLOS from the two lanes
	begin
	recieved_SLOS1_lane0.push_back(ELEC_vif.lane_0_rx);
	recieved_SLOS1_lane1.push_back(ELEC_vif.lane_1_rx);
	@(negedge ELEC_vif.gen3_lane_clk);
	if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)begin
		$display("the value of ELEC_vif.sbtx is %0d during send slos1 for for GEN3",ELEC_vif.sbtx);
		break;
	end
	end
	$display("the value of recieved_SLOS1_lane0 is %0p for GEN3",recieved_SLOS1_lane0);
	$display("the size of recieved_SLOS1_lane0 is %0d  for GEN3",recieved_SLOS1_lane0.size());
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
		end
		else	
		$error("SLOS1 is not correct on gen2");
		end
	gen3:begin 
			if(P_SLOS1_lane0==({2{SLOS2_128_1}}) && P_SLOS1_lane1==({2{SLOS2_128_1}}))
		begin
		$display("SLOS1 is correct on gen3");
		-> correct_OS;   //do that on all first OS on each gen
		end
		else	
		$error("SLOS1 is not correct on gen3");
	end
	endcase
	endtask:recieved_SLOS1_gen23

	//task to check the AT transaction
	task electrical_layer_monitor::check_AT_transaction(input  [9:0] q[$]);
	if(q[1]=={stop_bit,DLE,start_bit} && q[$-1]=={stop_bit,DLE,start_bit}
			&& q[1]=={stop_bit,STX_cmd,start_bit} &&q[$]=={stop_bit,ETX,start_bit})  //check the data later
			$display("AT transaction is correct");
			else
			$error("at transaction is not correct");
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

//run task
  task electrical_layer_monitor::run();
     mon_2_Sboard_trans=new();
      
        fork 
          begin  //thread to monitor(sbtx high)
		  forever 
		  begin
		  @(posedge ELEC_vif.sbtx)
	      wait (ELEC_vif.enable_rs==1'b0 && ELEC_vif.sbrx==1'b0) ;
          #10ns               //to make sure that the sbtx is high not pulse only
          if(ELEC_vif.sbtx==1'b1 && ELEC_vif.enable_rs==1'b0 && !ELEC_vif.sbrx)  //last condition in for do body at the second phase only 
		  begin
          ->sbtx_transition_high;  //to indicate to the sequance the sbtx is high "check on sboard"
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
			3'd2: //wait AT transaction with size=8 symbols
			begin
				@(!ELEC_vif.sbtx)  //it will come with sb clk at first posedge clk
				//case
				while(1)begin
				@(negedge ELEC_vif.SB_clock);
				recieved_transaction_data_symb.push_back(ELEC_vif.sbtx);  //check the corectness of the data.......

            if(recieved_transaction_data_symb.size()==8)
			  if(^recieved_transaction_data_symb[7]==1'b1 && recieved_transaction_data_symb[7]=={1'b1,ETX,1'b0})
			break;
			else if(recieved_transaction_data_symb.size()>8)
     			  $error("the size of AT transaction is more than 8 symbols");
			end
               check_AT_transaction(recieved_transaction_data_symb);
               mon_2_Sboard_trans.crc_received[15:8]=recieved_transaction_data_symb[5][8:1]; //check crc on scoreboard
			   mon_2_Sboard_trans.crc_received[7:0]=recieved_transaction_data_symb[4][8:1];
			   elec_mon_2_Sboard.put(mon_2_Sboard_trans);

           end
          3'd3: //wait for order sets 
          begin
            case (env_cfg_mem.transaction_type)
              LT_fall: begin   //wait for LT fall reaction on the dut
                @(!ELEC_vif.sbtx)
				if(!ELEC_vif.lane_0_tx && !ELEC_vif.lane_1_tx && !ELEC_vif.enable_rs)begin
				$display("[ELEC MONITOR] LT fall is correct");
				mon_2_Sboard_trans.sbtx='b0;
				elec_mon_2_Sboard.put(mon_2_Sboard_trans); 
				end
				else
				$error("[ELEC MONITOR] LT fall is not correct");
              end
              AT_cmd: begin //wait AT response
                
              end
              AT_rsp: begin  //  wait first type of os depend on generation 
			  case(env_cfg_mem.gen_speed)
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




