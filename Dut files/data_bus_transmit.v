/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block: data_bus_transmit
//Author: Seif Hamdy Fadda
//
//Description: the data bus transmit waits for a d_select signal coming from the control fsm indicating the type of ordered set to be
// sent and then send it through the lane_0_tx, after sending the ordered set it sends the control fsm a signal indicating that the 
// ordered set has been sent successfully, it also forwards the transport layer data coming from transport layer. 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module data_bus_transmit #(parameter SEED = 11'b10000000000)(

    input             rst, fsm_clk,
	input      [7:0]  transport_layer_data_in,
    input      [3:0]  d_sel,
	output reg [7:0]  lane_0_tx,
	output reg        os_sent,
	output reg        tx_lanes_on
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	reg [10:0] temp_prbs;
	reg [7:0]  temp_sipo;  // series in parallel out 
	reg [7:0]  temp_pipo0; 
	reg        prbs_en_slos1, prbs_en_slos2; //to enable prbs11 
	reg [3:0]  count_sipo;  
	reg [6:0]  count_pipo_64;
	reg [5:0]  count_pipo_32;
	reg [5:0]  count_pipo_32_ts4;
	reg [3:0]  count_ts4; // to update the ts4 header after sending each ts4
	reg [11:0] count_prbs; //prbs11 counter
	reg [3:0]  count_delay;
	reg [63:0] ts1_lane0 = 64'h01010000000064F2;  //0000000100000001000000000000000000000000000000000110010011110010
	reg [63:0] ts2_lane0 = 64'h01000000000064F2;  //0000000100000000000000000000000000000000000000000110010011110010 
	reg [31:0] ts1_head = 32'h7E02D0F0;
    reg [31:0] ts2_head = 32'h7E04B0F0;
    reg [31:0] ts3_head = 32'h7E0690F0;
    reg [31:0] ts4_head = 32'h7E0F01E0;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
    always @ (posedge fsm_clk or negedge rst) begin //reset to default values
        if (!rst) begin
			temp_prbs <= SEED;
		    temp_sipo <= 8'b00000000;
			temp_pipo0 <= 8'b0;
			count_prbs <= 'b0;
            count_sipo <= 'b0;
			count_pipo_64 <= 64;
			count_pipo_32 <= 32;
			count_pipo_32_ts4 <= 32;
			count_ts4 <= 'b0;
            prbs_en_slos1 <= 1'b0; prbs_en_slos2 <= 1'b0;
			lane_0_tx <= 8'b0;
			os_sent <= 1'b0;
			tx_lanes_on <= 1'b0;
        end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h0) begin // send slos1
			if (prbs_en_slos1 == 1'b1) begin //to enable prbs11
			    if(count_prbs != 'b100000000000) begin
				    count_prbs <= count_prbs +1;
				    temp_sipo <= {temp_sipo [6:0], temp_prbs[0]};
				    temp_prbs <= {temp_prbs [9:0],temp_prbs[10]^temp_prbs[8]}; //prbs11 
				    if (count_sipo != 'b1000) begin //output 8-bits
				        count_sipo <= count_sipo + 1'b1;
					    //lane_0_tx <= 8'b0;
					end
					else begin
					    count_sipo <= 1;
					    lane_0_tx <= temp_sipo;
					end
					if(count_sipo != 7) begin
					    tx_lanes_on <= 1'b1;
					end
				os_sent <= 1'b0;	
				end		
				else begin
				    os_sent <= 1'b1;
				    //lane_0_tx <= 8'b0;
				    prbs_en_slos1 <= 1'b0;
					count_ts4 <= 'b0;
				end
			end
			else begin
			    os_sent <= 1'b0;
			    prbs_en_slos1 <= 1'b1;
			    temp_sipo <= 8'b00000000; //
			    count_sipo <= 'b1;
			    count_prbs <= 'b0;
			    temp_prbs <= SEED;
			end	
		end	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h1) begin //send slos2
			if (prbs_en_slos2 == 1'b1) begin
			    if(count_prbs != 'b100000000000) begin
				    count_prbs <= count_prbs +1;
				    temp_sipo <= {temp_sipo [6:0], ~temp_prbs[0]};
				    temp_prbs <= {temp_prbs[9:0],temp_prbs[10]^temp_prbs[8]}; //prbs11
				    if (count_sipo != 'b1000) begin
				        count_sipo <= count_sipo + 1'b1;
					    //lane_0_tx <= 8'b0;
					end
					else begin
					    count_sipo <= 1;
					    lane_0_tx <= temp_sipo;
					end	
				os_sent <= 1'b0;	
				end				
				else begin
				    os_sent <= 1'b1;
					//lane_0_tx <= 8'b0;
				    prbs_en_slos2 <= 1'b0;
					count_ts4 <= 'b0;
					
				end
			end
			else begin
			    prbs_en_slos2 <= 1'b1;
			    temp_sipo <= 8'b00000001;
				os_sent <= 1'b0;
			    count_sipo <= 'b1;
			    count_prbs <= 'b0;
			    temp_prbs <= SEED;
			end
		end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h2) begin //send gen3 ts1
		    
		    temp_pipo0 <= {temp_pipo0[6:0], ts1_lane0[count_pipo_64-1]};
			if (count_pipo_64 != 0 & count_pipo_64 != 8 & count_pipo_64 != 16 & count_pipo_64 != 24 & 
			count_pipo_64 != 32 & count_pipo_64 != 40 & count_pipo_64 != 48 & count_pipo_64 != 56) begin  //output 8-bits
			    count_pipo_64 <= count_pipo_64 - 1;
				//lane_0_tx <= 0;
				os_sent <= 1'b0;
			end	
			else begin	
			    lane_0_tx <= temp_pipo0;
				if (count_pipo_64 == 0) begin 
			    	os_sent <= 1'b1;
					count_pipo_64 <= 64;
					count_pipo_32 <= 32;
					count_pipo_32_ts4 <= 32;
					temp_pipo0 <=0;
					count_ts4 <= 'b0;
				end	
				else begin
                    count_pipo_64 <= count_pipo_64 - 1;
					os_sent <= 1'b0;
				end	
			end
		end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h3) begin //send gen3 ts2
		    temp_pipo0 <= {temp_pipo0[6:0], ts2_lane0[count_pipo_64-1]};
			if (count_pipo_64 != 0 & count_pipo_64 != 8 & count_pipo_64 != 16 & 
			count_pipo_64 != 24 & count_pipo_64 != 32 & count_pipo_64 != 40 & count_pipo_64 != 48 & count_pipo_64 != 56) begin //output 8-bits
			    count_pipo_64 <= count_pipo_64 - 1;
				//lane_0_tx <= 0;
				os_sent <= 1'b0;
			end	
			else begin	
			    lane_0_tx <= temp_pipo0;
				if (count_pipo_64 == 0) begin
			    	os_sent <= 1'b1;
					count_pipo_64 <= 64;
					count_pipo_32 <= 32;
					count_pipo_32_ts4 <= 32;
					temp_pipo0 <=0;
					count_ts4 <= 'b0;
				end	
				else begin
                    count_pipo_64 <= count_pipo_64 - 1;
					os_sent <= 1'b0;
				end	
			end
		end	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h4) begin //send gen4 ts1
		    temp_pipo0 <= {temp_pipo0[6:0], ts1_head[count_pipo_32-1]};
			if (count_pipo_32 != 0 & count_pipo_32 != 8 & count_pipo_32 != 16 & count_pipo_32 != 24) begin //output 8-bits
			    count_pipo_32 <= count_pipo_32 - 1;
				//lane_0_tx <= 0;
				os_sent <= 1'b0;
			end	
			else begin	
			    lane_0_tx <= temp_pipo0;
				if (count_pipo_32 == 0) begin
			    	os_sent <= 1'b1;
					count_pipo_32 <= 32;
					count_pipo_32_ts4 <= 32;
					count_pipo_64 <= 64;
					temp_pipo0 <=0;
					count_ts4 <= 'b0;
				end	
				else begin
                    count_pipo_32 <= count_pipo_32 - 1;
					os_sent <= 1'b0;
				end	
			end
		end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h5) begin //send gen4 ts2
		    temp_pipo0 <= {temp_pipo0[6:0], ts2_head[count_pipo_32-1]};
			if (count_pipo_32 != 0 & count_pipo_32 != 8 & count_pipo_32 != 16 & count_pipo_32 != 24) begin //output 8-bits
			    count_pipo_32 <= count_pipo_32 - 1;
				//lane_0_tx <= 0;
				os_sent <= 1'b0;
			end	
			else begin	
			    lane_0_tx <= temp_pipo0;
				if (count_pipo_32 == 0) begin
			    	os_sent <= 1'b1;
					count_pipo_32 <= 32;
					count_pipo_32_ts4 <= 32;
					count_pipo_64 <= 64;
					temp_pipo0 <=0;
					count_ts4 <= 'b0;
				end	
				else begin
                    count_pipo_32 <= count_pipo_32 - 1;
					os_sent <= 1'b0;
				end	
			end
		end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h6) begin //send gen4 ts3
		    temp_pipo0 <= {temp_pipo0[6:0], ts3_head[count_pipo_32-1]};
			if (count_pipo_32 != 0 & count_pipo_32 != 8 & count_pipo_32 != 16 & count_pipo_32 != 24) begin //output 8-bits
			    count_pipo_32 <= count_pipo_32 - 1;
				//lane_0_tx <= 0;
				os_sent <= 1'b0;
			end	
			else begin	
			    lane_0_tx <= temp_pipo0;
				if (count_pipo_32 == 0) begin
			    	os_sent <= 1'b1;
					count_pipo_32 <= 32;
					count_pipo_32_ts4 <= 32;
					count_pipo_64 <= 64;
					temp_pipo0 <=0;
					count_ts4 <= 'b0;
				end	
				else begin
                    count_pipo_32 <= count_pipo_32 - 1;
					os_sent <= 1'b0;
				end	
			end
		end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h7) begin // send ts4
		    
            if (count_ts4 == 1) begin // to update the header
                ts4_head <= 32'h7E0F02D0;
			end
            else if (count_ts4 == 2) begin
                ts4_head <= 32'h7E0F03C0;
			end
			else if (count_ts4 == 3) begin
                ts4_head <= 32'h7E0F04B0;
			end
			else if (count_ts4 == 4) begin
                ts4_head <= 32'h7E0F05A0;
			end
			else if (count_ts4 == 5) begin
                ts4_head <= 32'h7E0F0690;
			end
			else if (count_ts4 == 6) begin
                ts4_head <= 32'h7E0F0780;
			end
			else if (count_ts4 == 7) begin
                ts4_head <= 32'h7E0F0870;
			end
			else if (count_ts4 == 8) begin
                ts4_head <= 32'h7E0F0960;
			end
			else if (count_ts4 == 9) begin
                ts4_head <= 32'h7E0F0A50;
			end
			else if (count_ts4 == 10) begin
                ts4_head <= 32'h7E0F0B40;
			end
			else if (count_ts4 == 11) begin
                ts4_head <= 32'h7E0F0C30;
			end
			else if (count_ts4 == 12) begin
                ts4_head <= 32'h7E0F0D20;
			end
			else if (count_ts4 == 13) begin
                ts4_head <= 32'h7E0F0E10;
			end
			else if (count_ts4 == 14) begin
                ts4_head <= 32'h7E0F0F00;
			end
            else begin
                count_ts4 <= 'b0;
				ts4_head <= 32'h7E0F01E0;
			end
		
		    temp_pipo0 <= {temp_pipo0[6:0], ts4_head[count_pipo_32_ts4-1]};
			if (count_pipo_32_ts4 != 0 & count_pipo_32_ts4 != 8 & count_pipo_32_ts4 != 16 & count_pipo_32_ts4 != 24) begin //output 8-bits
			    count_pipo_32_ts4 <= count_pipo_32_ts4 - 1;
				//lane_0_tx <= 0;
				os_sent <= 1'b0;
			end	
			else begin	
			    lane_0_tx <= temp_pipo0;
				if (count_pipo_32_ts4 == 0) begin
			    	os_sent <= 1'b1;
					count_pipo_32 <= 32;
					count_pipo_32_ts4 <= 32;
					count_pipo_64 <= 64;
					temp_pipo0 <=0;
					count_ts4 <= count_ts4 +1'b1;
				end	
				else begin
                    count_pipo_32_ts4 <= count_pipo_32_ts4 - 1;
					os_sent <= 1'b0;
				end	
			end
		end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		else if (d_sel == 4'h8) begin //transport layer data
		lane_0_tx <= transport_layer_data_in;
		os_sent <= 1'b0;	
		end	
	    else begin
			temp_prbs <= SEED;
            count_prbs <= 'b0;
		    temp_sipo <= 8'b00000000;
            count_sipo <= 'b0;
		    prbs_en_slos1 <= 1'b0;
			prbs_en_slos2 <= 1'b0;
			lane_0_tx <= 8'b0;
            os_sent <= 1'b0;
			count_ts4 <= 'b0;
			count_pipo_64 <= 64;
			count_pipo_32 <= 32;
		end	
    end

endmodule
`default_nettype none
`resetall	
		    
                			
    