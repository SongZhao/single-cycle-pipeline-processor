module FMUX(MEM_to_ALU, ALU_to_ALU, ID_EX_flop_to_ALU, F1,F2, src);  //Mux that choose which input to feed to ALU
input[15:0] MEM_to_ALU, ALU_to_ALU, ID_EX_flop_to_ALU;
input F1,F2;
output[15:0] src;
wire[15:0] src1;
wire f3;
assign f3 = F2&(!F1);
assign src1 = F1 ? ALU_to_ALU:ID_EX_flop_to_ALU;
assign src = f3 ? MEM_to_ALU : src1;


/*
assign src = (F_signal == 2'b10)? ALU_to_ALU :
             (F_signal == 2'b01)? MEM_to_ALU :
		        ID_EX_flop_to_ALU;
*/

endmodule 
