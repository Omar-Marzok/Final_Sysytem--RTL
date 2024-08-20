module FSM_TX  (
  input wire       Data_Valid,
  input wire       ser_done,
  input wire       PAR_EN,
  input wire       clk,
  input wire       RST,
  output reg       ser_en,
  output reg [1:0] mux_sel,
  output reg       busy );

localparam  [2:0]  IDLE   = 3'b000,
                   START  = 3'b001,
                   DATA   = 3'b010,
					         PARITY = 3'b011,
					         STOP   = 3'b100;
					         
reg count;
reg [2:0] current_state, next_state ;
		
always @(posedge clk or negedge RST)
 begin
  if(!RST)
   begin
     current_state <= IDLE ;
     busy <= 1'b0;
	 count <= 0;
   end
  else
   begin
     current_state <= next_state ;
     if ((next_state != IDLE) && (next_state != START))
       busy <= 1'b1;
     else
       busy <= 1'b0;
	   
	 if(current_state == STOP)
		count <= 1;
	 else
		count <=0;
   end
 end

always @(*)
 begin
  case(current_state)
  IDLE     : begin
              if(Data_Valid)
			         next_state = START ;
              else
               next_state = IDLE ;			  
             end
  START    : begin
              next_state = 	DATA;   
            end
  DATA     : begin
             if(ser_done)
               if(PAR_EN)
                begin
                 next_state = PARITY;
                end
               else
                begin
                 next_state = STOP;
                end
             else
                next_state = DATA;
            end
  PARITY   : begin
              next_state = STOP;
            end
  STOP     : begin
			if(count == 0)
				next_state = STOP ;
			else
				next_state = IDLE ;
            end			 
  default :   next_state = IDLE ;		 
  endcase
end	

 
 always @(*)
 begin
  mux_sel = 2'b01; // that will make mux_out = stop_bit = IDLE case 1'b1
  ser_en = 1'b0 ;
  case(current_state)
  IDLE     : begin
             	mux_sel = 2'b01;	  
             end
  START    : begin
              ser_en = 1'b1;
              mux_sel = 2'b00;   
            end
  DATA     : begin
              ser_en = 1'b1;
              mux_sel = 2'b10;
             if(ser_done)
              ser_en = 1'b0;
            end
  PARITY   : begin
              mux_sel = 2'b11;
            end
  STOP     : begin
              mux_sel = 2'b01;
            end			 
  default :  begin
              ser_en = 1'b0;
              mux_sel = 2'b01;
            end		 
  endcase
end	

 
 
endmodule