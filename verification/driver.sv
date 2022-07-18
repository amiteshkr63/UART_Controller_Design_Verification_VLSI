`include "transaction.sv"
`include "globals.vh"

class Driver;
	virtual intf.t_mp input_intf;
	mailbox drvr2sb;

	//Constructor
	function new(virtual intf.t_mp input_intf/*input_intf_new*/, mailbox drvr2sb);
		this.input_intf=input_intf;/*input_intf_new*/
		if(drvr2sb==null) begin
			$display("ERROR: drvr2sb is null\n");
			$finish;
		end
		else begin
			this.drvr2sb=drvr2sb;
		end
	endfunction : new

	//Method to send the packet to DUT
	task start();
		Transaction d_tr;
		repeat(`NO_OF_PACKETS) begin
			wait(input_intf.t_cb.UART_Tx_READY_BUSY);
			d_tr=new();
			if(tr.randomize()) begin
				$display("Randomization Successful\n");
				d_tr.driver_display();
				//@(posedge input_intf.t_clk)
				input_intf.t_cb.Tx_DATA<=d_tr.tr_Tx_DATA;
				input_intf.t_cb.UART_Tx_RQST<=d_tr.tr_UART_Tx_RQST;
				drvr2sb.put(d_tr);
			end
			else begin
				$display("Randomize Not Successful\n");
				ERROR++;
			end
		end
	endtask : start

endclass : Driver