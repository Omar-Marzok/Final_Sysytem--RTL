module System_TOP #(parameter DATA_WIDTH=8,RATIO_WD = 6)(
 input 	wire          			RX_IN_S,
 input 	wire          			RST,
 input 	wire          			REF_CLK,
 input 	wire          			UART_CLK,
 output wire         			framing_error,
 output wire          			parity_error,
 output wire                	TX_OUT_D );

 
wire 	clk_RX, clk_TX, RST_SYNC_2, RST_SYNC_1,
		Data_SYNC_EN, EMPTY, FULL, PULSE_IN, Rd_INC,
		EN_ALU, ALU_OUT_VALID, ALU_clk,CLK_EN, 
		RX_D_VLD, W_INC, RD_RrgF_V, RdEn_RF, WrEn_RF;
		
		
		

wire [DATA_WIDTH-1:0]	REG2, Data_UNSYNC, Data_SYNC,
						Rd_FIFO, Op_A, Op_B, WR_FIFO,
						RD_RrgF, REG3,WrData_RF;
						
wire [3:0]	ALU_FUN,Address;
wire [(2*DATA_WIDTH)-1 :0]	ALU_OUT;
wire	[5:0] div_ratio;
/////////////////////// UART /////////////////
UART_TOP #(.DATA_WIDTH(DATA_WIDTH))UART_TOP_U0 (
.RX_IN_S(RX_IN_S),
.Prescale(REG2[7:2]),
.PAR_TYP(REG2[1]),
.PAR_EN(REG2[0]),
.clk_RX(clk_RX),
.RST(RST_SYNC_2),
.RX_OUT_V(Data_SYNC_EN),
.RX_OUT_P(Data_UNSYNC),
.framing_error(framing_error),
.parity_error(parity_error),
.TX_IN_V(!EMPTY),  
.clk_TX(clk_TX),
.TX_IN_P(Rd_FIFO),
.TX_OUT_busy(PULSE_IN),
.TX_OUT_D(TX_OUT_D) 
);

//////////////////// Prescale_MUX //////////////////
CLKDIV_MUX CLKDIV_MUX_U0(
.prescale(REG2[7:2]),
.Div_Ratio(div_ratio)
);

/////////////////// clock divider ////////////////////
ClkDiv #(.RATIO_WD(RATIO_WD)) ClkDiv_TX ( 
.i_ref_clk(UART_CLK),
.i_rst_n(RST_SYNC_2),
.i_clk_en(REG3[7]),
.i_div_ratio(REG3[5:0]),
.o_div_clk(clk_TX)
);

ClkDiv #(.RATIO_WD(RATIO_WD)) ClkDiv_RX ( 
.i_ref_clk(UART_CLK),
.i_rst_n(RST_SYNC_2),
.i_clk_en(REG3[7]),
.i_div_ratio(div_ratio),
.o_div_clk(clk_RX)
);

///////////////// ALU ///////////////////
ALU #(.IN_WIDTH(DATA_WIDTH),.OUT_WIDTH(2*DATA_WIDTH)) ALU_U0(
.A(Op_A), 
.B(Op_B),
.ALU_FUN(ALU_FUN),
.Enable(EN_ALU),
.clk(ALU_clk),
.RST(RST_SYNC_1),
.ALU_OUT(ALU_OUT),
.OUT_VALID(ALU_OUT_VALID)
);

/////////////// clock gating ///////////
CLK_GATE  CLK_GATE_U0(
.clk(REF_CLK),
.CLK_EN(CLK_EN),
.GATED_CLK(ALU_clk)
);

////////////// RST SYNC /////////////////
RST_SYNC RST_SYNC_U1(
.clk(REF_CLK),
.RST(RST),
.SYNC_RST(RST_SYNC_1)
);

RST_SYNC RST_SYNC_U2(
.clk(UART_CLK),
.RST(RST),
.SYNC_RST(RST_SYNC_2)
);

//////////////// Data SYNC //////////////////
DATA_SYNC #(.BUS_WIDTH(DATA_WIDTH)) DATA_SYNC_u0 (
.bus_enable(Data_SYNC_EN),
.unsync_bus(Data_UNSYNC),
.clk(REF_CLK),
.RST(RST_SYNC_1),
.enable_pulse(RX_D_VLD),
.sync_bus(Data_SYNC)
);

/////////////// pulse generator /////////////////
PULSE_GEN PULSE_GEN_u0 (
.clk(clk_TX),
.RST(RST_SYNC_2),
.lvl_sig(PULSE_IN),
.pulse_sig(Rd_INC)
);

/////////////// ASYNC FIFO ///////////////////////

FIFO_top #(.DATA_WIDTH(DATA_WIDTH)) FIFO_U0(
.W_CLK(REF_CLK),
.W_RST(RST_SYNC_1),
.W_INC(W_INC),
.R_CLK(clk_TX),
.R_RST(RST_SYNC_2),
.R_INC(Rd_INC),
.WR_DATA(WR_FIFO),
.RD_DATA(Rd_FIFO),
.FULL(FULL),
.EMPTY(EMPTY)
);

////////////// Register file ///////////////////
register_file #(.WIDTH(DATA_WIDTH)) Reg_File_u0(
.WrData(WrData_RF),
.Address(Address),
.clk(REF_CLK),
.RST(RST_SYNC_1),
.WrEn(WrEn_RF),
.RdEn(RdEn_RF),
.RdData_Valid(RD_RrgF_V),
.REG0(Op_A),
.REG1(Op_B),
.REG2(REG2),
.REG3(REG3),
.RdData(RD_RrgF) 
);

////////////// System control ////////////////////
SYS_CTRL #(.DATA_WIDTH(DATA_WIDTH),.ALU_O_WIDTTH(2*DATA_WIDTH)) SYS_CTRL_u0 (
.ALU_OUT(ALU_OUT),
.OUT_Valid(ALU_OUT_VALID),
.RdData(RD_RrgF),
.RdData_Valid(RD_RrgF_V),
.RX_P_DATA(Data_SYNC),
.RX_D_VLD(RX_D_VLD),
.FIFO_FULL(FULL),
.clk(REF_CLK),
.RST(RST_SYNC_1),
.ALU_FUN(ALU_FUN),
.EN(EN_ALU),
.CLK_EN(CLK_EN),
.Address(Address),
.WrEn(WrEn_RF),
.RdEn(RdEn_RF),
.WrData(WrData_RF),
.TX_P_DATA(WR_FIFO),
.TX_D_VLD(W_INC)
);


endmodule