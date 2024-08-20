module serializer #(parameter IN_data = 8)(
  input wire [IN_data-1 :0] P_DATA,
  input wire                Data_Valid,
  input wire                ser_en,
  input wire                busy,
  input wire                clk,
  input wire                RST,
  output reg                ser_Data,
  output wire                ser_done );
  
  reg [IN_data-1 :0] Data;
  reg [3:0]          counter;
  
  always@(posedge clk, negedge RST)
  begin
    if(!RST)
      begin
       ser_Data <= 1'b1;
       counter  <= 1'b0;
       Data 	<= 'b0;
      end
    else if (ser_en && (counter != IN_data))
      begin
         ser_Data <= Data[counter] ;
         counter <= counter + 4'b1;
      end
    else if(Data_Valid && !busy)
      begin
         Data <= P_DATA;
      end

    else
      counter  <= 1'b0;
  end

assign ser_done = (counter == IN_data)? 1'b1 : 1'b0;

endmodule