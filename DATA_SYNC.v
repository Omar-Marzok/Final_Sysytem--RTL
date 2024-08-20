module DATA_SYNC #(parameter NUM_STAGES = 2, BUS_WIDTH = 8) (
    input wire           		bus_enable,
    input wire [BUS_WIDTH-1:0]  unsync_bus,
    input wire      			clk,
    input wire     				RST,
    output reg            		enable_pulse,
    output reg [BUS_WIDTH-1:0]  sync_bus
);

reg [NUM_STAGES-1:0] sync_flops;
reg 				 puls_gen;
wire				 en_pulse;
 //----------------> flop synchronizer 
always @(posedge clk or negedge RST) 
 begin
    if (!RST) 
    begin
		sync_flops <= 'b0;
    end 
    else
    begin
		sync_flops <= {sync_flops[NUM_STAGES-2:0],bus_enable};
    end
 end 

 //----------------> pulse generator 
always @(posedge clk or negedge RST) 
 begin
    if (!RST) 
    begin
		puls_gen <= 1'b0;
    end 
    else
    begin
		puls_gen <= sync_flops[NUM_STAGES-1];
    end
 end 

assign en_pulse = sync_flops[NUM_STAGES-1] & !puls_gen;


 //----------------> synchronous bus recive 
always @(posedge clk or negedge RST) 
 begin
    if (!RST) 
    begin
		enable_pulse <= 1'b0;
		sync_bus	 <= 'b0;
    end 
    else if (en_pulse)
    begin
		enable_pulse <= 1'b1;
		sync_bus	 <= unsync_bus;
	end
    else
	begin
		enable_pulse <= 1'b0;
		sync_bus	 <= 'b0;
    end
 end 

endmodule // DATA_SYNC