module Stop_Check  (
  input wire          stp_chk_en,
  input wire          sampled_bit,
  input wire          rst_check,
  input wire          clk,RST,
  output reg          stp_err );
  
  always@(posedge clk or negedge RST)
  begin
    if(!RST)
      stp_err <= 1'b1;
      
    else if(stp_chk_en)
      begin
        if(sampled_bit == 1'b1)
          stp_err <= 1'b0;
        else
          stp_err <= 1'b1;
      end
    else if(rst_check)
      stp_err <= 1'b1;
    else
      stp_err <= stp_err;
  end
  
endmodule


