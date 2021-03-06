module cpu(clk, rst_n, hlt, pc);
  input clk, rst_n;
  output hlt;
  output[15:0] pc;
  wire clk, z, re0, re1, we, hlt, src1sel, rst_n,cmplmt, ov, n, j_s, jr_s, z_en, n_en, ov_en, stall,
  b_s,mr, mw, lw_sel, lwsw_imm_sel, src1sel_1,cmplmt_1,lwsw_imm_sel_1,b_sel,Memr,Memw,RegWe,finalMux_jal,finalMux_lw,
RegWe_W,finalMux_jal_W,finalMux_lw_W,Memr_M1,Memw_M1,RegWe_W1,finalMux_jal_W1,
finalMux_lw_W1,Memr_M2,Memw_M2,RegWe_W2,finalMux_jal_W2,finalMux_lw_W2,RegWe_W3,
finalMux_jal_W3,finalMux_lw_W3,cmplmt_E, z_en1, n_en1, ov_en1, z_en_E, n_en_E, ov_en_E,flush, jflush, hlt_s, hlt_E,
hlt_M, hlt_1,addz_nop,dont_en, i_rdy,d_rdy, cache_stall,jstall,en,FA_1,FA_2,FB_1,FB_2;
 
                               //wire that connects each block
  
  wire [15:0] instr, p0_d, p1_d, dst, src1,src0, final_dst, data_load,r15, IF_ID_instr,
  ID_EX_p0, ID_EX_p1,pre_src1,EX_MEM_dst,EX_MEM_p1_d,MEM_WB_dst,MEM_WB_data_load,IF_ID_r15,ID_EX_r15,EX_MEM_r15,
  MEM_WB_r15,imm_src1,data_WB,MEM_WB_data,
  jump_addr;     // they are input&ouput of those blocks	
  
  wire [3:0] Shamt, func, p0_addr, p1_addr, AluOp, AluOp_E,dst_addr,ID_EX_func,ID_EX_Rs,ID_EX_Rt,ID_EX_Rd,
  ID_EX_Shamt,EX_MEM_Rs,EX_MEM_Rd,MEM_WB_Rd, jreg1,jreg2,jreg3,dst_addr1;

  wire[2:0]condition,condition_M;
  reg[2:0] flag_flop;
  wire[1:0]FJA;
  wire[7:0] ID_EX_offset; 
  


  ////////////////////////////////
  //connect each block togather
  /////////////////////////////////
  PC counter(.clk(clk), .pc(pc), .rst_n(rst_n), .hlt(hlt_1), .J_addr(IF_ID_instr[11:0]),
    .b_offset(ID_EX_offset), .branch_s(b_t), .jal_s(j_s) , .jr_s(jr_s), .r15_out(r15), .r15_in(jump_addr),
     .stall(stall_IF_ID), .jflush(jflush), .jstall(jstall));
  
  ///////////////////////
  //Hazard detector
  ////////////////////////
  HD hazard(.RS(IF_ID_instr[7:4]), .IF_ID_RT(IF_ID_instr[3:0]), .ID_EX_RT(ID_EX_Rd), .MEM_RD(Memr_M1), .stall(stall),
   .AluOp(AluOp_E), .z_flag_in(flag_flop[0]), .jr(jr_s), .addz_nop(addz_nop), .i_rdy(i_rdy), .d_rdy(d_rdy), .cache_stall(cache_stall), .stall_IF_ID(stall_IF_ID), .stall_jr(jstall), .ID_EX_we(RegWe_W));

  /////////////////// 
  //IF_ID_flip_flop
  ///////////////////
  IF_ID_flush flushIF(.bflush(b_t), .jflush(jflush), .flush(flush)); //flush block that combines branch flush and jump flush
  flop IF_ID_flop(.clk(clk), .x(instr), .y(IF_ID_instr), .stall(stall_IF_ID), .flush(flush), .hlt(hlt_1));	 //store instr
  
  flop_1bit_with_stall flag_en_en_flop(.clk(clk), .x(flush), .y(dont_en), .rst_n(rst_n), .stall(cache_stall)); //z_en flop

  ///////////// 
  //ID_block
  ////////////
  ID d(.instr(IF_ID_instr), .func(func), .Shamt(Shamt), .hlt(hlt_1), 
    .src1sel(src1sel), .p0_addr(p0_addr), .p1_addr(p1_addr), .dst_addr(dst_addr), 
    .re0(re0), .re1(re1), .we(we), .cmplmt(cmplmt), .b_s(b_s),.jal_s(j_s), .jr_s(jr_s), 
    .memtoReg(mr), .mem_wt(mw), .mem_rd(lw_sel), .lswj_sel(lwsw_imm_sel), .z_en(z_en),
     .n_en(n_en), .ov_en(ov_en), .dont_en(dont_en), .pc(pc)); 
  
  /////////////
  //RF block
  /////////////
  rf register(.clk(clk), .p0_addr(p0_addr), .p1_addr(p1_addr), .p0(p0_d), .p1(p1_d), .re0(re0), .re1(re1), 
    .dst_addr(MEM_WB_Rd), .dst(final_dst), .we(RegWe_W3), .hlt(hlt)); 
  
  /////////////////////////////
  //ID_EX_flip_flop for data
  ////////////////////////////////
  flop_16bit ID_EX_flop1(.clk(clk), .x(p0_d), .y(ID_EX_p0), .rst_n(rst_n), .stall(stall_IF_ID));  //p0--src0
  flop_16bit ID_EX_flop2(.clk(clk), .x(p1_d), .y(ID_EX_p1), .rst_n(rst_n), .stall(stall_IF_ID));  //p1--src1
  
  flop_4bit ID_EX_flop3(.clk(clk), .x(func), .y(ID_EX_func), .stall(stall_IF_ID));        //cs for alu	
  flop_4bit ID_EX_flop4(.clk(clk), .x(p0_addr), .y(ID_EX_Rs), .stall(stall_IF_ID));	  //Rs
  flop_4bit ID_EX_flop5(.clk(clk), .x(p1_addr), .y(ID_EX_Rt), .stall(stall_IF_ID));	  //Rt
  flop_4bit ID_EX_rd(.clk(clk), .x(dst_addr), .y(ID_EX_Rd), .stall(stall_IF_ID));
  flop_4bit Shamt_hlt(.clk(clk), .x(Shamt), .y(ID_EX_Shamt), .stall(stall_IF_ID));      //store Shamt
  flop_8bit immd(.clk(clk), .x(IF_ID_instr[7:0]), .y(ID_EX_offset), .stall(stall_IF_ID)); //store immd
  r15_ff_with_en ID_EX_r15_flop(.clk(clk), .x(r15), .y(ID_EX_r15), .rst_n(rst_n), .en(j_s), .z(finalMux_jal_x), 
                                .stall(stall_IF_ID), .jreg(jreg1)); //store r15
  ////////////////////////////
  //MUX that inserts nop
  ///////////////////////////
  S4MUX mux_stall1(.flush(b_t), .stall(stall), .x(func), .y(AluOp));
  S1MUX mux_stall2(.flush(b_t), .stall(stall), .x(src1sel), .y(src1sel_1));
  S1MUX mux_stall3(.flush(b_t), .stall(stall), .x(cmplmt), .y(cmplmt_1));
  S1MUX mux_stall4(.flush(b_t), .stall(stall), .x(lwsw_imm_sel), .y(lwsw_imm_sel_1));
  S3MUX mux_stall5(.flush(b_t), .stall(stall), .x(IF_ID_instr[11:9]), .y(condition));
  S1MUX mux_stall6(.flush(b_t), .stall(stall), .x(b_s), .y(b_sel));
  S1MUX mux_stall7(.flush(b_t), .stall(stall), .x(mr), .y(Memr));
  S1MUX mux_stall8(.flush(b_t), .stall(stall), .x(mw), .y(Memw));
  S1MUX mux_stall9(.flush(b_t), .stall(stall), .x(we), .y(RegWe));
  S1MUX mux_stall10(.flush(b_t), .stall(stall), .x(j_s), .y(finalMux_jal));
  S1MUX mux_stall11(.flush(b_t), .stall(stall), .x(lw_sel), .y(finalMux_lw));
  S1MUX mux_stallflag_en1(.flush(b_t), .stall(stall), .x(z_en), .y(z_en1));    
  S1MUX mux_stallflag_en2(.flush(b_t), .stall(stall), .x(n_en), .y(n_en1));     
  S1MUX mux_stallflag_en3(.flush(b_t), .stall(stall), .x(ov_en), .y(ov_en1));   
  S1MUX mux_stall_hlt(.flush(b_t), .stall(stall), .x(hlt_1), .y(hlt_s));       
 	
  ////////////////////////////////////
  //ID_EX_flip_flop for control signal
  ////////////////////////////////////
  flop_4bit ID_EX_cs1(.clk(clk), .x(AluOp), .y(AluOp_E), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs2(.clk(clk), .x(src1sel_1), .y(src1sel_E), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs3(.clk(clk), .x(cmplmt_1), .y(cmplmt_E), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs4(.clk(clk), .x(lwsw_imm_sel_1), .y(lwsw_imm_sel_E), .rst_n(rst_n), .stall(cache_stall));
  flop_3bit ID_EX_cs5(.clk(clk), .x(condition), .y(condition_M), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs6(.clk(clk), .x(b_sel), .y(b_s_M), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs7(.clk(clk), .x(Memr), .y(Memr_M1), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs8(.clk(clk), .x(Memw), .y(Memw_M1), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs9(.clk(clk), .x(RegWe), .y(RegWe_W), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs10(.clk(clk), .x(finalMux_jal), .y(finalMux_jal_W1), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_cs11(.clk(clk), .x(finalMux_lw), .y(finalMux_lw_W1), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_flag_enz(.clk(clk), .x(z_en1), .y(z_en_E), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_flag_enn(.clk(clk), .x(n_en1), .y(n_en_E), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_flag_enov(.clk(clk), .x(ov_en1), .y(ov_en_E), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall ID_EX_hlt(.clk(clk), .x(hlt_s), .y(hlt_E), .rst_n(rst_n), .stall(cache_stall));

  /////////////
  //Forward MUX
  /////////////
  FMUX forsrc0(.MEM_to_ALU(MEM_WB_data), .ALU_to_ALU(EX_MEM_dst), .ID_EX_flop_to_ALU(ID_EX_p0), .F1(FA_1), .F2(FA_2), .src(src0));
  FMUX forsrc1(.MEM_to_ALU(MEM_WB_data), .ALU_to_ALU(EX_MEM_dst), .ID_EX_flop_to_ALU(ID_EX_p1), .F1(FB_1), .F2(FB_2), .src(pre_src1));
  
  ////////////////////////////////////
  //two mux that selet immidiate value
  //////////////////////////////////// 
  SRC_imm_MUX imm_sel(.instr(ID_EX_offset), .src1sel(src1sel_E), .l_sw(lwsw_imm_sel_E), .en(en), .imm_src1(imm_src1));
  simple_mux  imm_r_sel(.p1(pre_src1), .imm(imm_src1), .en(en), .src1(src1));
  
  ////////////
  //ALU block
  ////////////  
  ALU alu1(.src0(src0), .src1(src1), .cs(AluOp_E), .cmplmt(cmplmt_E), .shamt(ID_EX_Shamt), .dst(dst), .ov(ov), .z(z), .n(n)); 
  
  ////////
  //Branch
  /////////
  bs branch(.b(b_s_M), .condition(condition_M), .flag_reg(flag_flop), .b_s(b_t));
  
  ////////////////////////////////
  //jump register value select mux
  ////////////////////////////////
  MuxJR R15_or_nR15(.alu(EX_MEM_dst), .r15(ID_EX_r15), .p0(ID_EX_p0), .addr(jump_addr), .FJA(FJA));
  
  ////////////////////////////
  //EX_MEN_flip_flop for data
  ////////////////////////////
  flop_16bit EX_MEM_dst1(.clk(clk), .x(dst), .y(EX_MEM_dst), .rst_n(rst_n), .stall(cache_stall));        //alu result
  flop_16bit EX_MEM_flop2(.clk(clk), .x(pre_src1), .y(EX_MEM_p1_d), .rst_n(rst_n), .stall(cache_stall)); //p1 value
  flop_16bit EX_MEM_r15_flop(.clk(clk), .x(ID_EX_r15), .y(EX_MEM_r15), .rst_n(rst_n), .stall(cache_stall));//r15 value
  flop_4bit EX_MEM_rd1(.clk(clk), .x(ID_EX_Rd), .y(EX_MEM_Rd), .stall(cache_stall));                       //dst addr
  flop_4bit EX_MEM_jreg_ff(.clk(clk), .x(jreg1), .y(jreg2), .stall(cache_stall));			   //jal signal for address seletion @ WB stage
  flop_4bit EX_MEM_flop4(.clk(clk), .x(ID_EX_Rs), .y(EX_MEM_Rs), .stall(cache_stall));			   //Rs operad for forwarding unite	
  /////////////////////////////////
  //one muxes that insert stall  
  ////////////////////////////////
   S1MUX mux_stall15(.flush(1'b0), .stall(addz_nop), .x(RegWe_W), .y(RegWe_W1)); // clear register write if addz is not suppose to be excutied 
  //////////////////////////////////////
  //EX_MEM_flip_flop for control signal
  ///////////////////////////////////////
 
  
  flop_1bit_with_stall EX_MEM_cs1(.clk(clk), .x(Memr_M1), .y(Memr_M2), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall EX_MEM_cs2(.clk(clk), .x(Memw_M1), .y(Memw_M2), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall EX_MEM_cs3(.clk(clk), .x(RegWe_W1), .y(RegWe_W2), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall EX_MEM_cs4(.clk(clk), .x(finalMux_jal_W1), .y(finalMux_jal_W2), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall EX_MEM_cs5(.clk(clk), .x(finalMux_lw_W1), .y(finalMux_lw_W2), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall EX_MEM_hlt(.clk(clk), .x(hlt_E), .y(hlt_M), .rst_n(rst_n), .stall(cache_stall));
  
  
  //MUX that select lw/alu data
  simple_mux lw_or_alu(.p1(data_load), .imm(EX_MEM_dst), .en(~Memr_M2), .src1(data_WB));

  //////////////////////////////
  //MEM_WB_flip_flop for data
  /////////////////////////////
  flop_16bit MEM_WB_flop_t(.clk(clk), .x(data_WB), .y(MEM_WB_data), .rst_n(rst_n), .stall(cache_stall));
  flop_4bit MEM_WB_Rd1(.clk(clk), .x(EX_MEM_Rd), .y(MEM_WB_Rd), .stall(cache_stall));
  flop_16bit MEM_WB_r15_flop(.clk(clk), .x(EX_MEM_r15), .y(MEM_WB_r15), .rst_n(rst_n), .stall(cache_stall));
  flop_4bit MEM_WB_jreg_ff(.clk(clk), .x(jreg2), .y(jreg3), .stall(cache_stall));
  /////////////////////////////////////
  //MEM_WB_flip_flop for control signal
  //////////////////////////////////// 
  flop_1bit_with_stall MEM_WB_cs1(.clk(clk), .x(RegWe_W2), .y(RegWe_W3), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall MEM_WB_cs2(.clk(clk), .x(finalMux_jal_W2), .y(finalMux_jal_W3), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall MEM_WB_cs3(.clk(clk), .x(finalMux_lw_W2), .y(finalMux_lw_W3), .rst_n(rst_n), .stall(cache_stall));
  flop_1bit_with_stall MEM_WB_hlt(.clk(clk), .x(hlt_M), .y(hlt), .rst_n(rst_n), .stall(cache_stall));
  /////////////////
  //Fowarding unit
  ////////////////
  jump_addr_forwarding Jump_F(.jr(jr_s), .EX_MEM_RW(RegWe_W2), .EX_MEM_RD(EX_MEM_Rd), .RS(IF_ID_instr[7:4]), .FJA(FJA));
  FU fowarding(.EX_MEM_RW(RegWe_W2), .MEM_WB_RW(RegWe_W3), .EX_MEM_RD(EX_MEM_Rd), .MEM_WB_RD(MEM_WB_Rd), .RS(ID_EX_Rs), .RT(ID_EX_Rt), .EX_MEM_RS(EX_MEM_Rs), .ID_EX_RD(ID_EX_Rd),.FA_1(FA_1), .FB_1(FB_1), .FA_2(FA_2), .FB_2(FB_2));


  //////////////////
  //Main Memory
  /////////////////   
  system_memory Main_memory(.clk(clk), .rst_n(rst_n), .i_addr(pc), .d_addr(EX_MEM_dst), .re(Memr_M2), 
                            .we(Memw_M2), .i_rdy(i_rdy), .d_rdy(d_rdy), .rd_data(data_load), .instr(instr), .wrt_data(EX_MEM_p1_d));
  ////////////////////
  // result_mux block
  ///////////////////
  Jreg_mux mux3(.jreg(jreg3), .Rd(MEM_WB_Rd), .jal(finalMux_jal_W3), .dst(dst_addr1), .lw(finalMux_lw_W3)); //select dst_addr for rf
  simple_mux final_dst_mux(.p1(MEM_WB_data), .imm(MEM_WB_r15), .en(finalMux_jal_W3), .src1(final_dst));

	always@(posedge clk, negedge rst_n)begin     //flop that used to store 3 flags
	if(!rst_n)
		flag_flop[0] <= 0;
	else if(z_en_E)
		flag_flop[0] <= z;
	end

	always@(posedge clk, negedge rst_n)begin 
	if(!rst_n)
		flag_flop[1] <= 0;
	else if(n_en_E)	
		flag_flop[1] <= n;
	end
	always@(posedge clk, negedge rst_n)begin 
	if(!rst_n)
		flag_flop[2] <= 0;
	else if(ov_en_E)
		flag_flop[2] <= ov;	
  	end

 endmodule 
