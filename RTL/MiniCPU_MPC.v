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
// Create Date:     5/17/2017 
// Design Name:     MiniCPU Microprogram Sequencer
// Module Name:     C:\XProjects\ISE10.1i\MiniCPU\MiniCPU_MPC.v
// Project Name:    C:\XProjects\ISE10.1i\MiniCPU
// Target Devices:  N/A 
// Tool versions:   Xilinx ISE 10.1i SP3
// 
// Description:
//
// This module implements a simple microprogram sequencer based on the Fair-
// child F9408. The sequencer provides:
//
//          (1) 3-bit instruction input
//          (2) loadable microprogram address register and incrementer;
//          (3) test input;
//          (4) 8-way multi-way branch control input;
//          (5) branch address input;
//          (6) 4-way branch address select output;
//          (7) next address output.
//
// These elements provide a relatively flexible general purpose microprogram
// controller without a complex instruction set. The instructions can
// be categorized into three classes: (1) fetch, (2) unconditional branches,
// and (3) conditional branches. The fetch instruction class, a single instruc-
// tion class, simply increments the program counter and outputs the current
// value of the program counter on the next address bus. The unconditional 
// branch instruction class provides instructions to select the next instruc-
// tion using the Via[1:0] outputs and place that value on the next address
// bus and simultaneously load the program counter. The unconditional branch
// instruction class also provides for 8-way multiway branching using an exter-
// nal (priority) encoder/branch selector.
//
//  I[2:0] MNEM Definition        T          MA[m:0]      Via 
//   000   BRV0 Branch Via 0      x          BA[m:0]       00
//   001   BRV1 Branch Via 1      x          BA[m:0]       01
//   010   BRV2 Branch Via 2      x          BA[m:0]       10
//   011   BRV3 Branch Via 3      x          BA[m:0]       11
//   100   BTH  Branch T High     1     {T0?BA[m:0]:PC+1}  00 
//   101   BTL  Branch T Low      0     {T0?PC+1:BA[m:0]}  00 
//   110   FTCH Next Instruction  x           PC+1         00 
//   111   BMW  Multi-way Branch  x     {BA[m:3],MW[2:0]}  00
//
// Dependencies: 
//
// Revision: 
//
//  0.00    17E17   MAM     File Created
//
//  0.10    17E26   MAM     Added Rdy input.
//
//  1.00    17E28   MAM     Changed decode for the instructions. BRV0 is now
//                          decoded as 0. This allows BRV0 0 to be used to
//                          trap uninitialized microprogram ROM/RAM or invalid
//                          opcodes. Also changed the default value of PC_In
//                          during MPC_Rst from 0 to the value of the parameter
//                          pRstAddrs. Goes along with placing BRV0 at 0.
//
// Additional Comments:
//
//  This MPC is a scaled down version of the synchronous 9408-based MPC used
//  by the M65C02A microprogrammed processor core. The objective for this
//  version is to implement the smallest subset, while retaining some addi-
//  tional functionality in reserve for future enhancements. Therefore, only
//  one conditional input was retained and two conditional branch instructions
//  to support it. The microsubroutine functionality was dropped because, like
//  the M65C02/M65C02A core, the microprogram does not use microsubroutines.
//
////////////////////////////////////////////////////////////////////////////////

module MiniCPU_MPC #(
    parameter pAddrWidth = 6,           // Original F9408 => 10-bit Address
    parameter pRstAddrs  = 0            // Reset Address
)(
    input   Rst,                        // Module Reset (Synchronous)
    input   Clk,                        // Module Clock
    input   Rdy,                        // Ready Input
    input   [2:0] I,                    // Instruction (see description)
    input   T,                          // Conditional Test Input
    input   [2:0] MW,                   // Multi-way Branch Address Select
    input   [(pAddrWidth-1):0] BA,      // Microprogram Branch Address Field
    output  [1:0] Via,                  // Unconditional Branch Address Select
    output  [(pAddrWidth-1):0] MA       // Microprogram Address
);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Local Parameters
//

localparam BRV0 =  0;   // Branch Via External Branch Address Source #0
localparam BRV1 =  1;   // Branch Via External Branch Address Source #1
localparam BRV2 =  2;   // Branch Via External Branch Address Source #2
localparam BRV3 =  3;   // Branch Via External Branch Address Source #3
localparam BTH  =  4;   // Branch if T is Logic 1, else fetch next instr.
localparam BTL  =  5;   // Branch if T is Logic 0, else fetch next instr.
localparam FTCH =  6;   // Fetch Next Instruction
localparam BMW  =  7;   // Multi-way Branch

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Declarations
//

wire    [(pAddrWidth - 1):0] Next;        // Output Program Counter Incrementer
reg     [(pAddrWidth - 1):0] PC_In;       // Input to Program Counter
reg     [(pAddrWidth - 1):0] PC;          // Program Counter

reg     dRst;                             // Reset stretcher
wire    MPC_Rst;                          // Internal MPC Reset signal

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

always @(posedge Clk)
begin
    if(Rst)
        dRst <= #1 1;
    else
        dRst <= #1 0;
end

assign MPC_Rst = (Rst | dRst);

//  Program Counter Incrementer

assign Next = (PC + 1);

//  Generate Unconditional Branch Address Select

assign Via = ((I[2]) ?  2'b00 : I[1:0]);

//  Generate Program Counter Input Signal

always @(*)
begin
    case({MPC_Rst, I})
        BRV0    : PC_In <=  BA;
        BRV1    : PC_In <=  BA;
        BRV2    : PC_In <=  BA;
        BRV3    : PC_In <=  BA;
        //
        BTH     : PC_In <=  (T ? BA   : Next);
        BTL     : PC_In <=  (T ? Next : BA  );
        FTCH    : PC_In <=  Next;
        BMW     : PC_In <=  {BA[(pAddrWidth - 1):3], MW};
        //
        default : PC_In <=  pRstAddrs;
    endcase
end

//  Generate Microprogram Address (Program Counter)

always @(posedge Clk)
begin
    if(MPC_Rst)
        PC <= #1 pRstAddrs;
    else if(Rdy)
        PC <= #1 PC_In;
end

//  Assign Memory Address Bus

assign MA = PC_In;

endmodule
