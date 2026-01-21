module fifo
	#(
		parameter FIFO_W = 32; // word width
		parameter FIFO_D = 16; // word depth
		)
	(
		input clk,
		input wen,
		input [FIFO_W-1:0] wdata,
		output full,
		input ren,
		output reg [FIFO_W-1:0] rdata,
		output empty
		);
	
	localparam ADDR_W = $clog2(FIFO_D);
	
	reg [ADDR_W:0] w_ptr,r_ptr; // extra bit for managing full/empty
	reg [FIFO_W-1:0] sram [ADDR_W-1:0];
	
	
	assign empty = w_ptr == r_ptr;
	assign full = (w_ptr[ADDR_W]^r_ptr[ADDR_W]) & (w_ptr[ADDR_W-1:0] == r_ptr[ADDR_W-1:0]);
	
	always@(posedge clk or posedge ares) begin
		if (ares) begin
			w_ptr <= 'd0;
			r_ptr <= 'd0;
			//rdata <= 'd0;
		end
		else if (sync_reset) begin
			w_ptr <= 'd0;
			r_ptr <= 'd0;
		end
		else begin
			if (wen &~ full)  begin
				w_ptr <= w_ptr + 1'b1;
				sram[w_ptr[ADDR_W-1:0]] <= wdata;
			end
			if (ren &~ empty) begin
				r_ptr <= r_ptr + 1'b1;
				rdata <= sram[r_ptr[ADDR_W-1:0]];
			end
		end
	end
	
	//assign rdata = sram[r_ptr[ADDR_W-1:0]];
	
endmodule