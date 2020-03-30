module PC(Clk, PcReSet, NEWPC, OLDPC, PcSel, Address, Branch, JumpTarget, JrTarget, Bobbles);

    input   PcReSet;
    input   PcSel;                 // bne beq 分支选择
    input   Clk;
    input   [2:0] Branch;         // Branch[1] beq 标识, Branch[0] bne 标识, Branch[2..0] = 111 强制标识 , Branch[2] jr 标识
    input   [25:0] JumpTarget;
    input   [31:0] Address;     // bne beq 跳转目标
    input   [31:0] JrTarget;
    input   [31:0] OLDPC;
    input   Bobbles;
    output  [31:0] NEWPC;

    reg [31:0] NEWPC;

    integer i;
    reg [31:0] temp;

    always@(posedge Clk or posedge PcReSet)
    begin
        if (PcReSet == 1) begin
            NEWPC <= 32'h0000_3000;
            temp <= 32'h0000_3000;
        end
        
        if (Bobbles == 1'b0) begin
            if (Branch == 3'b111) begin
                NEWPC = JrTarget;
            end
            else if (Branch == 3'b011) begin
                for(i = 2; i < 28; i = i + 1)
                    temp[i] = JumpTarget[i - 2];
                temp[31] = OLDPC[31];
                temp[30] = OLDPC[30];
                temp[29] = OLDPC[29];
                temp[28] = OLDPC[28];
                temp[1] = 0;
                temp[0] = 0;
                NEWPC = temp;
            end
            else 
            begin
                if(PcSel == 1) begin
                    for(i = 0; i < 30; i = i + 1)
                        temp[31 - i] = Address[29 - i];
                    temp[0] = 0;
                    temp[1] = 0;
                
                    NEWPC = NEWPC + temp;
                end else NEWPC = NEWPC+4;
            end
        end

    end

endmodule