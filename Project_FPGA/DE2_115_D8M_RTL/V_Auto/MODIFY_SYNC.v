module MODIFY_SYNC   (
input  PCLK  , 
input  S ,
output reg MS 
);

reg [15:0] NUM_H,NUM_L ; 

reg [15:0] CNT; 
reg rS  ; 


always @(posedge PCLK)begin 
  rS  <=  S  ; 
  MS  <=  ( NUM_H > NUM_L )? S :~S ; 
  //LEVEL LOW COUNTER
       if ( rS & !S  ) { NUM_H , CNT } <=  {CNT  , 16'h0 }   ; 
  else if ( !rS & S  ) { NUM_L , CNT } <=  {CNT  , 16'h0 }   ; 
  else CNT<=CNT+1 ; 
  end
  
  
 endmodule 