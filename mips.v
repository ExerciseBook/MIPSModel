`include "ctrl_encode_def.v"
`include "instruction_def.v"

module mips( clk, rst );

   // 时钟相关
   input   clk;
   input   rst;
   
   // 控制信号相关
	wire jump;						//指令跳转
	wire RegDst;						
	wire Branch;					//分支
	wire MemR;						//读存储器
	wire Mem2R;						//数据存储器到寄存器堆
	wire MemW;						//写数据存储器
	wire RegW;						//寄存器堆写入数据
	wire Alusrc;					//运算器操作数选择
	wire [1:0] ExtOp;				//位扩展/符号扩展选择
	wire [1:0] ALUOp;	   	   //Alu运算选择

   // 算数运算相关
   wire zero;  
   wire [31:0] Alu_Result;

   // 指令地址相关
	wire [31:0] PC;
	wire [31:0] NPC;
   wire [9:0] PCAddr;
   assign PCAddr = PC[11:2];
   assign PcSel = ( ( Branch && zero ) == 1 ) ? 1 : 0 ;

   // 指令本体
   wire [31:0] AnInstruction;

   // 拆分指令
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

   // 寄存器相关
   wire [4:0] RF_rd;
   assign RF_rd = (RegDst === 0) ? rt : rd ;

   // 符号扩展相关
   wire [31:0] Imm32;

   // 数据内存相关
   wire [31:0] DM_Out;
   wire [11:2] DM_Addr;
   assign DM_Addr = Alu_Result[11:2];

   // 寄存器相关
   wire [31:0] RD1;
   wire [31:0] RD2;
   wire [31:0] RF_WD;
   assign RF_WD = (Mem2R == 1) ? DM_Out : Alu_Result;

   // 算数运算相关
   wire AluSrc;
   wire [31:0] AluMux_Result;
   assign AluMux_Result = (AluSrc === 0) ? RD2 : Imm32;

   // 指令计数器模块
   PC U_PC (
      .Clk(clk), .PcReSet(rst), .PC(PC), .PcSel(PcSel), .Address(Imm32)
   ); 
   
   // 指令模块
   im_4k U_IM ( 
      .addr(PCAddr) , .dout(AnInstruction)
   );

   // 寄存器模块   
   RF U_RF (
      .A1(rs), .A2(rt), .A3(RF_rd), .WD(RF_WD), .clk(clk), 
      .RFWr(RegW), .RD1(RD1), .RD2(RD2)
   );

   // 符号扩展模块
   EXT U_SIGNEDEXT (
      .Imm16(Imm16), .EXTOp(ExtOp), .Imm32(Imm32)
   );

   // 算术运算模块
   alu U_ALU (
      .A(RD1), .B(AluMux_Result), .ALUOp(ALUOp), .C(Alu_Result), .Zero(Zero)
   );

   // 数据内存模块
   dm_4k U_DM (
      .addr(DM_Addr), .din(RD2), .DMWr(MemW), .clk(clk), .dout(DM_Out)
   );

   // 信号控制模块
   SingalManager U_SingalManager(
      .jump(jump),
      .RegDst(RegDst),
      .Branch(Branch),
      .MemR(MemR),
      .Mem2R(Mem2R),
      .MemW(MemW),
      .RegW(RegW),
      .Alusrc(AluSrc),
      .ExtOp(ExtOp),
      .Aluctrl(ALUOp),
      .OpCode(Op),
      .funct(Funct)
   );

endmodule