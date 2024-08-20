module RST_SYNC #(parameter NUM_STAGES = 2) (
    input wire      clk,
    input wire     	RST,
    output reg      SYNC_RST
);

reg [NUM_STAGES-1:0] sync_flops;

always @(posedge clk or negedge RST) 
 begin
    if (!RST) 
    begin
		sync_flops <= 0;
    end 
    else
    begin  
		sync_flops <= {sync_flops[NUM_STAGES-2:0],1'b1};
    end
 end 

always @(*) 
 begin 
	SYNC_RST = sync_flops[NUM_STAGES-1];
 end

endmodule // RST_SYNC