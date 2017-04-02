//Behavior level (event-driven) 
module alu(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;
    
    reg [7:0]Out;
    reg Carry;
    assign out = Out;
    assign carry = Carry;

    //monitoring until ctrl input
    always@(*) begin	
        //signal = 0000 aka Add(signed)
	if(ctrl == 4'b0000) 
	     {Carry,Out} <= x + y;
	//signal = 0001 aka Sub(signed)
	else if(ctrl[3:0] == 4'b0001) 
	    {Carry,Out} <= x - y;
	//signal = 0010 aka And
	else if(ctrl[3:0] == 4'b0010)
	    Out[7:0] <= x[7:0] & y[7:0];
	//signal = 0011 aka Or
	else if(ctrl[3:0] == 4'b0011)
	    Out[7:0] <= x[7:0] | y[7:0];
	//signal = 0100 aka Not
	else if(ctrl[3:0] == 4'b0100)
	    Out[7:0] <= ~x[7:0]; 
	//signal = 0101 aka Xor
	else if(ctrl[3:0] == 4'b0101)
	    Out[7:0] <= x[7:0] ^ y[7:0];
	//signal = 0110 aka Nor
	else if(ctrl[3:0] == 4'b0110)
	    Out[7:0] <= ~(x[7:0] | y[7:0]);
	//singal = 0111 aka Shift Left Logical variable
	else if(ctrl[3:0] == 4'b0111)
	    Out[7:0] <= y << x[2:0];
	//singal = 1000 aka Shift right Logical variable
	else if(ctrl[3:0] == 4'b1000)
	    Out[7:0] <= y >> x[2:0];
	//signal = 1001 aka Shift right arithmetic
	else if(ctrl[3:0] == 4'b1001)
	    Out[7:0] <= {x[7],x[7:1]};
	//signal = 1010 aka Rotate left
	else if(ctrl[3:0] == 4'b1010)
	    Out[7:0] <= {x[6:0],x[7]};
	//signal = 1011 aka Rotate right
	else if(ctrl[3:0] == 4'b1011)
	    Out[7:0] <= {x[0],x[7:1]};
	//singal = 1100 aka Equal
	else if(ctrl[3:0] == 4'b1100)
	    if(x[7:0] == y[7:0])
		Out[7:0] <= 8'b1;
	    else
		Out[7:0] <= 8'b0;
	//singal = 1101 || 1110 || 1111
	else
	    Out[7:0] <= 8'b0;
    end

endmodule
