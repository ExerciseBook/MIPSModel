// `include "global_def.v"
module RF( A1, A2, A3, WD, clk, RFWr, RD1, RD2 );
    
   input  [4:0]  A1, A2, A3;
   input  [31:0] WD;
   input         clk;
   input         RFWr;
   output [31:0] RD1, RD2;
   
   reg [31:0] rf[31:0];
   
   integer i;
   initial begin
       for (i=0; i<32; i=i+1)
          rf[i] = 0;
   end
   
   always @(posedge clk) begin
      $display("RFWr=%1B, WD=%8X, TargetAddr=%2X", RFWr, WD, A3);


      if (RFWr) rf[A3] <= WD;

      $display("R[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", rf[0], rf[1], rf[2], rf[3], rf[4], rf[5], rf[6], rf[7]);
      $display("R[08-15]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", rf[8], rf[9], rf[10], rf[11], rf[12], rf[13], rf[14], rf[15]);
      $display("R[16-23]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", rf[16], rf[17], rf[18], rf[19], rf[20], rf[21], rf[22], rf[23]);
      $display("R[24-31]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X", rf[24], rf[25], rf[26], rf[27], rf[28], rf[29], rf[30], rf[31]);
      $display("R[%4X]=%8X", A3, rf[A3]);
      
   end // end always
   
   assign RD1 = (A1 == 0) ? 32'd0 : rf[A1];
   assign RD2 = (A2 == 0) ? 32'd0 : rf[A2];
   
endmodule


