module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
    input        Clk, WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] busW;
    output [7:0] busX, busY;
    
    // write your design here
    reg [7:0] register[7:0];
    
    // write operation
    // $r0 = constant zero ,don't care write operation
    //write synchronusly on pos edge of Clk
    always@(posedge Clk) begin
	if(WEN == 1'b1) begin
	    if(RW != 3'b0)
		register[RW] = busW;
	    else
		register[RW] = 8'b0;
	end
    end
    //read operation
    //read asynchronously (trigger upon RX RY)
    reg [7:0]BusX,BusY;
    assign busX = BusX;
    assign busY = BusY;    
    always@(*) begin
	register[0] = 8'b0;
	BusX <= register[RX];
	BusY <= register[RY];
    end    
endmodule
