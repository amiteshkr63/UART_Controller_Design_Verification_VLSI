class Scoreboard;
	mailbox drvr2sb;
	mailbox rcvr2sb;

	function new();
		this.drvr2sb=drvr2sb;
		this.rcvr2sb=rcvr2sb;
	endfunction : new

	task start();
		Transaction tr_rcvd, tr_expctd;
		forever begin
			rcvr2sb.get(tr_rcvd);
			$display("%0d: Scoreboard received a packet from receiver",$time);
			drvr2sb.get(tr_expctd);
			if(tr_rcvd.compare(tr_expctd))
				$display("%0d: Scoreboard : Packet Matched",$time);
			else begin
				$display("%0d: Scoreboard : Packet Not Matched",$time);
				ERROR++;
			end
				
		end
	endtask : start
	
endclass : Scoreboard