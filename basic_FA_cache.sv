`define DATA_RANGE DATA_W-1:0
`define TAG_RANGE TAG_W + DATA_W-1:DATA_W
`define VALID_RANGE TAG_W + DATA_W
 
module FA_cache
	# (
		IDX_W = 2,
		TAG_W = 12,
		DATA_W = 32
	)
	(
		input clk,ares,sync_reset,
		input wen,
		//input [IDX_W-1:0 ] w_idx,
		input [TAG_W-1:0]  w_tag,
		input [DATA_W-1:0] w_data,
		input ren,
		//input [IDX_W-1:0 ] r_idx,
		input [TAG_W-1:0]  r_tag,
		output r_valid,
		output r_match,
		output [DATA_W-1:0] r_data
	);	
	
	reg [IDX_W-1:0] sram [TAG_W + DATA_W +1  -1 : 0]; // 1 bit for valid
	reg [2**IDX_W-1:0] match_idx;
	
	// Check match
	
	always@* begin
		for (int i=0;i<2**IDX_W-1;i++)
			match_idx[i] = r_tag == sram[i][TAG_RANGE];
	end
	
	always@(posedge clk or posedge ares) begin
		if (ares) begin
			r_valid <= 'd0;
			r_match <= 'd0;
			r_data  <= 'd0;
		end
		els if (sync_reset) begin
			r_valid <= 'd0;
			r_match <= 'd0;
			r_data  <= 'd0;
		end
		else begin
			if (ren) begin
				
			end
		end
	end
	
	always@(posedge clk or posedge ares) begin
		if (ares) begin
			for (int i=0;i<2**IDX_W;i++) sram[i] <='d0;
		end
		else if (sync_reset) begin
			for (int i=0;i<2**IDX_W;i++) sram[i] <='d0;
		end
		else begin
			if (wen) begin
				
			end
		end
		
	end
endmodule