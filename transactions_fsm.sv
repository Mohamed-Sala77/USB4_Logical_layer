/* 

Author: Ahmed Tarek Shafik Mohamed
Date: 20/2/2024
Block: Transactions FSM
Project: USB4 Logical layer Human based VS AI based code
sponsered by: Siemens EDA

Description:

- The following block is responsible of analyzing the SB transactions.

- The RTL design Team decided to implement feautures that depends mainly on AT and LT transactions.

- The Block takes sbrx input (as a byte) and starts registering the received symbols. if the CRC detects
no erros and symbols are received, registered and analyzed to the control unit as more clear commands as:

1) the address
2) read or write operation
3) the data
4) disconnect

- for more information please refer to the spec document.

*/


module transactions_fsm(

	input           sb_clk,
	input           rst,

	input [ 9 : 0 ] sbrx,
	input           error,

	input           tdisconnet,
	input           tconnect,



	output reg            t_valid,

	output reg            trans_error,

	output reg [ 23 : 0 ]  payload_in,
	output reg             s_read,s_write,
	output reg [ 7  : 0 ]  s_address,

	output reg             disconnect,

	output reg             crc_det_en

	);


//registers to ensure the output of the data at rising edge of the clock

reg valid_reg;

reg trans_error_reg;

reg [23:0] payload_in_reg;

reg s_read_reg,s_write_reg;



reg [7:0] read_write;


reg [7:0] s_address_reg;

reg disconnect_reg;



//systemverilog command for good visibility of the code state when debugging (synth.)

typedef enum logic [2:0] {

DISCONNECT='b000,

IDLE = 'b001,
DLE1 = 'b010,
AT = 'b011,
LT = 'b100,
DLE2 = 'b101

} state;


state cs,ns;



localparam DLE_SYMBOL = 8'hFE;
localparam STX_COMMAND_SYMBOL = 8'b00000101;
localparam STX_RESPONSE_SYMBOL = 8'b00000100;
localparam ETX_SYMBOL = 8'h40;


localparam LSE_SYMBOL = 8'b10000000;
localparam CLSE_SYMBOL = ~LSE_SYMBOL;


//maximum # of received data symbols =69

reg [6:0] max_data_counts; 

reg [3:0] des_count;



//registers to store the upcoming symbols in case of a success transmission


reg [7:0] storing_symbols [72];


assign read_write = storing_symbols[3];






/**********************************2 always blocks State Machine type ***********************************************************/


always @(posedge sb_clk or negedge rst) begin 
	if(~rst) begin
		cs <= DISCONNECT;
	end else begin
		cs <= ns ;
	end
end




always @(*) begin 

	case (cs)

		DISCONNECT: begin
			if (tconnect) begin
				ns = IDLE;
			end else begin
				ns=DISCONNECT; 
			end
		end


		IDLE: begin 
			if (sbrx [8:1] == DLE_SYMBOL && ~error) begin
				ns=DLE1;
			end else if (error) begin
				ns=IDLE;

			end else if (tdisconnet) begin

				ns=DISCONNECT;

			end else begin 
				ns=IDLE;
			end
		end


		DLE1: begin 

			if (error) begin
				ns=IDLE;

			end else if (tdisconnet) begin

				ns=DISCONNECT;

			end else begin

				case (sbrx [8:1])

					DLE_SYMBOL: ns=DLE1;

					STX_RESPONSE_SYMBOL: ns = AT;

					STX_COMMAND_SYMBOL: ns = AT;

					LSE_SYMBOL: ns=LT;

					default: ns=IDLE;

				endcase
			end
		end


		LT: begin 


			if (error) begin
				ns=IDLE;

			end else if (tdisconnet) begin

				ns=DISCONNECT;

			end else begin

				case (sbrx [8:1])

					DLE_SYMBOL: ns=DLE1;

					CLSE_SYMBOL: ns=IDLE;

					default: ns=LT;

				endcase
			end
		end


		AT: begin 


			if (error) begin
				ns=IDLE;

			end else if (tdisconnet) begin

				ns=DISCONNECT;

			end else begin

				case (sbrx [8:1])

					DLE_SYMBOL: ns= DLE2;

					default: begin 

						if (des_count == 0) begin

							if (max_data_counts < 69) begin

								ns = AT;

							end else begin 
								ns = IDLE;
							end
						end

					end
				endcase
			end
		end


		DLE2: begin 


			if (error) begin
				ns=IDLE;

			end else if (tdisconnet) begin

				ns=DISCONNECT;

			end else begin

				case (sbrx [8:1])

					ETX_SYMBOL: ns= IDLE;

					DLE_SYMBOL: ns= DLE2;


					STX_COMMAND_SYMBOL:ns= AT;


					STX_RESPONSE_SYMBOL:ns= AT;


					default : ns=DLE2;

				endcase

			end

		end

	endcase
end





always @(*) begin 


	case (cs)

		DISCONNECT: begin 

			valid_reg = 0;
			trans_error_reg = 0;
			payload_in_reg = 1;
			s_read_reg = 0;
			s_write_reg = 0;
			s_address_reg = 0;
			disconnect_reg = 1;
			crc_det_en = 0;
			trans_error_reg=0;

			if (tconnect) begin
				disconnect_reg=0;
			end

		end

		IDLE: begin 

			valid_reg = 0;
			trans_error_reg = 0;
			payload_in_reg = 1;
			s_read_reg = 0;
			s_write_reg = 0;
			s_address_reg = 0;
			disconnect_reg = 0;
			crc_det_en = 0;

			if (error) begin
				trans_error_reg=1;
			end else if (sbrx [8:1] == DLE_SYMBOL) begin
				storing_symbols[0] = sbrx [8:1];
				trans_error_reg=0;
				disconnect_reg=0;
				crc_det_en=1;
			end	if (tdisconnet) begin
				disconnect_reg=1;
			end

		end


		DLE1: begin 

			valid_reg = 0;
			disconnect_reg = 0;
			payload_in_reg=1;
			s_address_reg=0;
			crc_det_en = 1;


			if (error) begin
				trans_error_reg=1;
				crc_det_en = 0;
			end else begin

				trans_error_reg=0;

				case (sbrx [8:1])

					LSE_SYMBOL: begin 

						storing_symbols[1] = sbrx [8:1]; 
						crc_det_en = 0;


					end

					STX_RESPONSE_SYMBOL: begin

						storing_symbols[1] = sbrx [8:1]; 


					end

					STX_COMMAND_SYMBOL: begin 

						storing_symbols[1] = sbrx [8:1];

					end


				endcase
			end if (tdisconnet) begin
				disconnect_reg=1;
			end



		end

		LT: begin 

			valid_reg = 0;
			disconnect_reg = 0;
			crc_det_en = 0;

			if (error) begin
				trans_error_reg=1;
			end else begin

				trans_error_reg=0;


				case (sbrx [8:1])

					DLE_SYMBOL: begin 

						storing_symbols[1]=0;


					end

					CLSE_SYMBOL: begin 

						storing_symbols[2]=CLSE_SYMBOL;
						disconnect_reg = 1;

					end


				endcase
			end if (tdisconnet) begin
				disconnect_reg=1;
			end

		end


		AT: begin

			valid_reg = 0;
			disconnect_reg = 0;
			crc_det_en = 0;

			if (error) begin
				trans_error_reg=1;
			end else begin

				trans_error_reg=0;

				case (sbrx [8:1])

					DLE_SYMBOL: begin 
						storing_symbols [2+max_data_counts] = sbrx [8:1];
					end


					default : begin 

						if (max_data_counts < 69) begin
							storing_symbols[2+max_data_counts]=sbrx [8:1];
							if (max_data_counts > read_write[7:1] + 1) begin
								crc_det_en=0;
							end else begin
								crc_det_en=1;
							end  		
						end else begin storing_symbols[72]=0;
							crc_det_en=0;
						end

					end

				endcase

			end if (tdisconnet) begin
				disconnect_reg=1;
			end


		end

		DLE2: begin

			valid_reg = 0;
			disconnect_reg = 0;
			crc_det_en = 0;

			if (error) begin
				trans_error_reg=1;
			end else begin

				trans_error_reg=0;

				case (sbrx [8:1])

					ETX_SYMBOL: begin 
						storing_symbols[2+max_data_counts] =sbrx [8:1];
						valid_reg = 1;
					end

					DLE_SYMBOL: begin 

						if (max_data_counts < 69) begin
							storing_symbols[2+max_data_counts]=sbrx [8:1];
						end else begin 
							storing_symbols[72]=0;
						end

					end

					STX_COMMAND_SYMBOL: begin 

						storing_symbols[2]=sbrx [8:1];
						crc_det_en = 1;

					end

					STX_RESPONSE_SYMBOL: begin 

						storing_symbols[2]=sbrx [8:1];
						crc_det_en = 1;

					end

				endcase

			end if (tdisconnet) begin
				disconnect_reg=1;
			end


		end


	endcase

end


always @(*) begin

	s_address_reg = storing_symbols [2];

	payload_in_reg =  {storing_symbols[4],storing_symbols[5],storing_symbols[6]};

	if (storing_symbols[1] == STX_RESPONSE_SYMBOL) begin
		s_write_reg=0;
		s_read_reg=0;
	end else if (read_write[7]==1) begin
		s_write_reg=1;
		s_read_reg=0;
	end else if (read_write[7]==0) begin 
		s_write_reg=0;
		s_read_reg=1;
	end


end


always @ (posedge sb_clk or negedge rst) begin 
	if(~rst) begin
		max_data_counts <= 0;

	end else if ((cs == AT || cs == DLE2 ) && max_data_counts != 70) begin
		case (des_count)

			9: max_data_counts <= max_data_counts + 1;

			default : max_data_counts <= max_data_counts;
		endcase

	end else begin
		max_data_counts <= 0;

	end
end




always @ (posedge sb_clk or negedge rst) begin 
	if(~rst) begin
		des_count <= 0;

	end else if (cs == AT && des_count < 9 ) begin
		des_count <= des_count + 1 ;

	end else begin
		des_count <= 0;

	end
end





always @(posedge sb_clk) begin 

	t_valid <= valid_reg;

	trans_error <= trans_error_reg;

	payload_in <= payload_in_reg;

	s_read <= s_read_reg && valid_reg;

	s_write <= s_write_reg && valid_reg;

	s_address <= s_address_reg;

	disconnect <= disconnect_reg;

end

endmodule 
