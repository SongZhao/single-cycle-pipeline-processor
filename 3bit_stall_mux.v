module S3MUX(flush, stall, x, y);
input flush, stall;
input[2:0] x;
output[2:0] y;

assign y = ((flush||stall)==1)? 0 : x;

endmodule
