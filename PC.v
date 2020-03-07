module PC(Clk, PcReSet, PC, PcSel, Address);

	input   PcReSet;
	input   PcSel;
	input   Clk;
	input   [31:0] Address;
	
	output reg[31:0] PC;
	
	integer i;
	reg [31:0] temp;

	always@(posedge Clk or posedge PcReSet)
	begin
		if(PcReSet == 1) PC <= 32'h0000_3000;
			
		PC = PC+4;
	   if(PcSel == 1)
         begin
            for(i=0;i<30;i=i+1) temp[31-i] = Address[29-i];
            temp[0] = 0;
            temp[1] = 0;
            
            PC = PC+temp;
         end
	end

endmodule