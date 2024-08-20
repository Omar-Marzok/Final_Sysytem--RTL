module UART_TOP #(parameter DATA_WIDTH=8)(
 input 	wire          			RX_IN_S,
 input 	wire  [5:0]   			Prescale,
 input 	wire          			PAR_TYP,
 input 	wire          			PAR_EN,
 input 	wire          			clk_RX,
 input 	wire          			RST,
 output wire         			RX_OUT_V,
 output wire  [DATA_WIDTH-1:0]  RX_OUT_P,
 output wire         			framing_error,
 output wire          			parity_error,
 input  wire                	TX_IN_V,  
 input  wire                	clk_TX,
 input  wire [DATA_WIDTH-1 :0]  TX_IN_P,
 output wire                	TX_OUT_busy,
 output wire                	TX_OUT_D );


UART_TX #(.IN_data(DATA_WIDTH)) U0_UART_TX ( 
.Data_Valid(TX_IN_V),  
.PAR_EN(PAR_EN),
.clk(clk_TX),
.RST(RST),
.P_DATA(TX_IN_P),
.PAR_TYP(PAR_TYP),
.busy(TX_OUT_busy),
.TX_OUT(TX_OUT_D) 
  );
  
  
UART_RX U0_UART_RX(
.RX_IN(RX_IN_S),
.Prescale(Prescale),
.PAR_TYP(PAR_TYP),
.PAR_EN(PAR_EN),
.clk(clk_RX),
.RST(RST),
.data_valid(RX_OUT_V),
.P_DATA(RX_OUT_P),
.stp_err(framing_error),
.par_err(parity_error)
);

endmodule