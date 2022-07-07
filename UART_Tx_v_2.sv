`include "globals.vh"

module UART_Tx_v_2 (rst, clk, UART_Tx_RQST, Tx_DATA, UART_Tx_READY_BUSY, UART_Tx_OUT);

input rst;							//Reset Signal
input clk;							//Clock Signal
input UART_Tx_RQST;					//Request from APB to UART Tx 
input [`WORD_LENGTH-1:0]Tx_DATA;	//Data from APB to UART Tx
output reg UART_Tx_READY_BUSY;			//Acknowledgement from UART about of its status to APB
output reg UART_Tx_OUT;					//UART Tx OUT

//BUFFER SIZE
reg [`WORD_LENGTH:0]UART_BUFFER;

//Internal Connections
wire data_count_done;
wire baud_count_done;
logic DATA_COUNTER_STATUS;

//FSM STATES
typedef enum{IDLE, uSTART, DATA, STOP}states;
states PST, NST;

//Baud Count and Handling
localparam BAUD_COUNTER_MAX= `CLKRATE/`BAUD;
localparam BAUD_COUNTER_SIZE=$clog2(BAUD_COUNTER_MAX);

//Data Count and Handling
localparam TOTAL_DATA_COUNT=`WORD_LENGTH;
localparam DATA_COUNTER_SIZE=$clog2(`WORD_LENGTH);

//Baud and Data Counter
logic [BAUD_COUNTER_SIZE:0]baud_counter;
logic [DATA_COUNTER_SIZE:0]data_counter;

//Baud Rate Handling
always@(posedge clk) begin
	if(rst)
		begin
			baud_counter<=0;
		end
	else
		begin
			if(baud_count_done) begin
				baud_counter<='d0;
			end 
			else
				baud_counter<=baud_counter+'d1;
		end
end

//To detect the "TICK"
assign baud_count_done=(baud_counter==BAUD_COUNTER_MAX)?1'b1:1'b0;

//Data Counter Handling
always@(posedge clk) begin
	if(rst || DATA_COUNTER_STATUS==`COUNTER_STOP || data_count_done) begin
		data_counter<='b0;
	end
	else if(baud_count_done) begin
		data_counter<=data_counter+'d1;
		//UART_BUFFER<=UART_BUFFER>>1'b1;
	end
	else
	begin
		data_counter<=data_counter;
	end
end
assign data_count_done=(data_counter=='d8)?1'b1:1'b0;
//Present state Assignment
always_ff @(posedge clk or posedge rst) begin 
	if(rst) begin
		PST<=IDLE;
	end
	else begin
		PST<=NST;
	end
end

//FSM STATES
always_comb begin 
	case(PST)
		IDLE: 
			begin
				if (UART_Tx_RQST) begin
					NST=uSTART;
				end
				else begin
					NST=PST;
				end
			end
		uSTART:
			begin
				if (baud_count_done) begin
					NST=DATA;
				end
				else begin
					NST=PST;
				end
			end
		DATA:
			begin
				if (data_count_done) begin
					NST=STOP;
				end
				else begin
					NST=PST;
				end 
			end
		STOP:
			begin
				case(baud_count_done & UART_Tx_RQST) 
					'b00:NST=STOP;
					'b01:NST=STOP;
					'b11:NST=uSTART;
					default: NST=IDLE;
				endcase
			end
	endcase
end

//Tx_OUT ASSIGNMENT
always_comb begin
	case(PST)
		IDLE: 
			begin
				DATA_COUNTER_STATUS=`COUNTER_STOP;
				UART_Tx_READY_BUSY=`Tx_READY;
				UART_Tx_OUT=`UART_IDLE;
			end
		uSTART:	
			begin
				
				UART_BUFFER=Tx_DATA;
				UART_BUFFER[`WORD_LENGTH]=^UART_BUFFER[`WORD_LENGTH-1:0];
				UART_Tx_READY_BUSY=`Tx_BUSY;
				UART_Tx_OUT=`UART_START;
			end
		DATA:
			begin
				DATA_COUNTER_STATUS=`COUNTER_START;
				UART_Tx_READY_BUSY=`Tx_BUSY;
				//UART_Tx_OUT=UART_BUFFER[0];				ERROR-> vlog-7033 (Error (suppressible): always_ff with ModelSim)
				UART_Tx_OUT=UART_BUFFER[data_counter];
				//UART_BUFFER=UART_BUFFER>>1;
				if(data_counter=='d8 & baud_count_done) begin //////////////////////////////////////
					DATA_COUNTER_STATUS=`COUNTER_STOP;
				end
			end
		STOP:
			begin
				//DATA_COUNTER_STATUS=`COUNTER_STOP;
				UART_BUFFER=0;
				UART_Tx_READY_BUSY=`Tx_READY;
				UART_Tx_OUT=`UART_STOP;
			end
	endcase	
end
//UART_Tx_OUT states
endmodule : UART_Tx_v_2