//--AutoFous-------
module FOCUS_ADJ (
input             CLK_50 , 
input             RESET_N ,      
input             RESET_SUB_N ,   //KEY[0]  
input             AUTO_FOC,       //KEY[4]
input             SW_Y,           //SW[1]
input             SW_H_FREQ,      //SW[2]     
input             SW_FUC_ALL_CEN, //SW[4] 
input             SW_FUC_LINE ,   //SW[3] 
     
input             VIDEO_HS,
input             VIDEO_VS,
input             VIDEO_CLK,
input             VIDEO_DE , 
input   [7:0]     iR , 
input   [7:0]     iG , 
input   [7:0]     iB , 

output  reg [7:0] oR , 
output  reg [7:0] oG , 
output  reg [7:0] oB , 
output            READY ,
output            SCL , 
inout             SDA , 
output [9:0]      STATUS 

);
//=============================================================================
// REG/WIRE declarations
//=============================================================================

wire         VS_NS  ; 
wire         HS_NS ; 
wire  [15:0] VCM_DATA ;
wire   [9:0] STEP ; 
wire         VCM_END  ;
wire   [7:0] S  ; 
wire  [17:0] Y  ; 
wire         ACTIV_C; 
wire         ACTIV_V; 

//--AUTO SUNY MODIFY TO NEGTIVE PULSE-- 

AUTO_SYNC_MODIFY  RE(
       .PCLK     ( VIDEO_CLK ),
       .VS       ( VIDEO_VS),
       .HS       ( VIDEO_HS),
       .M_VS     ( VS_NS),
       .M_HS     ( HS_NS)
) ; 

LCD_COUNTER  cv1(
       .CLK      ( VIDEO_CLK ),
       .VS       ( VS_NS), 
       .HS       ( HS_NS), 
		 .DE       ( VIDEO_DE ) , 
       .V_CNT    ( V_CNT) ,
       .H_CNT    ( H_CNT) ,
       .LINE     ( LINE ),
       .ACTIV_C  ( ACTIV_C ),
       .ACTIV_V  ( ACTIV_V )
) ; 

//----VCM_STEP CONTROL & PIXEL HIGH_Statistics

VCM_CTRL_P pp(
        .iR           ( iR),
        .iG           ( iG),
        .iB           ( iB),
        .VS           ( VS_NS), 
        .HS           ( HS_NS), 
        .ACTIV_C      ( ACTIV_C) ,
        .ACTIV_V      ( ACTIV_V) ,
        .VIDEO_CLK    ( VIDEO_CLK   ), 
        .AUTO_FOC     ( AUTO_FOC    ),  
        .SW_FUC_ALL_CEN( SW_FUC_ALL_CEN) ,
        .VCM_END ( VCM_END) ,
        .Y            ( Y ),
        .S            ( S ),
        .STEP         ( STEP ),
        .VCM_DATA     ( VCM_DATA )

);

assign STATUS[9:0]  = { VCM_END , STEP[6:0] ,SCL,SDA  } ;
                                             
//-- I2C DELAY  -- 
I2C_DELAY   i2c (
    .RESET_N   ( RESET_SUB_N ),
    .CLK       ( VIDEO_VS )   , 
    .READY     ( READY  )
	 
	 
);
 
 
//-VCM_SETTING -- 
VCM_I2C i2c2( 
   .TR_IN      ( VS_NS  ),
   .RESET_N    ( READY  ), 
	.RESET_SUB_N( RESET_SUB_N ),
   .CLK_50     ( CLK_50 ),
   .I2C_SCL    ( SCL    ) ,
   .I2C_SDA    ( SDA    ),
   .VCM_DATA   ( VCM_DATA  ), 
	.TEST_MODE  ( 1 )//1: WRITE-READ-WRITE-  , 0: write only
	);
	 
//-----VIDEO MIXED  -- 

always @( posedge VIDEO_CLK ) 
   {oR, oG, oB}  <=    
   ((SW_FUC_LINE &  LINE )  ||  ( SW_FUC_ALL_CEN  &  ( ~VCM_END  &  LINE) ) )?  {8'hFF, 8'hFF, 8'h0} : 
   ( !SW_Y )?  //( ACTIV_C ? 24'h555555 :  
	{ iR, iG, iB }   : 
   (SW_H_FREQ)?  { 
     Y[15:8 ],
     Y[15:8 ],
     Y[15:8 ]
   } :
   {
	   S[7:0],
	   S[7:0],
	   S[7:0]
	 };
	 
endmodule 
	 