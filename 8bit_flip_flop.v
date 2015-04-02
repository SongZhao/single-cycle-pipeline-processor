module flop_8bit(stall, x, y,clk);
input stall,clk;
input [7:0] x;
output reg [7:0]y;

always @(posedge clk)begin
if(stall)
y<=y;
else
y<=x;

end
endmodule
