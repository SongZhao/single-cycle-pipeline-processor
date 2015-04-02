module PC(clk, pc, rst_n,hlt, J_addr,b_offset,branch_s, jal_s, jr_s, r15_out, r15_in,stall, jflush, jstall);

input clk, rst_n, hlt, branch_s, jr_s, jal_s,stall,jstall;	
input[11:0] J_addr;		// addr jump to
output[15:0] r15_out;
input [15:0] r15_in;			// register that stores previous PC when a jal excuted
input[7:0] b_offset;		// branch offset
output reg[15:0] pc;
wire[15:0] next_pc, sign_exaddr, sign_exoffset;
output jflush;


assign sign_exaddr = {{4{J_addr[11]}},J_addr};
assign sign_exoffset = {{8{b_offset[7]}}, b_offset};
assign r15_out = pc;

assign next_pc =  
                  
                  ((jr_s)&&(!jstall))? r15_in:
		              (stall)?pc:
		              (jal_s)? (pc + sign_exaddr):
		              (branch_s)? (pc - 1 + sign_exoffset): 
		              (hlt)? pc : pc+1;
assign jflush = ((jal_s||jr_s)&&(!jstall))? 1:0;

always@(posedge clk, negedge rst_n)
begin
if(!rst_n)
	pc <= 16'h0000;
else 
pc<= next_pc;		
					//if none of the branch or jump instruction encounterd
end


endmodule



