package virtual_sequence_pkg;


	// importing generators
	import elec_generator_pkg::*;
	import UL_generator_pkg::*;
	import config_space_stimulus_generator_pkg::*;

	// importing transactions
	import elec_layer_tr_pkg::*;
	

	class virtual_sequence;

		// Virtual Stimulus generators
		config_space_stimulus_generator v_config_space_stim;
		elec_layer_generator v_elec_layer_generator;
		upper_layer_generator v_upper_layer_generator;


		//Basic Flow 1
		task run;

			// Phase 1
			$display("[Virtual Sequence] Phase 1");
			v_elec_layer_generator.phase1_force();
			v_config_space_stim.execute("capability");
			v_config_space_stim.execute("generation");
			

			$display(" \n \n//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("  ⁂⁂⁂⁂⁂⁂ ------ phase 1 done ---- ⁂⁂⁂⁂⁂⁂  ") ;
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////\n \n");


			// Phase 2
			$display("[Virtual Sequence] Phase 2");
			v_elec_layer_generator.sbrx_high();


			$display(" \n \n//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("  ⁂⁂⁂⁂⁂⁂ ------ phase 2 done ---- ⁂⁂⁂⁂⁂⁂  ") ;
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////\n \n");



			// Phase 3
			$display("[Virtual Sequence] Phase 3: AT_cmd");
			v_elec_layer_generator.send_transaction(AT_cmd,3,0,8'h0A,7'hF,24'h000001); // testing AT command 
			//v_elec_layer_generator.sbrx_high(); // For Dubugging only until DUT is integrated


			//$display("[Virtual Sequence] Phase 3: LT_fall");
			//v_elec_layer_generator.send_transaction(LT_fall);  // Testing LT Fall 
			//v_elec_layer_generator.sbrx_high(); // For Dubugging only until DUT is integrated


			$display("[Virtual Sequence] Phase 3: AT_rsp");
			v_elec_layer_generator.send_transaction(AT_rsp,3,1,8'h0B,7'h3,24'h123456); // testing AT response 
			//v_elec_layer_generator.sbrx_high(); // For Dubugging only until DUT is integrated


			// @(EVENTT) from monitor after receiving AT CMND to respond with AT_rsp to continue phase 3
			//v_elec_layer_generator.send_transaction(AT_rsp,3,);




			$display(" \n \n//////////////////////////////////////");
			$display("//////////////////////////////////////");
			$display("//////////////////////////////////////");
			$display("  ⁂⁂⁂⁂⁂⁂ ------ phase 3 done ---- ⁂⁂⁂⁂⁂⁂  ") ;
			$display("//////////////////////////////////////");
			$display("//////////////////////////////////////\n \n");

			// Phase 4
			$display("[Virtual Sequence] Phase 4");
			v_elec_layer_generator.send_ordered_sets(TS1_gen4,gen4);

			//send responce order sets 
			$display("[Virtual Sequence] Phase 4: Sending TS1 ordered set for Gen 4");
			v_elec_layer_generator.send_ordered_sets(TS1_gen4,gen4);

			$display("[Virtual Sequence] Phase 4: Sending TS2 ordered set for Gen 4");
			v_elec_layer_generator.send_ordered_sets(TS2_gen4,gen4);

			$display("[Virtual Sequence] Phase 4: Sending TS3 ordered set for Gen 4");
			v_elec_layer_generator.send_ordered_sets(TS3,gen4);

			$display("[Virtual Sequence] Phase 4: Sending TS4 ordered set for Gen 4");
			v_elec_layer_generator.send_ordered_sets(TS4,gen4);



			$display(" \n \n//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("  ⁂⁂⁂⁂⁂⁂ ------ phase 4 done ---- ⁂⁂⁂⁂⁂⁂  ") ;
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////\n \n");



			//v_elec_layer_generator.send_ordered_sets(SLOS1,gen2);
			//$error("ALIIIIIIIIIIIIIII");
			//v_elec_layer_generator.sbrx_high(); // For Dubugging only until DUT is integrated


			//v_elec_layer_generator.sbrx_high(); 


			//v_elec_layer_generator.send_ordered_sets(/*OS*/,/*generation*///);
			//v_elec_layer_generator.send_ordered_sets(/*OS*/,/*generation*/);

		
			//Phase 5
			 //fork join for electrical_to_transport layer data and vice versa
			$display("[Virtual Sequence] Phase 5");
			v_upper_layer_generator.run();

			  $display(" \n \n//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("  ⁂⁂⁂⁂⁂⁂ ------ phase 5 done ---- ⁂⁂⁂⁂⁂⁂  ") ;
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////\n \n");
			
			// disable

		endtask : run


	endclass : virtual_sequence


endpackage : virtual_sequence_pkg
