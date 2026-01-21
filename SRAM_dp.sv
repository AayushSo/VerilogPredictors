`timescale 1ns/1ps


module SRAM_dp
	#(
		parameter ADD_W = 4, 	// address width
		parameter DAT_W = 32,	// data word width
		parameter DELAY = 5		// delay in terms of clock cycles
		)
	(
		input clk,ares,sync_reset,
		input wen,
		input [ADD_W-1:0] waddr,
		input [DAT_W-1:0] wdata,
		input ren,
		input [ADD_W-1:0] raddr,
		output [DAT_W-1:0] rdata,
		output rvalid
		);
	
	localparam NUM_ADDR = 2**ADD_W;
	reg [DAT_W-1:0] sram [NUM_ADDR-1:0];
	integer i;
	// Write logic
	always@(posedge clk or posedge ares) begin
		if (ares) begin
			for (i=0; i<NUM_ADDR; i=i+1) sram[i] <= 'b0;
		end
		else if (sync_reset) begin
			for (i=0; i<NUM_ADDR; i=i+1) sram[i] <= 'b0;
		end
		else begin
			if (wen) sram[waddr] <= wdata;
		end
	end
	
	// Read logic
	generate
		if (DELAY>0) begin
			// use pipeline
			reg [DAT_W:0] read_pipeline [DELAY-1:0];
			
			always@(posedge clk or posedge ares) begin
				if (ares) begin
					for (i=0; i<DELAY; i=i+1) read_pipeline[i] <= 'b0;
				end
				else if (sync_reset) begin
					for ( i=0; i<DELAY; i=i+1) read_pipeline[i] <= 'b0;
				end
				else begin
					read_pipeline[0] <= ren ? {sram[raddr],ren} : 'b0;
					for (i=1; i<DELAY; i=i+1) read_pipeline[i] <= read_pipeline[i-1];
				end
			end
			
			assign {rdata,rvalid} = read_pipeline[DELAY-1];
		end
		else begin
			assign rdata = sram[raddr];
			assign rvalid = ren;
		end
	endgenerate
	// always@* begin
		// rdata = #DELAY sram[raddr];
		// rvalid = #DELAY ren;
	// end
endmodule