module crc_16(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire active,
    input wire data_in,
    output reg crc_out
    );

reg [15:0] crc_reg;
reg [3:0] cnt;
wire feedback;

assign feedback = crc_reg[15] ^ data_in;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        crc_reg <= 16'hFFFF;
        cnt <= 4'b0;
    end else if (enable) begin
        cnt <= (cnt == 9)? 0 : cnt + 1;
		if (!active && cnt !=0 && cnt!=9) begin // Normal CRC Calculation Mode
            crc_reg <= {crc_reg[14:0], feedback};
            crc_reg[2] <= crc_reg[1] ^ feedback;
            crc_reg[15] <= crc_reg[14] ^ feedback;
        end else if (active && cnt!=0 && cnt!=9) begin // Output CRC bits serially
            crc_reg <= {crc_reg[14:0], 1'b0};
        end
    end else begin
	    crc_reg <= 16'hFFFF;
		cnt <= 4'b0;
	end
end

always @(*) begin
    if (active && cnt==0) begin
        crc_out = 1'b0;
    end else if (active && cnt==9) begin
        crc_out = 1'b1;
	end else if (active) begin
	    crc_out = crc_reg[15]; 
	end else begin
	    crc_out <= 1'b0;
	end
end

endmodule

`default_nettype none
`resetall