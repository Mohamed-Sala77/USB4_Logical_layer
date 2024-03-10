		class upper_layer_tr;
		//Components
		rand var [7:0] T_Data;
		rand var [2:0] phase; // specifies current initialization phase 
		rand GEN gen_speed;
		//constraints


		//Copy Function
		virtual function upper_layer_tr copy();
 			copy = new();
 			copy.T_Data = T_Data; // Copy data fields
 		endfunction


	endclass : upper_layer_tr



