module MIPI_BRIDGE_CONFIG  ( 
   input   RESET_N , 
	input   TR_IN , 	
   input   CLK_50 ,
	
   output   I2C_SCL, 
   inout   I2C_SDA,
   input   INT_n,
	
//----Test or ST-BUS --- 
   output reg [15:0] ID ,
//test
	output            CLK_400K ,
   output reg        I2C_LO0P,
   output reg [7:0]  ST ,
   output reg [7:0]  CNT,
	output reg [7:0]  WCNT,
   output reg [7:0]  SLAVE_ADDR,	 	
   output reg [15:0] WORD_DATA,
   output reg [15:0] POINTER  ,
	
	output           W_WORD_END ,
   output reg       W_WORD_GO ,
output    W_POINTER_END ,
output reg    W_POINTER_GO ,

output  R_END ,
output reg  R_GO,

	
	output [7:0]     WORD_ST,
	output [7:0]     WORD_CNT,
	output [7:0]     WORD_BYTE	,
   output [15:0]    R_DATA,
	output           SDAI_W ,
	output           TR ,
	output           I2C_SCL_O  ,
	output reg MIPI_BRIDGE_CONFIG_RELEASE  , 
   output [15:0 ] PLLControlRegister0,   
   output [15:0 ] PLLControlRegister1,   
   output [15:0 ] PLLControlRegister2,   
   output [15:0 ] PLLControlRegister3,    
   output [15:0 ] MCLKControlRegister 	
	);

parameter WORD_NUM_MAX = 13 	 ; 
//wire [10:0] WORD_NUM_MAX ; 
//assign WORD_NUM_MAX  = 1; 

//-- I2C clock 400k generater 
CLOCKMEM c1(  .CLK ( CLK_50 ) , .CLK_FREQ ( 125)  , .CK_1HZ (CLK_400K) ) ; 
  
//======== Main-ST =======
//==Pointer NUM==
parameter    MIPI_BRIDGE_I2C_ADDR   =8'h1C ;

//-WRITE-  -READ-
parameter    P_ID                   =16'h0000;// read chip and revision id; expected: 0x4401

parameter TIME_LONG  =100 ; 
//----
reg [31:0] DELY ;

always @(negedge RESET_N or posedge CLK_400K )begin 
if (!RESET_N  ) begin 
   ST <=0;
	W_POINTER_GO <=1;
   R_GO      <=1 ;		 
	W_WORD_GO <=1;
	WCNT <=0;  
	CNT  <=0;
	DELY <=0 ;	
	MIPI_BRIDGE_CONFIG_RELEASE <= 0 ;  
	
end
else  begin  
case (ST)
0: begin 
   ST<=1;//30; //Config Reg
	W_POINTER_GO <=1;
   R_GO  <=1 ;		 
	W_WORD_GO <=1;
	WCNT <=0;  
	CNT <=0;
	DELY <=0 ;	
   end
//<----------------READ -------	
1: begin 
   ST<=2;
	end	
2: begin 
	     if ( CNT==0 )     { SLAVE_ADDR[7:0] , POINTER[15:0]}  <={  MIPI_BRIDGE_I2C_ADDR[7:0] , P_ID[15:0] }   ;
   if ( W_POINTER_END ) begin  W_POINTER_GO  <=0; ST<=3 ; DELY<=0;  end
	end                // Write pointer
3: begin 
    
    if ( DELY ==2 ) begin 
     W_POINTER_GO  <=1;
     ST<=4 ;
	  DELY <=0 ; 
	 end
	 else DELY  <=DELY +1;
	end       
4: begin 
    
   if ( DELY ==3 ) begin  
       if  ( W_POINTER_END ) ST<=5 ; 	
	end 
   else DELY  <=DELY +1;	 
	 end 
5: begin ST<=6 ; end //delay
//read DATA 		 
6: begin 
	if ( R_END ) begin  R_GO  <=0; ST<=7 ; DELY<=0; end
	end                
7: begin 
    DELY  <=DELY +1;
    if ( DELY ==2 ) begin 	 
    R_GO  <=1;
    ST<=8 ; 
	 end
	 
	end       
8: begin 
   ST<=9 ; 
	end       
	
9: begin 
   if  ( R_END ) begin 
	       if ( CNT==0 )  ID    <= R_DATA ; 
	  CNT<=CNT+1 ;
	  ST<=10 ; 	
	end 
  end	
10: begin   
     if ( CNT ==1 )  begin 
	       ST<=28;
			 //MIPI_BRIDGE_CONFIG_RELEASE <= 1; 
		end 	 
	   else   ST<=1;	
		   DELY <=0;
	      W_POINTER_GO <=1;
         R_GO         <=1 ;		 
	      W_WORD_GO    <=1; 	 	  
	 end //delay
//<----------------------------------READ-----------------------
28: begin
    if (DELY < 5  ) DELY <=DELY+1; 
    else begin 
	    ST<=30;  
	 end  
end 
//<----------------------------------WRITE WORD-----------------
30: begin 
     ST<=31; 
	  WCNT<=0 ; 
    end	
31: begin 
      if  ( REG16_DATA16[31:16] == 16'hffff )  ST <= 40 ;     
		else  begin 
	      { SLAVE_ADDR[7:0] , POINTER [15:0] ,WORD_DATA [15:0]} <= {  MIPI_BRIDGE_I2C_ADDR[7:0] ,REG16_DATA16  } ; 
	      if ( W_WORD_END ) begin  W_WORD_GO  <=0; ST<=32 ;  DELY<=0;  end
		end 	
		
	end                // Write ID pointer 
32: begin 
    if ( DELY ==3 ) begin 
       W_WORD_GO  <=1;
       ST<=33 ; 
	 end
	 else  DELY <=DELY +1;
	end       
33: begin 
    ST<=34 ; 
	end       	
34: begin 
     if  ( W_WORD_END )  begin 	
			  WCNT<=WCNT+1 ;			 
			  ST<=35 ; 
	  end
	end              
35: begin 
        if  (  WCNT == WORD_NUM_MAX )    //13
		  begin   ST<= 36 ;  //1 WCNT <=0; 
		          CNT <=0; DELY <= 0; I2C_LO0P <= 1 ;  
		  end 
	     else   ST<=31 ; 	 
	 end 

36: begin 
     MIPI_BRIDGE_CONFIG_RELEASE <= 1;	 
    end 	  
	 
	 
//-------DELAY PROCESS 
40:begin 
     DELY <=0;
     ST<=41 ; 	 
	end 
41: begin 
    if ( DELY == REG16_DATA16[15:0] * 5  )   begin 
	  ST<=42; 
	  WCNT <=WCNT+1 ; 
	 end  
	 else  DELY <=DELY +1;	
end 	 
	 
42: begin 
    ST<=31; 
end 	 
	
	  
endcase 
end 
end



//===parameter ===
parameter  FIFO_LEVEL  =16'h8 ;  // try others? [0~511]
parameter  DATA_FORMAT =16'h0010 ; 

parameter  PLL_PRD     =1;   // 0- 15
parameter  PLL_FBD     =39; //0-511
parameter  PLL_FRS     =1;  //0-3
parameter  MCLK_HL     =1;  // (MCLK_HL+1)+ (MCLK_HL+1)

// REFCLK    20 MHz
// PPIrxCLK  100 MHz
// PCLK      25 MHz
// MCLK      25 MHz

//2b'00: div 8, 2b'01: div 4, 2b'10: div 2
parameter  PPICLKDIV   =2 ;  // ppi_clk:must between 66~125MHz
parameter  MCLKREFDIV  =2;   // mclkref clock:  < 125MHz
parameter  SCLKDIV     =0 ;  // sys_clk clock:  < 100MHz


parameter  WORDCOUNT   =800;

assign PLLControlRegister0   = ((PLL_PRD <<12) + PLL_FBD);                     
assign PLLControlRegister1   = ((PLL_FRS <<10) + (16'h2<<8) +  ( 16'h1<<1)+ 16'h1);
assign PLLControlRegister2   = ((PLL_FRS <<10)  + (16'h2<<8) + (16'h1<<4) + (16'h1<<1)+ 16'h1);
assign PLLControlRegister3   = ((PPICLKDIV<<4) + (MCLKREFDIV<<2) + SCLKDIV );          
assign MCLKControlRegister = ((MCLK_HL<<8) + MCLK_HL);                              


//-------WRITE TABLE 
reg [31:0] REG16_DATA16;

//static SZ_MIPI_REG_T MipiBridgeReg[] = {
always @(posedge CLK_400K )begin 
case (WCNT) 
	0: REG16_DATA16 <=  {16'h0002,16'h0001};              // System Control Register
	1: REG16_DATA16 <=  {16'hFFFF,16'h10};               // delay
	2: REG16_DATA16 <=  {16'h0002,16'h0000};              // System Control Register
	3: REG16_DATA16 <=  {16'h0016,PLLControlRegister0};   //PLL Control Register 0
	4: REG16_DATA16 <=  {16'h0018,PLLControlRegister1};   //PLL Control Register 1
	5: REG16_DATA16 <=  {16'hFFFF,16'h1010};              // delay
	6: REG16_DATA16 <=  {16'h0018,PLLControlRegister2};   //PLL Control Register 1
	7: REG16_DATA16 <=  {16'h0020,PLLControlRegister3};   //PLL Control Register 0
	8: REG16_DATA16 <=  {16'h000C,MCLKControlRegister};   //MCLK Control Register
	9: REG16_DATA16 <=  {16'h0060,16'h8006}; //<--- 
	10:REG16_DATA16 <=  {16'h0006,FIFO_LEVEL};  // FiFo Control Register   [0~511] // when reaches to this level FiFo controller asserts FiFoRdy for Parallel port to start output data
	11:REG16_DATA16 <=  {16'h0008,DATA_FORMAT}; //Data FormatControl Register //	{0x0022,WORDCOUNT}, //Word Count Register
	12:REG16_DATA16 <=  {16'h0004,16'h8047};    // Configuration Control Register
endcase 
end 
 
 
// --BIN 
 
//<-----------------------------MAIN-ST END ------------------------------------------
wire const_zero_sig/* synthesis keep */ ; 
assign const_zero_sig = 0 ;

//I2C-BUS
wire   SDAO; 

assign I2C_SCL_O       = W_WORD_SCL  & W_POINTER_SCL & R_SCL;
assign SDAO            = W_POINTER_SDAO & R_SDAO  & W_WORD_SDAO;
assign I2C_SDA =     ( ( SDAO )  ||     ( RESET_N==0 ) )?1'bz :const_zero_sig;//1'b0 ; 
assign I2C_SCL =     ( ( I2C_SCL_O)  || ( RESET_N==0 ) )?1'b1 :1'b0;//const_zero_sig;//1'b0 ;

//==== I2C WRITE WORD ===
wire   W_WORD_SCL ; 
wire   W_WORD_SDAO ;  

I2C_WRITE_WDATA  wrd(
   .RESET_N      ( RESET_N_1),
	.PT_CK        ( CLK_400K),
	.GO           ( W_WORD_GO),
	.LIGHT_INT    ( ),
	.POINTER      ( POINTER ),
   .WDATA	     ( WORD_DATA[15:0] ),  //16BIT 
	.SLAVE_ADDRESS( SLAVE_ADDR ),
	.SDAI         ( I2C_SDA),
	.SDAO         ( W_WORD_SDAO),
	.SCLO         ( W_WORD_SCL ),
	.END_OK       ( W_WORD_END),
	//--for test 
	.ST           ( WORD_ST ),
	.CNT          ( WORD_CNT),
	.BYTE         ( WORD_BYTE),
	.ACK_OK       (),
	.SDAI_W       ( SDAI_W ),
	.BYTE_NUM     (4 ) 
	
);


//==== I2C WRITE POINTER ===
wire   W_POINTER_SCL ; 
 
wire   W_POINTER_SDAO ;  

I2C_WRITE_PTR	  wpt(
   .RESET_N (RESET_N_1),
	.PT_CK        (CLK_400K),
	.GO           (W_POINTER_GO),
	.POINTER      (POINTER),
	.SLAVE_ADDRESS(SLAVE_ADDR ),//37
	.SDAI  (I2C_SDA),
	.SDAO  (W_POINTER_SDAO),
	.SCLO  (W_POINTER_SCL ),
	.END_OK(W_POINTER_END),
	//--for test 
	.ST (),
	.ACK_OK(),
	.CNT (),
	.BYTE() ,
   .BYTE_END (2) 	
);


//==== I2C READ ===

wire R_SCL; 
wire R_SDAO;  

I2C_READ_DATA rd( //
   .RESET_N (RESET_N_1),
	.PT_CK        (CLK_400K),
	.GO           (R_GO),
	.SLAVE_ADDRESS(SLAVE_ADDR ),
	.SDAI  (I2C_SDA),
	.SDAO  (R_SDAO),
	.SCLO  (R_SCL),
	.END_OK(R_END),
	.DATA16 (R_DATA),
	
	//--for test 
	.ST    (),
	.ACK_OK(),
	.CNT   (),
	.BYTE  ()  ,
   .END_BYTE  (1) ,//read 2 byte  	
);
	

	
	

//---I2C DELAY --- 	
wire   RESET_N_1 ;

I2C_RESET_DELAY DY (
  .CLK     (CLK_50), 
  .READY   (RESET_N_1)
) ; 



	
endmodule
	