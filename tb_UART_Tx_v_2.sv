`include "globals.vh"
`timescale 1us/100ns
module tb_UART_Tx_v_2 (); /* this is automatically generated */

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

	localparam  BAUD_COUNTER_MAX = (`Tx_CLKRATE)/(`BAUD);
	localparam BAUD_COUNTER_SIZE = $clog2(BAUD_COUNTER_MAX);
	localparam  TOTAL_DATA_COUNT = `WORD_LENGTH;
	localparam DATA_COUNTER_SIZE = $clog2(`WORD_LENGTH);

	logic                    rst;
	logic                    UART_Tx_RQST;
	logic [`WORD_LENGTH-1:0] Tx_DATA;
	logic                    UART_Tx_READY_BUSY;
	logic                    UART_Tx_OUT;

	UART_Tx_v_2 inst_UART_Tx_v_2
		(
			.rst           (rst),
			.clk           (clk),
			.UART_Tx_RQST  (UART_Tx_RQST),
			.Tx_DATA       (Tx_DATA),
			.UART_Tx_READY_BUSY (UART_Tx_READY_BUSY),
			.UART_Tx_OUT        (UART_Tx_OUT)
		);

	task init();
		rst          <= '1;
		UART_Tx_RQST <= '0;
		Tx_DATA      <= '0;
	endtask

	task drive();
		begin
			rst          <= '0;
			UART_Tx_RQST <= '1;
			Tx_DATA      <= 'b0101_0101+'b1;
		end
	endtask

	initial begin
		// do something

		init();
		repeat(BAUD_COUNTER_MAX*10)@(posedge clk);

		drive();

		repeat(BAUD_COUNTER_MAX*10)@(posedge clk);

		drive();
		
		repeat(BAUD_COUNTER_MAX*10)@(posedge clk);

		drive();
		
		repeat(BAUD_COUNTER_MAX*10)@(posedge clk);

		drive();
		
		
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_UART_Tx_v_2.fsdb");
			$fsdbDumpvars(0, "tb_UART_Tx_v_2", "+mda", "+functions");
		end
	end

endmodule
