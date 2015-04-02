module LW_MUX(mem_data, alu_data, lw, final_dst, r15, jal_s);

input [15:0] mem_data, alu_data,r15;  //input from memory, ALU and R15
input lw, jal_s;	              //select signal for jal and lw instruction.
		  	
output [15:0] final_dst; 


assign final_dst = (lw)? mem_data :	//set dst as data out from memory if it's lw instruction
		   (jal_s)? r15 : 	//set dst as link register if it's jal_s instruction
			alu_data;	//else dst reads from alu result

endmodule
