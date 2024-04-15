package env_cfg_class_pkg;
class env_cfg_class;
typedef enum logic [2:0] {None = 3'b00, LT_fall, AT_cmd, AT_rsp, LT_fall_wrong, AT_cmd_wrong, AT_rsp_wrong} tr_type;
typedef enum logic [1:0] {gen2, gen3, gen4} GEN; // indicates the generation
typedef enum logic [3:0] {SLOS1 = 4'b1000, SLOS2, TS1_gen2_3, TS2_gen2_3, TS1_gen4, TS2_gen4, TS3, TS4} OS_type;

bit [2:0] phase;
OS_type o_sets; 
GEN gen_speed;
tr_type transaction_type;
endclass
endpackage: env_cfg_class_pkg
