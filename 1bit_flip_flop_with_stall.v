module flop_1bit_with_stall(clk, x, y, rst_n, stall);
input clk, x, rst_n, stall;
output reg y;

always @(posedge clk, negedge rst_n)begin
if(!rst_n)
y<=0;
else if(stall)
y<=y;
else
y<=x;

end
endmodule
