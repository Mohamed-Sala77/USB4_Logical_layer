module prbs11_rec_g4 #(parameter lane0_lane1 = 1)
(
    input clk,
    input reset,
    input enable,
    input data_in,
    output reg os_rec
);

wire [10:0] seed;
reg [10:0] reg_val;
reg [8:0] counter;
reg error_check_en;
reg round_started;
reg error;
reg flag;
wire correct_val;
wire is_seed;

assign seed = (lane0_lane1)? 11'h7ff : 11'h770;
assign is_seed = (reg_val == seed);
assign correct_val = reg_val[10];

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        reg_val <= seed;
        round_started <= 0;
        os_rec <= 0;
        error <= 1;
        counter <= 0;
        error_check_en <= 0;
        flag <= 0;
    end else begin
        if (enable) begin
            if (is_seed && !round_started) begin //while receiving the last bit in the previous slos 
                round_started <= 1;
				reg_val <= seed;
				counter <= 0;
				error_check_en <= 0;
				error <= 0;
            end else begin
                reg_val <= {reg_val[9:0], (reg_val[10] ^ reg_val[8])};
				os_rec <= (counter == 0 && !error && flag);
				counter <= (counter == 9'h1bf)? 0 : counter + 1;
				flag = 1;
				if (counter == 'h1bf) begin
                    error_check_en <= 0;
				end else if (counter == 27) begin
                    error_check_en <= 1;
				end else begin
				    error_check_en <= error_check_en;
				end
				if (data_in != correct_val && error_check_en) begin
                    error <= 1;
				end else if (counter == 0) begin
				    error <= 0;
				end
            end
        end else begin //if not enabled
            reg_val <= seed;
            round_started <= 0;
            os_rec <= 0;
            error <= 1;
            error_check_en <= 1;
            counter <= 0;
            flag <= 0;
        end
    end
end

endmodule

`default_nettype none
`resetall