module ON_CHIP_FRAM  ( 
    input         W_CLK ,  
    input         R_CLK ,  
    input         W_DE   ,  
    input  [9:0]  W_DATA , 
    output [9:0]  R_DATA , 
    input         W_CLR , 
    input         R_CLR ,  
    input         R_DE,
    output [19:0]WR_ADDR,
    output [19:0]RD_ADDR

 ); 

//wire [19:0]WR_ADDR;
//wire [19:0]RD_ADDR;
 
//--read /write address  counter 
FRM_COUNTER wrw(.CLOCK( W_CLK),.CLR( W_CLR ),.DE( W_DE ),.ADDR( WR_ADDR)  );
FRM_COUNTER rrr(.CLOCK( R_CLK),.CLR( R_CLR ),.DE( R_DE ),.ADDR( RD_ADDR)  );

//FRAM_BUFF  GG(
//	                  .address_a ( WR_ADDR[19:0]     ),
//	                  .address_b ( RD_ADDR[19:0]     ),
//	                  .data_a    ( W_DATA [9:0] ),
//	                  .data_b    ( ),
//	                  .clock_a   ( W_CLK ),
//	                  .clock_b   ( R_CLK ),
//	                  .wren_a    ( W_DE ),
//	                  .wren_b    ( 0  ),
//	                  .q_a       ( ),
//	                  .q_b       ( R_DATA ),	
//	);

	
	
FRAM_BUFF GG(
	.wraddress(WR_ADDR[19:0]),
	.rdaddress(RD_ADDR[19:0]),
	.data     (W_DATA [9:0]),
	.wrclock  (W_CLK),
	.rdclock  (R_CLK),
	.wren     (W_DE),
	.q        (R_DATA[9:0] )
	);
	
	//	assign R_DATA  = 10'h3ff ; 
endmodule 	