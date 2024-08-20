module FSM_RX  (
  input wire          RX_IN,
  input wire   [3:0]  bit_cnt,
  input wire          PAR_EN,
  input wire          clk,
  input wire          RST,
  input wire   [5:0]  edge_cnt,
  input wire          par_err,
  input wire          strt_glitch,
  input wire          stp_err,
  input wire  [5:0]   Prescale,
  output reg          dat_samp_en,
  output reg          enable,
  output reg          par_chk_en,
  output reg          strt_chk_en,
  output reg          stp_chk_en,
  output reg          deser_en,
  output reg          rst_check,
  output reg          data_valid );


localparam  [2:0]  	IDLE   = 3'b000,
					START  = 3'b001,
					DATA   = 3'b010,
					PARITY = 3'b011,
					STOP   = 3'b100;
					         
reg [2:0] current_state, next_state ;
		
always @(posedge clk or negedge RST)
 begin
  if(!RST)
   begin
     current_state <= IDLE ;
     data_valid <= 1'b0;
   end
  else
   begin
     current_state <= next_state ;
     if(PAR_EN)
      begin 
      if(!par_err && !stp_err)
        data_valid <= 1'b1;
      else
        data_valid <= 1'b0;
      end
    else
      begin 
      if(!stp_err)
        data_valid <= 1'b1;
      else
        data_valid <= 1'b0;
      end
   end
 end

always @(*)
 begin
  case(current_state)
  IDLE     : begin
              if(!RX_IN)
		            next_state = START ;
              else
               	next_state = IDLE ;			  
             end
  START    : begin
              if(bit_cnt == 4'd0)
              	next_state = 	START;  
            	else
            	  next_state = 	DATA;
             end
  DATA     : begin
              if(strt_glitch)
                next_state = 	IDLE;
             else if(bit_cnt <= 4'd8)
              	 next_state = 	DATA;  
            	else if(PAR_EN)
                 next_state = PARITY;
             else
                 next_state = STOP;
            end
  PARITY   : begin
              if(bit_cnt == 4'd9)
              	next_state = 	PARITY;  
            	 else
            	  next_state = 	STOP;
            end
  STOP     : begin
              if(PAR_EN)
                begin
                  if(bit_cnt == 4'd10)
              	     next_state = 	STOP;  
            	     else
            	       next_state = 	IDLE;                  
                end 
            	 else 
          	   begin
            	   if(bit_cnt == 4'd9)
                    next_state = STOP;
                else
                    next_state = IDLE;
              end
             end		 
  default :   next_state = IDLE ;		 
  endcase
end	

 
 always @(*)
 begin
  enable = 1'b0;
  dat_samp_en = 1'b0;
  par_chk_en = 1'b0;
  stp_chk_en = 1'b0;
  deser_en = 1'b0;
  strt_chk_en = 1'b0;
  rst_check = 1'b0;
  
  case(current_state)
  IDLE     : begin
              rst_check = 1'b1;
              if(!RX_IN)
		            enable = 1'b0;
              else
        	       enable = 1'b0;
             end
  START    : begin
              enable = 1'b1;
              dat_samp_en = 1'b1;
              if(edge_cnt >= (Prescale/2 +2))
                strt_chk_en = 1'b1;
              else
                strt_chk_en = 1'b0;
             end
  DATA     : begin
              enable = 1'b1;
              dat_samp_en = 1'b1;
              if(edge_cnt == (Prescale/2 +3))
                deser_en = 1'b1;
              else
                deser_en = 1'b0;  
            end
  PARITY   : begin
              enable = 1'b1;
              dat_samp_en = 1'b1;
              if(edge_cnt == (Prescale/2 +3))
                par_chk_en = 1'b1;
              else
                par_chk_en = 1'b0;
            end
  STOP     : begin
              enable = 1'b1;
              dat_samp_en = 1'b1;
              if(edge_cnt == (Prescale/2 +3))
                stp_chk_en = 1'b1;
              else
                stp_chk_en = 1'b0;
             end		 
  default :   begin 
                enable = 1'b0;
                dat_samp_en = 1'b0;
                par_chk_en = 1'b0;
                stp_chk_en = 1'b0;
                deser_en = 1'b0;
                strt_chk_en = 1'b0;
                rst_check = 1'b0;
              end		 
  endcase
end	
 
endmodule
