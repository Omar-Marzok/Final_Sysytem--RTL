module UART_RX (
 input wire          RX_IN,
 input wire  [5:0]   Prescale,
 input wire          PAR_TYP,
 input wire          PAR_EN,
 input wire          clk,
 input wire          RST,
 output wire         data_valid,
 output wire  [7:0]   P_DATA,
 output wire          stp_err,
 output wire          par_err
);

   wire   [3:0]  bit_cnt;
   wire   [5:0]  edge_cnt;
   wire          strt_glitch;
   wire          dat_samp_en;
   wire          enable;
   wire          par_chk_en;
   wire          strt_chk_en;
   wire          stp_chk_en;
   wire          deser_en;
   wire          rst_check;
   wire          sampled_bit;
   
FSM_RX link1 (
  .RX_IN(RX_IN),
  .bit_cnt(bit_cnt),
  .PAR_EN(PAR_EN),
  .clk(clk),
  .RST(RST),
  .edge_cnt(edge_cnt),
  .par_err(par_err),
  .strt_glitch(strt_glitch),
  .stp_err(stp_err),
  .Prescale(Prescale),
  .dat_samp_en(dat_samp_en),
  .enable(enable),
  .par_chk_en(par_chk_en),
  .strt_chk_en(strt_chk_en),
  .stp_chk_en(stp_chk_en),
  .deser_en(deser_en),
  .rst_check(rst_check),
  .data_valid(data_valid) );
  
  
parity_Check link2 (
  .par_chk_en(par_chk_en),
  .rst_check(rst_check),
  .sampled_bit(sampled_bit),
  .PAR_TYP(PAR_TYP),
  .P_DATA(P_DATA),
  .clk(clk),
  .RST(RST),
  .par_err(par_err) );
  
Stop_Check link3 (
  .stp_chk_en(stp_chk_en),
  .sampled_bit(sampled_bit),
  .rst_check(rst_check),
  .clk(clk),
  .RST(RST),
  .stp_err(stp_err) );
  
strt_Check link4 (
  .strt_chk_en(strt_chk_en),
  .sampled_bit(sampled_bit),
  .rst_check(rst_check),
  .clk(clk),
  .RST(RST),
  .strt_glitch(strt_glitch) );
  
edge_bit_counter link5 (
  .enable(enable),
  .Prescale(Prescale),
  .clk(clk),
  .RST(RST),
  .edge_cnt(edge_cnt),
  .bit_cnt(bit_cnt) );
  
deserializer link6 (
  .sampled_bit(sampled_bit),
  .deser_en(deser_en),
  .clk(clk),
  .RST(RST),
  .P_DATA(P_DATA) );
  
data_sampling link7 (
  .RX_IN(RX_IN),
  .Prescale(Prescale),
  .dat_samp_en(dat_samp_en),
  .clk(clk),
  .RST(RST),
  .edge_cnt(edge_cnt),
  .sampled_bit(sampled_bit) );


endmodule 