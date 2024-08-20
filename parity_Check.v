module parity_Check #(parameter width=8) (
  input wire                par_chk_en,
  input wire                rst_check,
  input wire                sampled_bit,
  input wire                PAR_TYP,
  input wire [width-1:0]    P_DATA,
  input wire                clk,RST,
  output reg                par_err );
  
  reg par_bit;
  localparam Even_parity = 1'b0 ,Odd_parity = 1'b1;
     
  always@(posedge clk or negedge RST)
  begin
    if(!RST)
      begin
       par_err <= 1'b1;
      end
    else if(par_chk_en)
      begin
        if(sampled_bit == par_bit)
          par_err <= 1'b0;
        else
          par_err <= 1'b1;
      end
    else if(rst_check)
      par_err <= 1'b1;
    else
      par_err <= par_err;
  end
 
 always@(*)
 begin
  if(PAR_TYP == Even_parity)
    par_bit = ^P_DATA;
  else
    par_bit = ~^P_DATA;
 end
 
endmodule


