module flop_1bit(x, y,clk,rst_n);
input rst_n,clk;
input x;
output reg y;

always @(posedge clk, negedge rst_n)begin
if(!rst_n)
y<=0;
else
y<=x;

end
endmodule

