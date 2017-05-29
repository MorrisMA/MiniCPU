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
// Create Date:     09:03:40 07/20/2013
// Design Name:     SPSLmnCE
// Module Name:     C:/XProjects/ISE10.1i/M16C5x/Src/tb_SPSLmnCE.v
// Project Name:    M16C5x
// Target Device:   SRAM-based FPGAs: XC3S200A-4VQ100I 
// Tool versions:   Xilinx ISE 10.1i SP3 
// Description: 
//
// Verilog Test Fixture created by ISE for module: SPSLmnCE
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

module tb_SPSLmnCE;

parameter pDataWidth = 8;
parameter pAddrWidth = 4;

parameter pDepth = (2**pAddrWidth);

// UUT Port List Declarations

reg     Rst;
reg     Clk;
reg     En;
reg     Psh;
reg     Pop;
reg     [7:0] DI;
wire    [7:0] DO;
wire    Err;

//  Simulation Variables

integer i = 0;

// Instantiate the Unit Under Test (UUT)

SPSLmnCE    #(
                .pDataWidth(8),
                .pAddrWidth(4)
            ) uut (
                .Rst(Rst), 
                .Clk(Clk), 
                .En(En), 
                .Psh(Psh), 
                .Pop(Pop), 
                .DI(DI), 
                .DO(DO), 
                .Err(Err)
            );

initial begin
    // Initialize Inputs
    Rst = 1;
    Clk = 1;
    En  = 0;
    Psh = 0;
    Pop = 0;
    DI  = 0;

    // Wait 100 ns for global reset to finish
    
    #101 Rst = 0;
    
    // Add stimulus here
    
    for(i = 1; i < 17; i = i + 1) begin
        LIFO_Psh({i[3:0], i[3:0]});
    end
    
    LIFO_Pop;
    
    LIFO_Psh(8'h01);

    for(i = 1; i < 17; i = i + 1) begin
        LIFO_Pop();
    end

    LIFO_Psh(8'h01);
    LIFO_Psh(8'h02);
    LIFO_Psh(8'h04);
    LIFO_Psh(8'h08);
    LIFO_Psh(8'h10);
    LIFO_Psh(8'h20);
    LIFO_Psh(8'h40);
    LIFO_Psh(8'h80);
    LIFO_Psh(8'h7F);
    LIFO_Psh(8'hBF);
    LIFO_Psh(8'hDF);
    LIFO_Psh(8'hEF);
    LIFO_Psh(8'hF7);
    LIFO_Psh(8'hFB);
    LIFO_Psh(8'hFD);
    LIFO_Psh(8'hFE);

    LIFO_Psh(8'h00);
    LIFO_Psh(8'h00);

    for(i = 1; i < 17; i = i + 1) begin
        LIFO_Pop();
    end

    LIFO_Pop();
    LIFO_Pop();
    
    #100 $stop;

end

////////////////////////////////////////////////////////////////////////////////
//
//  Clocks and Enables
//
    
always #5 Clk = ~Clk;

always @(posedge Clk)
begin
    if(Rst)
        En <= #1 0;
    else
        En <= #1 ~En;
end

////////////////////////////////////////////////////////////////////////////////
//
//  Tasks and Functions
//
  
// LIFO Write Task

task LIFO_Psh;

    input   [(pDataWidth - 1):0] Data;

    begin
        @(posedge  En)    Psh = 1; DI = Data;
        @(posedge Clk) #1 Psh = 0;
    end
    
endtask

// LIFO Read Task

task LIFO_Pop;

    begin
        @(posedge  En)    Pop = 1;
        @(posedge Clk) #1 Pop = 0;
    end
    
endtask
      
endmodule

