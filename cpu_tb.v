module cpu_tb();
reg clk, rst_n;
wire [15:0] pc;



///Instantiate    

cpu iDut(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));

////////////////////////////////////
//read file that contains a 16X16 matrix
//and display the content in mem
///////////////////////////////////

////////////////////////////////////////////
//// set the we to high and make the clk///
/// change the status every 5 seconds ////
/////////////////////////////////////////

initial 
	begin
 	clk = 0;
	end	
always
	#5 clk = ~clk;



initial begin
	rst_n = 0;
	#1 rst_n = 1;

end
endmodule
		

	


	



