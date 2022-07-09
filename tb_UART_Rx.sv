`include "globals.vh"
`timescale 1us/100ns

module tb_UART_Rx (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(0.5) clk = ~clk;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk);
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	localparam  rBAUD_COUNTER_MAX = `Rx_CLKRATE/`BAUD;
	localparam rBAUD_COUNTER_SIZE = $clog2(rBAUD_COUNTER_MAX);
	localparam   TOTAL_DATA_COUNT = `WORD_LENGTH;
	localparam  DATA_COUNTER_SIZE = $clog2(`WORD_LENGTH);

	logic                    UART_Tx_IN;
	logic                    err_ack;
	logic [`WORD_LENGTH-1:0] UART_pckt;

	UART_Rx inst_UART_Rx
		(
			.r_clk      (clk),
			.r_rst      (clk),
			.UART_Tx_IN (UART_Tx_IN),
			.err_ack    (err_ack),
			.UART_pckt  (UART_pckt)
		);

	task init();
		UART_Tx_IN <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			UART_Tx_IN <= '0;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		drive(20);

		repeat(10)@(posedge clk);
		$finish;
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_UART_Rx.fsdb");
			$fsdbDumpvars(0, "tb_UART_Rx", "+mda", "+functions");
		end
	end

endmodule
