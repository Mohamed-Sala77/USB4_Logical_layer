interface upper_layer_if(input clk,
	
	input gen2_fsm_clk, 
	input gen3_fsm_clk,
	input gen4_fsm_clk,
 	input logic reset);

	//upper layer inputs signals
	logic [7:0] transport_layer_data_in;
	
	//upper layer Output signals
	logic [7:0] transport_layer_data_out;
	
     GEN gen_speed;
	//GEN generation_speed;
	logic [2:0] phase; 

endinterface: upper_layer_if


