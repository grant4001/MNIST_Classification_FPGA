module I2C_READ_DATA (
   input  				RESET_N ,
	input       		PT_CK,
	input       [7:0]	SLAVE_ADDRESS ,
	input       		GO,
	input       		SDAI,
	output reg  		SDAO,
	output reg  		SCLO,
	output reg  		END_OK , 
	output reg  [15:0] DATA16 , 
	//for TEST
	output reg  [7:0] ST ,
	output reg        ACK_OK,
	output reg  [7:0] CNT,
	output reg  [8:0] A ,
	output reg  [7:0] BYTE,
	input       [7:0] END_BYTE 
);


reg    [7:0]DELY ;    //ST DELAY
//wire   [7:0]END_BYTE ; 
//assign      END_BYTE =1;

always @( negedge RESET_N or posedge  PT_CK )begin
if (!RESET_N  )  begin 
   ST <=0;
			      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;
				DATA16 <=0;
end 	
	
else 
	  case (ST)
	    0: begin  
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;
				DATA16 <=0;
	         if (GO) ST  <=30 ;							
		    end		  
	  //----I2C READ-COMMAND---
	    1: begin  //start 
		      ST <=2 ; 
			   { SDAO,  SCLO } <= 2'b01; 
				A <= {SLAVE_ADDRESS | 1  ,1'b1 };//READ COMMAND
		    end
	    2: begin  //start 
		      ST <=3 ; 
			   { SDAO,  SCLO } <= 2'b00; 
		    end
			 
	    3: begin  //start 
		      ST <=4 ; 
			   { SDAO, A } <= { A ,1'b0 }; 
		    end
	    4: begin
		      ST <=5 ; 
			   SCLO <= 1'b1 ; 
				CNT <= CNT +1 ;
		    end
			 
	    5: begin  
			   SCLO <= 1'b0 ; 
			   if (CNT ==9) begin
				    ST <= 6 ; 
					 if ( !SDAI ) ACK_OK <=1 ; 
					 else ACK_OK <=0 ; 
				 end
				 else ST <= 2;
		    end			 
     //-----DATA READ---
	    6: begin 
		      ST <=7 ; 
			   {SDAO , SCLO} <= 2'b10; 			
				CNT <=0 ;
		    end
	    7: begin  
		      ST <=8 ;  
				DELY <=0;
			   SCLO <= 1'b1 ; 
				    if ( CNT !=8  ) DATA16 <= { DATA16[14:0], SDAI };
				   CNT <= CNT +1 ;
		    end			 
	    8: begin  		 
		    DELY <=DELY+1 ;
			 SCLO <= 1'b0 ; 
			 if (DELY ==2)  begin 			    
			    if (CNT ==8) begin
				      ST <= 7;
					   if ( BYTE  == END_BYTE )  SDAO <= 1'b1 ; 
					   else  
					   SDAO <= 1'b0 ;
				 end
			    else if (CNT == 9)  
				    begin 
					   BYTE <= BYTE +1 ;   ST <= 9; 
					 end
				 else ST <= 7;
			 end	 
		    end
	    9: begin
		     if  ( BYTE > END_BYTE ) ST <=10 ; 
			   else ST <=6 ; 
			   
         end
	    10: begin          //stop
		      ST <=11 ; 
			   { SDAO,  SCLO } <= 2'b00; 
         end
	    11: begin          //stop
		      ST <=12 ; 
			   { SDAO,  SCLO } <= 2'b01; 
         end
	    12: begin          //stop
		      ST <=13 ; 
			   { SDAO,  SCLO } <= 2'b11; 
         end	
		 13:	 
			  begin
		      ST     <= 30; 
				END_OK <= 1;
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         BYTE <=0;				
		     end
		//--- END ---
		30: begin
            if (!GO) ST  <=31;
          end
		//--- END ---
		  30: begin
            if (!GO) ST  <=31;
          end			
		  31: begin  //
		      END_OK<=0;
				ST    <=1;	
			end	
	  //---SLEEP UP-----		 
	    40: begin  //

		      END_OK<=0;
				CNT <=0 ; 
		      ST <=32 ; 
			   { SDAO,  SCLO } <= 2'b01; 
				A <= {SLAVE_ADDRESS ,1'b1 };//WRITE COMMAND
		    end
	    32: begin  //start 
		      ST <=33 ; 
			   { SDAO,  SCLO } <= 2'b00; 
		    end			 
	    33: begin  //start 
		      ST <=34 ; 
			   { SDAO, A } <= { A ,1'b0 }; 
		    end
	    34: begin  //start 
		      ST <=35 ; 
			   SCLO <= 1'b1 ; 
				CNT <= CNT +1 ;
		    end
			 
	    35: begin  
			  
			  if (CNT==9)  begin DELY<=0;  ST <= 36;end 
			  else begin ST <= 32; SCLO <= 1'b0 ; end 
		    end	
 			 
	    36: begin  
		         DELY<=DELY+1;
				   if ( DELY > 1 )  begin 
				         if ( SDAI==1 ) begin ST <= 31 ;  { SDAO,  SCLO } <= 2'b11; end
			            else  begin ST <=1 ;SCLO <= 1'b0;  end 
			      end
				end	
		//--I2C START--
	 			  	  
	  endcase 
  end

endmodule

