`include "globals.vh"
	
	logic t_rst;
	logic r_rst;
	logic UART_Tx_RQST;
	logic [`WORD_LENGTH-1:0]Tx_DATA;
	logic UART_Tx_READY_BUSY;
	logic [`WORD_LENGTH-1:0]UART_pckt;
	
	clocking t_cb(posedge t_clk);
		default input #1 output #1;
		output Tx_DATA;
		output UART_Tx_RQST;
		input UART_Tx_READY_BUSY;
	endclocking

	clocking r_cb(posedge r_clk);
		default input #1 output #1;
		input UART_pckt;
	endclocking

	modport t_mp (clocking t_cb, output t_rst, input t_clk);
	modport r_mp (clocking r_cb, output r_rst, input r_clk);

endinterface : intf