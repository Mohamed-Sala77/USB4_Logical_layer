package env_pkg;
	
	import UL_agent_pkg::*;
	import UL_scoreboard_pkg::*;
	import upper_layer_tr_pkg::*;

	import elec_agent_pkg::*;
	import elec_scoreboard_pkg::*;
	import elec_layer_tr_pkg::*;

	import config_space_pkg::*;
	import config_space_agent_pkg::*;
	import config_space_scoreboard_pkg::*;
	import config_space_stimulus_generator_pkg::*;

	import virtual_sequence_pkg::*;

	import ref_model_pkg::*;


	class Testenv;
		//interfaces
		virtual upper_layer_if v_if;
		virtual electrical_layer_if elec_v_if;
		virtual config_space_if v_cif;

		//Reference Model
		ref_model ref_model_inst ;

		// Agents
		upper_layer_agent agent_UL;
		elec_layer_agent agent_elec;
		config_space_agent agent_config;

		//Scoreboards
		upper_layer_scoreboard UL_sb;
		elec_layer_scoreboard elec_sb;
		config_space_scoreboard sb_config;

		//Virtual Sequence
		virtual_sequence vseq_config;

		// Mailboxes 
		mailbox #(upper_layer_tr) UL_mon_scr; // connects monitor to the scoreboard
		mailbox #(upper_layer_tr) UL_mod_scr; // connects reference model to the scoreboard
		mailbox #(upper_layer_tr) UL_gen_mod; // connects stimulus generator to the reference model

		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		mailbox #(elec_layer_tr) elec_mod_scr; // connects reference model to the scoreboard
		mailbox #(elec_layer_tr) elec_gen_mod; // connects stimulus generator to the reference model

		mailbox #(config_transaction) config_mon_scr ; // connects monitor to the scoreboard
		mailbox #(config_transaction) config_model_scr; // connects reference model to the scoreboard
		mailbox #(config_transaction) config_stim_model; // connects stimulus generator to the reference model



		// NEW Function
		function new(input virtual upper_layer_if v_if, input virtual electrical_layer_if elec_v_if, input virtual config_space_if v_cif);
			this.v_if = v_if;
			this.elec_v_if = elec_v_if;
			this.v_cif = v_cif;
		endfunction : new


		// Build phase
		function void build();

			// mailbox Handles
			UL_mon_scr = new();
			UL_mod_scr = new();
			UL_gen_mod = new();

			elec_mon_scr = new();
			elec_mod_scr = new();
			elec_gen_mod = new();

			config_mon_scr = new();
			config_model_scr = new();
			config_stim_model = new();

			// Reference model
    		ref_model_inst = new(config_stim_model, config_model_scr, elec_gen_mod, elec_mod_scr, UL_gen_mod, UL_mod_scr);


			// Agents
			agent_UL = new (v_if, UL_mon_scr, UL_gen_mod);
			agent_elec = new (elec_v_if, elec_mon_scr, elec_gen_mod);
			agent_config = new (v_cif, config_stim_model, config_mon_scr);
			agent_config.build();

			// Scoreboards
			UL_sb = new(UL_mon_scr, UL_mod_scr);
			elec_sb = new(elec_mon_scr, elec_mod_scr);
			sb_config = new(config_model_scr, config_mon_scr);

			// Virtual Sequence connections
			vseq_config = new();
			vseq_config.v_config_space_stim = agent_config.stimulus_gen; // configuration space Stimulus generator connection
			vseq_config.v_upper_layer_generator = agent_UL.UL_gen; // upper layer stimulus generator connection
			vseq_config.v_elec_layer_generator = agent_elec.elec_gen; // electrical layer stimulus generator connection

		endfunction : build

		// Agents' Run phase
		task run();
			fork

				// Upper layer run phase
				agent_UL.run();
				UL_sb.run();

				// Electrical layer run phase
				agent_elec.run();
				elec_sb.run();

				// configuration space run phase
				agent_config.run();
				sb_config.run();

				// Virtual Sequence run phase
				vseq_config.run();

				//Reference model
				ref_model_inst.run_phase();

			join
		endtask : run

	endclass : Testenv
endpackage : env_pkg
