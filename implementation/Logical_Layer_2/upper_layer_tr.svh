package upper_layer_tr_pkg;
	
	class upper_layer_tr;
		//Components
		rand var [7:0] T_Data;

		//constraints


		//Copy Function
		virtual function upper_layer_tr copy();
 			copy = new();
 			copy.T_Data = T_Data; // Copy data fields
 		endfunction
	endclass : upper_layer_tr
endpackage : upper_layer_tr_pkg



