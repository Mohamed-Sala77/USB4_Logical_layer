////////////////////////////////////////////////////////////////////////////////////
// Block: lane_distributer
//
// Author: Ahmed Zakaria
//
// Description: distributes data from data bus on both lanes 
//
/////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module lane_distributer_try 
(
  input  wire       clk_a, //faster clock
  input  wire       clk_b, //slower clock
  input  wire       rst, 
  input  wire       enable_t, //enable for transmitting side
  input  wire       enable_r, //enable for receiving side
  input  wire [3:0] d_sel, 
  input  wire [7:0] lane_0_tx_in, //data input from data bus
  input  wire [7:0] lane_1_tx_in, //data input from data bus
  input  wire [7:0] lane_0_rx_in, 
  input  wire [7:0] lane_1_rx_in, 
  output wire [7:0] lane_0_tx_out, 
  output wire [7:0] lane_1_tx_out, 
  output reg  [7:0] lane_0_rx_out, //data output to data bus
  output reg  [7:0] lane_1_rx_out, //data output to data bus
  output reg        enable_enc, //enable encoder next stage
  output reg        rx_lanes_on //enable data bus rx side
);
 
reg flag;
reg started;
reg [7:0] data;
reg [2:0] counter;
reg [7:0] lane_0_tx_out_reg; 
reg [7:0] lane_1_tx_out_reg; 

always@(posedge clk_a or negedge rst)
  begin
	if (!rst) 
      begin
		flag <= 0;
		lane_0_rx_out <= 'h0;
		lane_1_rx_out <= 'h0;
		rx_lanes_on <= 0;
		counter <= 'h0;
	  end
	else if (!enable_r) 
      begin
		flag <= 0;
		lane_0_rx_out <= 'h0;
		lane_1_rx_out <= 'h0;
		rx_lanes_on <= 0;
		counter <= 'h0;
	  end
	else if (d_sel != 'h8) 
      begin
		flag <= 0;
		lane_0_rx_out <= lane_0_rx_in;
		lane_1_rx_out <= lane_1_rx_in;
		rx_lanes_on <= 1;
		counter <= 'h0;
	  end
	else
	  begin
		flag <= (counter == 'h4)? !flag : flag;
		lane_0_rx_out <= (flag)? lane_1_rx_in : lane_0_rx_in; //data output to data bus
		lane_1_rx_out <= 'h0;
		rx_lanes_on <= 1;
		counter <= (counter == 'h4)? 'h0 : counter + 1;
	  end
  end

always@(posedge clk_b or negedge rst)
  begin
	if (!rst) 
      begin
		lane_1_tx_out_reg <= 0;
		started <= 0;
		enable_enc <= 0;
	  end
	else if (!enable_t) 
      begin
		lane_1_tx_out_reg <= 0;
		started <= 0;
		enable_enc <= 0;
	  end
	else
	  begin
		lane_1_tx_out_reg <= lane_0_tx_in;
		started <= 1;
		enable_enc <= started;
	  end
  end
  
always@(negedge clk_b or negedge rst)
  begin
	if (!rst) 
      begin
	    lane_0_tx_out_reg <= 0;
		data <= 0;
	  end
	else if (!enable_t) 
      begin
	    lane_0_tx_out_reg <= 0;
		data <= 0;
	  end
	else
	  begin
	    lane_0_tx_out_reg <= data;
		data <= lane_0_tx_in;
	  end
  end
		

always@ (*)
  begin
    if(!rst)
	  begin
	    lane_0_tx_out = 0;
	    lane_1_tx_out = 0;
	  end
    else if(d_sel != 'h8) //for ordered sets
	  begin
	    lane_0_tx_out = lane_0_tx_in;
	    lane_1_tx_out = lane_1_tx_in;
	  end
    else //for transport layer data
	  begin
	    lane_0_tx_out = lane_0_tx_out_reg;
	    lane_1_tx_out = lane_1_tx_out_reg;
	  end
  end
		
endmodule

`resetall