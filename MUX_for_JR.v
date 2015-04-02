module MuxJR(alu, r15, p0, addr, FJA);
input[15:0] alu, r15, p0;

input[1:0] FJA;
output[15:0]addr;



assign addr = (FJA == 2'b01) ? alu:
	      (FJA == 2'b10) ? p0:
	      (FJA == 2'b00) ? r15 : 16'b0;

endmodule
