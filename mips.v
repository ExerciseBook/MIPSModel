`include "ctrl_encode_def.v"
module mips( clk, rst );
   input   clk;
   input   rst;
   
   wire 		     RFWr;
   wire 		     DMWr;
   wire 		     PCWr;
   wire 		     IRWr;
   wire [1:0]    EXTOp = `EXT_SIGNED;
   wire [1:0]    ALUOp;
   wire [1:0]    NPCOp;
   wire 		     BSel;
   wire 		     Zero;


   // 指令地址模块
	wire [31:0] PC;
	wire [31:0] NPC;
   wire [9:0] PCAddr;
   assign PCAddr = PC[11:2];

   PC U_PC (
      .clk(clk), .rst(rst), .PCWr(PCWr), .NPC(NPC), .PC(PC)
   ); 
   
   // 指令模块
	wire [31:0] AnInstruction;
   im_4k U_IM ( 
      .addr(PCAddr) , .dout(AnInstruction)
   );

   // 解析指令
   wire [5:0] Op;
   wire [5:0] Funct;
   wire [4:0] rs;
   wire [4:0] rt;
   wire [4:0] rd;
   wire [15:0] Imm16;
   wire [25:0] IMM;

   assign Op = AnInstruction[31:26];
   assign Funct = AnInstruction[5:0];
   assign rs = AnInstruction[25:21];
   assign rt = AnInstruction[20:16];
   assign rd = AnInstruction[15:11];
   assign Imm16 = AnInstruction[15:0];
   assign IMM = AnInstruction[25:0];

   //TODO RF_rd 需要加选择器处理
   wire [4:0] RF_rd;

   //TODO RF_WD 需要加选择器处理 (写回数据)
   wire [31:0] RF_WD;

   // 寄存器模块
   wire [31:0] RD1;
   wire [31:0] RD2;
   RF U_RF (
      .A1(rs), .A2(rt), .A3(RF_rd), .WD(RF_WD), .clk(clk), 
      .RFWr(RFWr), .RD1(RD1), .RD2(RD2)
   );

   // 符号扩展模块
   wire [31:0] Imm32;
   EXT U_SIGNEDEXT (
      .Imm16(Imm16), .EXTOp(EXTOp), .Imm32(Imm32)
   );

   //TODO 从 ALUOp 解析出 AluMux_Op
   wire AluMux_Op;


   // 算术运算模块第二个输入口前的选择器
   wire [31:0] AluMux_Result;
   mux2 #(.WIDTH(32)) AluInputMux (.d0(RD2), .d1(Imm32), .s(AluMux_Op), .y(AluMux_Result));

   //TODO 将 Funct 转换为 ALUOp

   // 算术运算模块
   wire [31:0] Alu_Result;
   alu U_ALU (
      .A(RD1), .B(AluMux_Result), .ALUOp(ALUOp), .C(Alu_Result), .Zero(Zero)
   );

   // 数据内存模块
   wire [31:0] DM_Out;
   wire [11:2] DM_Addr;
   assign DM_Addr = Alu_Result[11:2];
   dm_4k U_DM (
      .addr(DM_Addr), .din(RD2), .DMWr(DMWr), .clk(clk), .dout(DM_Out)
   );
   
   //TODO PC+4 和 PC跳转
  
endmodule