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
// Create Date:     05/21/2017 
// Design Name:     Minimal CPU for anycpu.org 8-bit Challenge
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_YPtr.v
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU
// Target Devices:  Complex Programmable Logic Devices
// Tool versions:   Xilinx ISE 10.1i SP3
// 
// Description:
//
//  This module implements the functions of the MiniCPU Non-Local Pointer. It
//  is implemented as a 2 level push down stack. It supports push, pop, and 
//  swap functions.
//
//  The non-local pointer is a base register into memory. The offset from the
//  non-local pointer, YP, is provided by the operand register, KI. The non-
//  local pointer is loaded from or stored to the workspace using the workspace
//  pointer XP as the base register and the operand register KI as the offset.
//
// Dependencies:    none.
//
// Revision: 
//
//  0.00    17E21   MAM     Initial release.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module MiniCPU_YPtr (
    input   Rst,
    input   Clk,
    
    input   Rdy,
    
    input   Ld_Y,
    input   St_Y,
    input   SwpY,
    input   [15:0] DI,
    
    output  reg [15:0] YP,
    output  reg [15:0] YS
);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

always @(posedge Clk)
begin
    if(Rst)
        {YP, YS} <= #1 0;
    else if(Rdy & Ld_Y)
        {YP, YS} <= #1 {DI, YP};
    else if(Rdy & St_Y)
        {YP, YS} <= #1 {YS, YS};
    else if(Rdy & SwpY)
        {YP, YS} <= #1 {YS, YP};
end

endmodule
