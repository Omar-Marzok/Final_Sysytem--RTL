module ALU #(parameter IN_WIDTH=8,OUT_WIDTH=16)(
  input   wire  [IN_WIDTH-1:0] 	A,
  input   wire  [IN_WIDTH-1:0] 	B,
  input   wire  [3:0]  			ALU_FUN,
  input	  wire					Enable,
  input   wire         			clk,RST,
  output  reg   [OUT_WIDTH-1:0] ALU_OUT,
  output  reg         			OUT_VALID);
  
  reg [OUT_WIDTH-1:0] result;
  
always @(posedge clk or negedge RST)
begin
	if(!RST)
	begin
		ALU_OUT	<='b0;
		OUT_VALID <= 0;
	end
	else if (Enable)
    begin
		ALU_OUT <= result;
		OUT_VALID <= 1;
    end
	else
		OUT_VALID <= 0;
end 
 always @(*)
    begin
      case(ALU_FUN)
        4'b0000: begin
                  result      = A+B ;
                 end
        4'b0001: begin
                  result      = A-B ;
                 end
        4'b0010: begin
                  result      = A*B ;
                 end
        4'b0011: begin
                  result      = A/B ;
                 end 
        4'b0100: begin
                  result      = A&B ;
                 end                 
        4'b0101: begin
                  result      = A|B ;
                 end                
        4'b0110: begin
                  result      = ~(A & B);
                 end               
        4'b0111: begin
                  result      = ~(A | B) ;
                 end                
        4'b1000: begin
                  result      = A^B ;
                 end                
        4'b1001: begin
                  result      = A~^B;
                 end               
        4'b1010: begin
                  result      = (A == B)? 'd1 : 'b0 ;
                 end                 
        4'b1011: begin
                  result      = (A > B)? 'd1 : 'b0 ;
                 end            
        4'b1100: begin
                  result      = (A < B)? 'd1 : 'b0 ;
                 end            
        4'b1101: begin
                  result      = A >> 1 ;
                 end            
        4'b1110: begin
                  result      = A << 1 ;
                 end           
        default: begin
                  result      = 'b0 ;
                 end 
      endcase        
    end
 

endmodule

