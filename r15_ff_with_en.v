module r15_ff_with_en(rst_n, x, y,clk,en, stall, z, jreg);
input rst_n,clk,en,stall;
input [15:0] x;
output reg [15:0]y;
output reg z;
output reg [3:0] jreg;

always @(posedge clk, negedge rst_n)begin
if(!rst_n)
y<=0;

else if(en)
y<=x;
else if(stall)
y<=y;

end
always @(posedge clk)begin
if(en)
z<=1;
else if (stall)
z<=z;
else
z<=0;
end
always @(posedge clk)begin
  if(en)
    jreg<=4'hf;
  else if(stall)
    jreg<=jreg;
   else
     jreg<=4'h0;
     end

endmodule
