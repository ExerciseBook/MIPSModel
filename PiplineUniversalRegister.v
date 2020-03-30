module PiplineUniversalRegister #(parameter WIDTH = 32)(clk, rst, Wr, in, out);
            
   input                clk;
   input                rst;
   input                Wr; 
   input  [WIDTH-1 : 0] in;
   output [WIDTH-1 : 0] out;

   reg [WIDTH-1 : 0] out;
               
   always @(posedge clk or posedge rst) begin
      if ( rst ) begin
         out = 0;
      end
      else// if (Wr)
         out <= in;
   end
   
endmodule


module PiplineUniversalRegisterNeg #(parameter WIDTH = 32)(clk, rst, Wr, in, out);
            
   input                clk;
   input                rst;
   input                Wr; 
   input  [WIDTH-1 : 0] in;
   output [WIDTH-1 : 0] out;

   reg [WIDTH-1 : 0] out;
               
   always @(negedge clk or posedge rst) begin
      if ( rst ) begin
         out = 0;
      end
      else// if (Wr)
         out <= in;
   end
   
endmodule
