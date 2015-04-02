module cache_output_MUX(in_data, sel, out_data);
  input[63:0] in_data;
  input [1:0] sel;
  output [15:0] out_data;
  
  
  assign out_data = (sel == 2'b00)? in_data[15:0]:
                    (sel == 2'b01)? in_data[31:16]:
                    (sel == 2'b10)? in_data[47:32]: in_data[63:48];
                    
endmodule
