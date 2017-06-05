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

reg     Int;
wire    Ack;
wire    VP;
reg     [15:0] Vector;

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
                    
                    .Int(Int), 
                    .Ack(Ack),                    
                    .VP(VP),
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
    @(negedge Clk) #1 MDI = 8'h28;  // ROL      A<=$01, C<=0
    @(negedge Clk) #1 MDI = 8'hC1;  // BNC *+2  IP+2
    @(negedge Clk) #1 MDI = 8'h2A;  // ROR      A<=$00, C<=1
    @(negedge Clk) #1 MDI = 8'hC1;  // BNC *+2  IP+1
    // Test BPL, BNE; 17F04, MAM
    @(negedge Clk) #1 MDI = 8'hA1;  // BNE *+2  IP+1
    @(negedge Clk) #1 MDI = 8'hB1;  // BPL *+2  IP+2
    @(negedge Clk) #1 MDI = 8'h2A;  // ROR      A<=$80, C<=0
    @(negedge Clk) #1 MDI = 8'hA1;  // BNE *+2  IP+2
    @(negedge Clk) #1 MDI = 8'hB1;  // BPL *+2  IP+1
    // Test LDL
    @(negedge Clk) #1 MDI = 8'h40;  // LDL 0
    @(negedge Clk) #1 MDI = 8'hAA;  // MDI <= $AA
    @(negedge Clk) #1 MDI = 8'h21;  // XAB
    @(negedge Clk) #1 MDI = 8'h40;  // LDL 0
    @(negedge Clk) #1 MDI = 8'hAA;  // MDI <= $AA
    @(negedge Clk) #1 MDI = 8'h24;  // CLC
    @(negedge Clk) #1 MDI = 8'h2A;  // ROR
    @(negedge Clk) #1 MDI = 8'h26;  // ADC
    @(negedge Clk) #1 MDI = 8'h21;  // XAB
    @(negedge Clk) #1 MDI = 8'h41;  // LDL 1
    @(negedge Clk) #1 MDI = 8'hFF;  // MDI <= $FF
    @(negedge Clk) #1 MDI = 8'h25;  // SEC
    @(negedge Clk) #1 MDI = 8'h27;  // SBC  A <= $FF + ~$FF + 1; C, ~N, Z
    // Test Negative Branch -- Branch taken A == 0
    @(negedge Clk) #1 MDI = 8'h10;  // BPL  -2
    @(negedge Clk) #1 MDI = 8'hBE;  // 
    // Test Load Y and Swap YP<=>YS
    @(negedge Clk) #1 MDI = 8'h82;  // LDY  2
    @(negedge Clk) #1 MDI = 8'hAA;  // YPL <= $AA
    @(negedge Clk) #1 MDI = 8'h55;  // YPH <= $55
    @(negedge Clk) #1 MDI = 8'h84;  // LDY  4
    @(negedge Clk) #1 MDI = 8'h99;  // YPL <= $99
    @(negedge Clk) #1 MDI = 8'h66;  // YPH <= $66;   YS <= $55AA
    @(negedge Clk) #1 MDI = 8'h20;  // YP  <= $55AA; YS <= $6699
    // Test Store Y
    @(negedge Clk) #1 MDI = 8'h96;  // STY  6
    @(negedge Clk) #1 MDI = 8'h00;  // NOP
    @(negedge Clk) #1 MDI = 8'h00;  // NOP
    @(negedge Clk) #1 MDI = 8'h96;  // STY  6
    @(negedge Clk) #1 MDI = 8'h00;  // NOP
    @(negedge Clk) #1 MDI = 8'h00;  // NOP
    // Test Adj
    @(negedge Clk) #1 MDI = 8'h10;  // ADJ  #-8
    @(negedge Clk) #1 MDI = 8'hD8;  //
    @(negedge Clk) #1 MDI = 8'hD8;  // ADJ  #8
    // Test STL, LDN, STN, CPL; 17F05, MAM
    @(negedge Clk) #1 MDI = 8'h60;  // STL  0
    @(negedge Clk) #1 MDI = 8'h00;  //
    @(negedge Clk) #1 MDI = 8'h5E;  // LDN  14
    @(negedge Clk) #1 MDI = 8'h7E;  //
    @(negedge Clk) #1 MDI = 8'h2C;  // CPL
    @(negedge Clk) #1 MDI = 8'h7F;  // STN  0
    @(negedge Clk) #1 MDI = 8'h00;  //
    // Test AND, ORL, XOR
    @(negedge Clk) #1 MDI = 8'h42;  // LDL  2
    @(negedge Clk) #1 MDI = 8'hAA;
    @(negedge Clk) #1 MDI = 8'h21;  // XAB
    @(negedge Clk) #1 MDI = 8'h43;  // LDL  3
    @(negedge Clk) #1 MDI = 8'h55;
    @(negedge Clk) #1 MDI = 8'h2F;  // XOR
    @(negedge Clk) #1 MDI = 8'h6A;  // STL  10
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h4A;  // LDL  10
    @(negedge Clk) #1 MDI = 8'hFF;
    @(negedge Clk) #1 MDI = 8'h2F;  // XOR
    @(negedge Clk) #1 MDI = 8'h21;  // XAB
    @(negedge Clk) #1 MDI = 8'h42;  // LDL  2
    @(negedge Clk) #1 MDI = 8'hAA;
    @(negedge Clk) #1 MDI = 8'h2E;  // ORL
    @(negedge Clk) #1 MDI = 8'h6A;  // STL  10
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h2D;  // AND
    @(negedge Clk) #1 MDI = 8'h6A;  // STL  10
    @(negedge Clk) #1 MDI = 8'h00;
    // Test JSR, RTS
    @(negedge Clk) #1 MDI = 8'hF0;  // JSR  *+1
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h10;  // ADJ  #-8
    @(negedge Clk) #1 MDI = 8'hD8;
    @(negedge Clk) #1 MDI = 8'hE8;  // RTS  #8
    @(negedge Clk) #1 MDI = 8'h59;
    @(negedge Clk) #1 MDI = 8'h00;
    // Test Interrupt Behavior
    @(negedge Clk) #1 MDI = 8'h00; Int = 1'b1; Vector = 16'hFFF8;
    @(negedge Clk) #1 MDI = 8'h10;  // NFX
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    @(negedge Clk) #1 MDI = 8'hA0;  // BNE
    @(negedge Clk) #1 MDI = 8'hB0;  // BPL
    @(negedge Clk) #1 MDI = 8'hC0;  // BNC
    @(negedge Clk) #1 MDI = 8'hF0;  // JSR
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    @(negedge Clk) #1 MDI = 8'hE0;  // RTS
    @(negedge Clk) #1 MDI = 8'h63;
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    @(negedge Clk) #1 MDI = 8'h30;  // LDC
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h00;
    @(negedge Clk) #1 MDI = 8'h01;
    @(negedge Clk) #1 MDI = 8'hE0;  // RTS
    @(negedge Clk) #1 MDI = 8'h65;
    @(negedge Clk) #1 MDI = 8'h00;
    //
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    @(negedge Clk) #1 MDI = 8'h00;  Int = 1'b0; Vector = 16'hFFFE;
    @(negedge Clk) #1 MDI = 8'h00;  // PFX
    
end

////////////////////////////////////////////////////////////////////////////////

always #5 Clk = ~Clk;
      
////////////////////////////////////////////////////////////////////////////////

endmodule

