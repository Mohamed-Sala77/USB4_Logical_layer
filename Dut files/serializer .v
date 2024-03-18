////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: serializer
// Author: Seif Hamdy Fadda
//
// Description: serialize the parallel input (8-bits) in the sideband 
////////////////////////////////////////////////////////////////////////////////////////////////////////

module serializer #(parameter WIDTH = 8)
(
    input                  clk, rst,
    input      [WIDTH-1:0] parallel_in,
    output reg             ser_out
);
    reg [WIDTH-1:0] temp;
    wire            done;
	localparam      COUNTER_WIDTH = $clog2(WIDTH);
    reg        [COUNTER_WIDTH-1:0] count;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ser_out <= 1'b0;
            temp <= 'b0;
            count <= 'b0;
        end
        else begin
            ser_out <= temp[0];
            temp <= (done)? parallel_in : {1'b0, temp[WIDTH-1:1]};
			count <= (done)? 1'b0 : count+1;
        end
    end
	
assign done = (count == WIDTH-1);

endmodule

`default_nettype none
`resetall
