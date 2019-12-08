module I2C_DELAY  (
  input  RESET_N,
  input  CLK , 
  output reg READY ,
  output reg READY1
);

reg [31:0] DELAY  ;  
reg        READY_n ; 

always @(negedge RESET_N  or posedge CLK   ) 
if (!RESET_N) begin DELAY <= 0 ;  READY<=0;  end 
else if ( DELAY < 30*5) DELAY <= DELAY+1 ;
else READY <=1 ; 


endmodule 
