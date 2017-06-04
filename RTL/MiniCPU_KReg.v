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
// Create Date:     05/28/2017 
// Design Name:     Minimal CPU for anycpu.org 8-bit Challenge
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_KReg.v 
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU 
// Target Devices:  Complex Programmable Logic Devices
// Tool versions:   Xilinx ISE10.1i SP3
//
// Description:
//
//  This module implements the KI, or Operand, register for the Minimal CPU. 
//  During instruction fetches, the KI register is shifted left four bits, and
//  the least significant four bits of the memory data input is merged into the
//  least significant four bits of the register. After the completion of each
//  direct or indirect instruction, the KI register is cleared. (The actual im-
//  plementation is such that the upper 12 bits of the register are not cleared
//  until the beginning of the next instruction. Automatic clearing of the upper
//  12 bits of KI is the rule except for the PFX and NFX instructions. These two
//  instructions build the operand in the KI register. Therefore. the KI regis-
//  ter is not cleared at beginnin of the next instruction by either PFX or NFX.
//  During data memory reads, the memory data input is captured, under micro-
//  program control, into either the low 8 bits, KL, or the high 8-bits, KH.
//
// Dependencies: 
//
// Revision:
// 
//  0.01    17E28   MAM     File Created
//
//  1.00    17F03   MAM     Removed BRV2 and Vector inputs. Pipeline operation
//                          prevented using KI to capture vector from external
//                          interrupt handler and simultaneously fetch and
//                          load KI from vector location in program memory.
//                          Capture of interrupt vector on assertion of BRV2
//                          transferred to the MAR register in the PCU.
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module MiniCPU_KReg(
    input   Rst,
    input   Clk,
    
    input   Rdy,
    
    input   IF,
    input   LdKH,
    input   LdKL,
    input   ClrK,
    input   [ 7:0] DI,
    
    output  reg [15:0] KI
);

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

assign NFX = (DI[7:4] == 4'b0001);

always @(posedge Clk)
begin
    if(Rst)
        KI <= #1 ~0;
    else if(Rdy & LdKH)
        KI <= #1 {DI, KI[ 7:0]};
    else if(Rdy & LdKL)
        KI <= #1 {KI[15:8], DI};
    else if(Rdy & IF) begin
        if(ClrK)
            KI <= #1 ((NFX) ? ~{ 12'h000, DI[3:0]} : DI[3:0]);
        else
            KI <= #1 ((NFX) ? ~{KI[11:0], DI[3:0]} : {KI[11:0], DI[3:0]});
    end
end

endmodule
