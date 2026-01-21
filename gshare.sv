/*
GSHARE branch predictor.
Same-cycle output of branch prediction based on a saturating counter.
Prediction counter is selected based on XOR of PC with N-previous branch history.
*/
module gshare
	#(  parameter GH_WIDTH = 4,
		parameter PC_WIDTH = 32,
		parameter INDEX_W  = 4  
	)
	(
	input clk,ares,sync_reset,
	input [PC_WIDTH-1:0] instr_data,
	input instr_valid,
	input [INDEX_W-1:0] pred_result_idx,
	input pred_result_data,
	input pred_result_valid,
	output [INDEX_W+1-1:0] pred_data,
	output pred_valid
	// Pred State Table RAM signalling
	// output PST_ren,
	// output [INDEX_W-1:0] PST_raddr,
	// input [1:0] PST_rdata,
	// input PST_rvalid,
	// output PST_wen,
	// output [INDEX_W-1:0] PST_waddr,
	// output [1:0] PST_wdata
);
	
	// parameters
	localparam GHIST_W = GH_WIDTH < INDEX_W ? INDEX_W : GH_WIDTH;
	localparam INIT_PRED = 2'b10; // predict weakly taken initially
	
	reg [1:0] pred_state_table [(1<<INDEX_W)-1:0] ;
	reg [1:0] pred_state_next ;
	reg [GHIST_W-1:0] ghist;
	
	wire [INDEX_W-1:0] idx ;
	wire [1:0] pred_state; 
	wire [1:0] current_pred;
	reg [1:0] pred_state_table_state_next;
	
	integer i;
	
	//Read pred_state_table
	assign idx = instr_data[INDEX_W-1:0]^ghist[INDEX_W-1:0];
	assign pred_state = pred_state_table [idx];
	assign pred_data = {idx,pred_state[1]};
	assign pred_valid = instr_valid;
	
	// Update pred_state_table
	assign current_pred = pred_state_table[pred_result_idx];
	always@* begin
		case({pred_result_data,current_pred})
			3'b0_00 : pred_state_table_state_next = 2'b00;
			3'b0_01 : pred_state_table_state_next = 2'b00;
			3'b0_10 : pred_state_table_state_next = 2'b01;
			3'b0_11 : pred_state_table_state_next = 2'b10;
			3'b1_00 : pred_state_table_state_next = 2'b01;
			3'b1_01 : pred_state_table_state_next = 2'b10;
			3'b1_10 : pred_state_table_state_next = 2'b11;
			3'b1_11 : pred_state_table_state_next = 2'b11;
		endcase
	end
	
	always@(posedge clk or posedge ares) begin
		if (ares) begin
			for (i=0; i< INDEX_W ; i=i+1) pred_state_table[i] <= INIT_PRED;
		end
		
		else if (sync_reset) begin
			for (i=0; i< INDEX_W ; i=i+1) pred_state_table[i] <= INIT_PRED;
		end
		
		else begin
			if (pred_result_valid) begin
				pred_state_table[pred_result_idx] <= pred_state_table_state_next; 
			end
			end
	end
	
	// GHIST update
	always@(posedge clk or posedge ares) begin
		if (ares) ghist <= 'd0;
		else if (sync_reset) ghist <= 'd0;
		else if (pred_result_valid) ghist <= {ghist[GHIST_W-1:1],pred_result_data};
	end
	
	
endmodule


/*
//simple cache
	reg [INDEX_W +2 -1:0] cache[3:0]; // index+2 bit width cache, total of 4 lines
	reg [1:0] cache_ptr;
	reg [3:0] read_cache_hit;
	reg [1:0] read_cache_hit_data;
	reg [3:0] write_cache_hit;
	reg [1:0] write_cache_hit_data;
	
		
	// PREDICT STAGE
	assign idx = instr_data[INDEX_W-1:0]^ghist[INDEX_W-1:0];
	assign PST_ren = instr_valid;
	assign PST_raddr = idx;
	
	assign pred_data = PST_rdata[1];
	assign pred_valid = PST_rvalid;
	
	// Cache update
	always@* begin
		write_cache_hit = 'd0;
		for(int i=0;i<4;i++) begin
			write_cache_hit[i] = idx==cache[INDEX_W-1:0];
		end
	end
	always@* begin
		write_cache_hit_data = 'd0;
		if (|write_cache_hit[1:0]) begin
			if (write_cache_hit[0]) write_cache_hit_data = sram[0];
			else write_cache_hit_data = sram[1];
		end		
		else if (|write_cache_hit[3:2]) begin
			if (write_cache_hit[2]) write_cache_hit_data = sram[2];
			else write_cache_hit_data = sram[3];
		end		
	end
	
	always@(posedge clk or posedge ares) begin
		if (ares) begin
			cache_ptr <= 'd0;
			for (int i=0;i<4;i++) cache[i] <= 'd0;
		end
		else if (sync_reset) begin
			cache_ptr <= 'd0;
			for (int i=0;i<4;i++) cache[i] <= 'd0;
		end
		else begin
			if (instr_valid) begin
				cache[cache_ptr] <= {instr_data}
			end
		end
	end
	
*/