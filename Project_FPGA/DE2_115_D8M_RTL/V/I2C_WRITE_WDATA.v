module I2C_WRITE_WDATA  (
   input  				RESET_N ,
	input      		  	PT_CK,
	input      		  	GO,
	input LIGHT_INT ,
	input      [15:0] POINTER,
	input      [7:0] 	SLAVE_ADDRESS,	
	input      [15:0]	WDATA,		
	input            	SDAI,
	output reg       	SDAO,
	output reg       	SCLO,
	output reg       	END_OK,
	
	//--for test 
	output SDAI_W ,
	output reg [7:0] 	ST ,
	output reg [7:0] 	CNT,
	output reg [7:0] 	BYTE,
	output reg       	ACK_OK,
   input      [7:0]  BYTE_NUM  // 4 : 4 byte 	
);

//=====byte end ==== 
//parameter 	BYTE_NUM = 4;
 
//===reg/wire  
reg   [8:0]A ;
reg   [7:0]DELY ;
assign SDAI_W =SDAI ;



always @( negedge RESET_N or posedge  PT_CK )begin
if (!RESET_N  )  
begin 
            ST     <=0 ; 
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;	
end 		
else 
	  case (ST)
	    0: begin  //start 		      
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;	
	         if (GO) ST  <=30 ; // inital 							
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
			 
	    5: begin  //start 
			   SCLO <= 1'b0 ; 
			   if (CNT==9) begin
				     if ( BYTE == BYTE_NUM )  ST <= 6 ; 
					  else  begin 
					           CNT <=0 ; 
					           ST <= 2 ;
					                if ( BYTE ==0 ) begin BYTE <=1  ; A <= {POINTER[15:8] ,1'b1 }; end 
					           else if ( BYTE ==1 ) begin BYTE <=2  ; A <= {POINTER[7:0] ,1'b1 }; end 
						        else if ( BYTE ==2 ) begin BYTE <=3  ; A <= {WDATA[15:8] ,1'b1 }; end 
						        else if ( BYTE ==3 ) begin BYTE <=4  ; A <= {WDATA[7:0] ,1'b1 }; end 
							  end
					  if ( !SDAI_W ) ACK_OK <=1 ; 
					  else ACK_OK <=0 ; 
				 end
				 else ST <= 2;
		    end

	    6: begin          //stop
		      ST <=7 ; 
			   { SDAO,  SCLO } <= 2'b00; 
         end

	    7: begin          //stop
		      ST <=8 ; 
			   { SDAO,  SCLO } <= 2'b01; 
         end
	    8: begin          //stop
		      ST <=9 ; 
			   { SDAO,  SCLO } <= 2'b11; 
						
         end //stop
		9:	begin
		      ST     <= 30; 
				SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;
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
				   if ( DELY > 10 )  begin 
							 //if ( LIGHT_INT==1 ) begin 
							  ST <= 31 ;  { SDAO,  SCLO } <= 2'b11; 
							  //end
			             //else  begin ST <=5 ;SCLO <= 1'b0;  end 
			      end
			end		
	  endcase 
 end
 
endmodule
