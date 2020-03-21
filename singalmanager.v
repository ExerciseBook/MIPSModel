`include "instruction_def.v"
`include "ctrl_encode_def.v"

module SingalManager(jump, RegDst, Branch, MemR, Mem2R, MemW, RegW, Alusrc, ExtOp, Aluctrl, OpCode, funct);
	
	input [5:0]		OpCode;				//指令操作码字段
	input [5:0]		funct;				//指令功能字段

	output jump;						//指令跳转
	output RegDst;						
	output [1:0]Branch;						//分支
	output MemR;						//读存储器
	output Mem2R;						//数据存储器到寄存器堆
	output MemW;						//写数据存储器
	output RegW;						//寄存器堆写入数据
	output [1:0]Alusrc;						//运算器操作数选择
	output reg[1:0] ExtOp;				//位扩展/符号扩展选择
	output reg[4:0] Aluctrl;			//Alu运算选择
	
	reg [9:0] out;

	assign jump = out[9];
	assign RegDst = out[8];
	assign Branch = out[7:6];
	assign MemR = out[5];
	assign Mem2R = out[4];
	assign MemW = out[3];
	assign RegW = out[2];
	assign Alusrc = out[1:0];

	always@(OpCode or funct)
	begin

		case (OpCode)
			`INSTR_RTYPE_OP : begin
				case (funct)
					`INSTR_ADDU_FUNCT: begin // addu
						out <= 10'b0000000100;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_ADDU;
					end
					`INSTR_ADD_FUNCT: begin // add
						out <= 10'b0000000100;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_ADD;
					end
					`INSTR_SUBU_FUNCT: begin // subu
						out <= 10'b0000000100;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_SUBU;
					end
					`INSTR_SUB_FUNCT: begin // sub
						out <= 10'b0000000100;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_SUB;
					end
					`INSTR_SLT_FUNCT: begin // slt
						out <= 10'b0000000100;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_SLT;
					end
					`INSTR_SLL_FUNCT: begin // sll
						out <= 10'b0000000111;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_SLL;
					end
					`INSTR_SRL_FUNCT: begin // srl
						out <= 10'b0000000111;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_SRL;
					end
					`INSTR_SRA_FUNCT: begin // sra
						out <= 10'b0000000111;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_SRA;
					end
					`INSTR_AND_FUNCT: begin // and
						out <= 10'b0000000100;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_AND;
					end
					default: begin
						out <= 10'b000000000;
						ExtOp <= `EXT_ZERO;
						Aluctrl <= `ALUOp_NOP;
					end
				endcase
			end
			`INSTR_ORI_OP: begin // ori
				out <= 10'b0100000101;
				ExtOp <= `EXT_ZERO;
				Aluctrl <= `ALUOp_OR;
			end
			`INSTR_SW_OP: begin // sw
				out <= 10'b0100001001;
				ExtOp <= `EXT_SIGNED;
				Aluctrl <= `ALUOp_ADD;
			end
			`INSTR_LW_OP: begin // lw
				out <= 10'b0100110101;
				ExtOp <= `ALUOp_ADDU;
				Aluctrl <= `ALUOp_ADD;
			end
			`INSTR_BEQ_OP: begin // beq
				out <= 10'b0010000000;
				ExtOp <= `EXT_SIGNED;
				Aluctrl <= `ALUOp_SUB;
			end
			`INSTR_BNE_OP: begin // bne
				out <= 10'b0001000000;
				ExtOp <= `EXT_SIGNED;
				Aluctrl <= `ALUOp_SUB;
			end
			`INSTR_LUI_OP: begin // lui
				out <= 10'b0100000101;
				ExtOp <= `EXT_HIGHPOS;
				Aluctrl <= `ALUOp_OR;
			end
			`INSTR_SLTI_OP: begin // slti
				out <= 10'b0100000101;
				ExtOp <= `EXT_SIGNED;
				Aluctrl <= `ALUOp_SLT;
			end
			`INSTR_J_OP: begin // j
				out <= 10'b0011000000;
				ExtOp <= `EXT_ZERO;
				Aluctrl <= `ALUOp_NOP;
			end
			default: begin
				out <= 10'b0000000000;
				ExtOp <= `EXT_ZERO;
				Aluctrl <= `ALUOp_NOP;
			end
		endcase


	end

endmodule