module im_4k( addr, dout );
    
    input [11:2] addr;
    input [31:0] dout;
    
    reg [31:0] imem[1023:0];
    
    assign dout = imem[addr];
    
endmodule    
