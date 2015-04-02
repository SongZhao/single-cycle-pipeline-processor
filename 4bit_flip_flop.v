module flop_4bit(stall, x, y,clk);
input stall,clk;
input [3:0] x;
output reg [3:0]y;

always @(posedge clk)begin
if(stall)
y<=y;
else
y<=x;

end
endmodule
