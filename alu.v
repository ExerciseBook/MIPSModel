`include "ctrl_encode_def.v"
module alu (A, B, ALUOp, C, Zero);
           
   input  [31:0] A, B;
   input  [4:0]  ALUOp;
   output [31:0] C;
   output        Zero;
   
   reg [31:0] C;

   wire [4:0] sa;
   assign sa = B[10:6];
   

   wire signed [31:0] SignedA, SignedB;
   assign SignedA = A;
   assign SignedB = B;

   always @( A or B or ALUOp ) begin

      case ( ALUOp )
      // `ALUOp_NOP  :
         `ALUOp_ADDU : C = A + B;
         `ALUOp_ADD  : C = A + B;
         `ALUOp_SUBU : C = A - B;
         `ALUOp_SUB  : C = SignedA - SignedB;
         `ALUOp_AND  : C = A & B;
         `ALUOp_OR   : C = A | B;
         `ALUOp_NOR  : C = ~(A | B);
         `ALUOp_XOR  : C = A ^ B;
         `ALUOp_SLT  : if (SignedA < SignedB) C = 1; else C = 0; //TODO
         `ALUOp_SLTU : if (A < B) C = 1; else C = 0;
      // `ALUOp_EQL  :
      // `ALUOp_BNE  :
      // `ALUOp_GT0  :
      // `ALUOp_GE0  :
      // `ALUOp_LT0  :
      // `ALUOp_LE0  :
         `ALUOp_SLL  : C = A << sa;
         `ALUOp_SRL  : C = A >> sa;
         `ALUOp_SRA  : C = SignedA >>> sa;
         default:   ;
      endcase

      $display("A=%8X, B=%8X, sa=%2X ALUOP=%5b, C=%8X", A, B, sa, ALUOp, C);
   end

   assign Zero = (A == B) ? 1 : 0;

endmodule
    
