`include "transaction.sv"
`include "globals.vh"
class Receiver;
	virtual intf.r_mp output_intf;
	mailbox rcvr2sb;

	//Constructor
	function new(virtual intf.r_mp output_intf/*output_intf_new*/);
		this.output_intf=output_intf/*output_intf_new*/;
		if(rcvr2sb==null) begin
			$display("**ERROR**:rcvr2sb is null");
			$finish;
		end
		else
			this.rcvr2sb=rcvr2sb;
	endfunction : new

	//Method to receive the packet to DUT
	task start();
		Transaction r_tr;
		logic [7:0]temp;
		forever begin
			wait(input_intf.t_mp.t_cb.UART_Tx_READY_BUSY)
			begin
				temp=output_intf.r_cb.tr_UART_pckt;
				r_tr=new();
				r_tr.assign(temp);
				r_tr.receiver_display();
				rcvr2sb.put(r_tr);
			end
			repeat(1040)@(posedge input_intf.clk);
		end
	endtask : start
endclass : Receiver