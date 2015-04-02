module flop_2bit(stall, x, y,clk);
input stall,clk;
input [1:0] x;
output reg [1:0]y;

always @(posedge clk)begin
if(stall)
y<=y;
else
y<=x;

end
endmodule
