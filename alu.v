`include "ctrl_encode_def.v"
module alu (A, B, ALUOp, C, Zero);
           
   input  [31:0] A, B;
   input  [1:0]  ALUOp;
   output [31:0] C;
   output        Zero;
   
   reg [31:0] C;
       
   always @( A or B or ALUOp ) begin
      case ( ALUOp )
         2'b00 : C = A + B;
         2'b01 : C = A - B;
         default: C = A | B; //TODO 先整完第一个 Checkpoint
      endcase

      $display("A=%8X, B=%8X, C=%8X, ALUOp=%2B",A,B,C,ALUOp);
   end // end always;
   
   assign Zero = (A == B) ? 1 : 0;

endmodule
    
