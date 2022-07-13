`include "globals.vh"

module top (t_rst, t_clk, UART_Tx_RQST, Tx_DATA, UART_Tx_READY_BUSY,
	r_clk, r_rst, UART_pckt);

//UART_Tx
input t_rst;
input t_clk;
input UART_Tx_RQST;					//Request from APB to UART Tx 
input [`WORD_LENGTH-1:0]Tx_DATA;	//Data from APB to UART Tx
output UART_Tx_READY_BUSY;			//Acknowledgement from UART about of its status to APB
output [`WORD_LENGTH-1:0]UART_pckt;
wire UART_Tx_OUT;					//From UART_Tx to UART_Rx
wire err_ack;						//After verifying Parity ack from Rx to Tx

//UART_Rx
input r_clk;  
input r_rst;					
wire [`WORD_LENGTH-1:0]UART_pckt;  //After receiving 8bits of data from UART_Tx, UART_Rx outs packet of 8bits  	

UART_Tx_v_2 inst_UART_Tx_v_2
	(
		.rst                (t_rst),
		.clk                (t_clk),
		.UART_Tx_RQST       (UART_Tx_RQST),
		.Tx_DATA            (Tx_DATA),
		.UART_Tx_READY_BUSY (UART_Tx_READY_BUSY),
		.UART_Tx_OUT        (UART_Tx_OUT),
		.err_ack            (err_ack)
	);

UART_Rx inst_UART_Rx
	(
		.r_clk      (r_clk),
		.r_rst      (r_rst),
		.UART_Tx_IN (UART_Tx_OUT),
		.err_ack    (err_ack),
		.UART_pckt  (UART_pckt)
	);

endmodule : top