module deserializer #(parameter width=8) (
  input wire                sampled_bit,
  input wire                deser_en,
  input wire                clk,
  input wire                RST,
  output reg  [width-1:0]   P_DATA );
  
  reg [3:0] i ;
  
  always@(posedge clk or negedge RST)
  begin
    if(!RST)
      begin
       P_DATA <= 8'b0;
       i <= 4'b0;
     end
    else if(deser_en)
      begin
        i <= i + 4'b1;
        P_DATA[i] <= sampled_bit;
      end
    else
      begin
       P_DATA <= P_DATA;
       if (i >= 4'd8)
         i <= 4'b0;
       else
         i <= i;
      end
  end
  
  
endmodule
