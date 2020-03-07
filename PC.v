module PC( clk, rst, PCWr, NPC, PC );
           
   input         clk;
   input         rst;
   input         PCWr;
   input  [31:2] NPC;
   output reg[31:2] PC;
   
   reg [1:0] tmp;
               
   always @(posedge clk or posedge rst) begin
      if ( rst ) 
         {PC, tmp} <= 32'h0000_3000;   
      else if ( PCWr ) 
         PC <= NPC;
   end // end always
           
endmodule
