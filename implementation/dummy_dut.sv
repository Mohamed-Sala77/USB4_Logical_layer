
module dummy_dut (

	input clk, rst,
	input [7:0] tansport_layer_data_in, c_data_in, lane_0_rx, lane_1_rx,
	input lane_disable, sbrx,
	output reg sbtx, c_read, c_write,
	output reg [7:0] tansport_layer_data_out, c_address, c_data_out, lane_0_tx, lane_1_tx 

	);




	typedef enum logic [2:0] {phase_1_cap, phase_1_gen, phase_2, phase_3, phase_4, phase_5} state;

	state current_state, next_state;


	always @ (posedge clk or negedge rst)
	begin
		if (!rst)
		begin
			current_state <= phase_1_cap;
		end

		else
		begin
			current_state <= next_state;

		end
	end


	//Output Calculations
	always @ (*)
	begin
		case (current_state)

			phase_1_cap: begin
				c_read = 'b1;
				c_address = 'd4;
			end

			phase_1_gen: begin
				c_read = 'b1;
				c_address = 'd5;
			end
			
			phase_2: begin
				if (sbrx == 1)
					sbtx = 1'b1;
				else
					sbtx = 1'b0;
			end


		endcase // current_state

	end


	//Next State Calculations
	always @ (*)
	begin
		case (current_state)

			phase_1_cap: begin

				if (c_data_in == 'h40)
					next_state = phase_1_gen;
				else
					next_state = phase_1_cap;			
			end
			

			phase_1_gen: begin
				
				if (c_data_in == 'h44)
					next_state = phase_2;
				else
					next_state = phase_1_gen;
			end

			phase_2: begin

				if (sbrx == 1)
					next_state = phase_3;
				else
					next_state = phase_2;

			end



		endcase // current_state




	end



endmodule : dummy_dut