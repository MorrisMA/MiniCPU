////////////////////////////////////////////////////////////////////////////////
//
//  CPU for anycpu.com 8-bit Challenge
// 
//  Copyright 2017 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU General Public License as convey-
//  ed in the license provided below.
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program.  If not, see <http://www.gnu.org/licenses/>, or write to
//
//  Free Software Foundation, Inc.
//  51 Franklin Street, Fifth Floor
//  Boston, MA  02110-1301 USA
//
//  Further, no use of this source code is permitted in any form or means
//  without inclusion of this banner prominently in any derived works.
//
//  Michael A. Morris <morrisma_at_mchsi_dot_com>
//  164 Raleigh Way
//  Huntsville, AL 35811
//  USA
//
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     05/26/2017 
// Design Name:     Minimal CPU for anycpu.org 8-bit Challenge
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_EU.v
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU 
// Target Devices:  Complex Programmable Logic Devices
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
//  This module implements the Execution Unit for the Minimal CPU. It incor-
//  porates the Microprogram Controller (MPC), the branch address logic, the
//  microprogram memory, and the microprogram pipeline registers.
//
//  The microprogram memory is implemented using a 64 x 40 LUT-based distributed
//  ROM. A pipeline register is employed at the output of the distributed ROM
//  to provide a synchronous implementation. The MPC utilized in the implementa-
//  tion is derived from the MPC used for the M65C02A, which is a synchronous
//  implementation usually coupled with a synchronous microprogram memory using
//  Block RAMs. (Note: For the anycpu.com 8-bit challenge, microprogram memories
//  in Block RAMs are not allowed.)
//
// Dependencies: 
//
// Revision: 
//
//  0.00    17E26   MAM     File Created
//
//  1.00    17E28   MAM     Implemented the microprogram as a distributed RAM.
//                          Registered ROM inference resulted in synthesizer
//                          mapping the microprogram into Block RAM which is
//                          not allowed by the rules of the challenge. Using
//                          coregen to build a ROM was an option, but not 
//                          appealing from either a portability or testability
//                          perspective. Simulating with the coregen model not
//                          not as convenient as modifying the memory initia-
//                          lization file (mif) using SMRTool. Also increased
//                          the pre-synthesis width of the microprogram from
//                          42 bits to 48 bits. Separated out the interrupt
//                          acknowledge signal from the CC select bits into its
//                          own dedicated field. Four unused bits automatically
//                          trimmed by the synthesizer.
//
//  1.10    17F03   MAM     Modified the uPL register to register output of the
//                          microprogram ROM on Rst or Rdy. This allows the NA
//                          to be presented to external memory while Rst is 
//                          being asserted to the core. Modified Done signal to
//                          asserted only for BRV1 or BRV3; previously asserted
//                          on (|Via). Added VP output to signal when vector is
//                          being read.
//
//  1.20    17F05   MAM     Modified the mnemonic for BGT to BPL. Changed the
//                          ALU Control Field from Exe to LdOp, which loads the
//                          ALU Operation Delay Register. The delayed operation
//                          is executed during the instruction fetch cycle of
//                          following instruction.
//
//  1.21    17F05   MAM     Modified the Vector Pull output to be function of 
//                          the interrupt acknowledge signal, Ack, and Rst.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module MiniCPU_EU #(
    parameter pMiniCPU_uPgm = "MiniCPU_uPROM.mif",   // Microprogram File
    parameter pAddrWidth    = 6,    // Original F9408 => 10-bit Address
    parameter pRstAddrs     = 1,    // Original Reset Address => 0
    parameter pIntHndlr     = 6'd5  // _Int Microroutine Address
)(
    input   Rst,                    // System Reset
    input   Clk,                    // System Clock

    input   Rdy,                    // External Ready signal
    
    input   Int,                    // Interrupt Request from External Handler
    input   CC,                     // Condition Code State
    input   [4:0] IR,               // Instruction Register (Direct/Indirect)               
    
    output  Done,                   // Instruction Fetch, Execution Complete

    output  BRV3,                   // Interruptable Instruction Fetch
    output  BRV2,                   // Begin Interrupt Service, Capture Vector
    output  BRV1,                   // Non-interruptable Instruction Fetch
    
    //  Microprogram Fields
    
    output  [7:0] NAOp,             // Next Address Control Field
    
    output  IF,                     // Program Memory Read (Instruction Fetch)
    output  Rd,                     // Data Memory Read
    output  Wr,                     // Data Memory Write
    
    output  LdOp,                   // Load ALU Op delay register
    
    output  LdKH,                   // Load KI[15:8] from DI
    output  LdKL,                   // Load KI[ 7:0] from DI
    output  ClrK,                   // Clear KI[15:4] on IF from DI[3:0]
    
    output  IPH,                    // DO <= IPH
    output  IPL,                    // DO <= IPL
    output  YPH,                    // DO <= YPH
    output  YPL,                    // DO <= YPL
    output  ALU,                    // DO <= ALU
    
    output  AdjX,                   // XP <= XP + KI
    output  IncX,                   // XP <= XP + 1
    output  Ld_N,                   // XP <= NA
    output  Ld_X,                   // XP <= {RA, RB}
    
    output  SwpY,                   // YP <= YS, YS <= YP (YP <=> YS)
    output  St_Y,                   // YP <= YS, YS <= YS
    output  Ld_Y,                   // YP <= KI, YS <= YP
    
    output  [4:0] AUOp,             // ALU Operation
    
    output  NC,                     // Condition Code Test: ~C
    output  PL,                     // Condition Code Test: ~N
    output  NE,                     // Condition Code Test: ~Z
    
    output  Ack,                    // Interrupt Acknowledge
    
    output  VP                      // Vector Pull
);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

wire    [2:0] I;                    // MPC Instruction
wire    [2:0] MW;                   // MPC Multiway Branch Input
reg     [5:0] BA;                   // MPC Branch Address Input
wire    [1:0] Via;                  // MPC Unconditional Branch Selector
wire    [5:0] MA;                   // MPC Microprogram Memory Address

reg     [47:0] ROM [63:0];
reg     [47:0] uPL;                 // Microprogram Pipeline Register
wire    [ 5:0] uBA;                 // Microprogram Branch Address Field

reg     dRst;                       // Delayed Rst; extends module reset 1 cycle

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

always @(posedge Clk) dRst <= #1 Rst;

assign Done = (Via[0]);             // Instruction Fetch, Execution Complete

assign BRV3 = (Via == 2'b11);       // Interruptable Instruction Fetch
assign BRV2 = (Via == 2'b10);       // Begin Interrupt Service, Capture Vector
assign BRV1 = (Via == 2'b01);       // Non-interruptable Instruction Fetch

//  Multiway Branch Field Definition

assign MW = {uBA[2:1], Int};

//  Implement the Branch Address Field Multiplexer for Instruction Decode

always @(*)
begin
    case(Via)
        2'b01   : BA <= {Via[0], IR};
        2'b11   : BA <= ((Int) ? pIntHndlr : {Via[0], IR});
        default : BA <= uBA;
    endcase
end

MiniCPU_MPC #(
                .pAddrWidth(pAddrWidth),
                .pRstAddrs(pRstAddrs)
            ) MPC (
                .Rst(Rst), 
                .Clk(Clk),
                
                .Rdy(Rdy),
                
                .I(I), 
                .T(CC),
                
                .MW(MW), 
                .BA(BA), 
                
                .Via(Via), 
                .MA(MA)
            );

initial
    $readmemb(pMiniCPU_uPgm, ROM, 0, 63);
    
assign WE_uPROM = (IR == 5'h02);
    
always @(posedge Clk)
begin
    if(WE_uPROM)
        ROM[MA] <= #1 0;
end

always @(posedge Clk)
begin
    if(Rst | Rdy)
        uPL <= #1 ROM[MA];
end

//  Assign uPL fields

assign I    = uPL[46:44];       // MPC Instruction Field                    (4)
assign uBA  = uPL[41:36];       // MPC Branch Address Field                 (8)
assign NAOp = uPL[35:28];       // Next Address Operation                   (8)
assign IF   = uPL[27];          // Program Memory Read (Instruction Fetch)  (1)
assign Rd   = uPL[26];          // Data Memory Read                         (1)
assign Wr   = uPL[25];          // Data Memory Write                        (1)
assign LdOp = uPL[24];          // Load ALU Op Delay Register               (1)          
assign LdKH = uPL[23];          // Load KI[15:8] from DI                    (1)
assign LdKL = uPL[22];          // Load KI[ 7:0] from DI                    (1)
assign ClrK = uPL[21];          // Clear KI[15:4] on load from DI[3:0]      (1)
assign IPH  = uPL[20];          // DO <= IP[15:8]                           (1)
assign IPL  = uPL[19];          // DO <= IP[ 7:0]                           (1)
assign YPH  = uPL[18];          // DO <= YP[15:8]                           (1)
assign YPL  = uPL[17];          // DO <= YP[ 7:0]                           (1)
assign ALU  = uPL[16];          // DO <= ALU                                (1)
assign AdjX = uPL[15];          // XP <= XP + KI                            (1)
assign IncX = uPL[14];          // XP <= XP + 1                             (1)
assign Ld_N = uPL[13];          // XP <= NA                                 (1)
assign Ld_X = uPL[12];          // XP <= {RA, RB}                           (1)
assign SwpY = uPL[11];          // YP <= YS, YS <= YP                       (1)
assign St_Y = uPL[10];          // YP <= YS, YS <= YS                       (1)
assign Ld_Y = uPL[ 9];          // YP <= KI                                 (1)
assign AUOp = uPL[ 8:4];        // ALU Operation Select                     (5)
assign NC   = uPL[ 3];          // CC Select: ~C                            (1)
assign PL   = uPL[ 2];          // CC Select: ~N                            (1)
assign NE   = uPL[ 1];          // CC Select: ~Z                            (1)
assign Ack  = uPL[ 0];          // Interrupt Acknowledge Cycle Start        (1)

assign VP = ~(Rst | dRst) & Ack;    // Vector Pull

endmodule
