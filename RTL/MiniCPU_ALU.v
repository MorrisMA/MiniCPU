////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     05/12/2017 
// Design Name:     Minimal CPU for anycpu.org 8-bit Challenge
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_ALU.v 
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU
// Target Devices:  Complex Programmable Logic Devices
// Tool versions:   ISE 10.1i SP3
//
// Description:
//
//  This module implements the Arithmetic and Logic Unit (ALU) for the Minimal
//  CPU (MiniCPU). The ALU supports the following operations:
//
//      (1) Exchange of the two ALU working registers: RA, and RB;
//      (2) Exchange of the two ALU working registers with the workspace poin-
//          ter register XP;
//      (3) Loading ALU working register RA from the operand register KI;
//      (4) Clearing and Setting the Carry Flag;
//      (5) Adding with Carry and Subtracting with Borrow (Not Carry);
//      (6) Rotation left or right through the Carry flag;
//      (7) Arithmetic left or shifts through the Carry flag;
//      (8) Logical Complement, AND, OR, and XOR.
//
//  The MiniCPU is a zero address machine. Working register RA of the MiniCPU
//  ALU is the accumulator and functions as the left operand for any two op-
//  erand ALU operations. Working register RB must be set to hold the right
//  operand for two operand instructions:
//
//      (1) ADC/SBC;
//      (2) AND/ORL/XOR.
//
//  Working register RA is also the source and destination of any one operand
//  instructions:
//
//      (1) LDA;
//      (2) ROL/ASL;
//      (3) ROR/ASR;
//      (4) CPL.
//
//  The register pair {RA, RB} is the source and destination for the instruc-
//  tion to set/save the workspace pointer XP.
//
//  Like a classic accumulator-based machine, the MiniCPU's RA must be used to
//  load/save RB. The exchange RA and RB instruction, XAB, used to perform the
//  required loading and saving of RB from/to RA.
//
// Dependencies: 
//
// Revision: 
//
//  0.01    17E12   MAM     Initial Creation
//
//  1.00    17F04   MAM     Added a register to capture and delay the ALU Op
//                          value. The delay register holds the ALU operation
//                          value until the next instruction fetch when the ALU
//                          operation is performed using the operand data in KI.
//                          The delayed operand register is cleared after every
//                          instruction fetch. It is only loaded on a specific
//                          microprogram control signal: LdOp. The value is held
//                          in the register until the fetch of the next instruc-
//                          tion.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module MiniCPU_ALU(
    input   Rst,
    input   Clk,

    input   Rdy,
    
    input   IF,
    input   LdOp,
    
    input   [ 4:0] Op,
    
    input   [15:0] XP,
    input   [ 7:0] DI,
    output  [ 7:0] DO,
    output  reg C,
    output  Z,
    output  N,
    
    output  reg [7:0] A,
    output  reg [7:0] B
);

////////////////////////////////////////////////////////////////////////////////
//
//  Local Parameters
//

localparam pSBC = 4'b0111;
localparam pROL = 4'b1000;
localparam pROR = 4'b1010;

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     [4:0] dOp;
wire    [4:0] AUOp;

wire    CE;

wire    [7:0] S, T, U, V, W, X, Y;
wire    C7;

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Implement ALU Operation Code Multiplexer

always @(posedge Clk)
begin
    if(Rst | (Rdy & IF))
        dOp <= #1 0;
    else if(Rdy & LdOp)
        dOp <= #1 Op;
end

assign AUOp = ((IF) ? ((|dOp) ? dOp : Op) : 0);

//  ALU Control

assign CE = Rdy & AUOp[4];

assign T = ((AUOp[3:0] == pSBC) ? ~B : B);
assign {C7, S} = (A + T + C);

assign U = A & B;
assign V = A | B;
assign W = A ^ B;

assign X = ((AUOp[3:0] == pROL) ? {A[6:0],    C} : {A[6:0], 1'b0}); // ROL/ASL
assign Y = ((AUOp[3:0] == pROR) ? {C,    A[7:1]} : {A[7], A[7:1]}); // ROR/ASR

always @(posedge Clk)
begin
    if(Rst)
        C <= #1 0;
    else if(CE)
        case(AUOp[3:0])
            4'b0100 : C <= #1 0;            // CLC
            4'b0101 : C <= #1 1;            // SEC
            4'b0110 : C <= #1 C7;           // ADC
            4'b0111 : C <= #1 C7;           // SBC
            4'b1000 : C <= #1 A[7];         // ROL
            4'b1001 : C <= #1 A[7];         // ASL
            4'b1010 : C <= #1 A[0];         // ROR
            4'b1011 : C <= #1 A[0];         // ASR
            default : C <= #1 C;
        endcase
end

always @(posedge Clk)
begin
    if(Rst)
        A <= #1 0;
    else if(CE)
        case(AUOp[3:0])
            4'b0000 : A <= #1  A;           // SWP
            4'b0001 : A <= #1  B;           // XAB
            4'b0010 : A <= #1 XP[15:8];     // XCH
            4'b0011 : A <= #1 DI;           // LDA
            4'b0100 : A <= #1  A;           // CLC 
            4'b0101 : A <= #1  A;           // SEC 
            4'b0110 : A <= #1  S;           // ADC
            4'b0111 : A <= #1  S;           // SBC
            4'b1000 : A <= #1  X;           // ROL
            4'b1001 : A <= #1  X;           // ASL
            4'b1010 : A <= #1  Y;           // ROR
            4'b1011 : A <= #1  Y;           // ASR
            4'b1100 : A <= #1 ~A;           // CPL
            4'b1101 : A <= #1  U;           // AND
            4'b1110 : A <= #1  V;           // ORL
            4'b1111 : A <= #1  W;           // XOR
        endcase
end

always @(posedge Clk)
begin
    if(Rst)
        B <= #1 0;
    else if(CE)
        case(AUOp[3:0])
            4'b0001 : B <= #1 A;            // XAB
            4'b0010 : B <= #1 XP[7:0];      // XCH
            default : B <= #1 B;
        endcase
end

assign DO =   A;
assign N  =   A[7];
assign Z  = ~|A;

endmodule
