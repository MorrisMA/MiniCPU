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
// Create Date:     05/21/2017 
// Design Name:     Minimal CPU for anycpu.org 8-bit Challenge
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_XPtr.v
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU
// Target Devices:  Complex Programmable Logic Devices
// Tool versions:   Xilinx ISE 10.1i SP3
// 
// Description:
//
//  This module implements the functions of the MiniCPU workspace pointer. The
//  workspace pointer acts like a standard stack pointer during subroutine 
//  calls and returns. In other words, the workspace pointer is adjusted by -2
//  when the return address is pushed onto the stack, and by +2 when the return
//  address is popped off the stack. The return from subroutine (RTS) instruc-
//  tion includes an offset that is added to the workspace pointer to recover
//  the local stack space of the subroutine before the return address is pulled
//  from the stack. 
//
//  The workspace pointer can be adjusted to allocate (negative adjustments), or
//  deallocate (positive adjustments) local workspace on the stack. The work-
//  space pointer, XP, is used as a base register into the workspace. The offset
//  is provided by the operand register.
//
// Dependencies:    none.
//
// Revision: 
//
//  0.00    17E21   MAM     Initial release.
//
//  1.00    17F05   MAM     Added the KI port and modified to support adding KI
//                          to XP by the AdjX control input.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module MiniCPU_XPtr (
    input   Rst,
    input   Clk,
    
    input   Rdy,
    
    input   IncX,
    input   AdjX,
    input   Ld_N,
    input   Ld_X,
    input   [15:0] NA,
    input   [15:0] KI,
    input   [15:0] DI,
    
    output  reg [15:0] XP
);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

always @(posedge Clk)
begin
    if(Rst)
        XP <= #1 0;
    else if(Rdy & Ld_N)
        XP <= #1 NA;
    else if(Rdy & Ld_X)
        XP <= #1 DI;
    else if(Rdy & (IncX | AdjX))
        XP <= #1 XP + ((IncX) ? 16'h0001 : KI);
end

endmodule
