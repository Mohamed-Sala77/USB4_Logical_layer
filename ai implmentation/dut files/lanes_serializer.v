`default_nettype none

module lanes_serializer 
(
    input wire  clk,                    // Clock input
    input wire  rst,                  // Active low reset
    input wire  enable,                 // Enable signal for serialization
    input wire  [1:0] gen_speed,        // 2-bit input for generation speed
    input wire  [131:0] Lane_0_tx_in, // Parallel data input
    input wire  [131:0] Lane_1_tx_in, // Parallel data input
    output reg  Lane_0_tx_out,             // Serial data output
    output reg  Lane_1_tx_out,             // Serial data output
    output reg  enable_scr,                   // Ready signal, high when not serializing
    output wire scr_rst                    // Reset seed of scrambler in the following stage
);

    // Internal variables
    reg [131:0] shift_reg0;    // Shift register for the data being serialized
    reg [131:0] shift_reg1;    // Shift register for the data being serialized
    reg [7:0] counter; // Extended counter size for synchronization
    reg [7:0] max_count;                // Maximum count based on gen_speed

    always @(*) begin
        // Assign max_count based on gen_speed
        case (gen_speed)
            2'b00: max_count = 8;
            2'b01: max_count = 132;
            2'b10: max_count = 66;
            default: max_count = 8; // Default to gen_speed=2'b00
        endcase
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset logic
            shift_reg0 <= 0;
            shift_reg1 <= 0;
            counter <= 0;
            Lane_0_tx_out <= 1'b0;
            Lane_1_tx_out <= 1'b0;
            enable_scr <= 1'b0;
        end else if (enable) begin
            if (counter == 0) begin
                // Load new data into shift register every DATA_WIDTH cycles
                shift_reg0 <= Lane_0_tx_in;
                shift_reg1 <= Lane_1_tx_in;
		    Lane_0_tx_out <= Lane_0_tx_in[7];
		    Lane_1_tx_out <= Lane_1_tx_in[7];
                counter <= max_count-1;
                enable_scr <= 1'b1; //enable scrambler next stage
            end else begin
                // Serialize the data, shifting right each clock cycle
                shift_reg0 <= shift_reg0 >> 1;
                shift_reg1 <= shift_reg1 >> 1;
                Lane_0_tx_out <= shift_reg0[1]; // Output the next bit
                Lane_1_tx_out <= shift_reg1[1]; // Output the next bit
                counter <= counter - 1'b1;
                enable_scr <= 1; 
            end
        end else begin
            // When enable is low, reset the serializer
            shift_reg0 <= 0;
            shift_reg1 <= 0;
            counter <= 0;
            Lane_0_tx_out <= 1'b0;
            Lane_1_tx_out <= 1'b0;
            enable_scr <= 1'b0;
        end
    end
	
assign scr_rst = (counter == 0);

endmodule

`resetall
