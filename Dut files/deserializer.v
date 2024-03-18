////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: deserializer
// Author: Seif Hamdy Fadda
//
// Description: deserialize the serial input into 8-bits output in the sideband
////////////////////////////////////////////////////////////////////////////////////////////////////////

module deserializer #(parameter WIDTH = 8) (

    input                  rst, clk,
	input                  in_bit, 
    output reg [WIDTH-1:0] parallel_data
); 
    reg        [WIDTH-1:0]        temp;
	localparam COUNTER_WIDTH =    $clog2(WIDTH);
    reg       [COUNTER_WIDTH-1:0] count;
	
	always @(posedge clk or negedge rst) begin
	    if (!rst) begin
            parallel_data <= 'b0;
			temp <= 'b0;
			count <= 'b0;
		end	
		else begin
			temp <= {in_bit, temp[WIDTH-1:1]};
			if (count == WIDTH-1) begin
			    count <= 0;
			    parallel_data <= temp;
			end	
			else begin	
			    count <= count + 1;
			end	
		end	
	end		
endmodule			

`default_nettype none
`resetall

