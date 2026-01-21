`timescale 1ns/1ps

module tb_SRAM_dp;
    // Parameters
    localparam ADD_W = 4;
    localparam DAT_W = 32;
    localparam DELAY = 2; // Testing with a 2-cycle delay

    // Signals
    logic clk;
    logic ares, sync_reset;
    logic wen, ren;
    logic [ADD_W-1:0] waddr, raddr;
    logic [DAT_W-1:0] wdata;
    wire [DAT_W-1:0] rdata;
    wire rvalid;

    // Instantiate the Unit Under Test (UUT)
    SRAM_dp #(
        .ADD_W(ADD_W),
        .DAT_W(DAT_W),
        .DELAY(DELAY)
    ) uut (
        .clk(clk),
        .ares(ares),
        .sync_reset(sync_reset),
        .wen(wen),
        .waddr(waddr),
        .wdata(wdata),
        .ren(ren),
        .raddr(raddr),
        .rdata(rdata),
        .rvalid(rvalid)
    );

    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test Sequence
    initial begin
	$dumpfile("waveform.vcd");  // Name of the file to dump to
    $dumpvars;
        // Initialize signals
        ares = 1;
        sync_reset = 0;
        wen = 0;
        ren = 0;
        waddr = 0;
        raddr = 0;
        wdata = 0;

        // 1. Asynchronous Reset
        #15 ares = 0;
        $display("[%0t] Reset complete", $time);

        // 2. Write Data
        @(posedge clk);
        wen = 1;
        waddr = 4'hA;
        wdata = 32'hDEADBEEF;
        @(posedge clk);
        wen = 0;
        $display("[%0t] Wrote DEADBEEF to Address A", $time);

        // 3. Perform Read (Check Delay)
        @(posedge clk);
        ren = 1;
        raddr = 4'hA;
        @(posedge clk);
        ren = 0; // Pulse ren for one cycle
        $display("[%0t] Requested Read from Address A (ren high)", $time);

        // 4. Monitor pipeline
        repeat(DELAY + 1) begin
            @(posedge clk);
            $display("[%0t] rvalid: %b, rdata: %h", $time, rvalid, rdata);
        end

        #20 $finish;
    end
endmodule