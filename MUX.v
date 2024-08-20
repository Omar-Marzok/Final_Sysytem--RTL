module MUX (
  input wire [1:0] mux_sel,
  input wire       ser_data,
  input wire       par_bit,
  input wire       clk,
  input wire       RST,  
  output reg       TX_OUT
  );


localparam  [1:0]  START  = 2'b00,
                   STOP   = 2'b01,
                   DATA   = 2'b10,
					         PARITY = 2'b11;

 wire start_bit = 1'b0;
 wire stop_bit = 1'b1;
 
 always@(posedge clk, negedge RST )
 begin
   if(!RST)
     TX_OUT <= 1'b1;
   else
    case(mux_sel)
      START    : begin
                 	TX_OUT <= 1'b0; 
                 end
      STOP     : begin
                  TX_OUT <= 1'b1;   
                 end
      DATA     : begin
                  TX_OUT <= ser_data;
                 end
      PARITY   : begin
                  TX_OUT <= par_bit;
                 end
 		 
  endcase
 end
endmodule