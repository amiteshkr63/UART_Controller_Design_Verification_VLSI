`include "globals.vh"
`timescale 1us/100ns
module top_tb ();
reg t_rst, t_clk, UART_Tx_RQST;
reg [`WORD_LENGTH-1:0]Tx_DATA;
wire UART_Tx_READY_BUSY, UART_Tx_OUT;
reg	r_clk, r_rst;
wire [`WORD_LENGTH-1:0]UART_pckt;  
	top inst_top
		(
			.t_rst              (t_rst),
			.t_clk              (t_clk),
			.UART_Tx_RQST       (UART_Tx_RQST),
			.Tx_DATA            (Tx_DATA),
			.UART_Tx_READY_BUSY (UART_Tx_READY_BUSY),
			.UART_Tx_OUT        (UART_Tx_OUT),
			.r_clk              (r_clk),
			.r_rst              (r_rst),
			.err_ack            (err_ack),
			.UART_pckt          (UART_pckt)
		);
initial begin
	{t_clk, t_rst, r_clk, r_rst}=4'b0101;
	#10;
	{t_rst, r_rst}=2'b00;
	{UART_Tx_RQST, Tx_DATA}=9'h1ff;
end

always #1 t_clk=~t_clk;
always #1 r_clk=~r_clk;

always begin
	Tx_DATA=$random;
	#10000;
end
endmodule : top_tb