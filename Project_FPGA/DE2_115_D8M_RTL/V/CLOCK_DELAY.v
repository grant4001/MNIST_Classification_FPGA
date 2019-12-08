module CLOCK_DELAY  ( 
input  iCLK , 
output oCLK 
);
wire [9:0]  PCK;


//================
lcell l0(.in(iCLK) ,.out(PCK[0]) ); 

lcell l1(.in(PCK[0]) ,.out(PCK[1]) ); 
lcell l2(.in(PCK[1]) ,.out(PCK[2]) ); 
lcell l3(.in(PCK[2]) ,.out(PCK[3]) ); 
lcell l4(.in(PCK[3]) ,.out(PCK[4]) ); 
lcell l5(.in(PCK[4]) ,.out(PCK[5]) ); 
lcell l6(.in(PCK[5]) ,.out(PCK[6]) ); 
lcell l7(.in(PCK[3]) ,.out(oCLK)); 



endmodule  

