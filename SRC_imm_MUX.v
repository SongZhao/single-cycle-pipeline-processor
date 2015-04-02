module SRC_imm_MUX(instr, src1sel, l_sw, en, imm_src1);	//selet immdiate value if lw/sw/jal encoutered
input[7:0]instr;
input src1sel, l_sw;
output en;
output[15:0] imm_src1;
wire[15:0] s1, s2;
assign en = (src1sel||l_sw);
assign s1 = {{8{instr[7]}},instr[7:0]};
assign s2 = {{12{instr[3]}},instr[3:0]};
assign imm_src1 = (src1sel)?s1:
		  (l_sw)? s2: 16'h0;

endmodule 


