module IFIDflop(stall, x, y, bflush, jflush, clk, hlt);  //16bit flip_flop with stall
input stall, bflush,clk,hlt,jflush;
input [15:0] x;
output reg [15:0]y;

always @(posedge clk)begin
if(bflush)
y<=0;
else if(jflush)
y<=16'h0f00;

else if(stall||hlt)
y<=y;



else
y<=x;

end
endmodule




