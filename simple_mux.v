module simple_mux(p1,imm,en,src1); //16bit choosing mux
input[15:0]p1,imm;
input en;
output[15:0] src1;


assign src1 = (en)? imm:p1; //if en is up, choose imm, otherwise p1;

endmodule

