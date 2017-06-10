`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   05:17:00 06/10/2017
// Design Name:   MiniCPU_Core
// Module Name:   C:/XProjects/ISE10.1i/MiniCPU/tb_MiniCPU.v
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

module tb_MiniCPU;

// UUT Ports

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
wire    [ 7:0] MDI;

// Define Memory

reg     [7:0] ROM [255:0];  // Simulated Program Memory
reg     [7:0] ROM_DO;
reg     [7:0] RAM [511:0];  // Simulated Data Memory
reg     [7:0] RAM_DO;

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
    Rst    = 1;
    Clk    = 1;
    Int    = 0;
    Vector = 16'h0000;
    Rdy    = 1;

    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    // Add stimulus here

end

////////////////////////////////////////////////////////////////////////////////

always #5 Clk = ~Clk;

////////////////////////////////////////////////////////////////////////////////

assign MDI = ((Rd) ? RAM_DO : ROM_DO);

initial
    $readmemh("MiniCPU_ROMv2.txt", ROM, 0, 255);
    
always @(negedge Clk)
begin
    if(IF)
        ROM_DO <= #1 ROM[MAO];
end

always @(posedge Clk)
begin
    if(Wr)
        RAM[MAO[8:0]] <= #1 MDO;
end

always @(negedge Clk)
begin
    if(Rd)
        RAM_DO <= #1 RAM[MAO[8:0]];
end
      
endmodule

