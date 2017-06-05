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
// Create Date:     05/22/2017 
// Design Name:     Minimal CPU for anycpu.org 8-bit Challenge
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_Core.V
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU 
// Target Devices:  Complex Programmable Logic Devices
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description: 
//
// Dependencies: 
//
// Revision: 
//
//  1.00    17E22   MAM     File Created
//
//  1.10    17F03   MAM     Modified port list to bring out the Vector Pull
//                          signal added to the EU. EU generates VP when the
//                          vector is being read.
//
//  1.20    17F04   MAM     Modified to push the Ld_Y signal delay register into
//                          the PCU's YReg module. This move precipated by the
//                          need to add a delayed ALU Op(eration) register. The
//                          ALU Op delay register is required to post the ALU
//                          operation that must be excuted after the required
//                          operand from data memory is available in KI.
//
//  1.21    17F05   MAM     Updated value of pIntHndlr parameter. Moved VP port.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module MiniCPU_Core #(
    parameter pMiniCPU_uPgm = "MiniCPU_uPROM.mif",   // Microprogram File
    parameter pAddrWidth    = 6,    // Original F9408 => 10-bit Address
    parameter pRstAddrs     = 1,    // Original Reset Address => 0
    parameter pIntHndlr     = 5     // _Int Microroutine Address
)(
    input   Rst,
    input   Clk,

    output  Done,

    input   Int,
    output  Ack,
    output  VP,
    input   [15:0] Vector,

    input   Rdy,
    
    output  IF,
    output  Rd,
    output  Wr,
    output  [15:0] MAO,
    output  reg [7:0] MDO,
    input   [ 7:0] MDI
);

////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

reg     CC;
wire    BRV3, BRV2;

wire    [4:0] IR;

wire    [ 7:0] NAOp;

wire    LdKH, LdKL, ClrK;
wire    [15:0] KI;

wire    IPH, IPL, YPH, YPL, ALU;
wire    AdjX, IncX, Ld_N, Ld_X;
wire    SwpY, St_Y, Ld_Y;
wire    [15:0] IP, XP, YP;

wire    LdOp;
wire    [4:0] AUOp;
wire    [7:0] DO, A, B;

wire    NC, PL, NE;
wire    C, N, Z;

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//  Condition Code Multiplexer

always @(*)
begin
    casex({NC, PL, NE})
        3'b1xx  : CC <= ~C;
        3'b01x  : CC <= ~N;
        3'b001  : CC <= ~Z;
        default : CC <=  1;
    endcase
end

//  Memory Data Output Multiplexer

always @(*)
begin
    casex({IPH, IPL, YPH, YPL})
        4'b1xxx : MDO <= IP[15:8];
        4'b01xx : MDO <= IP[ 7:0];
        4'b001x : MDO <= YP[15:8];
        4'b0001 : MDO <= YP[ 7:0];
        default : MDO <= DO;
    endcase
end

//  Instruction Register

assign IR = ((MDI[7:4] == 4'b0010) ? {1'b1, MDI[3:0]} : {1'b0, MDI[7:4]});

//  Operand Register

MiniCPU_KReg    KR (
                    .Rst(Rst), 
                    .Clk(Clk),
                    
                    .Rdy(Rdy),
                    
                    .IF(IF),
                    .LdKH(LdKH), 
                    .LdKL(LdKL), 
                    .ClrK(ClrK), 
                    .DI(MDI), 

                    .KI(KI)
                );

MiniCPU_EU  #(
                .pMiniCPU_uPgm(pMiniCPU_uPgm),  // Microprogram File
                .pAddrWidth(pAddrWidth),    // Original F9408 => 10-bit Address
                .pRstAddrs(pRstAddrs),      // Original Reset Address => 0
                .pIntHndlr(pIntHndlr)       // _Int Microroutine Address
            ) EU (
                .Rst(Rst), 
                .Clk(Clk),
                
                .Rdy(Rdy), 

                .Int(Int),

                .CC(CC), 
                .IR(IR),
                
                .Done(Done),
                
                .BRV3(BRV3), 
                .BRV2(BRV2), 
                .BRV1(), 

                .NAOp(NAOp), 

                .IF(IF), 
                .Rd(Rd), 
                .Wr(Wr), 
                
                .LdOp(LdOp),
                
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
                .PL(PL), 
                .NE(NE), 
                
                .Ack(Ack),
                .VP(VP)
            );
                        
MiniCPU_PCU PC (
                .Rst(Rst), 
                .Clk(Clk),
                 
                .Rdy(Rdy), 

                .Int(Int), 
                .Vector(Vector), 

                .NAOp(NAOp), 

                .CC(CC), 
                .BRV3(BRV3),
                .BRV2(BRV2),

                .KI(KI), 

                .NA(MAO), 

                .IncX(IncX), 
                .AdjX(AdjX), 
                .Ld_N(Ld_N), 
                .Ld_X(Ld_X), 
                .XDI({A, B}),

                .Ld_Y(Ld_Y), 
                .St_Y(St_Y), 
                .SwpY(SwpY),

                .IP(IP),
                .MA(), 
                .XP(XP),
                .YP(YP),
                .YS()
            );

MiniCPU_ALU AU (
                .Rst(Rst), 
                .Clk(Clk),
                
                .Rdy(Rdy), 

                .IF(IF),
                .LdOp(LdOp),
                
                .Op(AUOp),
                
                .XP(XP), 
                .DI(KI[7:0]),
                .DO(DO), 
                .C(C), 
                .Z(Z), 
                .N(N),
                
                .A(A),
                .B(B)
            );

endmodule
