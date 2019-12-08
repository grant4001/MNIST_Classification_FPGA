module I2C_RESET_DELAY  (
  input  CLK , 
  output reg READY 
);

reg [31:0] DELAY  ;  
reg        READY_n ; 
always @( posedge CLK   ) 
if ( DELAY < 30*5) DELAY <= DELAY+1 ;
else READY <=1 ; 

endmodule 
