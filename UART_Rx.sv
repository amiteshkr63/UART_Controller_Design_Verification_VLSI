`include "globals.vh"
module UART_Rx (
	input r_clk,  
	input r_rst,
	input UART_Tx_IN,					//From UART_Tx to UART_Rx
	output reg err_ack,						//After verifying Parity ack from Rx to Tx
	output reg [`WORD_LENGTH-1:0]UART_pckt  //After receiving 8bits of data from UART_Tx, UART_Rx outs packet of 8bits  	
);
//UART Rx Buffer Declaration
reg [`WORD_LENGTH:0]UART_Rx_BUFFER;	//storing all 8bits of data + parity

//Internal connections
wire rdata_count_done;
wire rbaud_count_done;
reg sync_UART_Tx_IN;					//Dual FF sychronizer out of signal UART_Tx_IN
logic rDATA_COUNTER_STATUS;

//FSM states
typedef enum{IDLE, START, STORE, PCKT_OUT}states;
states PST, NST;

//Baud Count and Handling
localparam rBAUD_COUNTER_MAX= `Rx_CLKRATE/`BAUD;
localparam rBAUD_COUNTER_SIZE=$clog2(rBAUD_COUNTER_MAX);

//Data Count and Handling
localparam TOTAL_DATA_COUNT=`WORD_LENGTH + `PARITY_LENGTH;
localparam DATA_COUNTER_SIZE=$clog2(`WORD_LENGTH);

//Baud and Data Counter
logic [rBAUD_COUNTER_SIZE:0]rbaud_counter;
logic [DATA_COUNTER_SIZE:0]rdata_counter;

//Dual FF synchronizer 
reg temp;
always@(posedge r_clk , posedge r_rst) begin
	if (r_rst) begin
		{temp, sync_UART_Tx_IN}<=2'b11;
	end
	else begin
		{temp, sync_UART_Tx_IN}<={UART_Tx_IN, temp};
	end
end

//Baud rate Handling
always@(posedge r_clk) begin
	if (r_rst) begin
		rbaud_counter<=0;
	end
	else begin
		if(rbaud_count_done) begin
			rbaud_counter<=0;
		end
		else begin
			rbaud_counter<=(NST!=IDLE)?rbaud_counter+'d1:rbaud_counter;//////////////////////////////
		end
	end
end

//To detect the "TICK"
assign rbaud_count_done=(rbaud_counter==rBAUD_COUNTER_MAX-'d1)?1'b1:1'b0;
//Subtracted "1" to sync sync_UART_Tx_IN with rbaud_count_done

//Data Counter Handling
always@(posedge r_clk) begin
	if (r_rst || rdata_count_done || rDATA_COUNTER_STATUS==`COUNTER_STOP) begin
		rdata_counter<=0;
	end
	else if(rbaud_count_done) begin
		rdata_counter<=rdata_counter+'d1;
	end
	else begin
		rdata_counter<=rdata_counter;
	end
end
assign rdata_count_done=((rdata_counter==(TOTAL_DATA_COUNT-'d1)) & rbaud_count_done)?1'b1:1'b0;

//Present state assignments
always_ff @(posedge r_clk or posedge r_rst) begin
	if(r_rst) begin
		 PST<= IDLE;
	end else begin
		 PST<=NST;
	end
end

//FSM Machine
always_comb begin
	case(PST)
		IDLE:
			begin
				if(~sync_UART_Tx_IN) begin
					NST=START;
				end
				else begin
					NST=PST;
				end
			end
		START:
			begin
				if(rbaud_count_done) begin
					NST=STORE;
				end
				else begin
					NST=PST;
				end
			end
		STORE:
			begin
				if(rdata_count_done) begin
					NST=PCKT_OUT;
				end
				else begin
					NST=PST;
				end
			end
		PCKT_OUT:
			begin
				case ({rbaud_count_done, sync_UART_Tx_IN})
					'b00:NST=PST;
					'b01:NST=PST;
					'b10:NST=START;
					default:NST=IDLE;
				endcase
			end
	endcase
end

//UART_pckt and Error handlings
always_comb begin 	//To get rid of overwriting at the same location of UART_Buffer twice when sync_UART_Tx_IN changes
//always@(negedge rbaud_count_done) begin
	case(PST)
	IDLE:	begin
				{UART_pckt, err_ack}=2'b0;
				rDATA_COUNTER_STATUS=`COUNTER_STOP;
			end
	START:	begin
				{UART_pckt, err_ack}=2'b0;
				UART_Rx_BUFFER='b0;
				rDATA_COUNTER_STATUS=`COUNTER_STOP;
			end
	STORE:	
		begin
			rDATA_COUNTER_STATUS=`COUNTER_START;
			{UART_pckt, err_ack}=2'b0;
			UART_Rx_BUFFER[rdata_counter]=(rbaud_count_done==1'b0)?sync_UART_Tx_IN:UART_Rx_BUFFER[rdata_counter];
			if(rdata_counter=='d8 & rbaud_count_done) begin //////////////////////////////////////
				rDATA_COUNTER_STATUS=`COUNTER_STOP;
			end
		end
	PCKT_OUT:
		begin
			UART_pckt=UART_Rx_BUFFER[`WORD_LENGTH-1:0];
			if((UART_Rx_BUFFER[`WORD_LENGTH]==^UART_Rx_BUFFER[`WORD_LENGTH-1:0]) | sync_UART_Tx_IN) begin
				//At this state we expect a STOP bit, if not raise errr
				//Verifying parity, if not verified raise err
				err_ack=`PCKT_OK;
			end
			else begin
				err_ack=`PCKT_NOT_OK;
			end
		end
	endcase 
	end
endmodule : UART_Rx