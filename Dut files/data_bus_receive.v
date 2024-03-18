//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block: data bus reciever
//Author: Seif Hamdy Fadda
//
//Description: the data bus reciever is used in detecting the different ordered sets of gen3 and gen4 and sending the control fsm 
// a signal indicating the type of the ordered set, it also forowards the transport layer data to the transport layer.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module data_bus_receive #(parameter SEED = 11'b10000000000)(

    input            rst, fsm_clk, data_os,
    input      [7:0] lane_0_rx,
	input      [3:0] d_sel,
	output reg [7:0] transport_layer_data_out,
	output reg [3:0] os_in
	
);  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg        lane_0_rx_ser;
    reg [10:0] temp_prbs_slos1,temp_prbs_slos2;   //prbs11 temps                           
	reg [63:0] temp_pipo_64;
    reg [31:0] temp_pipo_32;	
    reg [7:0]  temp_piso;   // parallel in series out 
    reg        piso_busy;	
	reg [11:0] count_prbs_slos1,count_prbs_slos2;// prbs11 counters
	reg [3:0]  count_sipo,count_piso;
	reg [63:0] ts1_lane0 = 64'h01010000000064F2;  //0000000100000001000000000000000000000000000000000110010011110010
	reg [63:0] ts2_lane0 = 64'h01000000000064F2;  //0000000100000000000000000000000000000000000000000110010011110010 
	reg [31:0] ts1_head = 32'h7E02D0F0;
    reg [31:0] ts2_head = 32'h7E04B0F0;
    reg [31:0] ts3_head = 32'h7E0690F0;
    reg [31:0] ts4_head = 32'h7E0F0F00;
	reg        error_prbs_slos1;
	reg        error_prbs_slos2;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
    always @ (posedge fsm_clk or negedge rst) begin     // reseting values to default values
        if (!rst) begin
            temp_prbs_slos1 <= SEED; temp_prbs_slos2 <= SEED; 
		    temp_pipo_64 <= 64'b0;
		    temp_pipo_32 <= 32'b0;
			temp_piso <= 8'b00000000;
			count_prbs_slos1 <= 'b0; count_prbs_slos2 <= 'b0; 
            count_sipo <= 'b0;
			count_piso <= 'b0;
			os_in <= 4'h9;
			lane_0_rx_ser <= 1'b0;
			piso_busy <= 1'b0;
			error_prbs_slos1 <= 1'b0;
			error_prbs_slos2 <= 1'b0;
			transport_layer_data_out <= 8'b0;
        end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        else if ( data_os == 1'b1 & d_sel == 4'h8 ) begin // transport layer data forowarding
		    transport_layer_data_out <= lane_0_rx;
			os_in <= 4'h8;
		end	
		    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	    else begin //ordered sets detecting
		    lane_0_rx_ser <= temp_piso[7];                                  //serializer
            temp_piso <= (piso_busy)? {temp_piso[6:0],1'b0} : lane_0_rx;
            piso_busy = (!(count_piso == 7));
                if (count_piso == 7) begin
				    if (error_prbs_slos1 == 1'b1) begin
					    temp_prbs_slos1 <= SEED;
						count_prbs_slos1 <= 'b0;
						error_prbs_slos1 <= 1'b0;
					end	
                    if (error_prbs_slos2 == 1'b1) begin
					    temp_prbs_slos2 <= SEED;
						count_prbs_slos2 <= 'b0;
						error_prbs_slos2 <= 1'b0;
					end	
                end
			count_piso <= (piso_busy)? count_piso+1 : 1'b0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////            
			temp_pipo_64 <= {temp_pipo_64[62:0],lane_0_rx_ser};            //deserializer to detect gen3 ts1 and ts2 
		    
            			
            if (count_sipo== 2 ) begin
                    if (temp_pipo_64 == ts1_lane0 ) begin
				    os_in <= 4'h2;
					count_sipo <=1;
				    end	
				    else if (temp_pipo_64 == ts2_lane0) begin
                        os_in  <= 4'h3;
					    count_sipo <=1;
				    end	
				    else begin 
                       //os_in  <= 4'h9;
                       count_sipo <=1;					
				    end    
			end
			else begin
			    count_sipo <= count_sipo+1'b1;
			end	
//////////////////////////////////////////////////////////////////////////////////////////			
            if (count_prbs_slos1 != 2048 ) begin                                               // detecting slos1
			    if (count_prbs_slos1 == 1'b0) begin
				    if(lane_0_rx_ser == 0) begin
						count_prbs_slos1 <= count_prbs_slos1 +1;
						if (count_prbs_slos2 != 2047  & count_sipo != 2 ) begin // to prevent sending os_in = 4'h9 before checking other ordered sets at this clock cycle 
						    os_in <= 4'h9;
						end	
					end
					else begin
						count_prbs_slos1 <= 'b0;
						if (count_prbs_slos2 !=2047 & count_sipo != 2 ) begin
						    os_in <= 4'h9;
						end
					end
				end	
			    else if(lane_0_rx_ser == temp_prbs_slos1[0])begin
					temp_prbs_slos1 <= {temp_prbs_slos1[9:0],temp_prbs_slos1[10]^temp_prbs_slos1[8]};
				    count_prbs_slos1 <= count_prbs_slos1 +1;
					    if (count_prbs_slos1 == 2047) begin
				                os_in <=4'h0;
					            count_prbs_slos1 <= 'b0;
				        end
                        else begin
                           if (count_prbs_slos2 !=2047  & count_sipo != 2 ) begin
						    os_in <= 4'h9;
						   end
                        end	
				end		
				else begin
					count_prbs_slos1 <= 'b0;
					temp_prbs_slos1 <= SEED;
					error_prbs_slos1 <= 1'b1;
					if (count_prbs_slos2 != 2047 & count_sipo != 2 ) begin
						    os_in <= 4'h9;
					end
 			    end
			end
///////////////////////////////////////////////////////////////////////////////////////////////////////			
			if (count_prbs_slos2 != 2048 ) begin      // detect slos2
			    if (count_prbs_slos2 == 1'b0) begin
				    if(lane_0_rx_ser == 1) begin
						count_prbs_slos2 <= count_prbs_slos2 +1;
						if (count_prbs_slos1 !=2047  & count_sipo != 2 ) begin
						    os_in <= 4'h9;
						end
					end
					else begin
						count_prbs_slos2 <= 'b0;
						if (count_prbs_slos1 !=2047  & count_sipo != 2 ) begin
						    os_in <= 4'h9;
						end
					end
				end	
			    else if(lane_0_rx_ser == ~temp_prbs_slos2[0])begin
					temp_prbs_slos2 <= {temp_prbs_slos2[9:0],temp_prbs_slos2[10]^temp_prbs_slos2[8]};
				    count_prbs_slos2 <= count_prbs_slos2 +1;
					if (count_prbs_slos2 == 2047) begin
				        os_in <=4'h1;
					    count_prbs_slos2 <= 'b0;
				    end
                    else begin
                        if (count_prbs_slos1 !=2047  & count_sipo != 2 ) begin
						os_in <= 4'h9;
						end
                    end	
				end		
				else begin
					error_prbs_slos2 <= 1'b1;
					count_prbs_slos2 <= 'b0;
					temp_prbs_slos2 <= SEED;
					if (count_prbs_slos1 !=2047 &    count_sipo != 2) begin
						os_in <= 4'h9;
					end
 			    end
			end	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            temp_pipo_32 <= {temp_pipo_32[30:0],lane_0_rx_ser};            //deserializer to detect gen4 ts1, ts2, ts3, ts4 
            			
            if (count_sipo== 2 ) begin
                    if (temp_pipo_32 == ts1_head ) begin
				    os_in <= 4'h4;
					count_sipo <=1;
				    end	
				    else if (temp_pipo_32 == ts2_head) begin
                        os_in  <= 4'h5;
					    count_sipo <=1;
				    end
				    else if (temp_pipo_32 == ts3_head) begin
                        os_in  <= 4'h6;
					    count_sipo <=1;
				    end
                    else if (temp_pipo_32 == ts4_head) begin
                        os_in  <= 4'h7;
					    count_sipo <=1;
				    end					
				    else begin 
                       //os_in  <= 4'h9;
                       count_sipo <=1;					
				    end    
			end
			else begin
			    count_sipo <= count_sipo+1'b1;
			end    
            	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////				 
   		end
	end
endmodule
`default_nettype none
`resetall	