`include "ctrl_encode_def.v"
`include "instruction_def.v"

module mips( clk, rst );
   // 时钟相关
   input   clk;
   input   rst;
   
   // MEM/WB 级寄存器 [定义]
   wire [32+32+5+1-1 : 0] Pipline_MEMWBRegister_in;
   //                                   32   + 32         + 5        + 1
   //assign Pipline_MEMWBRegister_in = {MEM_PC, MEM_WBData, MEM_RF_rd, MEM_RegW};
   wire [32+32+5+1-1 : 0] Pipline_MEMWBRegister_out;

   wire Pipline_MEMWBRegister_reset;
   wire Pipline_MEMWBRegister_reset_;
   assign Pipline_MEMWBRegister_reset_ = rst | Pipline_MEMWBRegister_reset;
   wire Pipline_MEMWBXRegister_write;
   PiplineUniversalRegisterNeg #(.WIDTH(32+32+5+1)) Pipline_MEMWBRegister(
      .clk(clk), .rst(Pipline_MEMWBRegister_reset_), .Wr(Pipline_MEMWBRegister_write),
      .in(Pipline_MEMWBRegister_in), .out(Pipline_MEMWBRegister_out)
   );

   wire [31:0] WB_PC;
   wire [31:0] WB_WBData;
   wire [4:0] WB_RF_rd;
   wire WB_RegW;

   assign WB_PC      = Pipline_MEMWBRegister_out[32+32+5+1-1 : 32+5+1];
   assign WB_WBData  = Pipline_MEMWBRegister_out[   32+5+1-1 :    5+1];
   assign WB_RF_rd   = Pipline_MEMWBRegister_out[      5+1-1 :      1];
   assign WB_RegW    = Pipline_MEMWBRegister_out[          0         ];


   // 控制信号相关
   wire jump;                    // 指令跳转
   wire [1:0]RegDst;             
   wire [2:0]Branch;             // 分支
   wire ID_MemR;                 // 读存储器
   wire ID_Mem2R;                // 数据存储器到寄存器堆
   wire ID_MemW;                 // 写数据存储器
   wire ID_RegW;                 // 寄存器堆写入数据
   wire [1:0] AluSrc;            // 运算器操作数选择
   wire [1:0] ExtOp;             // 位扩展/符号扩展选择
   wire [4:0] ID_ALUOp;          // Alu运算选择

   wire Bobbles;                 // 气泡
   wire JumpInterrupt;           // 无懈可击

   // 算数运算相关
   wire ID_zero;  
   wire EX_zero;  
   wire [31:0] EX_Alu_Result;

   // 指令地址相关
   wire [31:0] IF_PC;
   wire [9:0] PCAddr;
   assign PCAddr = IF_PC[11:2];
   assign PcSel = ( ( (Branch[1] && ID_zero) === 1) || ( (Branch[0]===1) &&(ID_zero===0) ) ) ? 1 : 0 ;

   // 指令本体
   wire [31:0] AnInstruction;

   // IF/ID 级寄存器
   wire [32+32-1 : 0] Pipline_IFIDRegister_in;
   wire [32+32-1 : 0] Pipline_IFIDRegister_out_;
   assign Pipline_IFIDRegister_in = Bobbles ? Pipline_IFIDRegister_out_ : {IF_PC, AnInstruction};

   wire Pipline_IFIDRegister_reset;
   wire Pipline_IFIDRegister_reset_;
   assign Pipline_IFIDRegister_reset_ = rst | Pipline_IFIDRegister_reset;
   wire Pipline_IFIDRegister_write;
   PiplineUniversalRegister #(.WIDTH(64)) Pipline_IFIDRegister(
      .clk(clk), .rst(Pipline_IFIDRegister_reset_), .Wr(Pipline_IFIDRegister_write),
      .in(Pipline_IFIDRegister_in), .out(Pipline_IFIDRegister_out_)
   );

   // 拆分指令

   wire [32+32-1 : 0] Pipline_IFIDRegister_out;
   assign Pipline_IFIDRegister_out = JumpInterrupt ? 64'd0 : Pipline_IFIDRegister_out_;

   wire [31:0] ID_PC;
   wire [5:0] Op;
   wire [5:0] Funct;
   wire [4:0] rs;
   wire [4:0] rt;
   wire [4:0] rd;
   wire [15:0] Imm16;
   wire [25:0] IMM;

   assign ID_PC   = Pipline_IFIDRegister_out[63:32];
   assign Op      = Pipline_IFIDRegister_out[31:26];
   assign Funct   = Pipline_IFIDRegister_out[5:0];
   assign rs      = Pipline_IFIDRegister_out[25:21];
   assign rt      = Pipline_IFIDRegister_out[20:16];
   assign rd      = Pipline_IFIDRegister_out[15:11];
   assign Imm16   = Pipline_IFIDRegister_out[15:0];
   assign IMM     = Pipline_IFIDRegister_out[25:0];

   // 寄存器相关
   wire [4:0] ID_RF_rd = (RegDst[0] === 0) ? ( (RegDst[1] === 0) ? rd : rt ) : 5'b11111 ;

   wire [4:0] RF_rd;
   assign RF_rd = WB_RF_rd ;

   // 符号扩展相关
   wire [31:0] Imm32;

   // 寄存器相关
   wire [31:0] ID_RD1_RF;
   wire [31:0] ID_RD2_RF;
   wire [31:0] RF_WD;
   assign RF_WD = WB_WBData ; 

   // 转发相关 [定义]
   wire [31:0] ID_RD1_DE;
   wire [31:0] ID_RD2_DE;   

   // 算数运算相关
   wire [31:0] ID_Alu_AIn;
   assign ID_Alu_AIn = (RegDst[0] === 0) ? ((AluSrc[1] === 0) ? ID_RD1_DE : ID_RD2_DE) : ID_PC;

   wire [31:0] ID_Alu_BIn;
   assign ID_Alu_BIn = (RegDst[0] === 0) ? ((AluSrc[0] === 0) ? ID_RD2_DE : Imm32) : 4;

   // 指令计数器模块
   PC U_PC (
      .Clk(clk), .PcReSet(rst), .NEWPC(IF_PC), .OLDPC(WB_PC), .PcSel(PcSel), .Address(Imm32), .Branch(Branch), .JumpTarget(IMM), .JrTarget(ID_RD1_DE),
      .Bobbles(Bobbles), .Interrupt(JumpInterrupt)
   ); 
   
   // 指令模块
   im_4k U_IM ( 
      .addr(PCAddr) , .dout(AnInstruction)
   );

   // 寄存器模块   
   RF U_RF (
      .A1(rs), .A2(rt), .A3(RF_rd), .WD(RF_WD), .clk(clk), 
      .RFWr(WB_RegW), .RD1(ID_RD1_RF), .RD2(ID_RD2_RF)
   );

   // 符号扩展模块
   EXT U_SIGNEDEXT (
      .Imm16(Imm16), .EXTOp(ExtOp), .Imm32(Imm32)
   );

   // 相等比较
   assign ID_zero = (ID_Alu_AIn === ID_Alu_BIn) ? 1 : 0;

   // 信号控制模块
   SingalManager U_SingalManager(
      .jump(jump),
      .RegDst(RegDst),
      .Branch(Branch),
      .MemR(ID_MemR),
      .Mem2R(ID_Mem2R),
      .MemW(ID_MemW),
      .RegW(ID_RegW),
      .Alusrc(AluSrc),
      .ExtOp(ExtOp),
      .Aluctrl(ID_ALUOp),
      .OpCode(Op),
      .funct(Funct)
   );

   // ID/EX 级寄存器
   wire [32+32+32+32+5+1+1+1+1+5-1 : 0] Pipline_IDEXRegister_in;
   //                                32   + 32        + 32        + 32       + 5       + 1      + 1       + 1      + 1      , 5
   assign Pipline_IDEXRegister_in = {ID_PC, ID_Alu_AIn, ID_Alu_BIn, ID_RD2_DE, ID_RF_rd, ID_MemR, ID_Mem2R, ID_MemW, ID_RegW, ID_ALUOp};
   wire [32+32+32+32+5+1+1+1+1+5-1 : 0] Pipline_IDEXRegister_out;

   wire Pipline_IDEXRegister_reset;
   wire Pipline_IDEXRegister_reset_;
   assign Pipline_IDEXRegister_reset_ = rst | Pipline_IDEXRegister_reset;
   wire Pipline_IDEXRegister_write;
   PiplineUniversalRegister #(.WIDTH(32+32+32+32+5+1+1+1+1+5)) Pipline_IDEXRegister(
      .clk(clk), .rst(Pipline_IDEXRegister_reset_), .Wr(Pipline_IDEXRegister_write),
      .in(Pipline_IDEXRegister_in), .out(Pipline_IDEXRegister_out)
   );

   wire [31:0] EX_PC;
   wire [31:0] EX_Alu_AIn;
   wire [31:0] EX_Alu_BIn;
   wire [31:0] EX_RD2;
   wire [4:0] EX_RF_rd;
   wire EX_MemR;
   wire EX_Mem2R;
   wire EX_MemW;
   wire EX_RegW;
   wire [4:0] EX_ALUOp;

   assign EX_PC      = Pipline_IDEXRegister_out[32+32+32+32+5+1+1+1+1+5-1 : 32+32+32+5+1+1+1+1+5];
   assign EX_Alu_AIn = Pipline_IDEXRegister_out[   32+32+32+5+1+1+1+1+5-1 :    32+32+5+1+1+1+1+5];
   assign EX_Alu_BIn = Pipline_IDEXRegister_out[      32+32+5+1+1+1+1+5-1 :       32+5+1+1+1+1+5];
   assign EX_RD2     = Pipline_IDEXRegister_out[         32+5+1+1+1+1+5-1 :          5+1+1+1+1+5];
   assign EX_RF_rd   = Pipline_IDEXRegister_out[            5+1+1+1+1+5-1 :            1+1+1+1+5];
   assign EX_MemR    = Pipline_IDEXRegister_out[              1+1+1+1+5-1 :              1+1+1+5];
   assign EX_Mem2R   = Pipline_IDEXRegister_out[                1+1+1+5-1 :                1+1+5];
   assign EX_MemW    = Pipline_IDEXRegister_out[                  1+1+5-1 :                  1+5];
   assign EX_RegW    = Pipline_IDEXRegister_out[                    1+5-1 :                    5];
   assign EX_ALUOp   = Pipline_IDEXRegister_out[                      5-1 :                    0];

   // 算术运算模块
   alu U_ALU (
      .A(EX_Alu_AIn), .B(EX_Alu_BIn), .ALUOp(EX_ALUOp), .C(EX_Alu_Result), .Zero(EX_zero)
   );

   // EX/MEM 级寄存器
   wire [32+32+32+5+1+1+1+1-1 : 0] Pipline_EXMEMRegister_in;
   //                                 32   + 32           + 32    + 5       + 1      + 1       + 1      , 1
   assign Pipline_EXMEMRegister_in = {EX_PC, EX_Alu_Result, EX_RD2, EX_RF_rd, EX_MemR, EX_Mem2R, EX_MemW, EX_RegW};
   wire [32+32+32+5+1+1+1+1-1 : 0] Pipline_EXMEMRegister_out;

   wire Pipline_EXMEMRegister_reset;
   wire Pipline_EXMEMRegister_reset_;
   assign Pipline_EXMEMRegister_reset_ = rst | Pipline_EXMEMRegister_reset;
   wire Pipline_EXMEMXRegister_write;
   PiplineUniversalRegister #(.WIDTH(32+32+32+5+1+1+1+1)) Pipline_EXMEMRegister(
      .clk(clk), .rst(Pipline_EXMEMRegister_reset_), .Wr(Pipline_EXMEMRegister_write),
      .in(Pipline_EXMEMRegister_in), .out(Pipline_EXMEMRegister_out)
   );

   wire [31:0] MEM_PC;
   wire [31:0] MEM_Alu_Result;
   wire [31:0] MEM_RD2;
   wire [4:0] MEM_RF_rd;
   wire MEM_MemR;
   wire MEM_Mem2R;
   wire MEM_MemW;
   wire MEM_RegW;

   assign MEM_PC           = Pipline_EXMEMRegister_out[32+32+32+5+1+1+1+1-1 : 32+32+5+1+1+1+1];
   assign MEM_Alu_Result   = Pipline_EXMEMRegister_out[   32+32+5+1+1+1+1-1 :    32+5+1+1+1+1];
   assign MEM_RD2          = Pipline_EXMEMRegister_out[      32+5+1+1+1+1-1 :       5+1+1+1+1];
   assign MEM_RF_rd        = Pipline_EXMEMRegister_out[         5+1+1+1+1-1 :         1+1+1+1];
   assign MEM_MemR         = Pipline_EXMEMRegister_out[           1+1+1+1-1 :           1+1+1];
   assign MEM_Mem2R        = Pipline_EXMEMRegister_out[             1+1+1-1 :             1+1];
   assign MEM_MemW         = Pipline_EXMEMRegister_out[               1+1-1 :               1];
   assign MEM_RegW         = Pipline_EXMEMRegister_out[                   0                  ];

   // 数据内存相关
   wire [31:0] MEM_DM_Out;
   wire [11:2] MEM_DM_Addr;
   wire [31:0] MEM_WBData;
   
   assign MEM_DM_Addr = MEM_Alu_Result[11:2];
   assign MEM_WBData =  (MEM_Mem2R == 1) ? MEM_DM_Out : MEM_Alu_Result ;

   // 数据内存模块
   dm_4k U_DM (
      .addr(MEM_DM_Addr), .din(MEM_RD2), .DMWr(MEM_MemW), .clk(clk), .dout(MEM_DM_Out)
   );

   // MEM/WB 级寄存器
   //                                 32    + 32         + 5        + 1
   assign Pipline_MEMWBRegister_in = {MEM_PC, MEM_WBData, MEM_RF_rd, MEM_RegW};

   // 转发相关 [判断]
   assign ID_RD1_DE =
         (rs == 05'b00000) ? 32'd0 : (
            (EX_RF_rd == rs) ? EX_Alu_Result : (
               (MEM_RF_rd == rs) ? MEM_WBData : ID_RD1_RF
            )
         );
   assign ID_RD2_DE =
         (rt == 5'b00000) ? 32'd0 : (
            (EX_RF_rd == rt) ? EX_Alu_Result : (
               (MEM_RF_rd == rt) ? MEM_WBData : ID_RD2_RF
            )
         );

   // 阻塞相关[判断]
   //    如果 是分支指令 并且 前一条是运算指令 并且 当前的分支指令需要前一条指令的运算结果 [1]
   //        Branch[1] ^ Branch[0]      ALUOp <> 0     (EX_RF_rd == rs) || (EX_RF_rd == rt)
   //    取消当前操作 原地TP
   //
   //    如果 前一条是LW 并且 当前的分支指令需要前一条指令的运算结果 [2]
   //       OP = b100011    (EX_RF_rd == rs) || (EX_RF_rd == rt)
   //    取消当前操作 复读上一条指令 原地TP
   assign Bobbles =
      (Branch[1] ^ Branch[0]) && (
         ( (EX_ALUOp != 0) && (EX_RF_rd != 0) && ((EX_RF_rd == rs) || (EX_RF_rd == rt)) ) // [1]
      )
      || 
      ( EX_Mem2R && (EX_RF_rd != 0) && ((EX_RF_rd == rs) || (EX_RF_rd == rt)) ) // [2]
      ||
      ( MEM_Mem2R && (MEM_RF_rd != 0) && ((MEM_RF_rd == rs) || (MEM_RF_rd == rt)) ); // [2]

endmodule