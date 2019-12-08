module MIPI_BRIDGE_CAMERA_Config   (
 input  RESET_N , 
 input  CLK_50 , 
 
 output MIPI_I2C_SCL , 
 inout  MIPI_I2C_SDA , 
 output MIPI_I2C_RELEASE ,  
 output CAMERA_I2C_SCL,
 inout  CAMERA_I2C_SDA,
 output CAMERA_I2C_RELAESE,
 
 output [9:0] STEP ,
 output       VCM_RELAESE 

 ); 
 


 //wire VCM_RELAESE ;
 wire VCM_I2C_SCL ; 
//---FIRST VCM-TEST 
//VCM_TEST   vmt( 
//   .RESET_N     ( 0 ),//RESET_N  & MIPI_I2C_RELEASE),
//   .CLK_50      ( CLK_50) ,
//   //.I2C_SCL     ( VCM_I2C_SCL   ), 
//   //.I2C_SDA     ( CAMERA_I2C_SDA),
//	//.VCM_RELAESE ( VCM_RELAESE ) , 
//	.STEP  (STEP )   	
//);
// 
assign  VCM_RELAESE =1 ; 
//--Camera share  SCL -- 
assign CAMERA_I2C_SCL = ( !VCM_RELAESE)  ?  VCM_I2C_SCL  : CAMERA_I2C_SCL_ ;
 
//--D8M CAMERA I2C -- 
wire CAMERA_I2C_SCL_ ; 
MIPI_CAMERA_CONFIG  camiv( 
   .RESET_N ( VCM_RELAESE & RESET_N  &  MIPI_I2C_RELEASE ),
	.TR_IN   ( ) , 	
   .CLK_50  ( CLK_50   ) ,
	.CLK_400K( CLK_400K ) , //<--
   .I2C_SCL ( CAMERA_I2C_SCL_ ), 
   .I2C_SDA ( CAMERA_I2C_SDA),
   .INT_n   (),
	.MIPI_CAMERA_RELAESE  ( CAMERA_I2C_RELAESE )
);

wire CLK_400K ; 
//--MIPI BRIDGE I2C -- 
MIPI_BRIDGE_CONFIG  mpiv( 
   .RESET_N  (RESET_N) ,  
   .CLK_400K (CLK_400K),//<--
   .CLK_50   (CLK_50 ) ,
   .I2C_SCL  (MIPI_I2C_SCL), 
   .I2C_SDA  (MIPI_I2C_SDA),
	.MIPI_BRIDGE_CONFIG_RELEASE (MIPI_I2C_RELEASE)  , 
   .INT_n()
);



endmodule 
