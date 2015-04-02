module S1MUX(flush, stall, x, y); //stall mux that stall the control signal flip_flop
input flush, stall;
input x;
output y;

assign y = ((flush||stall)==1)? 0 : x;

endmodule
