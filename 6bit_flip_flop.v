module flop_6bit(stall, x, y,clk);
input stall,clk;
input [5:0] x;
output reg [5:0]y;

always @(posedge clk)begin
if(stall)
y<=y;
else
y<=x;

end
endmodule
