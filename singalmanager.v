module SingalManager(jump, RegDst, Branch, MemR, Mem2R, MemW, RegW, Alusrc, ExtOp, Aluctrl, OpCode, funct);
	
	input [5:0]		OpCode;				//指令操作码字段
	input [5:0]		funct;				//指令功能字段

	output jump;						//指令跳转
	output RegDst;						
	output Branch;						//分支
	output MemR;						//读存储器
	output Mem2R;						//数据存储器到寄存器堆
	output MemW;						//写数据存储器
	output RegW;						//寄存器堆写入数据
	output Alusrc;						//运算器操作数选择
	output [1:0]ExtOp;					//位扩展/符号扩展选择
	output reg[1:0] Aluctrl;			//Alu运算选择
	
	
	assign jump = 1;
	assign RegDst = OpCode[0];
	assign Branch = !(OpCode[0] || OpCode[1]) && OpCode[2];
	assign MemR = (OpCode[0] && OpCode[1] && OpCode[5]) && (!OpCode[3]);
	assign Mem2R = MemR;
	assign MemW = OpCode[1] && OpCode[0] && OpCode[3] && OpCode[5];
	assign RegW = (OpCode[2] && OpCode[3]) || (!OpCode[2] && !OpCode[3]);
	assign Alusrc = OpCode[0] || OpCode[1];
	assign ExtOp = {1'b0, OpCode[2] && OpCode[3]};

	always@(OpCode or funct)
	begin
		Aluctrl[1] = ExtOp[0];
		if((OpCode[1]| | OpCode[2]) == 0)
			Aluctrl[0] = funct[1];
		else
			Aluctrl[0] = !(OpCode[1] || OpCode[0]);
	end

endmodule