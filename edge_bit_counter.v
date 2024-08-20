module edge_bit_counter #(parameter width=6) (
// define input ports
  input wire   		    enable,
  input wire  [width-1 : 0] Prescale,  //prescale 8,16 or 32
  input wire       clk,
  input wire       RST,

// define output ports
  output reg  [width-1 : 0] edge_cnt,
  output reg  [3:0]   bit_cnt );

always @(posedge clk or negedge RST)
 begin
  if(!RST)
   begin
     bit_cnt <= 'b0;
     edge_cnt <= 'b0;
   end
  else if (enable)
   begin
	  edge_cnt <= edge_cnt + 1'b1;
	  if (edge_cnt == Prescale-1)
	   begin
	    edge_cnt <= 'b0;
	    bit_cnt <= bit_cnt + 1'b1;
	   end
	 end
  else
	   begin
	    bit_cnt <= 'b0;
	    edge_cnt <= 'b0;
	   end
end

endmodule
