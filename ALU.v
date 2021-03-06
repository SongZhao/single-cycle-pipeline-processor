module ALU(src0, src1, cs, cmplmt, shamt, dst,ov, z,n);

input [15:0] src0, src1; // two sources for ALU
input [3:0] cs, shamt; // control signal for functions select and shamt for number of bits shift
input cmplmt; // 2's complement signal, if subtraction is enable, this signal will enable
output [15:0] dst; // result
output ov, z, n; // overflow and zero flag
wire [15:0] com_dst;// result of 2's complement
wire [15:0] sat, sum, diff, opt,and_dst, nor_dst, lhb_dst, llb_dst, lw_sw_dst,satsum;
wire srl, sra, ls,cs_sat,cs_opt,cs_and,cs_nor,cs_lwsw,cs_llb,cs_lhb,ov1,ov2,ov3,ov4,sat1,sat2,sat3,sat4,
	o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,ov5,ov6,ov13,ov14; // shift right logical, shift right arithmetic and shift left



///////////////////////////////////////
// local varibles of functions with //
//corresponding select signals    ///
////////////////////////////////////


localparam [3:0] add0 = 4'b0000;
localparam [3:0] addz0 = 4'b0001;
localparam [3:0] sub0 = 4'b0010;
localparam [3:0] and0 = 4'b0011;
localparam [3:0] nor0 = 4'b0100;
localparam [3:0] sll0 = 4'b0101;
localparam [3:0] srl0 = 4'b0110;
localparam [3:0] sra0 = 4'b0111;
localparam [3:0] lw = 4'b1000;
localparam [3:0] sw = 4'b1001;
localparam [3:0] lhb0 = 4'b1010;
localparam [3:0] llb0 = 4'b1011;
localparam [3:0] hlt0 = 4'b1111;
localparam [3:0] B = 4'b1100;
localparam [3:0] jal = 4'b1101;
localparam [3:0] jr = 4'b1110;
assign com_dst = cmplmt? ((~src1)+1):src1;  // 2's complement

//assign {co, sum} = src0 + src1;             //add
//assign {co, diff} = src0 + com_dst;         //sub

assign {co, sum} = cmplmt?((~src1)+1) + src0 : src0+src1;

assign o1 = (cs == add0);
assign o2 = (cs == addz0);

assign o3 = (!src0[15])&(!src1[15]);
assign o4 = sum[15]&o3;
assign o5 = o1|o2;
assign ov1 = o5&o4;

assign o6 = src0[15]&src1[15];
assign o7 = (!sum[15])&o6;
assign ov2 = o5&o7;


assign o8 = (cs == sub0);

assign o9 = (!src0[15])&(src1[15]);
assign o10 = sum[15]&o9;
assign ov3 =o8&o10;

assign o11 = (src0[15])&(!src1[15]);
assign o12 = (!sum[15])&o11;
assign ov4 = o8&o12;

assign ov5 = ov1|ov2;
assign ov6 = ov3|ov4;
assign ov = ov5|ov6;


assign ov13 = o1|o2|o8;                            //saturation logic
assign ov14 = (!ov)&ov13;
assign satsum = (src0[15])? 16'h8000 : 16'h7fff; 
assign sat = ov14? sum : satsum;                     



assign z = (dst == 0)? 1:0; // if result is 0, set zero flag on
assign n = (dst[15] ==1)? 1 :0;// if result is negative, set neg flag on

/////////////////////////////////
/// assign signals for shift ////
////////////////////////////////

assign srl = (cs ==srl0)? 1:0;
assign sra = (cs ==sra0)? 1:0;
assign ls = (cs ==sll0)? 1:0;
//////////////////////////////
/// call the shift block    //
/////////////////////////////

shifter iShift(.src0(src0), .shamt(shamt), .srl(srl),.sra(sra), .ls(ls), .opt(opt));

assign and_dst = src0&src1; // AND function

assign nor_dst = ~(src0| src1);// Nor function

assign lhb_dst = {src1[7:0], src0[7:0]}; //load dst register to src0, immediate to src1
assign llb_dst = {{8{src1[7]}},src1[7:0] };//load immediate to src1

assign lw_sw_dst = src1 + src0;

///////////////////////////////////////
/// Mux for ALU to execute the right //
// functions ////////////
////////////////////


assign cs_sat = (~cs[3])&&(~cs[2])&&(~(cs[0]&&cs[1]));

assign cs_opt = (~cs[3])&&(cs[2])&&(cs[0]||cs[1]);
assign cs_and = (~cs[3])&&(~cs[2])&&(cs[1])&&(cs[0]);
assign cs_nor = (~cs[3])&&(cs[2])&&(~cs[1])&&(~cs[0]);
assign cs_lwsw = (cs[3])&&((~cs[2])&&(~cs[1]));
assign cs_llb = (cs[3])&&(~cs[2])&&(cs[1])&&(cs[0]);
assign cs_lhb = (cs[3])&&(~cs[2])&&(cs[1])&&(~cs[0]);

assign dst = (cs_sat)? sat:
	     (cs_opt)? opt:
	     (cs_and)? and_dst:
             (cs_nor)? nor_dst:
	     (cs_lwsw)? lw_sw_dst:
	     (cs_llb)? llb_dst:
	     (cs_lhb)? lhb_dst:dst;
		

endmodule




