module S6MUX(flush, stall, x, y);
input flush, stall;
input[5:0] x;
output[5:0] y;

assign y = ((flush||stall)==1)? 0 : x;

endmodule

