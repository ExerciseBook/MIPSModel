`include "instruction_def.v"
`include "ctrl_encode_def.v"

module SingalManager(jump, RegDst, Branch, MemR, Mem2R, MemW, RegW, Alusrc, ExtOp, Aluctrl, OpCode, funct, JumpInterrupt);
    
    input [5:0]        OpCode;          // 指令操作码字段
    input [5:0]        funct;           // 指令功能字段

    output jump;                        // 指令跳转
    output [1:0]RegDst;                        
    output [2:0]Branch;                 // 分支
                                        //  Branch[1] beq 标识, Branch[0] bne 标识, Branch[2..0] = 111 强制标识 , Branch[2] jr 标识
    output MemR;                        // 读存储器
    output Mem2R;                       // 数据存储器到寄存器堆
    output MemW;                        // 写数据存储器
    output RegW;                        // 寄存器堆写入数据
    output [1:0]Alusrc;                 // 运算器操作数选择
    output reg[1:0] ExtOp;              // 位扩展/符号扩展选择
    output reg[4:0] Aluctrl;            // Alu运算选择

    input JumpInterrupt;                // 无懈可击

    reg [11:0] out;                     // 输出信号组

    assign jump = out[11];              // 分解输出信号
    assign RegDst = out[10:9];
    assign Branch = out[8:6];
    assign MemR = out[5];
    assign Mem2R = out[4];
    assign MemW = out[3];
    assign RegW = out[2];
    assign Alusrc = out[1:0];

    always@(OpCode or funct)
    begin
        if (JumpInterrupt) begin
            // 由于跳转，预装载的指令需要清除，因而这里需要阻塞
            out <= 12'b000000000000;
            ExtOp <= `EXT_ZERO;
            Aluctrl <= `ALUOp_NOP;
        end else begin
            case (OpCode)
                `INSTR_RTYPE_OP : begin
                    case (funct)
                        `INSTR_ADDU_FUNCT: begin // addu
                            out <= 12'b000000000100;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_ADDU;
                        end
                        `INSTR_ADD_FUNCT: begin // add
                            out <= 12'b000000000100;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_ADD;
                        end
                        `INSTR_SUBU_FUNCT: begin // subu
                            out <= 12'b000000000100;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_SUBU;
                        end
                        `INSTR_SUB_FUNCT: begin // sub
                            out <= 12'b000000000100;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_SUB;
                        end
                        `INSTR_SLT_FUNCT: begin // slt
                            out <= 12'b000000000100;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_SLT;
                        end
                        `INSTR_SLL_FUNCT: begin // sll
                            out <= 12'b000000000111;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_SLL;
                        end
                        `INSTR_SRL_FUNCT: begin // srl
                            out <= 12'b000000000111;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_SRL;
                        end
                        `INSTR_SRA_FUNCT: begin // sra
                            out <= 12'b000000000111;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_SRA;
                        end
                        `INSTR_AND_FUNCT: begin // and
                            out <= 12'b000000000100;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_AND;
                        end
                        `INSTR_OR_FUNCT: begin // or
                            out <= 12'b000000000100;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_OR;
                        end
                        `INSTR_JR_FUNCT: begin // jr
                            out <= 12'b000111000000;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_NOP;
                        end
                        default: begin
                            out <= 12'b000000000000;
                            ExtOp <= `EXT_ZERO;
                            Aluctrl <= `ALUOp_NOP;
                        end
                    endcase
                end
                `INSTR_ORI_OP: begin // ori
                    out <= 12'b010000000101;
                    ExtOp <= `EXT_ZERO;
                    Aluctrl <= `ALUOp_OR;
                end
                `INSTR_ADDI_OP: begin // addi
                    out <= 12'b010000000101;
                    ExtOp <= `EXT_SIGNED;
                    Aluctrl <= `ALUOp_ADD;
                end
                `INSTR_SW_OP: begin // sw
                    out <= 12'b010000001001;
                    ExtOp <= `EXT_SIGNED;
                    Aluctrl <= `ALUOp_ADD;
                end
                `INSTR_LW_OP: begin // lw
                    out <= 12'b010000110101;
                    ExtOp <= `ALUOp_ADDU;
                    Aluctrl <= `ALUOp_ADD;
                end
                `INSTR_BEQ_OP: begin // beq
                    out <= 12'b000010000000;
                    ExtOp <= `EXT_SIGNED;
                    Aluctrl <= `ALUOp_SUB;
                end
                `INSTR_BNE_OP: begin // bne
                    out <= 12'b000001000000;
                    ExtOp <= `EXT_SIGNED;
                    Aluctrl <= `ALUOp_SUB;
                end
                `INSTR_LUI_OP: begin // lui
                    out <= 12'b010000000101;
                    ExtOp <= `EXT_HIGHPOS;
                    Aluctrl <= `ALUOp_OR;
                end
                `INSTR_SLTI_OP: begin // slti
                    out <= 12'b010000000101;
                    ExtOp <= `EXT_SIGNED;
                    Aluctrl <= `ALUOp_SLT;
                end
                `INSTR_J_OP: begin // j
                    out <= 12'b000011000000;
                    ExtOp <= `EXT_ZERO;
                    Aluctrl <= `ALUOp_NOP;
                end
                `INSTR_JAL_OP: begin 
                    out <= 12'b001011000100;
                    ExtOp <= `EXT_ZERO;
                    Aluctrl <= `ALUOp_ADD;
                end
                default: begin
                    out <= 12'b000000000000;
                    ExtOp <= `EXT_ZERO;
                    Aluctrl <= `ALUOp_NOP;
                end
            endcase
        end

    end

endmodule