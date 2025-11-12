
module two_bit(
	input clk,ares,sync_reset,
	input instr_valid,
	input pred_result_data,
	input pred_result_valid,
	output pred_data,
	output pred_valid
);

	reg [1:0] pred_state;
	wire [1:0] pred_state_next;

	always@* begin
		pred_state_next = pred_state;
		if (pred_result_valid) begin
			// case({pred_state,pred_data})
				// 3'b00_0 : pred_state_next = 2'b00; 
				// 3'b00_1 : pred_state_next = 2'b01; 
				// 3'b01_0 : pred_state_next = 2'b00; 
				// 3'b01_1 : pred_state_next = 2'b10; 
				// 3'b10_0 : pred_state_next = 2'b01; 
				// 3'b10_1 : pred_state_next = 2'b11; 
				// 3'b11_0 : pred_state_next = 2'b10; 
				// 3'b11_1 : pred_state_next = 2'b11; 
			// endcase
			// compressing the above case table:
			pred_state_next[0] = (pred_state[1]&pred_result_data) | (~pred_state[0]&(pred_state[1]|pred_result_data) ); 
			pred_state_next[1] = (pred_state[1]&pred_result_data) | ( pred_state[0]&(pred_state[1]|pred_result_data) ); 
		end
	end

	always@(posedge clk or posedge ares) begin
		if (ares) pred_state <= 2'b01;
		else if (sync_reset) pred_state <= 2'b01;
		else pred_state <= pred_state_next;
	end

	assign pred_data = pred_state[1];
	assign pred_valid = instr_valid;

endmodule