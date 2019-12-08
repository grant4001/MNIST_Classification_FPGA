


module RAW_RGB_BIN  (
input CLK , 
input RESET_N , 
input [9:0] D0,
input [9:0] D1,
input X,
input Y,

output reg		[9:0]	R,
output reg		[9:0]	G, 
output reg		[9:0]	B
);

reg  [9:0]	rD0;
reg  [9:0]	rD1;

wire [10:0] T1,T2 ; 
assign T1 = rD0+D1;
assign T2 = rD1+D0;

always@(posedge CLK or negedge RESET_N)
begin
	if( !RESET_N )
	begin
		R	<=	0;
		G	<=	0;
		B	<=	0;
		rD0<=	0;
		rD1<=	0;
	end
	else
	begin
		rD0	<=	D0;
		rD1	<=	D1;
		if({Y ,X }     == 2'b10)
		begin
			R	<=	 D0;
			G	<=  T1[10:1];
			B	<=	 rD1;
		end	
		else if({Y ,X }== 2'b11)
		begin
			R	<=	rD0;
			G	<=  T2[10:1];
			B	<=	D1;
		end
		else if({Y ,X }== 2'b00)
		begin
			R	<=	D1;
			G	<=  T2[10:1];
			B	<=	rD0;
		end
		else if({Y ,X }== 2'b01)
		begin
			R	<=	rD1;
			G	<=  T1[10:1];
			B	<=	D0;
		end
	end
end


endmodule 