//RTL (use continuous assignment)
module alu_rtl(
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

    //construct 16 cases of operation as sig[15:0]    
    wire [7:0] sig0,sig1,sig2, sig3, sig4, sig5, sig6, sig7;
    wire [7:0] sig8,sig9,sig10,sig11,sig12,sig13,sig14,sig15;
    wire carry_sig [1:0];

    //signal = 0000 aka Add(signed)
    assign {carry_sig[0],sig0[7:0]} = x + y;
    //signal = 0001 aka Sub(signed)
    assign {carry_sig[1],sig1[7:0]} = x - y;
    //signal = 0010 aka And
    assign sig2[7:0] = x[7:0] & y[7:0];
    //signal = 0011 aka Or
    assign sig3[7:0] = x[7:0] | y[7:0];
    //signal = 0100 aka Not
    assign sig4[7:0] = ~x[7:0];
    //signal = 0101 aka Xor
    assign sig5[7:0] = x[7:0] ^ y[7:0];
    //signal = 0110 aka Nor
    assign sig6[7:0] = ~(x[7:0] | y[7:0]);
    //signal = 0111 aka Shift Left Logical variable
    assign sig7[7:0] = y << x[2:0] ;
    //signal = 1000 aka Shift right Logical variable
    assign sig8[7:0] = y >> x[2:0] ;
    //signal = 1001 aka Shift right arithmetic
    assign sig9[7:0] = {x[7],x[7:1]};
    //signal = 1010 aka Rotate left
    assign sig10[7:0] = {x[6:0],x[7]};
    //signal = 1011 aka Rotate right
    assign sig11[7:0] = {x[0] , x[7:1]};
    //signal = 1100 aka Equal
    assign sig12[7:0] = (x[7:0] == y[7:0]) ? 8'b00000001 : 8'b00000000;
    //signal = 1101 aka NOP
    assign sig13[7:0] = 8'b00000000;
    //signal = 1110 aka NOP
    assign sig14[7:0] = 8'b00000000;
    //signal = 1111 aka NOP
    assign sig15[7:0] = 8'b00000000;

    //use conditional mux to get the right case from control
    wire[7:0] tmp0,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6;
    wire[7:0] tmp7,tmp8,tmp9,tmp10,tmp11,tmp12,tmp13;

    //ctrl[0]
    assign tmp0[7:0] = ctrl[0] ?  sig1[7:0] :  sig0[7:0];
    assign tmp1[7:0] = ctrl[0] ?  sig3[7:0] :  sig2[7:0];
    assign tmp2[7:0] = ctrl[0] ?  sig5[7:0] :  sig4[7:0];
    assign tmp3[7:0] = ctrl[0] ?  sig7[7:0] :  sig6[7:0];
    assign tmp4[7:0] = ctrl[0] ?  sig9[7:0] :  sig8[7:0];
    assign tmp5[7:0] = ctrl[0] ? sig11[7:0] : sig10[7:0];
    assign tmp6[7:0] = ctrl[0] ? sig13[7:0] : sig12[7:0];
    assign tmp7[7:0] = ctrl[0] ? sig15[7:0] : sig14[7:0];
    //ctrl[1]
    assign  tmp8[7:0] = ctrl[1] ? tmp1[7:0] : tmp0[7:0];
    assign  tmp9[7:0] = ctrl[1] ? tmp3[7:0] : tmp2[7:0];
    assign tmp10[7:0] = ctrl[1] ? tmp5[7:0] : tmp4[7:0];
    assign tmp11[7:0] = ctrl[1] ? tmp7[7:0] : tmp6[7:0];
    //ctrl[2]
    assign tmp12[7:0] = ctrl[2] ?  tmp9[7:0] :  tmp8[7:0];
    assign tmp13[7:0] = ctrl[2] ? tmp11[7:0] : tmp10[7:0];
    //ctrl[3]
    assign out[7:0] = ctrl[3] ? tmp13[7:0] : tmp12[7:0];

    assign carry = ctrl[0] ? carry_sig[1] : carry_sig[0];
endmodule
