
interface electrical_layer_if(input clk);

	// elec layer inputs signals
	logic sbrx;
	logic lane_0_rx;
	logic lane_1_rx;

	// elec layer Output signals
	logic sbtx;
	logic lane_0_tx;
	logic lane_1_tx;

endinterface : electrical_layer_if
