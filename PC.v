module PC(Clk, PcReSet, PC, PcSel, Address, Branch, JumpTarget, JrTarget);

	input   PcReSet;
	input   PcSel;
	input   Clk;
	input   [2:0] Branch;
	input	[25:0] JumpTarget;
	input   [31:0] Address;
	input   [31:0] JrTarget;
	
	output reg[31:0] PC;
	
	integer i;
	reg [31:0] temp;

	always@(posedge Clk or posedge PcReSet)
	begin
		if(PcReSet == 1) begin
			PC <= 32'h0000_3000;
			temp <= 32'h0000_3000;
		end
		
		if (Branch == 3'b111) begin
			PC = JrTarget;
		end
		else if (Branch == 3'b011) begin
			for(i = 2; i < 28; i = i + 1)
				temp[i] = JumpTarget[i - 2];
			temp[31] = PC[31];
			temp[30] = PC[30];
			temp[29] = PC[29];
			temp[28] = PC[28];
			temp[1] = 0;
			temp[0] = 0;
			PC = temp;
		end
		else 
		begin
			PC = PC+4;
			if(PcSel == 1) begin
				for(i = 0; i < 30; i = i + 1)
					temp[31 - i] = Address[29 - i];
				temp[0] = 0;
				temp[1] = 0;
			
				PC = PC + temp;
			end
		end


	end

endmodule