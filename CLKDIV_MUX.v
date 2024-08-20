module CLKDIV_MUX (
input  wire	[5:0] prescale,
output reg	[5:0] Div_Ratio
);

always@(*)
begin
	case(prescale)
	6'b001000: Div_Ratio = 'b100;
	6'b010000: Div_Ratio = 'b010;
	6'b100000: Div_Ratio = 'b001;
	default	 : Div_Ratio = 'b001;
	endcase
end


endmodule