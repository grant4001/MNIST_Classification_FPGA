module VGA_RD_COUNTER  ( 
  input VGA_CLK ,
  input VGA_VS , 
  input READ_Request , 
//--------
  output reg	[10:0]	X_Cont,
  output reg	[10:0]	Y_Cont
  

) ;

//--------
reg rDVAL ; 
always @(negedge VGA_VS or posedge VGA_CLK )begin
  if ( !VGA_VS ) begin 
    X_Cont<=0;
    Y_Cont<=0;
end 
else 
begin 
  rDVAL <= READ_Request   ; 
  if ( !rDVAL)    X_Cont<=0;  else  X_Cont<=X_Cont+1 ;   
  if (  rDVAL  && !READ_Request)    Y_Cont <=Y_Cont+1 ; 
end 
end 

endmodule 