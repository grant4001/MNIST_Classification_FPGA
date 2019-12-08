module I2C_WRITE_PTR  (
   input  				RESET_N ,
	input      			PT_CK,
	input      			GO,
	input      [15:0]	POINTER,
	input      [7:0]	SLAVE_ADDRESS,	
	input      			SDAI,
	output reg 			SDAO,
	output reg 			SCLO,
	output reg 			END_OK,
	
	//--for test 
	output reg [7:0]	ST ,
	output reg 			ACK_OK,
	output reg [7:0] 	CNT ,
	output reg [7:0] 	BYTE  ,
	input      [7:0] 	BYTE_END //1 byte pointer   :2 1 byte pointer	
	
);

reg   [8:0]A ;
reg   [7:0]DELY ;

always @( negedge RESET_N or posedge  PT_CK )begin
if ( !RESET_N ) begin 
            ST <=0;
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;	   
 end  
else 
	  case (ST[7:0] )
	     0: begin  //start 		      
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;	
	         if (GO) ST  <=10 ; // inital 							
		    end	  
	    1: begin  //start 
		      ST <=2 ; 
			   { SDAO,  SCLO } <= 2'b01; 
				A <= {SLAVE_ADDRESS ,1'b1 };//WRITE COMMAND
		    end
	    2: begin  //start 
		      ST <=3 ; 
			   { SDAO,  SCLO } <= 2'b00; 
		    end			 
	    3: begin  //start 
		      ST <=4 ; 
			   { SDAO, A } <= { A ,1'b0 }; 
		    end
	    4: begin  //start 
		      ST <=5 ; 
			   SCLO <= 1'b1 ; 
				CNT <= CNT +1 ;
		    end
			 
	    5: begin  
			 SCLO <= 1'b0 ; 
			 if (CNT==9) begin
				      if ( BYTE ==BYTE_END )  ST <= 6 ; 
					   else  
						begin 
							CNT <=0 ; 
							     if  (BYTE ==0)  begin  A <= {POINTER[15:8] ,1'b1 };   BYTE <=1 ; end 
							else if  (BYTE ==1)  begin  A <= {POINTER[7:0] ,1'b1 };    BYTE <=2 ; end 
							ST <= 2 ; 
						end
					   if   ( !SDAI ) ACK_OK <=1 ; 
					   else  ACK_OK <=0 ; 
				 end
			 else ST <= 2;
		    end
	    6: begin          //stop
				ST <=7 ; 
			   {SDAO,SCLO } <= 2'b00; 
         end

	    7: begin          //stop
		      ST <=8 ; 
			   {SDAO,SCLO } <= 2'b01; 
         end
	    8: begin          //stop
		      ST <=9 ; 
			   {SDAO,SCLO } <= 2'b11; 						
         end //stop
		9:	begin
		      ST     <= 10; 
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;					
		     end
		//--- END ---
		 10: begin
            if ( !GO  ) ST  <=11;
          end
	  //---SLEEP UP-----		 
	    11: begin  //
		      END_OK<=0;
				CNT <=0 ; 
		      ST  <=12 ; 
			   { SDAO,  SCLO } <= 2'b01; 
				A <= {SLAVE_ADDRESS ,1'b1 };//WRITE COMMAND
		    end
	    12: begin  //start 
		      ST <=13 ; 
			   { SDAO,  SCLO } <= 2'b00; 
		    end			 
	    13: begin  //start 
		      ST <=14 ; 
			   { SDAO, A } <= { A ,1'b0 }; 
		    end
	    14: begin  //start 
		      ST <=15 ; 
			   SCLO <= 1'b1 ; 
				CNT <= CNT +1 ;
		    end
			 
	    15: begin  
			  
			  if (CNT==9)  begin DELY<=0;  ST <=  16;end 
			  else begin ST <=  12; SCLO <= 1'b0 ; end 
		    end	
 			 
	    16: begin  
		         DELY<=DELY+1;
				   if ( DELY > 1 )  begin 
				         if ( SDAI==1 ) begin ST <=  17 ; //{ SDAO,  SCLO } <= 2'b11; 
							end
			            else  
							begin ST <=5 ;SCLO <= 1'b0;  end 
			      end
				end	
				
///----	   
        17: begin          //stop
				ST <=18 ; 
			   {SDAO,SCLO } <= 2'b00; 
         end

	    18: begin          //stop
		      ST <=19 ; 
			   {SDAO,SCLO } <= 2'b01; 
         end
	    19: begin          // restart 
		       ST <= 20 ;  
			   {SDAO,SCLO } <= 2'b11; 
				 DELY<=0;
         end 
	    20: begin  
		          DELY<=DELY+1;
				     if ( DELY > 2 )  ST <=11 ;
				end 				
				
				
				
				
	  endcase 
 end
 
endmodule
