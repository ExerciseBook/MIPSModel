`include "ctrl_encode_def.v"
module alu (A, B, ALUOp, C, Zero);
           
   input  [31:0] A, B;
   input  [1:0]  ALUOp;
   output [31:0] C;
   output        Zero;
   
   reg [31:0] C;
       
   always @( A or B or ALUOp ) begin
      case ( ALUOp )
      // `ALUOp_NOP  :
         `ALUOp_ADDU : C = A + B;
         `ALUOp_ADD  : C = A + B;
         `ALUOp_SUBU : C = A - B;
         `ALUOp_SUB  : C = A + (~B) + 1;
         `ALUOp_AND  : C = A & B;
         `ALUOp_OR   : C = A | B;
         `ALUOp_NOR  : C = ~(A | B);
         `ALUOp_XOR  : C = A ^ B;
         `ALUOp_SLT  : if ((A + (~B) + 1) & 32'h80000000 === 32'h80000000) C = 1; else C = 0; //TODO
         `ALUOp_SLTU : if (A < B) C = 1; else C = 0;
      // `ALUOp_EQL  :
      // `ALUOp_BNE  :
      // `ALUOp_GT0  :
      // `ALUOp_GE0  :
      // `ALUOp_LT0  :
      // `ALUOp_LE0  :
         `ALUOp_SLL  : C = A << B;
         `ALUOp_SRL  : C = A >> B;
         `ALUOp_SRA  : C = A >>> B;
         default:   ;
      endcase
   end // end always;
   
   assign Zero = (A == B) ? 1 : 0;

endmodule
    
