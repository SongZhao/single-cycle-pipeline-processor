module flop_16bit(rst_n, x, y,clk,stall);
input rst_n,clk,stall;
input [15:0] x;
output reg [15:0]y;

always @(posedge clk, negedge rst_n)begin
if(!rst_n)
y<=0;
else if(stall)
y<=y;
else
y<=x;

end
endmodule
