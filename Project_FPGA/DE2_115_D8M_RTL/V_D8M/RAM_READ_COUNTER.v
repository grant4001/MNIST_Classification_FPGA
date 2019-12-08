//--RAW TO RGB --- 	
module RAM_READ_COUNTER  (
	input  CLK ,
	input  CLR ,
	input  EN ,
	output  [15:0] CNT 
);

reg [15:0] CNT_ ;

assign CNT = CNT_ ; 

always @(posedge CLK )
 if ( !CLR) CNT_ <=0; 
 else if ( EN ) CNT_ <=CNT_ +1 ; 

endmodule 