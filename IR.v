module IR (clk, rst, IRWr, im_dout, instr);
               
   input         clk;
   input         rst;
   input         IRWr; 
   input  [31:0] im_dout;
   output [31:0] instr;
   
   reg [31:0] instr;
               
   always @(posedge clk or posedge rst) begin
      if ( rst ) 
         instr <= 0;
      else if (IRWr)
         instr <= im_dout;
   end // end always
      
endmodule
