module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);
    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

// declaration of wire/reg
    wire [7:0] busX,busY,busW,x; 
    wire carry;
    reg [7:0] tmp;
    assign x = tmp;
// submodule instantiation
    register_file register(.Clk(Clk), .WEN(WEN), .RW(RW), .busW(busW), .RX(RX),
			   .RY(RY), .busX(busX), .busY(busY));
    alu alu(.ctrl(Ctrl), .x(x), .y(busY), .carry(carry), .out(busW));

// combinational part
   //Sel choose which to ALU
    always@(*) begin
	if(!Sel)
	    tmp <= DataIn;
	else
	    tmp <= busX;
    end
// sequential part

endmodule
