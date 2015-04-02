module S4MUX(flush, stall, x, y);
input flush, stall;
input[3:0] x;
output[3:0] y;

assign y = ((flush||stall)==1)? 0 : x;

endmodule
