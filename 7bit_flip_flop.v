module flop_7bit(stall, x, y,clk);
input stall,clk;
input [6:0] x;
output reg [6:0]y;

always @(posedge clk)begin
if(stall)
y<=y;
else
y<=x;

end
endmodule
