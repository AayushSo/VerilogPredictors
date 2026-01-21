module testbench;
	reg clk,ares,sync_reset;
	reg instr_v;
	reg [1:0] pred_res;
	wire [1:0] pred;
	
	//parameters 
	parameter T1=0;
	parameter T2=0;
    parameter NUM_INSTR = 16;
	
	integer i;
	
	two_bit dut(
		// DUT input
		.clk(clk), 							// clock
		.ares(ares), 						// async reset
		.sync_reset(sync_reset), 			// sync_reset
		.instr_valid(instr_v), 				// instruction valid
		.pred_result_data(pred_res[1]),		// branch realization 1/0
		.pred_result_valid(pred_res[0]),	// branch realization 1/0
		// DUT output
		.pred_data(pred[1]),				// prediction
		.pred_valid(pred[0])				// prediction valid bit
	);
	
	always #1 clk = ~clk;

	initial begin
		clk = 1;
		ares = 1;
		sync_reset = 0;
		instr_v = 0;
		pred_res=2'b00;
		
		#10 ares = 0;
		
		// launch instruction
		#(T1*2) instr_v = 1;
		#2  instr_v = 0;
		
		for (i = 1; i < NUM_INSTR; i=i+1) begin
			// commit instruction
			if (i<4) begin
				#(T2*2) pred_res = 2'b01;
				#2  pred_res[0] = 0;
			end
			else if (i<9) begin
				#(T2*2) pred_res = 2'b11;
				#2  pred_res[0] = 0;
			end
			else begin
				#(T2*2) pred_res = {$urandom_range(0,1),1'b1};
				#2  pred_res[0] = 0;
			end
			
			// launch instruction
			#(T1*2) instr_v = 1;
			#2  instr_v = 0;
		end
		
		#(T2*2) pred_res = 2'b01;
		#2  pred_res[0] = 0;
				
		
		
	end

endmodule