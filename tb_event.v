module testbench;
	reg clk,ares,sync_reset;
	reg instr_v;
	reg [1:0] pred_res;
	wire [1:0] pred;
	
	// parameters
	parameter T=1;
    parameter NUM_INSTR = 16;
    //  instruction delay 
    parameter INSTR_MIN_DELAY = T;     
    parameter INSTR_MAX_DELAY = T * 3; 
    //  instruction to result delay 
    parameter RESULT_MIN_DELAY = 0;     
    parameter RESULT_MAX_DELAY = T * 3; 
    
	// event array
    //event instr_sent[NUM_INSTR];
    reg [NUM_INSTR-1:0] instr_sent;
	
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
	
	// probes
	//initial `probe_start;   // Start the timing diagram
	// `probe(clk);
	// `probe(ares);
	// `probe(instr_v);
	// `probe(pred_res);
	// `probe(pred);
	// `probe(dut.pred_state);
	// `probe(dut.pred_state_next);
	

    initial begin
        clk = 1;
        ares = 1;
        sync_reset = 0;
        instr_v = 0;
        pred_res=2'b00;
        
        #10 ares = 0; 

        fork
            //  THREAD 1: Controls instr_v 
            begin
                for (int i = 0; i < NUM_INSTR; i++) begin
                    #($urandom_range(INSTR_MAX_DELAY, INSTR_MIN_DELAY));
                    instr_v = 1;
                    #2;
                    instr_v = 0;
                    //-> instr_sent[i]; 
					instr_sent[i]=1'b1;
                end
            end

            //  THREAD 2: Controls pred_res 
            begin
                for (int i = 0; i < NUM_INSTR; i++) begin
                    //@(instr_sent[i]);
					wait (instr_sent[i]==1);
                    #($urandom_range(RESULT_MAX_DELAY, RESULT_MIN_DELAY));
                    if (i <4) begin // Example data
                        pred_res = 2'b01; 
                    end 
					else if (i < 9) begin
						pred_res = 2'b11;
					end
					else begin
                        pred_res = {$urandom_range(0,1),1'b1};
                    end
                    #2; 
                    pred_res[0] = 0;
                end
            end
        join
        
        #50 $finish; 
        
    end

endmodule