module parity_calc #(parameter IN_data = 8)(
  input wire [IN_data-1 :0] P_DATA,
  input wire                Data_Valid,
  input wire                clk,
  input wire                RST,
  input wire                busy,
  input wire                PAR_TYP,
  output reg                par_bit );


  localparam Even_parity = 1'b0 ,Odd_parity = 1'b1;
  
always@(posedge clk, negedge RST)
begin
  if (!RST)
    par_bit <= 1'b0;
  else if(Data_Valid && !busy)
    if(PAR_TYP == Even_parity)
      par_bit <= ^P_DATA;
    else
      par_bit <= ~^P_DATA;
        
end
endmodule