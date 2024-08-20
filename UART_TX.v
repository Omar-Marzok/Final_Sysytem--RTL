module UART_TX #(parameter IN_data=8)( 
  input  wire                Data_Valid,  
  input  wire                PAR_EN,
  input  wire                clk,
  input  wire                RST,
  input  wire [IN_data-1 :0] P_DATA,
  input  wire                PAR_TYP,
  output wire                busy,
  output wire                TX_OUT );
 
 wire ser_done;
 wire ser_en;
 wire par_bit;
 wire [1:0] mux_sel;
 wire ser_data;

FSM_TX fsm (
.Data_Valid(Data_Valid),
.ser_done(ser_done),
.PAR_EN(PAR_EN),
.clk(clk),
.RST(RST),
.ser_en(ser_en),
.mux_sel(mux_sel),
.busy(busy) );

MUX mux (
.mux_sel(mux_sel),
.ser_data(ser_data),
.par_bit(par_bit),
.clk(clk),
.RST(RST),  
.TX_OUT(TX_OUT));

parity_calc #(.IN_data(IN_data)) par (
.P_DATA(P_DATA),
.Data_Valid(Data_Valid),
.clk(clk),
.RST(RST),
.busy(busy),
.PAR_TYP(PAR_TYP),
.par_bit(par_bit) );

serializer #(.IN_data(IN_data)) ser (
.P_DATA(P_DATA),
.Data_Valid(Data_Valid),
.ser_en(ser_en),
.busy(busy),
.clk(clk),
.RST(RST),
.ser_Data(ser_data),
.ser_done(ser_done) );

endmodule
