module jump_addr_forwarding(jr, EX_MEM_RW, EX_MEM_RD, RS, FJA);
input jr, EX_MEM_RW;
input[3:0] EX_MEM_RD, RS;
output [1:0] FJA;

assign FJA = (EX_MEM_RW && (EX_MEM_RD == RS)&&jr&&(~(RS == 4'hf))) ? 2'b01:     //ALU to mux
      					   (~(RS == 4'hf)) ? 2'b10:     //RF to mux
                                                          2'b00;     //r15_ff to mux

endmodule
       																

