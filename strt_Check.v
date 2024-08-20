module strt_Check  (
  input wire          strt_chk_en,
  input wire          sampled_bit,
  input wire          rst_check,
  input wire          clk,RST,
  output reg          strt_glitch );
  
  always@(posedge clk or negedge RST)
  begin
    if(!RST)
      strt_glitch <= 1'b0;
      
    else if(strt_chk_en)
      begin
        if(sampled_bit == 1'b0)
          strt_glitch <= 1'b0;
        else
          strt_glitch <= 1'b1;
      end
    else if(rst_check)
      strt_glitch <= 1'b0;
    else
      strt_glitch <= strt_glitch;
  end
  
endmodule
