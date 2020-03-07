module mips( clk, rst );
   input   clk;
   input   rst;
   
   wire 		     RFWr;
   wire 		     DMWr;
   wire 		     PCWr;
   wire 		     IRWr;
   wire [1:0]  EXTOp;
   wire [1:0]  ALUOp;
   wire [1:0]  NPCOp;
   wire 		     BSel;
   wire 		     Zero;
   
	wire [31:0] PC;
   assign PCAddr = PC[11:2];

   PC U_PC (
      .clk(clk), .rst(rst), .PCWr(PCWr), .NPC(NPC), .PC(PC)
   ); 
   
	wire [31:0] im_dout;

   im_4k U_IM ( 
      .addr(PCAddr) , .dout(im_dout)
   );

   assign Op = im_dout[31:26];
   assign Funct = im_dout[5:0];
   assign rs = im_dout[25:21];
   assign rt = im_dout[20:16];
   assign rd = im_dout[15:11];
   assign Imm16 = im_dout[15:0];
   assign IMM = im_dout[25:0];

   RF U_RF (
      .A1(rs), .A2(rt), .A3(A3), .WD(WD), .clk(clk), 
      .RFWr(RFWr), .RD1(RD1), .RD2(RD2)
   );
   
      

  
endmodule