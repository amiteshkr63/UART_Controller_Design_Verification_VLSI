`ifndef "GUARD_TRANSACTION"
`define "GUARD_TRANSACTION"

class Transaction;
	
	rand bit tr_UART_Tx_RQST;
	randc bit [`WORD_LENGTH-1:0]tr_Tx_DATA;///************************************///////////////
	bit tr_UART_Tx_READY_BUSY;
	bit [`WORD_LENGTH-1:0]tr_UART_pckt;
	constraint  golden_data{tr_Tx_DATA inside {'h00,'hff, 'haa, 'h55, [1:80]};}
	
	function void driver_display();
		$display("===========Generated Packet==============");
		$display($time, " Tx_Data=%8b", tr_Tx_DATA);
		$display("UART_Tx_READY_BUSY=%b", tr_UART_Tx_READY_BUSY);
	endfunction : driver_display

	function void receiver_display();
		$display("===========Received Packet==============");
		$display($time, " Rx_Pckt=%8b", tr_UART_pckt);
	endfunction : receiver_display

	function void assign(ref logic [7:0]temp);		//Capturing Receiver output from Receiver module
		this.tr_UART_pckt=temp;
	endfunction : assign

	function int compare(ref Transaction tr_expctd);
		if(this.tr_Tx_DATA==tr_expctd.tr_UART_pckt) begin
			$display("Transmitted packet EQUAL to Recieved packet");
			return 1;
		end
		else begin
			$display("Transmitted packet NOT EQUALS to Recieved packet");
			return 0;
		end
			
	endfunction : compare
endclass : Transaction