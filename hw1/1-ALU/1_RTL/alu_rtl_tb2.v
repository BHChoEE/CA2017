//behavior tb
`timescale 1ns/10ps
`define CYCLE		70
`define HCYCLE	5

module alu_rtl_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;
    
    alu_rtl alu1(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );
    
   initial begin
       $dumpfile("alu.vcd");
       $dumpvars;
//        $fsdbDumpfile("alu.fsdb");
//        $fsdbDumpvars;
   end

    initial begin
        ctrl = 4'b1101;
        x    = 8'b01001001;
        y    = 8'b11010001;
        
        #(`CYCLE);
	// 0000 Add(signed)
        ctrl = 4'b0000;
        #(`HCYCLE);
        if( out == 8'b00011010 && carry == 1'b1) $display( "PASS --- 0000 Add" );
        else $display( "FAIL --- 0000 Add %b, %b, 00011010, 1",out,carry );

	// 0001 Sub(signed)
        ctrl = 4'b0001;
        #(`HCYCLE);
        if( out == 8'b01111000 && carry == 1'b1) $display( "PASS --- 0001 Sub" );
        else $display( "FAIL --- 0001 Sub %b, %b, 01111000, 1 ",out,carry );

	// 0010 And
	ctrl = 4'b0010;
	#(`HCYCLE);
	if(out == 8'b01000001) $display( "PASS --- 0010 boolean and");
	else $display( "FAIL --- 0010 boolean and %b , 01000001", out);

	// 0011 Or
	ctrl = 4'b0011;
	#(`HCYCLE);
	if( out == 8'b11011001 ) $display( "PASS --- 0011 boolen or");
	else $display( "FAIL --- 0011 boolen or %b , 11011001", out);

        // 0100 boolean not
        ctrl = 4'b0100;
        #(`HCYCLE);
        if( out == 8'b10110110 ) $display( "PASS --- 0100 boolean not" );
        else $display( "FAIL --- 0100 boolean not %b , 10110110", out );

	// 0101 Xor
        ctrl = 4'b0101;
        #(`HCYCLE);
        if( out == 8'b10011000 ) $display( "PASS --- 0101 boolean xor" );
        else $display( "FAIL --- 0101 boolean xor %b , 10011000",out );

	// 0110 Nor
        ctrl = 4'b0110;
        #(`HCYCLE);
        if( out == 8'b00100110 ) $display( "PASS --- 0110 boolean nor" );
        else $display( "FAIL --- 0110 boolean nor %b , 00100110",out );

	// 0111 Shift Left Logical variable
        ctrl = 4'b0111;
        #(`HCYCLE);
        if( out == 8'b10100010 ) $display( "PASS --- 0111 shift left logical" );
        else $display( "FAIL --- 0111 Shift Left Logical %b , 10100010",out );

	// 1000 Shift Right Logical variable
        ctrl = 4'b1000;
        #(`HCYCLE);
        if( out == 8'b01101000 ) $display( "PASS --- 1000 shift right logical" );
        else $display( "FAIL --- 1000 Shift Right Logical %b , 01101000",out );

	// 1001 Shift Right Arithmetic
        ctrl = 4'b1001;
        #(`HCYCLE);
        if( out == 8'b00100100 ) $display( "PASS --- 1001 shift right arithmetic" );
        else $display( "FAIL --- 0100 shift right arithmetic %b , 00100100",out );

	// 1010 Rotate left
        ctrl = 4'b1010;
        #(`HCYCLE);
        if( out == 8'b10010010 ) $display( "PASS --- 1010 rotate left" );
        else $display( "FAIL --- 1010 rotate left %b , 10010100 " ,out );

	// 1011 Rotate Right
        ctrl = 4'b1011;
        #(`HCYCLE);
        if( out == 8'b10100100 ) $display( "PASS --- 1011 rotate right" );
        else $display( "FAIL --- 1011 rotate right %b, 10100100 ",out );

	// 1100 Equal
	x = 8'b10010101;
	y = 8'b10010101;
        ctrl = 4'b1100;
        #(`HCYCLE);
        if( out == 8'b00000001 ) $display( "PASS --- 1100 equal" );
        else $display( "FAIL --- 1100 equal %b , 00000001",out );

	// 1101 NOP
        ctrl = 4'b1101;
        #(`HCYCLE);
        if( out == 8'b00000000 ) $display( "PASS --- 1101 NOP" );
        else $display( "FAIL --- 1101 NOP %b, 00000000",out );

       // finish tb
        #(`CYCLE) $finish;
    end
endmodule
