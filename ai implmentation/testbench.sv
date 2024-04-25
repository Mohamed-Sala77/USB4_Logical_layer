//include the transaction classes
`include "elec_layer_tr.svh"
`include "config_space_pkg.sv"
`include "upper_layer_tr.svh"

//include the memory classes
`include "env_cfg_class.sv"

//include the generator classes
`include "elec_layer_generator.svh"
`include "up_stimulus_generator.sv"
`include "config_generator.sv"

//include the driver classes
`include "elec_layer_driver.svh"
`include "config _driver.sv"
`include "up_driver.sv"

//include the monitor classes
`include "elec_layer_monitor.svh"
`include "up_monitor.sv"
`include "config_monitor.sv"

//include the agent classes
`include "elec_layer_agent.svh"
`include "up_agent.sv"
`include "config_agent.sv"

//include the scoreboard classes
`include "elec_layer_scoreboard.svh"
`include "up_scoreboard.sv"
`include "config_scoreboard.sv"

//include the virtual sequence classes
`include "virtual_sequence.sv"

//include the test environment classes
`include "Testenv.svh"


//include innterfaces
`include "config_space_if.sv"
`include "upper_layer_if.sv"
`include "electrical_layer_if.sv"





