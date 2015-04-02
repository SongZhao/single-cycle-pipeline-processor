module FU(EX_MEM_RW, MEM_WB_RW, EX_MEM_RD, MEM_WB_RD,RS, RT, EX_MEM_RS, ID_EX_RD,FA_1, FB_2, FA_2, FB_1);
input EX_MEM_RW, MEM_WB_RW;
input [3:0] EX_MEM_RD, MEM_WB_RD, RS, RT, EX_MEM_RS, ID_EX_RD;
//output [1:0] FA, FB;
output FA_1, FA_2, FB_1, FB_2;
wire f1;
assign f1 = (EX_MEM_RD ==RS);
assign FA_1 = (EX_MEM_RW&f1);
assign f3 = (MEM_WB_RD ==RS);
assign FA_2 = MEM_WB_RW&f3;

/*
assign FA_1 = (EX_MEM_RW && (EX_MEM_RD ==RS))? 2'b10: //ALU to ALU
            (MEM_WB_RW && (MEM_WB_RD ==RS))? 2'b01://MEM to ALU
             2'b00;  
*/
assign f2 = (EX_MEM_RD ==RT);
assign FB_1 = f2&EX_MEM_RW;
assign f4 = (MEM_WB_RD ==RT);
assign FB_2 = f4&MEM_WB_RW;

/*
assign FB = (EX_MEM_RW && (EX_MEM_RD ==RT ))? 2'b10:
            (MEM_WB_RW && (MEM_WB_RD ==RT ))?2'b01 : 2'b00;
*/

endmodule
