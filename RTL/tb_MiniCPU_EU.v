`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:18:57 05/27/2017
// Design Name:   MiniCPU_EU
// Module Name:   C:/XProjects/ISE10.1i/MiniCPU/tb_MiniCPU_EU.v
// Project Name:  MiniCPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MiniCPU_EU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_MiniCPU_EU;

	// Inputs
	reg Rst;
	reg Clk;
	reg Rdy;
	reg Int;
	reg CC;
	reg [4:0] IR;

	// Outputs
	wire Done;
	wire BRV3;
	wire BRV2;
	wire BRV1;
	wire [7:0] NAOp;
	wire IF;
	wire Rd;
	wire Wr;
	wire LdKH;
	wire LdKL;
	wire ClrK;
	wire IPH;
	wire IPL;
	wire YPH;
	wire YPL;
	wire ALU;
	wire AdjX;
	wire IncX;
	wire Ld_N;
	wire Ld_X;
	wire SwpY;
	wire St_Y;
	wire Ld_Y;
	wire [4:0] AUOp;
	wire NC;
	wire GT;
	wire NE;
	wire Ack;

	// Instantiate the Unit Under Test (UUT)
    
	MiniCPU_EU uut (
		.Rst(Rst), 
		.Clk(Clk), 
		.Rdy(Rdy), 
		.Int(Int), 
		.CC(CC), 
		.IR(IR), 
		.Done(Done), 
		.BRV3(BRV3), 
		.BRV2(BRV2), 
		.BRV1(BRV1), 
		.NAOp(NAOp), 
		.IF(IF), 
		.Rd(Rd), 
		.Wr(Wr), 
		.LdKH(LdKH), 
		.LdKL(LdKL), 
		.ClrK(ClrK), 
		.IPH(IPH), 
		.IPL(IPL), 
		.YPH(YPH), 
		.YPL(YPL), 
		.ALU(ALU), 
		.AdjX(AdjX), 
		.IncX(IncX), 
		.Ld_N(Ld_N), 
		.Ld_X(Ld_X), 
		.SwpY(SwpY), 
		.St_Y(St_Y), 
		.Ld_Y(Ld_Y), 
		.AUOp(AUOp), 
		.NC(NC), 
		.GT(GT), 
		.NE(NE), 
		.Ack(Ack)
	);
    
initial begin
    // Initialize Inputs
    Rst = 1;
    Clk = 1;
    Rdy = 1;
    Int = 0;
    CC  = 1;
    IR  = 0;
    
    // Wait 100 ns for global reset to finish

    #101 Rst = 0;
    
    // Add stimulus here
    
    @(negedge BRV2) #1;
    
    @(posedge Clk) #1 IR = 5'h01;
    @(posedge Clk) #1 IR = 5'h03;
    @(posedge Clk) #1 IR = 5'h04;
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h05;
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h06;
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h07;
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h08;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h09;
    @(posedge Clk) #1;
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h0A;
    @(posedge Clk) #1 IR = 5'h0B;
    @(posedge Clk) #1 IR = 5'h0C;
    @(posedge Clk) #1 IR = 5'h0D;
    @(posedge Clk) #1 IR = 5'h0E;
    @(posedge Clk) #1; 
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h0F;
    @(posedge Clk) #1; 
    @(posedge Clk) #1;
    @(posedge Clk) #1 IR = 5'h10;
    @(posedge Clk) #1 IR = 5'h11;
    @(posedge Clk) #1 IR = 5'h12;
    @(posedge Clk) #1 IR = 5'h13;
    @(posedge Clk) #1 IR = 5'h14;
    @(posedge Clk) #1 IR = 5'h15;
    @(posedge Clk) #1 IR = 5'h16;
    @(posedge Clk) #1 IR = 5'h17;
    @(posedge Clk) #1 IR = 5'h18;
    @(posedge Clk) #1 IR = 5'h19;
    @(posedge Clk) #1 IR = 5'h1A;
    @(posedge Clk) #1 IR = 5'h1B;
    @(posedge Clk) #1 IR = 5'h1C;
    @(posedge Clk) #1 IR = 5'h1D;
    @(posedge Clk) #1 IR = 5'h1E;
    @(posedge Clk) #1 IR = 5'h1F;

//    @(posedge Clk) #1 IR = 5'h02;
    
    @(posedge Clk) #1 IR = 5'h00; 
    @(posedge Clk) #1 IR = 5'h00;
    @(posedge Clk) #1;

    $stop;
end

always #5 Clk = ~Clk;
      
endmodule

