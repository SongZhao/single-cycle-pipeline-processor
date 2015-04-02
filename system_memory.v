module system_memory(clk, rst_n, i_addr, d_addr, re, we, i_rdy,d_rdy, rd_data, instr, wrt_data);
input clk, rst_n, re, we;
input[15:0] i_addr, d_addr, wrt_data;
output i_rdy, d_rdy;
output[15:0] instr, rd_data;

wire [15:0]i_addr, d_addr, instr, rd_data;
wire[13:0] u_mem_addr;
wire[63:0] sw_data_nothit, sw_data_hit, d_wrt_data, mem_rd_data, i_rd_data, d_rd_data;
wire clk, rst_n, ihit, dhit, re, we, u_re, u_we, u_rdy, d_re, d_we, wdirty, i_rdy,
      d_rdy, dirty, cache_stall;
wire u_sel;
wire[7:0] d_tag;

cache Icache(.clk(clk), .rst_n(rst_n), .addr(i_addr[15:2]), .wr_data(mem_rd_data), .wdirty(1'b0), .we(i_we), 
             .re(1'b1), .rd_data(i_rd_data), .tag_out(), .hit(ihit), .dirty());
cache Dcache(.clk(clk), .rst_n(rst_n), .addr(d_addr[15:2]), .wr_data(d_wrt_data), .wdirty(wdirty), .we(d_we),
             .re(d_re), .rd_data(d_rd_data), .tag_out(d_tag), .hit(dhit), .dirty(dirty));

ControlSM state_machine(.clk(clk), .re(re), .we(we), .ihit(ihit), .dhit(dhit), .dirty(dirty), .u_re(u_re), 
                        .u_we(u_we), .u_rdy(u_rdy), .rst_n(rst_n), .i_we(i_we), .d_re(d_re), .d_we(d_we), 
                        .wdirty(wdirty), .i_rdy(i_rdy), .d_rdy(d_rdy), .u_sel(u_sel));
                        
cache_output_MUX icache_mux(.in_data(i_rd_data), .sel(i_addr[1:0]), .out_data(instr));
cache_output_MUX dcache_mux(.in_data(d_rd_data), .sel(d_addr[1:0]), .out_data(rd_data));

unified_mem main_mem(.clk(clk), .rst_n(rst_n), .addr(u_mem_addr), .re(u_re), .we(u_we), .wdata(d_rd_data), 
                      .rd_data(mem_rd_data), .rdy(u_rdy));
  
  
assign u_mem_addr = (u_sel == 0)? i_addr[15:2]:
                    (u_sel == 1)? {d_tag,d_addr[13:6]}: 14'b0;
                    
                    
assign sw_data_nothit = (d_addr[1:0] == 2'b00) ? {{mem_rd_data[63:16]},wrt_data}:
                	 (d_addr[1:0] == 2'b01) ? {{mem_rd_data[63:32]},wrt_data,{mem_rd_data[15:0]}}:
                 	(d_addr[1:0] == 2'b10) ? {{mem_rd_data[63:47]},wrt_data,{mem_rd_data[31:0]}}:
                                    					 {wrt_data,{mem_rd_data[47:0]}};

assign sw_data_hit = (d_addr[1:0] == 2'b00)?{{d_rd_data[63:16]},wrt_data}:
                 	(d_addr[1:0] == 2'b01) ? {{d_rd_data[63:32]},wrt_data,{d_rd_data[15:0]}}:
                	 (d_addr[1:0] == 2'b10) ? {{d_rd_data[63:47]},wrt_data,{d_rd_data[31:0]}}:
                                     {wrt_data,{d_rd_data[47:0]}};                                   


assign d_wrt_data = (re)? mem_rd_data:
		    (dhit)? sw_data_hit:sw_data_nothit;

//assign cache_stall = ((!i_rdy)||(!d_rdy))? 1'b1: 1'b0;
endmodule                   
                    
                    

 
 
