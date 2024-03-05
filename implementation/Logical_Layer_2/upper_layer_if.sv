interface upper_layer_if(input logic clk, input logic rx_clk, input logic reset);

	//upper layer inputs signals
	logic [7:0] transport_layer_data_in;
	
	//upper layer Output signals
	logic [7:0] transport_layer_data_out;

endinterface: upper_layer_if


