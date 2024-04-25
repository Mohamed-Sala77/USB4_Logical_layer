`default_nettype none
module decoding_block (
    input wire enc_clk,
    input wire rst,
    input wire enable_dec,
    input wire [131:0] lane_0_rx_enc,
    input wire [131:0] lane_1_rx_enc,
    input wire [1:0] gen_speed,
    input wire [3:0] d_sel,
    output reg [7:0] lane_0_rx,
    output reg [7:0] lane_1_rx,
    output reg       data_os,
    output reg enable_deskew
);

// Define arrays to store decoded data
reg [7:0] mem_0 [15:0];
reg [7:0] mem_1 [15:0];

// Index of the current memory location
reg [3:0] mem_index;
//reg [3:0] d_sel_reg; // to save values when mem_index not 1
reg flag;
reg [3:0] max_byte_num;

integer i;

parameter GEN4 = 0;
parameter GEN2 = 2;
parameter GEN3 = 1;



always @(*) begin
    case (gen_speed)
        GEN4: max_byte_num = 0;
        GEN2: max_byte_num = 7;
        GEN3: max_byte_num = 15;
        default: max_byte_num = 1;
    endcase
end


always @(posedge enc_clk or negedge rst) begin
    if (~rst) begin
        // Reset condition: rst = 0
        lane_0_rx <= 0;
        lane_1_rx <= 0;
        enable_deskew <= 0;
        data_os <= 0;
        // Reset mem_index
        mem_index <= 0;
        flag <= 0;
        
    end else if(~enable_dec) begin

			enable_deskew <= 0;
			flag <= 0;
			lane_0_rx <= mem_0[mem_index];
			lane_1_rx <= mem_1[mem_index];

		end else begin
		
			lane_0_rx <= mem_0[mem_index];
			lane_1_rx <= mem_1[mem_index];
			
			if (mem_index == 0) begin
            flag <= 1;
        end else begin
            flag <= 0;
        end
        if (gen_speed == 0) begin
            enable_deskew <= flag;
        end else begin
            enable_deskew <= 1;
        end

			
        case (gen_speed)
            GEN4: begin // gen_speed = 4
            // Save lane_0_rx_enc as bytes in mem_0 locations from 0 to 15
            if (mem_index==0) begin
                    for (i = 0; i < 16; i = i + 1) begin
                        mem_0[i] <= lane_0_rx_enc[i*8 +: 8];
                         mem_1[i] <= lane_0_rx_enc[i*8 +: 8];
                    end
                  end
                
                if (d_sel == 8 ) begin
                    data_os <= 1;
                  end
                  else begin
                    data_os <= 0;
                  end
                    
                end

            GEN3: begin // gen_speed = 1
                if (mem_index == 15) begin
                    // Save lane_0_rx_enc as bytes in mem_0 locations from 0 to 15
                    for (i = 0; i < 16; i = i + 1) begin
                        mem_0[i] <= lane_0_rx_enc[i*8 +: 8];
                         mem_1[i] <= lane_0_rx_enc[i*8 +: 8];
                    end
                    if (mem_0[15][3:0] == 4'b1010) begin
                        // Ordered sets
                        data_os <= 0;
                    end else if (mem_0[15][3:0] == 4'b0101) begin
                        // Transport layer data
                        data_os <= 1;
                end
            end
            end
           GEN2: begin // gen_speed = 2
                if (mem_index == 7) begin
                    // Save lane_0_rx_enc as bytes in mem_0 locations from 0 to 7
                    for (i = 0; i < 8; i = i + 1) begin
                        mem_0[i] <= lane_0_rx_enc[i*8 +: 8];
                         mem_1[i] <= lane_0_rx_enc[i*8 +: 8];
                    end
                        if (mem_0[7][1:0] == 2'b10) begin
                        // Ordered sets
                        data_os <= 0;
                    end else if (mem_0[7][1:0] == 2'b01) begin
                        // Transport layer data
                        data_os <= 1;
                end
                end
                end
                endcase
            end
            end
    
 
// Update mem_index and d_sel based on conditions
always @(posedge enc_clk or negedge rst) begin
    if (~rst) begin
        mem_index <= max_byte_num;
    end else if (~enable_dec )   begin  
       mem_index <= max_byte_num;
   end else if (mem_index != max_byte_num) begin
			mem_index <= mem_index + 1;
		end else begin
			mem_index <= 0;
		end
	end

endmodule
`resetall	
