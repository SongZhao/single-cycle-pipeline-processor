module shifter(src0, shamt, srl, sra,ls,opt );
output[15:0] opt;// output
input [15:0] src0;// the input which need shift operation
input [3:0] shamt; //shift amount
input srl,sra, ls; // control bits for shift operations
wire[15:0] w1,w2,w3; // intermediate result
wire [2:0] sel1, sel2, sel3, sel4; // control of the mux
localparam[2:0] srl0 = 3'b100; // shift right logical is 100 
localparam[2:0] sra0 = 3'b010; // shift right arithmetic is 010
localparam[2:0] ls0 = 3'b001; // shift left is 001
localparam[2:0] same0 = 3'b000;// nothing changed is 000

/////////////////////////////////////////////////
// selx is used to calculate the mux selection///
/////////////////////////////////////////////////

assign sel1 = {srl&shamt[0], sra&shamt[0], ls&shamt[0]}; 
assign sel2 = {srl&shamt[1], sra&shamt[1], ls&shamt[1]};
assign sel3 = {srl&shamt[2], sra&shamt[2], ls&shamt[2]};
assign sel4 = {srl&shamt[3], sra&shamt[3], ls&shamt[3]};

/////////////////////////////////////////////////////
//first mux to check with the least bit of shamt ///
///////////////////////////////////////////////////

assign w1 =  (sel1 == srl0) ? {1'b0, src0[15:1]}:
	     (sel1 == sra0) ? {src0[15], src0[15:1]}:
             (sel1 == ls0)  ? {src0[14:0],1'b0}:
             (sel1 == same0) ?  src0:
			         16'hx;	

/////////////////////////////////////////////////////
//second mux to check with the second bit of shamt ///
///////////////////////////////////////////////////

assign w2 =  (sel2 == srl0) ? {2'b0, w1[15:2]}:
	     (sel2 == sra0) ? {{2{src0[15]}}, w1[15:2]}:
             (sel2 == ls0)  ? {w1[13:0],2'b0}:
             (sel2 == same0) ?  w1:
			         16'hx;

/////////////////////////////////////////////////////
//third mux to check with the third bit of shamt ///
////////////////////////////////////////////////////
	
assign w3 =  (sel3 == srl0) ? {4'b0, w2[15:4]}:
	     (sel3 == sra0) ? {{4{src0[15]}}, w2[15:4]}:
             (sel3 == ls0)  ? {w2[11:0],4'b0}:
             (sel3 == same0) ?  w2:
			         16'hx;

/////////////////////////////////////////////////////
//last mux to check with the last bit of shamt ///
///////////////////////////////////////////////////


assign opt =  (sel4 == srl0) ? {8'b0, w3[15:8]}:
	     (sel4 == sra0) ? {{8{src0[15]}}, w3[15:8]}:
             (sel4 == ls0)  ? {w3[7:0],8'b0}:
             (sel4 == same0) ?  w3:
			         16'hx;	
	


endmodule