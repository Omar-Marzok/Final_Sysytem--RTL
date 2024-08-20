module register_file #(parameter WIDTH = 8, DEPTH =16)(
  
 input  wire  [WIDTH-1:0]      		WrData,
 input  wire  [$clog2(DEPTH)-1:0]   Address,
 input  wire              			clk,
 input  wire              			RST,
 input  wire              			WrEn,
 input  wire              			RdEn,
 output reg							RdData_Valid,
 output wire  [WIDTH-1:0]      		REG0,REG1,REG2,REG3,
 output reg   [WIDTH-1:0]      		RdData );

reg [WIDTH-1:0] Reg_File [0:DEPTH-1];
integer i;

always @(posedge clk, negedge RST) 
begin
    if (!RST) 
	begin
		RdData <= 'b0;
		RdData_Valid <=1'b0;
        for (i=0; i < DEPTH; i=i+1)
		begin
			if(i == 2)
				/* UART config 
				REG2[0]: Parity Enable(Default = 1)
				REG2[1]: Parity Type(Default = 0)
				REG2[7:2]: Prescale(Default = 32)*/
				Reg_File[i] <= 8'b1000_0001;
			else if (i == 3)
				// Div Ration config REG3[5:0]: Division ratio(Default = 32)
				// REG3[7]: CLK_DIV EN
				Reg_File[i] <= 8'b1010_0000;
			else
				Reg_File[i] <= 8'b0000_0000;
		end
	end
	else if (WrEn && !RdEn)
    begin
        Reg_File[Address] <= WrData; 
    end
    else if (RdEn && !WrEn)
    begin
        RdData <= Reg_File[Address];
		RdData_Valid <= 1'b1;
    end
	else
		RdData_Valid <= 1'b0;
 end
 
assign REG0 = Reg_File[0];
assign REG1 = Reg_File[1];
assign REG2 = Reg_File[2];
assign REG3 = Reg_File[3];
 
 
endmodule


