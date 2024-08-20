module CLK_GATE  (
    input wire      clk,
    input wire     	CLK_EN,
    output wire      GATED_CLK
);

reg latch;

always @(clk or CLK_EN)
 begin 
	if(!clk)
		latch <= CLK_EN;
 end

 assign GATED_CLK = clk & latch;
 
endmodule 