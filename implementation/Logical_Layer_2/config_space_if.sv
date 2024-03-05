

interface config_space_if (input clk);

	logic lane_disable;
	logic [7:0] c_data_in;

	logic c_read, c_write;
	logic [7:0] c_address, c_data_out;
	
endinterface : config_space_if
