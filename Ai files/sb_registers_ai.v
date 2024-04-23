`default_nettype none

module sb_registers (
	input wire s_read_o_s_write_0,
	input wire [7:0] s_address_o,
	input wire [7:0] s_data_o,
	output reg [23:0] sb_read,
	input wire sb_clk,
	input wire rst
	);

  reg [7:0] sb_memory [0:156]; // 8-bit wide and 157 in depth register file
  wire [23:0] link_configuration; // Internal register for link configuration

  
  assign link_configuration = {sb_memory[80], sb_memory[79],sb_memory[78]};

  always @(posedge sb_clk or negedge rst) begin
  	if (~rst) begin

  		sb_memory[78] <= 8'b00000011;
  		sb_memory[79] <= 8'b00110011;
  		sb_memory[80] <= 8'b00000101;
  		sb_memory[85] <= 8'b0;
  		sb_memory[86] <= 8'b0;
  		sb_memory[87] <= 8'b11000000;
  		sb_memory[88] <= 8'b11000000;
      sb_read <= 24'b0; // Reset to zero

  end else begin
      if (s_read_o_s_write_0) begin // Read operation
      	sb_read <= link_configuration;
      end else begin // Write operation
      	sb_memory[s_address_o] <= s_data_o;
	sb_read <= sb_read;
      end
  end
end

endmodule

