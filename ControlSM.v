module ControlSM(clk, re, we, ihit, dhit, dirty, u_re, u_we, u_rdy,rst_n, i_we, d_re, d_we, wdirty, 
                  i_rdy, d_rdy, u_sel);
 
input clk, re, we, ihit, dhit, dirty, u_rdy, rst_n;
output reg u_re, u_we, i_we, d_we, wdirty, i_rdy, d_rdy;
output d_re;
output reg u_sel;
reg [1:0] state, nxt_state;

localparam IDLE = 2'b00;
localparam DATA_RD = 2'b01;
localparam EVICT = 2'b10;
localparam INSTR_RD = 2'b11;


assign d_re = (re||we)? 1:0;

always@(posedge clk, negedge rst_n)                 //state machine
if(!rst_n)
state<=IDLE;
else
state<=nxt_state;

always@(*)
  begin 
    nxt_state = IDLE;
    u_sel = 0;
    u_re = 0;
    u_we = 0;
    i_we = 0;
    d_we = 0;
    i_rdy =0;
    d_rdy =0; 
    wdirty = 0;   
    case(state)
      IDLE: begin
        if((!re)&&(!we))			  //if no re or we signal engage, d-cache will always be rdy
          d_rdy = 1; 
        if((re||we)&&dhit&&ihit) begin                            //if dcache hit, update the content and set dirty bit, stay in current state
          if(we)begin
	  d_we = 1;
          wdirty = 1;end 
          
          d_rdy = 1;
          i_rdy = 1;
          nxt_state = IDLE; end
        else if((((!re)&&(!we))||dhit)&&(!ihit)) begin       //if icache not hit, enable unifie memory read, set nxt_state to INSTR_RD
          u_re = 1;                                          
          u_sel = 0;                                     //select signal for addr select mux set to 00 which is i_addr
          d_rdy = 1;                                         
          nxt_state = INSTR_RD; end                    
        else if((re||we)&&(!dhit)&&(!dirty)) begin           //if Dcache miss and dirty bit is not set 
          u_sel = 1;
          u_re = 1;                                          
          nxt_state = DATA_RD;end                      	     // set next state to DATA_RD
        else if ((re||we)&&(!dhit)&&(dirty))begin              //if Dcache miss and dirty bit set
          u_sel = 1;                                     //the select mux will select the addr[tag+index] for the write back
          //u_we = 1;
          nxt_state = EVICT;end 
	else if(ihit)begin					
          i_rdy = 1;
          nxt_state = IDLE; end                            //    set next state to EVICT
        
      end
      
      INSTR_RD: begin
          d_rdy = 1;					//when we handle I-miss, the d-miss should already be handled.
          u_sel = 0;                                //enable unified memory read, set the addr mux select I_addr
          u_re = 1;
        if(!u_rdy)                                  //if u_memory is not ready, stay in current state
          nxt_state = INSTR_RD;                       
        else if(u_rdy)begin                                       //if u_memory is ready, enable the Icache write, set nxt state to IDLE
          i_we = 1;
          nxt_state = IDLE;end
        end 
        
      DATA_RD: begin
        u_sel = 1;                                //Enable u_memory read,
        u_re = 1;
        if(!u_rdy)                                  //if the memory is not rdy, stay in current state
          nxt_state = DATA_RD;              
        else if(u_rdy) begin                                                      
          d_we = 1;
          begin
          if(we)
            wdirty = 1;
          else
            wdirty = 0; 
          end
          //d_rdy = 1;
          if(!ihit)                                           // if icache is a miss, handle the miss
          nxt_state = INSTR_RD;
          else
          nxt_state = IDLE;
          end
      end  
            
        
      EVICT: begin                                  //enble memory write to write back to memory
        u_sel = 1;
        u_we = 1;
       
        if(!u_rdy)                                  //if memory is not rdy, stay in current state  
          nxt_state = EVICT;
        else                                        //if the write complete, jump to DATA_RD state  
          nxt_state = DATA_RD;
        end
        
      default: begin                                 //default
        nxt_state = IDLE;
        u_re = 0;
        u_we = 0;
        i_we = 0;
        d_we = 0;
        i_rdy =0;
        d_rdy =0; 
	wdirty = 0; 
      end
    endcase
end  
 endmodule 
             
          
          
  
   
 
  
