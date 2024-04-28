class upper_layer_tr;
//Components
rand var [7:0] T_Data;		//for model data for 0 -> 7
rand var [7:0] T_Data_1;	//for model  data for 8 -> 15
//rand var [127:0] T_Data;
rand var [2:0] phase; // specifies current initialization phase 
GEN gen_speed;

bit send_to_elec_enable; //to enable sending data to the electrical layer
bit enable_receive; // to enable the monitor of the UL to start receiving data from transport_data_out
//constraints

/*
//Copy Function
virtual function upper_layer_tr copy();
	 copy = new();
	 copy.T_Data = T_Data; // Copy data fields
 endfunction
*/

virtual function string convert2string();
return $sformatf("\nTransaction:   T_Data = %0h   ,\tT_Data_1 = %0h   ,\nphase = %0d   ,\tgen_speed = %s   ,\tsend_to_elec_enable = %0b   ,\tenable_receive = %0b  \n\n", 
	T_Data, T_Data_1, phase, gen_speed, send_to_elec_enable, enable_receive);
endfunction

endclass : upper_layer_tr



