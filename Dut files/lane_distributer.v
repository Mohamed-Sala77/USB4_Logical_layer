////////////////////////////////////////////////////////////////////////////////////
// Block: lane_distributer
//
// Author: Ahmed Zakaria
//
// Description: distributes data from data bus on both lanes 
//
/////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module lane_distributer 
(
  input  wire       clk_a, //faster clock
  input  wire       clk_b, //slower clock
  input  wire       rst, 
  input  wire       enable_t, //enable for transmitting side
  input  wire       enable_r, //enable for receiving side
  input  wire [7:0] data_in, //data input from data bus
  input  wire [7:0] lane_0_rx, 
  input  wire [7:0] lane_1_rx, 
  output reg  [7:0] lane_0_tx, 
  output reg  [7:0] lane_1_tx, 
  output reg  [7:0] data_out, //data output to data bus
  output reg        enable_enc, //enable encoder next stage
  output reg        rx_lanes_on //enable data bus rx side
);
 
reg flag;
reg started;
reg [7:0] data;
reg [3:0] counter;

always@(posedge clk_a or negedge rst)
  begin
	if (!rst) 
      begin
		flag <= 0;
		data_out <= 'h0;
		rx_lanes_on <= 0;
		counter <= 'h0;
	  end
	else if (!enable_r) 
      begin
		flag <= 0;
		data_out <= 'h0;
		rx_lanes_on <= 0;
		counter <= 'h0;
	  end
	else
	  begin
		flag <= (counter == 'h7)? !flag : flag;
		data_out <= (flag)? lane_1_rx : lane_0_rx; //data output to data bus
		rx_lanes_on <= 1;
		counter <= (counter == 'h7)? 'h0 : counter + 1;
	  end
  end

always@(posedge clk_b or negedge rst)
  begin
	if (!rst) 
      begin
		lane_1_tx <= 0;
		started <= 0;
		enable_enc <= 0;
	  end
	else if (!enable_t) 
      begin
		lane_1_tx <= 0;
		started <= 0;
		enable_enc <= 0;
	  end
	else
	  begin
		lane_1_tx <= data_in;
		started <= 1;
		enable_enc <= started;
	  end
  end
  
always@(negedge clk_b or negedge rst)
  begin
	if (!rst) 
      begin
	    lane_0_tx <= 0;
		data <= 0;
	  end
	else if (!enable_t) 
      begin
	    lane_0_tx <= 0;
		data <= 0;
	  end
	else
	  begin
	    lane_0_tx <= data;
		data <= data_in;
	  end
  end
		   
endmodule

`resetall