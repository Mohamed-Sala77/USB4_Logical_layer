///////////////////////****driver package****//////////////////////////////
package electrical_layer_driver_pkg;
  import electrical_layer_transaction_pkg::*;
 
 class electrical_layer_driver;
  // Class properties and methods go here
    
    
    
    
    
    
    task automatic CALC_CRC(input bit [7:0] STX, input bit [7:0] data_symb[$], output bit [15:0] CRC_out);
    bit [15:0] crc; // Initial value
    bit [15:0] poly; // Polynomial (CRC-16)
    bit [15:0] data;
    int i;
    bit [7:0] crc_high, crc_low;
    // Reverse each byte of the CRC output
    bit [7:0] crc_high_rev;
    bit [7:0] crc_low_rev;

    crc = 16'hFFFF;
    poly = 16'h8005;

    // Include STX in CRC calculation
    data_symb.push_front(STX);

    // Calculate CRC
    for(i=0; i<data_symb.size(); i++) begin
      data = {8'b0, data_symb[i]};
      for(int j = 0; j < 16; j++) begin
        if((data[j] ^ crc[15]) == 1'b1) begin
          crc = crc << 1;
          crc = crc ^ poly;
        end else begin
          crc = crc << 1;
        end
      end
    end

    // Assign crc to {crc_high, crc_low}
  
    {crc_high, crc_low} = crc;



    for(i = 0; i < 8; i++) begin
      crc_high_rev[i] = crc_high[7-i];
      crc_low_rev[i] = crc_low[7-i];
    end

    CRC_out = {crc_high_rev, crc_low_rev};
  endtask


  task run();
    // Add your code here
  endtask

  endclass

endpackage : electrical_layer_driver_pkg


/*// Testbench
module CRC_Test;

  bit [7:0] STX = 8'h05;
  bit [7:0] data_symb[] = '{8'h01, 8'h0a};
  bit [15:0] CRC_out;

  initial begin
    CALC_CRC(STX, data_symb, CRC_out);
    $display("CRC_out = %h", CRC_out);
  end



endmodule*/