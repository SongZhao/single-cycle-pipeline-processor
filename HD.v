module HD(RS, ID_EX_RT, IF_ID_RT, MEM_RD, stall, AluOp, z_flag_in, jr,addz_nop,i_rdy,d_rdy, 
cache_stall,stall_IF_ID, stall_jr,ID_EX_we);
input [3:0]RS, ID_EX_RT, IF_ID_RT, AluOp;
input MEM_RD, z_flag_in, jr, i_rdy,d_rdy, ID_EX_we;
output stall,addz_nop,cache_stall, stall_IF_ID,stall_jr;
wire addz_nop, stall_jr,cache_stall;

assign stall= (MEM_RD &&((ID_EX_RT == RS) || (ID_EX_RT == IF_ID_RT)))? 1'b1: 0;
assign addz_nop = ((AluOp == 4'b1)&&(z_flag_in == 0))? 1'b1: 0;
assign stall_jr = (jr&&(RS == ID_EX_RT)&&ID_EX_we)? 1'b1:0;  
assign stall_IF_ID  = (stall||cache_stall||stall_jr)? 1:0;
assign cache_stall = ~i_rdy|~d_rdy;

endmodule

