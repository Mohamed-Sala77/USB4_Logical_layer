	class virtual_sequence;

		// Virtual Stimulus generators
		config_space_stimulus_generator v_config_space_stim;
		elec_layer_generator v_elec_layer_generator;
		upper_layer_generator v_upper_layer_generator;


		//Basic Flow 1 for gen 4
		task run;
			parameter [63:0] freq_40 = 40 * 10 ** 9;			//40 GHz

			/*repeat (5)
			begin
				//fork 

					v_upper_layer_generator.send_transport_data(gen4);
			end*/
			// v_upper_layer_generator.send_transport_data(gen4);
			// v_upper_layer_generator.send_transport_data(gen4);
			// v_upper_layer_generator.send_transport_data(gen4);
			// v_upper_layer_generator.send_transport_data(gen4);
			// v_upper_layer_generator.send_transport_data(gen4);

			// v_elec_layer_generator.send_ordered_sets(SLOS1,gen2);
			//v_elec_layer_generator.send_ordered_sets(SLOS1,gen3);
			// v_elec_layer_generator.send_ordered_sets(SLOS2,gen2);
			// v_elec_layer_generator.send_ordered_sets(SLOS2,gen3);

			/*v_elec_layer_generator.send_ordered_sets(TS1_gen2_3,gen2);
			v_elec_layer_generator.send_ordered_sets(TS1_gen2_3,gen3);
			v_elec_layer_generator.send_ordered_sets(TS2_gen2_3,gen2);
			v_elec_layer_generator.send_ordered_sets(TS2_gen2_3,gen3);


			$stop;*/
			
			//Phase 1
			v_elec_layer_generator.phase_force(1);
			
			v_config_space_stim.execute;

			//Phase 2
			v_elec_layer_generator.sbrx_high("Host");

			//$stop;

			// Phase 3
			v_elec_layer_generator.phase_force(3);

			v_elec_layer_generator.send_transaction(AT_rsp,3,0,8'd78,7'd3,24'h053303);  
			

			v_elec_layer_generator.send_transaction(AT_cmd,3,0,8'd78,7'd3,24'h000000); 

			//$stop;


			
			// v_elec_layer_generator.send_transaction(LT_fall);  // Testing LT Fall 

			
			// // Phase 4

			// v_elec_layer_generator.send_ordered_sets(SLOS1,gen2);
			// v_elec_layer_generator.send_ordered_sets(SLOS1,gen2);
			// v_elec_layer_generator.send_ordered_sets(SLOS1,gen3);
			// v_elec_layer_generator.send_ordered_sets(SLOS2,gen2);
			// v_elec_layer_generator.send_ordered_sets(SLOS2,gen3);

			// v_elec_layer_generator.send_ordered_sets(TS1_gen2_3,gen2);
			// v_elec_layer_generator.send_ordered_sets(TS2_gen2_3,gen3);


			v_elec_layer_generator.phase_force(4, gen4);
			//v_elec_layer_generator.phase_force(4);
			v_elec_layer_generator.send_ordered_sets(TS1_gen4,gen4);

			//v_elec_layer_generator.send_ordered_sets(TS1_gen4,gen4);

			v_elec_layer_generator.send_ordered_sets(TS2_gen4,gen4);
			
			v_elec_layer_generator.send_ordered_sets(TS3,gen4);
			//#(tTrainingError); //To test tTrainingError
			v_elec_layer_generator.send_ordered_sets(TS4,gen4);
		
	
			
			// Phase 5
			// fork join for electrical_to_transport layer data and vice versa
			//v_elec_layer_generator.phase_force(5);

			#((10**15)/freq_40);

			fork 
				begin
					repeat (5)
						v_upper_layer_generator.send_transport_data(gen4);
				end

				begin
					//repeat (5)
						v_elec_layer_generator.elec_phase_5_read_control (gen4, "enable");		
				end

			join

			v_elec_layer_generator.elec_phase_5_read_control (gen4, "disable");		

			fork
				begin
					repeat(10)
						v_elec_layer_generator.send_to_transport_layer(gen4);

				end

				begin
					v_upper_layer_generator.start_receiving(gen4);
				end

			join

			v_upper_layer_generator.disable_monitor();


			//v_elec_layer_generator.send_to_transport_layer(gen4);


			/*
			repeat (5)
			begin
				//fork 

					v_upper_layer_generator.send_transport_data(gen4);
					v_elec_layer_generator.elec_read_enable_phase_5 (gen4);

				//join

			end
			*/
			//disable
			$stop();

		endtask : run





		//Basic Flow 1 for gen 3
		task normal_scenario_gen_3;
			parameter [63:0] freq_40 = 40 * 10 ** 9;			//40 GHz
			parameter [63:0] freq_20 = 64'd20 * 10 ** 9;		//20 GHz

			
			
			//Phase 1
			v_elec_layer_generator.phase_force(1);
			
			v_config_space_stim.execute;

			//Phase 2
			v_elec_layer_generator.sbrx_high("Host");

			//$stop;

			// Phase 3
			v_elec_layer_generator.phase_force(3);

			v_elec_layer_generator.send_transaction(AT_rsp,3,0,8'd78,7'd3,24'h013303);  
			

			v_elec_layer_generator.send_transaction(AT_cmd,3,0,8'd78,7'd3,24'h000000); 

			//$stop;


			
			// v_elec_layer_generator.send_transaction(LT_fall);  // Testing LT Fall 

			
			// // Phase 4

			// v_elec_layer_generator.send_ordered_sets(SLOS1,gen2);
			// v_elec_layer_generator.send_ordered_sets(SLOS1,gen2);
			// v_elec_layer_generator.send_ordered_sets(SLOS1,gen3);
			// v_elec_layer_generator.send_ordered_sets(SLOS2,gen2);
			// v_elec_layer_generator.send_ordered_sets(SLOS2,gen3);

			// v_elec_layer_generator.send_ordered_sets(TS1_gen2_3,gen2);
			// v_elec_layer_generator.send_ordered_sets(TS2_gen2_3,gen3);


			v_elec_layer_generator.phase_force(4, gen3);

			
			v_elec_layer_generator.send_ordered_sets(SLOS1,gen3);
			v_elec_layer_generator.send_ordered_sets(SLOS2,gen3);
			

			v_elec_layer_generator.send_ordered_sets(TS1_gen2_3,gen3);
			v_elec_layer_generator.send_ordered_sets(TS2_gen2_3,gen3);

			//v_elec_layer_generator.phase_force(4);
			// v_elec_layer_generator.send_ordered_sets(TS1_gen4,gen4);

			// //v_elec_layer_generator.send_ordered_sets(TS1_gen4,gen4);

			// v_elec_layer_generator.send_ordered_sets(TS2_gen4,gen4);
			
			// v_elec_layer_generator.send_ordered_sets(TS3,gen4);
			// //#(tTrainingError); //To test tTrainingError
			// v_elec_layer_generator.send_ordered_sets(TS4,gen4);
		
	
			
			// Phase 5
			// fork join for electrical_to_transport layer data and vice versa
			//v_elec_layer_generator.phase_force(5);

			#((10**15)/freq_20);

			fork 
				begin
					repeat (5)
						v_upper_layer_generator.send_transport_data(gen3);
				end

				begin
					//repeat (5)
						v_elec_layer_generator.elec_phase_5_read_control (gen3, "enable");		
				end

			join

			v_elec_layer_generator.elec_phase_5_read_control (gen3, "disable");		

			fork
				begin
					repeat(10)
						v_elec_layer_generator.send_to_transport_layer(gen3);

				end

				begin
					v_upper_layer_generator.start_receiving(gen3);
				end

			join

			v_upper_layer_generator.disable_monitor();


			//v_elec_layer_generator.send_to_transport_layer(gen4);


			/*
			repeat (5)
			begin
				//fork 

					v_upper_layer_generator.send_transport_data(gen4);
					v_elec_layer_generator.elec_read_enable_phase_5 (gen4);

				//join

			end
			*/
			//disable
			$stop();

		endtask : normal_scenario_gen_3


	endclass : virtual_sequence
