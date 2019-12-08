module AUTO_FOCUS_ON  (
 
 input CLK_50 , 
 input I2C_RELEASE , 
 output AUTO_FOC  

) ; 
reg [31:0] PULSE ; 

//--- COUNTER --- 
always @(negedge I2C_RELEASE or posedge CLK_50 ) begin 
if (!I2C_RELEASE) 
   PULSE <= 0;
else if (PULSE < 32'hfffffff0)  
   PULSE <= PULSE + 1 ; 
end 

//--- AUTO_FOC ON ---
assign AUTO_FOC = (PULSE < 100000000)?0 : 1 ;  

endmodule 