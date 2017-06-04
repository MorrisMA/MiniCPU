///////////////////////////////////////////////////////////////////////////////
//
//  Minimal CPU for anycpu.com 8-bit Challenge
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
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     05/20/2017 
// Design Name:     Minimal CPU for anycpu.org 8-bit Challenge
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_PCU.v
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU 
// Target Devices:  Complex Programmable Logic Devices
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
//  This file provides the MiniCPU program control unit, or address generator. 
//
// Dependencies:    none 
//
// Revision: 
//
//  0.01    17E20   MAM     Initial release.
//
//  1.00    17F03   MAM     Modified AR next address term so that CC is a mux
//                          select rather and an AND term with KI. Before this
//                          change, the result of CC & KI was always zero. Also,
//                          added BRV2 to port list, and now use BRV2 to force
//                          the MAR to capture the interrupt vector address
//                          when Int is asserted at the completion of interrup-
//                          table instructions.
//
// Additional Comments:
//
//  The MiniCPU_PCU is based on the M65C02A Address Generator module. It has
//  been cut down extensively to provide the next address generation function
//  of the MiniCPU. It implements the instruction pointer (IP), the workspace
//  pointer (XP), the non-local pointer (YP), and the non-local pointer shadow
//  register (YS).
//
//  It includes a memory address register (MA) so that sequential 16-bit reads
//  and writes can be readily implemented. Sixteen bit read/write operations
//  are required for subroutine call and return operations, for reset and in-
//  terrupt vector operations, and for loading/storing the non-local pointer
//  from the workspace.
//
//  The instruction pointer is a simple register. Incrementing the instruction
//  pointer is performed using the next address adder, and capturing the next
//  address in the instruction pointer as required.
//
//  The workspace pointer behaves somewhat like a stack pointer. The MiniCPU
//  does not provide push/pop instructions. Only the return address is pushed
//  by the jump to subroutine (JSR) and popped by the return from subroutine 
//  (RTS) instructions. For these instructions, the push/pop address is com-
//  puted by the next address generator's adder.
//
//  Unlike most processors, the the return address pushed on the stack is the
//  address of the current instruction. When the RTS instruction loads the
//  return address, the first instruction is fetched after incrementing the in-
//  struction pointer by 1. This mechanism, which is like that used by the
//  6502/65C02 processors, saves a cycle during the execution of the JSR in-
//  struction. The RTS instruction includes a constant which is added to the
//  workspace pointer before the return address is popped from the workspace.
//  This allows the stack frame of the subroutine to be easily removed from the
//  workspace. The return address is popped from the workspace, which leaves
//  the workspace pointer pointing at the frame of the calling procedure.
//
//  The workspace pointer is implemented as a loadable up counter. It is loaded
//  from the {A, B} register pair, i.e. the ALU registers, and from the output
//  of the address generator's adder. The first load operation actually ex-
//  changes the workspace pointer with the {A, B} register pair. The second
//  load operation allows the workspace pointer to be adjusted by the KI value
//  of the adjust workspace pointer instruction (ADJ) or the RTS instruction.
//  The up counter function enables the pop operation in parallel with the
//  address generator. Although the address generator also computes the pop
//  address, completing the adjustment of the workspace pointer using the ad-
//  dress generator adder after the high byte of the return address is read
//  from the workspace would introduce a single cycle delay. The up counter
//  functionality of the workspace pointer enables the MiniCPU to fetch the
//  instruction and simultaneously complete the adjustment of the workspace
//  so that the workspace pointer is pointing to the workspace of the calling
//  procedure when the instruction at the return address is executed.
//
//  The non-local pointer YP holds a pointer used for access to variables in
//  memory which are not relative to the workspace pointer XP. There are two
//  non-local pointers: YP and YS. The load non-local (LDN) and the store non-
//  local (STN) instructions perform load/store operations of the A register
//  relative to YP. The YP register may be loaded from or stored to the work-
//  space relative to XP using the load Y (LDY) or store Y (STY) instructions.
//  The active non-local pointer, YP, may be swapped with the shadow non-local
//  pointer, YS, by using the swap non-local pointer (SWP) instruction.
//
///////////////////////////////////////////////////////////////////////////////

module MiniCPU_PCU (
    input   Rst,                    // System Reset
    input   Clk,                    // System Clock
    
    input   [7:0] NAOp,             // Address Generator Operation Select
    
    input   CC,                     // Conditional Branch Input Flag
    input   BRV3,                   // Interrupt or Next Instruction Select
    input   BRV2,                   // Interrupt Vector Capture
    input   Int,                    // Unmasked Interrupt Request Input

    input   Rdy,                    // Ready Input
    
    input   [15:0] Vector,          // Interrupt/Trap Vector
    input   [15:0] KI,              // Operand Register

    output  [15:0] NA,              // Next Address Output

    input   IncX,                   // Workspace Pointer Increment (Pop)
    input   AdjX,                   // Workspace Pointer Adjust X = X + KI
    input   Ld_N,                   // Workspace Pointer Load NA (Adj/Psh)
    input   Ld_X,                   // Workspace Pointer Load DI (Exchange)
    input   [15:0] XDI,             // Workspace Pointer Input

    input   Ld_Y,                   // Non-Local Pointer Load YP from KI
    input   St_Y,                   // Non-Local Pointer Store YP
    input   SwpY,                   // Non-Local Pointer Swap YP and YS

    output  reg [15:0] MA,          // Memory Address Register
    output  reg [15:0] IP,          // Instruction Pointer Register
    output  [15:0] XP,              // Workspace Pointer Register
    output  [15:0] YP,              // Non-Local Pointer Register
    output  [15:0] YS               // Non-Local Pointer Shadow Register
);

////////////////////////////////////////////////////////////////////////////////
//
//  Module Declarations
//

wor     [15:0] AL, AR;              // Wired-OR busses for address operands

wire    CE_M;                       // Memory Address Register Clock Enable
wire    CE_I;                       // Instruction Pointer Clock Enable

///////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Next Address Generator
//
//          L IXYM KN C   
// Vec:  8'b1_0000_10_0;     // NA <= 0 +  K + 0; I <= NA
// Inc:  8'b1_1000_00_1;     // NA <= I +  0 + 1; I <= NA
// Rel:  8'b1_1000_10_1;     // NA <= I +  K + 1; I <= NA
// Rtn:  8'b1_0000_10_1;     // NA <= 0 +  K + 1; I <= NA
// Psh:  8'b0_0100_01_0;     // NA <= X + ~0 + 0;
// Pop:  8'b0_0100_00_1;     // NA <= X +  0 + 1;
// Lcl:  8'b0_0100_10_0;     // NA <= X +  K + 0;
// Non:  8'b0_0010_10_0;     // NA <= Y +  K + 0;                         
// Nxt:  8'b0_0001_00_1;     // NA <= M +  0 + 1;

assign Ld_I  = NAOp[7];
//
assign Sel_I = NAOp[6];
assign Sel_X = NAOp[5];
assign Sel_Y = NAOp[4];
assign Sel_M = NAOp[3];
//
assign Sel_K = NAOp[2];
assign Sel_N = NAOp[1];
//
assign Ci    = NAOp[0];

//  Generate Left Address Operand

assign AL = ((Sel_I) ? IP  : 16'b0);
assign AL = ((Sel_X) ? XP  : 16'b0);
assign AL = ((Sel_Y) ? YP  : 16'b0);
assign AL = ((Sel_M) ? MA  : 16'b0);

//  Generate Right Address Operand

assign AR = ((Sel_K) ? ((CC) ? KI : 16'b0) : 16'b0);
assign AR = ((Sel_N) ?  ~16'b0             : 16'b0);

//  Compute Next Address

assign NA = (AL + AR + Ci);

//  Memory Address Register

assign CE_M = Rdy;

always @(posedge Clk)
begin
    if(Rst | BRV2)
        MA <= #1 Vector;
    else if(CE_M)
        MA <= #1 NA;
end

//  Instruction Pointer

assign CE_I = Rdy & ((BRV3) ? (Ld_I & ~Int) : Ld_I);

always @(posedge Clk)
begin
    if(Rst)
        IP <= #1 ~0;
    if(CE_I)
        IP <= #1 NA;
end

//  Workspace Pointer

MiniCPU_XPtr    XPtr (
                    .Rst(Rst), 
                    .Clk(Clk),

                    .Rdy(Rdy), 

                    .IncX(IncX),
                    .AdjX(AdjX),
                    .Ld_N(Ld_N),
                    .Ld_X(Ld_X),
                    .NA(NA),
                    .DI(XDI),
                    
                    .XP(XP)
                );
                
//  Non-Local Pointer

MiniCPU_YPtr    YPtr (
                    .Rst(Rst),
                    .Clk(Clk),
                    
                    .Rdy(Rdy),
                    
                    .Ld_Y(Ld_Y),
                    .St_Y(St_Y),
                    .SwpY(SwpY),
                    .DI(KI),
                    
                    .YP(YP),
                    .YS(YS)
                );

endmodule
