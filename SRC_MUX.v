module SRC_MUX(instr, p1, src1sel, src1, sw_offset, l_sw);
input [7:0] instr; // immediate value input 
input [15:0] p1;   // register1 output
input src1sel,l_sw;	   // control signal that selects register input 
		   	   // or immediate input
input [3:0] sw_offset;		
output [15:0] src1; //output to ALU src1
wire[15:0] s1, s2;
//if src1sel is enabled, the mux will choose the sign extend
// immediate value, else it will choose the register value.
assign s1 = {{8{instr[7]}}, instr[7:0]};
assign s2 = {{12{instr[3]}},instr[3:0]};
assign src1 = (src1sel)? s1 :				//for lhb and llb
		(l_sw)? s2: p1;			//for lw and sw

endmodule
