`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   08:10:08 05/31/2017
// Design Name:   MiniCPU_Core
// Module Name:   C:/XProjects/ISE10.1i/MiniCPU/tb_MiniCPU_Core.v
// Project Name:  MiniCPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MiniCPU_Core
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_MiniCPU_Core;

// Inputs

reg     Rst;
reg     Clk;

wire    Done;

wire    VP;
reg     Int;
reg     [15:0] Vector;
wire    Ack;

reg     Rdy;
wire    IF;
wire    Rd;
wire    Wr;
wire    [15:0] MAO;
wire    [ 7:0] MDO;
reg     [ 7:0] MDI;

// Instantiate the Unit Under Test (UUT)

MiniCPU_Core    uut (
                    .Rst(Rst), 
                    .Clk(Clk),
                    
                    .Done(Done),
                    
                    .VP(VP),
                    .Int(Int), 
                    .Ack(Ack),                    
                    .Vector(Vector),
                    
                    .Rdy(Rdy), 
                    .IF(IF), 
                    .Rd(Rd), 
                    .Wr(Wr), 
                    .MAO(MAO), 
                    .MDO(MDO), 
                    .MDI(MDI)
                );

initial begin
    // Initialize Inputs
    Rst     = 1;
    Clk     = 1;
    Int     = 0;
    Vector  = 16'hFFFE;
    Rdy     = 1;
    
    MDI = 0;    // PFX #0

    // Wait 100 ns for global reset to finish
    #101 Rst = 0;
    
    // Add stimulus here
    
    @(posedge Clk) #1;
    @(negedge Clk) #1;
    @(negedge Clk) #1;
    @(negedge Clk) #1;
    @(negedge Clk) #1;
    @(negedge Clk) #1;
    @(negedge Clk) #1;
    @(negedge Clk) #1 Rst = 1;
    @(negedge Clk) #1 Rst = 0;
    @(negedge Clk) #1;
    @(negedge Clk) #1;
    @(negedge Clk) #1 MDI = 8'h01;  // LDC #$12 => PFX #1; LDC #2
    @(negedge Clk) #1 MDI = 8'h32;
    @(negedge Clk) #1 MDI = 8'h03;  // LDC #$34 => PFX #3; LDC #4
    @(negedge Clk) #1 MDI = 8'h34;
    @(negedge Clk) #1 MDI = 8'h03;  // LDC #$32 => PFX #3; LDC #2
    @(negedge Clk) #1 MDI = 8'h32;
    @(negedge Clk) #1 MDI = 8'h01;  // LDC #$10 => PFX #3; LDC #0
    @(negedge Clk) #1 MDI = 8'h30;
    @(negedge Clk) #1 MDI = 8'h10;  // LDC #-1  => NFX #0; LDC #15
    @(negedge Clk) #1 MDI = 8'h3F;
    @(negedge Clk) #1 MDI = 8'h22;  // XCH
    @(negedge Clk) #1 MDI = 8'h31;  // LDC #1
    @(negedge Clk) #1 MDI = 8'h21;  // XAB
    @(negedge Clk) #1 MDI = 8'h24;  // CLC
    @(negedge Clk) #1 MDI = 8'h26;  // ADC
    @(negedge Clk) #1 MDI = 8'h26;  // ADC
    @(negedge Clk) #1 MDI = 8'h26;  // ADC
    @(negedge Clk) #1 MDI = 8'h26;  // ADC
    @(negedge Clk) #1 MDI = 8'h25;  // SEC
    @(negedge Clk) #1 MDI = 8'h27;  // SBC
    @(negedge Clk) #1 MDI = 8'h27;  // SBC
    @(negedge Clk) #1 MDI = 8'h27;  // SBC
    @(negedge Clk) #1 MDI = 8'h27;  // SBC
    @(negedge Clk) #1 MDI = 8'h21;  // XAB
    @(negedge Clk) #1 MDI = 8'h30;  // LDC #0
    @(negedge Clk) #1 MDI = 8'h25;  // SEC
    @(negedge Clk) #1 MDI = 8'h2A;  // ROR
    @(negedge Clk) #1 MDI = 8'h2B;  // ASR
    @(negedge Clk) #1 MDI = 8'h2B;  // ASR
    @(negedge Clk) #1 MDI = 8'h2B;  // ASR
    @(negedge Clk) #1 MDI = 8'h2B;  // ASR
    @(negedge Clk) #1 MDI = 8'h2B;  // ASR
    @(negedge Clk) #1 MDI = 8'h2B;  // ASR
    @(negedge Clk) #1 MDI = 8'h2B;  // ASR
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h29;  // ASL
    @(negedge Clk) #1 MDI = 8'h28;  // ROL
    @(negedge Clk) #1 MDI = 8'hC1;  // BNC
    @(negedge Clk) #1 MDI = 8'h2A;  // ROR
    @(negedge Clk) #1 MDI = 8'hC1;  // BNC

    @(negedge Clk) #1 MDI = 8'h00;  // NOP
end

////////////////////////////////////////////////////////////////////////////////

always #5 Clk = ~Clk;
      
////////////////////////////////////////////////////////////////////////////////

endmodule

