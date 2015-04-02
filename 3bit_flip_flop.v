module flop_3bit(stall, x, y,clk);
input stall,clk;
input [2:0] x;
output reg [2:0]y;

always @(posedge clk)begin
if(stall)
y<=y;
else
y<=x;

end
endmodule
