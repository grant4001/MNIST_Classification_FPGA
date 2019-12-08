module Line_Buffer_J (	
 input        CCD_PIXCLK, //50MHZ
 input        mCCD_FVAL ,
 input        mCCD_LVAL , 	
 input [9:0]  mCCD_DATA , 
 input [15:0] X_Cont    , 
 input        VGA_CLK, // 25MHZ 
 input        READ_Request ,
 input        VGA_VS ,	
 input [12:0] READ_Cont ,
 input [12:0] V_Cont , 
 output [9:0]  taps0x,
 output [9:0]  taps1x 	,
 output  reg   [1:0] WR , 
 output  WR0, WR1, WR2 
 
 
 
						);
						
						
						
			
//====== WIRE /REG  ==== 					
wire [9:0] T0 ; 	
wire [9:0] T1 ; 	
wire [9:0] T2 ; 					

//====== WIRE /REG  ==== 	

//----3 SRAM BUFFER  WRITE ENABLE  COUNTER -----
reg pre_CCD_LVAL ; 
always @( posedge CCD_PIXCLK  or  negedge mCCD_FVAL  )
if  (!mCCD_FVAL) begin 
   WR<=0; 
	pre_CCD_LVAL <= mCCD_LVAL ;
end 
else  begin 
   pre_CCD_LVAL <= mCCD_LVAL  ; 
   if ( pre_CCD_LVAL &&  !mCCD_LVAL   )  begin 
      if ( WR >= 2) WR<=0; 
      else   WR<= WR +1 ; 	
	end 	
end 		
	
//----3 SRAM BUFFER  WRITE ENABLE  -----	
assign WR0 = ( WR==0)?1:0 ;  
assign WR1 = ( WR==1)?1:0 ;  
assign WR2 = ( WR==2)?1:0 ;  

//--- OUT0  SELECTION--- 
assign taps0x = READ_Request ? (  (
   ( WR==0)? T1: (  
   ( WR==1)? T2: (  
   ( WR==2)? T0: T0 
	)))) :0 ;
	
//--- OUT1  SELECTION--- 
assign taps1x = READ_Request ? (  (
   ( WR==0)? T2: (  
   ( WR==1)? T0: (  
   ( WR==2)? T1: T1
	))))  :0 ;
//
//always @( posedge VGA_CLK ) begin   
//taps0x <= READ_Request ? (  (
//   ( WR==0)? T1: (  
//   ( WR==1)? T2: (  
//   ( WR==2)? T0: T0 
//	)))) :0 ;
//
////--- OUT1  SELECTION--- 
//taps1x <= READ_Request ? (  (
//   ( WR==0)? T2: (  
//   ( WR==1)? T0: (  
//   ( WR==2)? T1: T1
//	))))  :0 ;
//end 
//	
//---0 : 2PORT LINE BUFFER 	
int_line d1(
	.wrclock    (CCD_PIXCLK),
	.data       (mCCD_DATA ),
	.wraddress  (X_Cont),
	.wren       (WR0 & mCCD_LVAL),
	.rdclock    (VGA_CLK),	
	.rdaddress  (READ_Cont),
	.q          (T0)
	);
	
//---1 : 2PORT LINE BUFFER 						
int_line d2(
	.wrclock    (CCD_PIXCLK),
	.data       (mCCD_DATA),
	.wraddress  (X_Cont),
	.wren       (WR1 & mCCD_LVAL),
	.rdclock    (VGA_CLK),	
	.rdaddress  (READ_Cont),
	.q          (T1)
	);
	
//---2 : 2PORT LINE BUFFER 		
int_line d3(
	.wrclock    (CCD_PIXCLK),
	.data       (mCCD_DATA ),
	.wraddress  (X_Cont),
	.wren       (WR2 & mCCD_LVAL),
	.rdclock    (VGA_CLK),	
	.rdaddress  (READ_Cont),
	.q          (T2)
	);
	
	
endmodule 	
						