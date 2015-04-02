module flop_12bit(stall, x, y,clk);
input stall,clk;
input [11:0] x;
output reg [11:0]y;

always @(posedge clk)begin
if(stall)
y<=y;
else
y<=x;

end
endmodule
