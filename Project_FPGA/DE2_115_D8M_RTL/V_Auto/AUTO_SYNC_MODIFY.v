//-----AUTO SYNC_TO_NS---
module AUTO_SYNC_MODIFY  (
input PCLK ,
input VS ,
input HS,

output M_VS,
output M_HS 

) ; 

//--v
MODIFY_SYNC   vs(
 .PCLK(PCLK),  
 .S  (VS), 
 .MS (M_VS)
);
//--h
MODIFY_SYNC   hs(
 .PCLK(PCLK),  
 .S  (HS), 
 .MS (M_HS)
);

endmodule 
