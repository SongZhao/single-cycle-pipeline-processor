module flop(stall, x, y, flush,clk, hlt);  //16bit flip_flop with stall
input stall, flush,clk,hlt;
input [15:0] x;
output reg [15:0]y;

always @(posedge clk)begin
if(flush&&(~stall))
y<=0;

else if(stall||hlt)
y<=y;



else
y<=x;

end
endmodule




