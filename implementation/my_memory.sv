package my_memory;

class mem;
bit [2:0]   gen ;
bit [2:0]   gen_config ;
bit usb4;  // represent  the type of data that i should send to the scoreboard
                                    // 1 - it is  USB4 connection -/ 0- it is not USB4 connection
//bit [2:0] phase ;                  // represent the phase of the transaction

endclass //mem

endpackage
