module PC(Clk, PcReSet, NEWPC, OLDPC, PcSel, Address, Branch, JumpTarget, JrTarget, Bobbles, Interrupt);

    input   PcReSet;
    input   PcSel;                  // bne beq 分支选择
    input   Clk;
    input   [2:0] Branch;           // Branch[1] beq 标识, Branch[0] bne 标识, Branch[2..0] = 011 j jal 标识 , Branch[2] jr 标识
    input   [25:0] JumpTarget;
    input   [31:0] Address;         // bne beq 跳转目标
    input   [31:0] JrTarget;
    input   [31:0] OLDPC;
    input   Bobbles;
    output  [31:0] NEWPC;
    output  Interrupt;              // 无 懈 可 击

    reg [31:0] NEWPC;
    reg Interrupt;

    integer i;
    reg [31:0] temp;

    always@(posedge Clk or posedge PcReSet)
    begin
        // 复位信号
        if (PcReSet == 1) begin
            NEWPC <= 32'h0000_3000;
            temp <= 32'h0000_3000;
            Interrupt <= 1'b0;
        end
        
        if (Bobbles == 1'b0) begin // 不阻塞的正常情况

            if (Branch == 3'b111) begin // jr 指令的跳转操作
                NEWPC = JrTarget;
                Interrupt <= 1'b1;
            end
            else if (Branch == 3'b011) begin // j 和 jal 指令的跳转操作
                for(i = 2; i < 28; i = i + 1)
                    temp[i] = JumpTarget[i - 2];
                temp[31] = OLDPC[31];
                temp[30] = OLDPC[30];
                temp[29] = OLDPC[29];
                temp[28] = OLDPC[28];
                temp[1] = 0;
                temp[0] = 0;
                NEWPC = temp;
                // NEWPC = {OLDPC[31:28], JumpTarget, 2'b00};
                Interrupt <= 1'b1;
            end
            else 
            begin
                if(PcSel == 1) begin // beq / bnq 跳转操作
                    for(i = 0; i < 30; i = i + 1)
                        temp[31 - i] = Address[29 - i];
                    temp[0] = 0;
                    temp[1] = 0;
                
                    NEWPC = NEWPC + temp;
                    Interrupt <= 1'b1;
                end else begin // 普通情况，读取下一条指令
                    NEWPC = NEWPC+4;
                    Interrupt <= 1'b0;
                end
            end
        end

    end

    initial begin
        NEWPC <= 32'h0000_3000;
        temp <= 32'h0000_3000;
        Interrupt <= 1'b0;
    end

endmodule