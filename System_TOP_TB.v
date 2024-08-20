`timescale  1ns/1ps

module System_TOP_TB #(parameter DATA_WIDTH_tb=8,RATIO_WD_tb = 6)();
reg          			RX_IN_S_tb;
reg          			RST_tb;
reg          			REF_CLK_tb;
reg          			UART_CLK_tb;
wire         			framing_error_tb;
wire          			parity_error_tb;
wire                	TX_OUT_D_tb; 

/////////////////// //////////////////////
parameter 	REF_CLK_PERIOD	= 20,
			RX_CLK_PERIOD	= 271.267,
			TX_CLK_PERIOD	= 8680.556;

localparam 	WITH_PARITY = 1'b1, NO_PARITY = 1'b0,
			EVEN_PAR = 1'b0   , ODD_PAR  = 1'b1;
			
reg [DATA_WIDTH_tb-1:0] Address,Data;
reg [DATA_WIDTH_tb+2:0]	Frame;

////////////////// initial block //////////////////
initial 
begin

//--> initialize & reset 
 initialize();
 reset ();
 
  /////////////////// test Register File Write command //////////////
 //--> Frame 0 (RF_Write)
 config_packet('hAA,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
 //--> Frame 1 (Address)
 Address = 'd7;
 config_packet(Address,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> Frame 2 (DATA)
 Data = 'd3;
 config_packet(Data,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
 /////////////////// test Register File Read command //////////////
 //--> Frame 0 (RF_Read)
 config_packet('hBB,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
 //--> Frame 1 (Address)
 Address = 'd7;
 config_packet(Address,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
 //--> Recive the output data
 check_out_data(DUT.Reg_File_u0.register_file.Reg_File[Address]);
 
 ////////////// test ALU Operation command with operand //////////
 //--> Frame 0 (ALU_WOP)
 config_packet('hCC,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
 //--> Frame 1 (Operand A )
 Data = 'd30;
 config_packet(Data,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> Frame 2 (Operand B )
 Data = 'd10;
 config_packet(Data,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> Frame 3 (ALU FUN )
 Data = 'd2; // Multiplication
 config_packet(Data,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> check the 16 bit out data 8 by 8 (out = 300)
 check_out_data(8'h2C);
 check_out_data(8'h01);
 
   ////////////// test ALU Operation command with No operand //////////
 //--> Frame 0 (ALU_NOP)
 config_packet('hDD,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> Frame 1 (ALU FUN )
 Data = 'd0; // Addition
 config_packet(Data,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> check the 16 bit out data 8 by 8 (out = 40)
 check_out_data(8'h28);
 check_out_data(8'h00);
 
 
  /////////////////// change the configration //////////////
 //--> Frame 0 (RF_Write)
 config_packet('hAA,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
 //--> Frame 1 (Address)
 Address = 'd2;
 config_packet(Address,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> Frame 2 (DATA)
 Data = 'b0100_0011;	// odd parity and prescale = 16
 config_packet(Data,WITH_PARITY,EVEN_PAR,Frame);
 send_packet(Frame,WITH_PARITY); 
 #(4*TX_CLK_PERIOD)
 
  ////////////// test ALU Operation command with operand //////////
 //--> Frame 0 (ALU_WOP)
 config_packet('hCC,WITH_PARITY,ODD_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
 //--> Frame 1 (Operand A )
 Data = 'd7;
 config_packet(Data,WITH_PARITY,ODD_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> Frame 2 (Operand B )
 Data = 'd3;
 config_packet(Data,WITH_PARITY,ODD_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> Frame 3 (ALU FUN )
 Data = 'd0; // Multiplication
 config_packet(Data,WITH_PARITY,ODD_PAR,Frame);
 send_packet(Frame,WITH_PARITY);
 
  //--> check the 16 bit out data 8 by 8 (out = 10)
 check_out_data(8'hA);
 check_out_data(8'h0);
 
 #10000 $stop;  // end stimulus here
end

///////////////  TASKS  ///////////

//-----> initialization
task initialize;
  begin
    RX_IN_S_tb 	= 1;
    REF_CLK_tb 	= 0;
    UART_CLK_tb	= 0;
  end
endtask

//-----> Reset
task reset;
  begin
    RST_tb = 1'b1;
    #RX_CLK_PERIOD
    RST_tb = 1'b0;
    #RX_CLK_PERIOD
    RST_tb = 1'b1;
    #RX_CLK_PERIOD;
  end
endtask

//----------------> task to create a packt
task config_packet ;
  input [DATA_WIDTH_tb-1:0] data;
  input  par_en;
  input  par_typ;
  output [10:0] pack;
  reg     par_bit;
  begin
    pack[0] = 1'b0;
    pack[8:1] = data;
    if(par_en)
      begin
        if(par_typ == EVEN_PAR)
          par_bit = ^data;
        else
          par_bit = ~^data; 
        pack[9] = par_bit;
        pack[10] = 1'b1; 
      end
    else
      pack[10:9] = 2'b11; 
  end
endtask 

//----------------> task to send a packt
task send_packet ;
  input [10:0] pack;
  input        par_en;
  integer bit;
  begin
     @(negedge UART_CLK_tb);
     for (bit=0 ; bit < 10 ;bit = bit + 1 )
     begin
      RX_IN_S_tb = pack[bit];
      #(TX_CLK_PERIOD);
     end 
    if(par_en)
	 begin
      RX_IN_S_tb = pack[10];
	 end
    else
	 begin
      RX_IN_S_tb = pack[9];
	 end
	#(TX_CLK_PERIOD);
	RX_IN_S_tb = 1'b1;
  end  
endtask

//-----------> task to recive the output packt
task check_out_data ;
  input [DATA_WIDTH_tb-1:0] expec_data;
  reg [DATA_WIDTH_tb-1:0] out_data;
  integer bit;
  begin
	@(posedge DUT.UART_TOP_U0.TX_OUT_busy)
    @(negedge DUT.UART_TOP_U0.clk_TX);
    for (bit=0 ; bit < DATA_WIDTH_tb ;bit = bit + 1 )
     begin
		#(TX_CLK_PERIOD);
		out_data[bit] = TX_OUT_D_tb;
     end 
	 
	if (out_data == expec_data) 
	begin
		$display("Succeeded at time = %t",$time);
	end
	else 
	begin
		$display("Failed at time = %t",$time);
	end
  end  
endtask

always #(REF_CLK_PERIOD/2) 	REF_CLK_tb =~REF_CLK_tb;
always #(RX_CLK_PERIOD/2) UART_CLK_tb =~UART_CLK_tb;
	
System_TOP #(.DATA_WIDTH(DATA_WIDTH_tb)) DUT (
.RX_IN_S(RX_IN_S_tb),
.RST(RST_tb),
.REF_CLK(REF_CLK_tb),
.UART_CLK(UART_CLK_tb),
.framing_error(framing_error_tb),
.parity_error(parity_error_tb),
.TX_OUT_D(TX_OUT_D_tb)
);

endmodule
