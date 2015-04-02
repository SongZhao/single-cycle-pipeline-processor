module Jreg_mux(jreg, Rd, jal, dst,lw); //This is the mux that selet dst_addr for Rf
input[3:0] jreg, Rd;
input jal,lw;
output[3:0] dst;

assign dst = (jal||(!lw))? jreg :Rd;  //if its jal and not lw, choose jreg 

endmodule
