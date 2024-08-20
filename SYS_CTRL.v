module SYS_CTRL #(parameter ALU_O_WIDTTH = 16, DATA_WIDTH = 8) (

    input wire [ALU_O_WIDTTH-1:0] 	ALU_OUT,
    input wire           			OUT_Valid,
    input wire [DATA_WIDTH-1:0] 	RdData,
    input wire           			RdData_Valid,
    input wire [DATA_WIDTH-1:0] 	RX_P_DATA,
    input wire           			RX_D_VLD,
	input wire						FIFO_FULL,
    input wire      				clk,
    input wire     					RST,
    output reg [3:0] 				ALU_FUN,
    output reg            			EN,
    output reg           	 		CLK_EN,
    output reg [3:0] 				Address,
    output reg            			WrEn,
    output reg            			RdEn,
    output reg [DATA_WIDTH-1:0] 	WrData,
    output reg [DATA_WIDTH-1:0] 	TX_P_DATA,
    output reg            			TX_D_VLD
);


localparam 	[2:0] 	IDEL 		= 'b0000,
					RF_Wr_Addr 	= 'b0001,
					RF_Wr_Data	= 'b0010,
					RF_Rd_Addr 	= 'b0011,
					Operand_A 	= 'b0100,
					Operand_B 	= 'b0101,
					ALU_FUN_OP 	= 'b0110,
					ALU_OP_2	= 'b0111,
					FULL_RD		= 'b1000,
					FULL_ALU_1	= 'b1001,
					FULL_ALU_2	= 'b1010;
					
					
reg [3:0] current_state, next_state,Addr;
reg 	  store_Addr,count;

// state transition
always @(posedge clk or negedge RST) 
 begin
    if (!RST) 
    begin
	current_state <= 'b0;
    end 
    else
    begin
    current_state <= next_state;
    end
 end 

 // store the address to use it
 always @(posedge clk or negedge RST) 
 begin
    if (!RST) 
    begin
	Addr <= 'b0;
    end 
    else if(store_Addr)
    begin
    Addr <= RX_P_DATA;
    end
 end 

always @(*) 
 begin 

	case(current_state)
	IDEL:		begin
				if (RX_D_VLD)
					begin
					if(RX_P_DATA == 'hAA)
						next_state = RF_Wr_Addr;
					else if (RX_P_DATA == 'hBB)
						next_state = RF_Rd_Addr;
					else if (RX_P_DATA == 'hCC)
						next_state = Operand_A;
					else if (RX_P_DATA == 'hDD)
						next_state = ALU_FUN_OP;
					else
						next_state = IDEL;
					end
				else
					next_state = IDEL;
				end

	RF_Wr_Addr:	begin
				if (RX_D_VLD)
					next_state = RF_Wr_Data;
				else
					next_state = RF_Wr_Addr;
				end
				
	RF_Wr_Data:	begin
				if (RX_D_VLD)
					next_state = IDEL;
				else
					next_state = RF_Wr_Data;
				end
	
	RF_Rd_Addr:	begin
				if (RdData_Valid && FIFO_FULL)
					next_state = FULL_RD;
				else if (RdData_Valid && !FIFO_FULL)
					next_state = IDEL;
				else
					next_state = RF_Rd_Addr;
				end
				
	Operand_A:	begin
				if (RX_D_VLD)
					next_state = Operand_B;
				else
					next_state = Operand_A;
				end

	Operand_B:	begin
				if (RX_D_VLD)
					next_state = ALU_FUN_OP;
				else
					next_state = Operand_B;
				end

	ALU_FUN_OP:	begin
				if (OUT_Valid && FIFO_FULL)
					next_state = FULL_ALU_1;
				else if (OUT_Valid && !FIFO_FULL)
					next_state = ALU_OP_2;
				else
					next_state = ALU_FUN_OP;
				end
	
	ALU_OP_2:	begin
				if (FIFO_FULL)
					next_state = FULL_ALU_2;
				else
					next_state = IDEL;
				end
				
	FULL_ALU_1:	begin
				if (FIFO_FULL)
					next_state = FULL_ALU_1;
				else
					next_state = FULL_ALU_2;
				end
				
	FULL_ALU_2:	begin
				if (FIFO_FULL)
					next_state = FULL_ALU_2;
				else
					next_state = IDEL;
				end		

	FULL_RD:	begin
				if (FIFO_FULL)
					next_state = FULL_RD;
				else
					next_state = IDEL;
				end	
				
	default : next_state = IDEL;
	endcase
 end

 
 always @(*) 
 begin 
	count = 0;
	case(current_state)
	IDEL:		begin
				ALU_FUN 	='b0;
				EN			='b0;
				CLK_EN		='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA	='b0;
				TX_D_VLD	='b0;
				store_Addr	='b0;
				end

	RF_Wr_Addr:	begin
				ALU_FUN 	='b0;
				EN			='b0;
				CLK_EN		='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA	='b0;
				TX_D_VLD	='b0;
				if (RX_D_VLD)
					store_Addr	='b1;
				else
					store_Addr	='b0;
				end
				
	RF_Wr_Data:	begin
				ALU_FUN 	='b0;
				EN			='b0;
				CLK_EN		='b0;
				RdEn		='b0;
				Address		= Addr;
				WrData		= RX_P_DATA;
				TX_P_DATA	='b0;
				TX_D_VLD	='b0;
				store_Addr	='b0;
				if (RX_D_VLD)
					WrEn		='b1;
				else
					WrEn		='b0;	
				end
	
	RF_Rd_Addr:	begin
				ALU_FUN 	='b0;
				EN			='b0;
				CLK_EN		='b0;
				WrEn		='b0;
				WrData		='b0;
				Address		= RX_P_DATA;
				TX_P_DATA 	= RdData;
				store_Addr	='b0;
				
				if (RX_D_VLD)
					RdEn		='b1;
				else
					RdEn		='b0;
				
				if(RdData_Valid && !FIFO_FULL)
					TX_D_VLD  	='b1;
				else
					TX_D_VLD  	='b0;
				end
				
	Operand_A:	begin
				ALU_FUN 	='b0;
				EN			='b0;
				CLK_EN		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		= RX_P_DATA;
				TX_P_DATA	='b0;
				TX_D_VLD	='b0;
				store_Addr	='b0;
				if (RX_D_VLD)
					WrEn		='b1;
				else
					WrEn		='b0;
				end

	Operand_B:	begin
				ALU_FUN 	='b0;
				EN			='b0;
				CLK_EN		='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b1;
				WrData		= RX_P_DATA;
				TX_P_DATA	='b0;
				TX_D_VLD	='b0;
				store_Addr	='b0;
				if (RX_D_VLD)
					WrEn		='b1;
				else
					WrEn		='b0;
				end

	ALU_FUN_OP:	begin
				ALU_FUN 	= RX_P_DATA[3:0];
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA 	= ALU_OUT[7:0];
				store_Addr	='b0;
				CLK_EN		='b1;
				if (RX_D_VLD)
					EN			='b1;
				else
					EN			='b0;

				if(OUT_Valid && !FIFO_FULL)
				begin
					TX_D_VLD  	='b1;
				end
				else
					TX_D_VLD  	='b0;
				end
				
	ALU_OP_2:	begin
				ALU_FUN 	='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA 	= ALU_OUT[15:8];
				store_Addr	='b0;
				CLK_EN		='b0;
				EN			='b0;
				if (FIFO_FULL)
					TX_D_VLD  	='b0;
				else
					TX_D_VLD  	='b1;
				end
				
	FULL_ALU_1:	begin
				ALU_FUN 	='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA 	= ALU_OUT[7:0];
				store_Addr	='b0;
				CLK_EN		='b0;
				EN			='b0;
				if (FIFO_FULL)
					TX_D_VLD  	='b0;
				else
					TX_D_VLD  	='b1;
				end
				
	FULL_ALU_2:	begin
				ALU_FUN 	='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA 	= ALU_OUT[15:8];
				store_Addr	='b0;
				CLK_EN		='b0;
				EN			='b0;
				if (FIFO_FULL)
					TX_D_VLD  	='b0;
				else
					TX_D_VLD  	='b1;
				end	

	FULL_RD:	begin
				ALU_FUN 	='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA 	= RdData;
				store_Addr	='b0;
				CLK_EN		='b0;
				EN			='b0;
				if (FIFO_FULL)
					TX_D_VLD  	='b0;
				else
					TX_D_VLD  	='b1;
				end
				
	default:	begin
				ALU_FUN 	='b0;
				EN			='b0;
				CLK_EN		='b0;
				WrEn		='b0;
				RdEn		='b0;
				Address		='b0;
				WrData		='b0;
				TX_P_DATA	='b0;
				TX_D_VLD	='b0;
				store_Addr	='b0;
				end
	endcase
 end

	
endmodule // SYS_CTRL