
module data_sampling #(parameter width=6) (
// define input ports
  input wire       RX_IN,
  input wire  [width-1 : 0] Prescale,  //prescale 8,16 or 32
  input wire       dat_samp_en,
  input wire       clk,
  input wire       RST,
  input wire 	[width-1 : 0]   edge_cnt,

// define output ports
  output reg    sampled_bit );

 reg [1:0] sum;


always @(posedge clk or negedge RST)
 begin
  if(!RST)
   begin
     sampled_bit <= 1'b0;
     sum         <= 2'b00;
   end
  else if (dat_samp_en)
   begin
    if ((edge_cnt >= (Prescale/2 - 1)) && (edge_cnt <= (Prescale/2 + 1)))
      begin
        sum <= sum + RX_IN;
      end
    else if ((Prescale/2 +2) == edge_cnt)
      begin
        sampled_bit <= (sum > 1)? 1:0;
      end
    else
        sum <= 2'b00;  
   end
  end

endmodule