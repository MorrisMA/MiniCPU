////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2013 by Michael A. Morris, dba M. A. Morris & Associates
//
//  All rights reserved. The source code contained herein is publicly released
//  under the terms and conditions of the GNU Lesser Public License. No part of
//  this source code may be reproduced or transmitted in any form or by any
//  means, electronic or mechanical, including photocopying, recording, or any
//  information storage and retrieval system in violation of the license under
//  which the source code is released.
//
//  The source code contained herein is free; it may be redistributed and/or 
//  modified in accordance with the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either version 2.1 of
//  the GNU Lesser General Public License, or any later version.
//
//  The source code contained herein is freely released WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
//  PARTICULAR PURPOSE. (Refer to the GNU Lesser General Public License for
//  more details.)
//
//  A copy of the GNU Lesser General Public License should have been received
//  along with the source code contained herein; if not, a copy can be obtained
//  by writing to:
//
//  Free Software Foundation, Inc.
//  51 Franklin Street, Fifth Floor
//  Boston, MA  02110-1301 USA
//
//  Further, no use of this source code is permitted in any form or means
//  without inclusion of this banner prominently in any derived works. 
//
//  Michael A. Morris
//  Huntsville, AL
//
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:         M. A. Morris & Associates 
// Engineer:        Michael A. Morris 
// 
// Create Date:     06:47:44 07/20/2013 
// Design Name:     Parameterizable Single Port Synchronous LIFO
// Module Name:     SPSLmnCE 
// Project Name:    M16C5x Verilog Components Library 
// Target Devices:  RAM-based FPGAs: XC3S200A-4VQ100I 
// Tool versions:   Xilinx ISE 10.1i SP3
// 
// Description: 
//
//  This module implements a parameterizable Last-In, First-Out (LIFO) function.
//  Parameters allow setting the depth, width, and memory contents. It's intend-
//  ed for use as return address stacks for microprogram sequencers, microcompu-
//  ters, ALUs, etc.
//
//  The module provides a clock enable, and separate push and pop operation con-
//  trol inputs. An error output provides an indication that a push operation
//  occurred while the storage element is full, or that a pop operation occurred
//  while the storage element is empty.
//
// Dependencies: 
//
// Revision: 
//
//  0.01    13G20   MAM     File Created
//
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////

module SPSLmnCE #(
    parameter pInit = "SPSLmnCE.mif",       // LIFO initial values
    parameter pDataWidth = 16,              // LIFO data bus width
    parameter pAddrWidth =  6               // LIFO address bus width
)(
    input   Rst,                        // Reset
    input   Clk,                        // Clock
    input   En,                         // Clock Enable
    input   Psh,                        // Push - LIFO[++A] <= DI, pre-increment
    input   Pop,                        // Pop - DO <= LIFO[A--], post-decrement
    input   [(pDataWidth - 1):0] DI,    // LIFO Input Data Port
    output  [(pDataWidth - 1):0] DO,    // LIFO Output Data Port
    output  Err                         // Error Flag
);

////////////////////////////////////////////////////////////////////////////////
//
//  Module Parameter List
//

localparam  pDepth = (2**pAddrWidth);

////////////////////////////////////////////////////////////////////////////////
//
//  Module Level Declarations
//

    reg     [(pDataWidth - 1):0] LIFO [(pDepth - 1):0];
    reg     [(pAddrWidth - 1):0] A;
    
    reg     FF, EF;
    
    wire    Wr;
    wire    [(pAddrWidth - 1):0] Addr;

////////////////////////////////////////////////////////////////////////////////
//
//  Implementation
//

//
//  Address Counter
//

always @(posedge Clk)
begin
    if(Rst)
        A <= #1 0;
    else if(En)
        A <= #1 ((Psh & ~FF) ? Addr : ((Pop & |A) ? (A - 1) : A));
end

//
//  Empty Flag Register
//

always @(posedge Clk)
begin
    if(Rst)
        EF <= #1 ~0;
    else if(En)
        EF <= #1 ((Pop & ~EF) ? (~|Addr) : ((Psh) ? 0 : EF));
end

//
//  Full Flag Register
//

always @(posedge Clk)
begin
    if(Rst)
        FF <= #1 0;
    else if(En)
        FF <= #1 ((Psh & ~FF) ? ( &Addr) : ((Pop) ? 0 : FF));
end

//
//  Error Flag Logic
//

assign Err = ((Psh) ? FF : ((Pop) ? EF : 0));

//
//  Single-Port Synchronous RAM
//

initial
  $readmemh(pInit, LIFO, 0, (pDepth - 1));

assign Wr   = (En & Psh & ~FF);
assign Addr = ((Psh & ~FF) ? (A + {{(pAddrWidth - 1){1'b0}},~EF}) : A); 

always @(posedge Clk)
begin
    if(Wr) 
        LIFO[Addr] <= #1 DI;    // Synchronous Write
end

assign DO = LIFO[Addr];         // Asynchronous Read

endmodule
