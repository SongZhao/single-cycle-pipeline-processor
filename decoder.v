module ID(instr, func, Shamt, hlt, src1sel, p0_addr, p1_addr, dst_addr, re0, re1, we, cmplmt,jal_s, jr_s, memtoReg, mem_wt, mem_rd, lswj_sel, z_en, n_en, ov_en, b_s,dont_en,pc);
input [15:0] instr,pc; //instruction code input from IM
input dont_en;

output [3:0] Shamt;	//control signal for functions and shamt for number of bits shift
output [3:0] func, p0_addr, p1_addr, dst_addr;//address for first operand, second operand and destination

output re0, re1, we, src1sel, cmplmt, jal_s, jr_s,b_s, memtoReg, mem_wt, mem_rd, lswj_sel, z_en, n_en, ov_en,hlt; //control signal for IF, SRC_MUX and ALU

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
///////
//localparam for branch control
//////
localparam [2:0] NE = 3'b000;
localparam [2:0] E = 3'b001;
localparam [2:0] GT = 3'b010;
localparam [2:0] LT = 3'b011;
localparam [2:0] GE = 3'b100;
localparam [2:0] LE = 3'b101;
localparam [2:0] OV = 3'b110;
localparam [2:0] TRUE = 3'b111;



assign hlt = ((func == hlt0)&&(~(pc == 16'h0)))? 1 : 0;		//enable hlt signal if hlt instruction is excuted.

assign func = instr[15:12];	//set the last 4 bits as the control signal for functions
 
assign p0_addr = (func == lhb0) ? instr[11:8] :instr[7:4]; 	  //set address for register0 as instr bits 11-8
							   // if its a lhb instruction, set it as 15 if its 
							   // jr instruction set it as instr			
							   // bits 7-4 if its other instruction 	

assign p1_addr = (func == sw) ? instr[11:8] : instr[3:0];	//set address for register1 as instr bits 3-0			

assign dst_addr = (func == jal)? 4'hf : instr[11:8];	//set dst address as instr bits 11-8

assign src1sel = ((func == lhb0)||(func == llb0)&&(~(pc == 16'h0)))? 1 : 0;		//set select signal for SRC_MUX as 1 if 
				// lhb or llb instruction is excuted
assign lswj_sel = ((func == lw)||(func == sw)||(func == jr)&&(~(pc == 16'h0)))? 1 :0; //set select signal for SRC_MUX as 1 if
						     //	lw or sw instruction is excuted

assign Shamt =  (pc == 16'h0)? 0:
		(func == sll0)? instr[3:0] :	//set Shamt as instr bits 3-0 if sll, srl
		(func == srl0)? instr[3:0] :    // or sra is excuted
		(func == sra0)? instr[3:0]: 0;

assign cmplmt = ((func == sub0)&(~(pc == 16'h0)))? 1 : 0;		//set 2's complement signal as 1 if sub 	
						// instruction is excuted

assign re0 = (pc == 16'h0) ?0:
	     (func == add0)? 1:			//enable register0 read signal if add, addz
	     (func == addz0)? 1:		// sub, and, nor, sll, srl, sra, lhb instruction 
	     (func == sub0)? 1:			// is excuted.
	     (func == and0)? 1:
	     (func == nor0)? 1:
	     (func == sll0)? 1:
	     (func == srl0)? 1:
	     (func == sra0)? 1:
	     (func == lhb0)? 1:
	     (func == lw)? 1:
	     (func == sw)? 1:
	     (func == jr)? 1: 0;

assign re1 = (pc == 16'h0) ?0:
	     (func == add0)? 1:			//enable resigter1 read signal if add, addz,
	     (func == addz0)? 1:		// sub, and or nor instruction is excuted
	     (func == sub0)? 1:
	     (func == and0)? 1:
	     (func == nor0)? 1:
	      (func == sw)? 1: 0;

assign we = (pc == 16'h0) ?0:
       (func == add0)? 1:			//enable we signal if add, addz, sub, and, nor
	     (func == addz0)? 1:		// sll, srl, sra, lhb, llb instruction is excuted.
	     (func == sub0)? 1:
	     (func == and0)? 1:
	     (func == nor0)? 1:
	     (func == sll0)? 1:
	     (func == srl0)? 1:
	     (func == sra0)? 1:
	     (func == lhb0)? 1: 
	     (func == llb0)? 1:
	     (func == lw) ? 1:
	     (func == jal)? 1: 0;	

assign b_s = ((func == B)&&(~(pc == 16'h0)))?1:0;								
		

assign jal_s = ((func == jal)&&(~(pc == 16'h0)))? 1:0;							//enable jal signal
assign jr_s = ((func == jr)&&(~(pc == 16'h0)))? 1:0;
//assign jflush = (jal_s||jr_s)? 1:0;						        //enable jr signal
assign memtoReg = ((func == lw)&&(~(pc == 16'h0)))? 1:0;							//mem/alu to dst select signal 
assign mem_rd = ((func == lw)&&(~(pc == 16'h0)))? 1:0;							//read mem when get lw instruction
assign mem_wt = ((func == sw)&&(~(pc == 16'h0)))? 1:0;							//write mem when get sw instruction


assign z_en =   (pc == 16'h0) ?0: 
		(((func == add0)&&(!dont_en))||(func == addz0)||(func == sub0)||(func == and0)||(func == nor0)||(func == sll0)||(func == srl0)||(func == sra0))? 1 : 0;
assign n_en = (pc == 16'h0) ?0:
		((func == add0)||(func == addz0)||(func == sub0))? 1 : 0;
assign ov_en = (pc == 16'h0) ?0:
		((func == add0)||(func == addz0)||(func == sub0))? 1 : 0;


endmodule

