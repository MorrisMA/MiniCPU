Minimal CPU for anycpu.org 8-bit Challenge
==========================================

Copyright (C) 2017, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under GPL v3.

General Description
-------------------

This project provides a minimal CPU core that satisfies the requirements posed 
by the 8-bit CPU challenge as defined by Arlet Ottens on anycpu.org. The 
parameters of the challenge are as follows:

    Arlet wrote: As a result of a thread on 6502.org, I would like to propose a 
    challenge. The challenge is create a 6502-era CPU, using an FPGA, using 
    roughly similar amount of resources as were available to the 6502 designers. 
    The CPU needs to have similar capabilities as the 6502: 16 bit address bus, 8 
    bit data bus, 2 interrupts, reset, RDY. To make design easier, the data bus 
    may be split into separate in/out buses. Instead of an NMI, you can make 
    higher priority maskable IRQ. It should interface to either a block RAM, or an 
    external async SRAM. It doesn't need to be 6502 compatible, but you should be 
    able to port typical 6502 programs to it.
    
    Maximum area is 128 slices on a Spartan 6 (XC6SLX4), which is about what my 
    NMOS 6502 core requires. Use of block RAMs or DSP blocks is not permitted 
    inside the CPU, but these resources may be used outside the CPU to build a 
    complete working system. The goal is to make something as powerful as possible 
    that could theoretically have existed as a 40 pin DIP in the 70's, hopefully 
    better than the 6502 itself. One of the goals is to keep room for future 
    improvement, so filling up the opcode space is not encouraged.
    
The 8-bit processor core supplied in this project meets the objectives defined 
above. The processor core provided supplies the core functions required for a 
complete processor. The supplied core expects to be connected to a synchronous 
Block RAM memory array, and to memory mapped peripherals. One peripheral 
function required is that of a vectored interrupt handler that supports the 
types and number of interrupts and traps required by the application. (Note: 
the interrupt handler peripheral is expected to supply the reset vector as 
well as any interrupt vectors that the application may require. The interrupt 
handler is also required to provide the interrupt enable/disable functionality 
that the application may require.)

The processor core supplied in the project consists of a 8-bit ALU with 8-bit 
two registers with a modified stack-like organization. The processor does not 
include a processor status word, or flags register. The ALU does have a carry 
register to support multi-precision addition and subtraction. The ALU 
accumulator, the left operand of any dual operand operation, can be tested for 
zero and for negative values, although arithmetic 2's Complement overflow is 
not supported in the current implementation. (Note: if the carry flag needs to 
be preserved, either in an interrupt service routine, or through a function 
call, then its value must be captured using either the conditional branch on 
no carry instruction, or with the rotate instructions. Once captured in the 
ALU accumulator, the value can be preserved in the workspace.)

A 16-bit workspace pointer provides a stack-like capability for the processor 
core. The workspace pointer is automatically adjusted during subroutine calls 
and subroutine returns. The workspace pointer can be adjusted to allocate and 
deallocate locally accessible variables. The subroutine return instruction 
also deallocates the allocated workspace on the stack before the return 
address is popped from the stack. Thus, at the end of the subroutine return, 
if the proper workspace deallocation value is provided, the workspace pointer 
is left pointing to the base of the calling function's allocated workspace. The 
workspace pointer register is the base register for workspace relative 
addressing. Instructions for loading the accumulator (or the general pointer 
register described next), or storing the accumulator to the workspace include 
an offset (positive or negative) which is automatically added to the workspace 
register during the operand read/write cycle.

In addition to the 16-bit workspace pointer, the processor also provides a 
dual 16-bit register stack for general memory addressing. These two base-
relative pointers are supported by three instructions which allow the pointer 
stack to be loaded, unloaded from the workspace, and swapped. Like the 
workspace pointer, the offset for the base-relative address is supplied by the 
instruction.

A 16-bit instruction pointer provides the addressing of the processor core 
into program memory. All program memory accesses are performed relative to the 
instruction pointer. This applies to conditional branches and subroutine 
calls.

A 16-bit operand register is the final register in the core. The operand 
register provides the offsets into the local (relative to the workspace) and 
non-local address spaces (relative to the pointer stack). The operand register 
also provides the instruction opcodes for indirect instructions. Indirect 
instructions are instructions which extend the basic, direct instructions of 
the processor. Using the operand register in this manner allows the MiniCPU's 
instruction set to be extended in the future.

MiniCPU Instruction Set
-----------------------

The MiniCPU instruction set consists of 16 single byte direct instructions, 
and 16 single byte indirect instructions executed by the EXE direct 
instruction. In total, the MiniCPU instruction set is composed of 31 
instructions.

Each instruction read from memory consists of a 4-bit instruction and a 4-bit 
constant. The 4-bit constant is either the least significant four bits of an 
operand, or the least significant four bits of an indirect instruction opcode. 
For all direct instructions, except for the EXE direct instruction, the 
operand register provides an operand: a load constant, a local or non-local 
address space offset, a workspace allocation/deallocation, or a instruction 
pointer relative offset. 

Since only four bits are included in each instruction byte, two direct 
instructions, PFX and NFX, are used to load additional nibbles into the 
operand register. (Note: these prefix instructions can be manually added to 
the instruction stream, but it is more convenient for the assembler to 
automatically insert the required number of prefix instructions. Except for 
subroutine calls and the loading of constants less than 0 or greater than 15, 
there should be no need for prefix instructions. Negative branches will 
require the use of the NFX (Negative Prefix) instruction to correctly define 
the negative relative offset. **The operand register is cleared at the 
completion of all instructions except the PFX and NFX prefix instructions.**)

    0x  - PFX   : Prefix            Shifts the operand register, KI, left four 
                                    positions and logically OR in the least
                                    significant four bits of the instruction byte.
    1x  - NFX   : Negative Prefix   Performs operations like PFX except that it
                                    complements the value loaded into the operand
                                    register.
    2x  - EXE   : Execute           Execute the indirect instruction whose opcode
                                    is in the operand register. (See below.)
    3x  - LDK   : Load Constant     Load operand register into the ALU accumulator.
    4x  - LDL   : Load Local        Load accumulator from workspace pointer plus KI.
    5x  - LDN   : Load Non-local    Load accumulator from non-local pointer plus KI.
    6x  - STL   : Store Local       Store accumulator at workspace pointer plus KI.
    7x  - STN   : Store Non-Local   Store accumulator at non-local pointer plus KI.
    8x  - LDY   : Load Y            Load Non-Local Pointer from workspace + KI.
    9x  - STY   : Store Y           Store Non-Local Pointer at workspace + KI.
    Ax  - BNE   : Branch if ~Z      Branch relative to IP if accumulator <> 0.
    Bx  - BGT   : Branch if ~N      Branch relative to IP if accumulator positive.
    Cx  - BNC   : Branch if ~C      Branch relative to IP if Carry == 0.
    Dx  - ADJ   : Adjust Workspace  Workspace Pointer adjusted by operand register.
    Ex  - RTS   : Return Subroutine Adjust workspace pointer by value of operand
                                    and pull return address.
    Fx  - JSR   : Jump Subroutine   Push return address to the workspace and jump to
                                    subroutine relative to IP.
    20  - SWP   : Swap Pointer Stk  Swap Non-Local Pointer stack values.
    21  - XCH   : Swap X and {A, B} Swap workspace pointer with ALU registers.
    22  - XAB   : Swap A and B      Swap ALU registers
    23  - LDA   : Load accumulator  Load accumulator from KI (LDK, LDL, LDN)
    24  - CLC   : Clear Carry       C <= 0
    25  - SEC   : Set Carry         C <= 1
    26  - ADC   : Add with C        A <= A +  B + C
    27  - SBC   : Subtract with C   A <= A + ~B + C
    28  - ROL   : Rotate Left       {C, A} <= {A, C}
    29  - ASL   : Arith. Left Shift {C, A} <= {A, 0}
    2A  - ROR   : Rotate Right      {A, C} <= {C, A}
    2B  - ASR   : Arith. Right Shft {A, C} <= {A[7], A}
    2C  - CPL   : Complement Accum  A <= ~A
    2D  - AND   : AND ALU Registers A <= A & B
    2E  - ORL   : ORL ALU Registers A <= A | B
    2F  - XOR   : XOR ALU Registers A <= A ^ B

# Instruction timing

Assuming that no prefix instructions are required, the following table shows 
the instruction timing for the MiniCPU instruction set. (Note: each prefix 
instruction required to set up the operand register adds 1 cycle to the 
instruction timing.)

    0x  - PFX   : 1
    1x  - NFX   : 1
    2x  - EXE   : 1
    3x  - LDK   : 1
    4x  - LDL   : 2
    5x  - LDN   : 2
    6x  - STL   : 2
    7x  - STN   : 2
    8x  - LDY   : 3
    9x  - STY   : 3
    Ax  - BNE   : 1
    Bx  - BGT   : 1
    Cx  - BNC   : 1
    Dx  - ADJ   : 1
    Ex  - RTS   : 3
    Fx  - JSR   : 3
    20  - SWP   : 1
    21  - XCH   : 1
    22  - XAB   : 1
    23  - LDA   : 1
    24  - CLC   : 1
    25  - SEC   : 1
    26  - ADC   : 1
    27  - SBC   : 1
    28  - ROL   : 1
    29  - ASL   : 1
    2A  - ROR   : 1
    2B  - ASR   : 1
    2C  - CPL   : 1
    2D  - AND   : 1
    2E  - ORL   : 1
    2F  - XOR   : 1

Implementation
--------------

The implementation of the current core provided consists of the following 
Verilog source files and memory initialization files:

    MiniCPU_Core.v                  (MiniCPU Processor Core)
        MiniCPU_KReg.v              (MiniCPU Operand Register)
        M65C02A_EU.v                (MiniCPU Execution Unit)
            MiniCPU_MPC.v           (MiniCPU Micro-Program Controller)
            MiniCPU_uPROM.mif       (MiniCPU Microprogram ROM Memory Initialization File)
        MiniCPU_PCU.v               (MiniCPU Program Control Unit)
            MiniCPU_XReg.v          (MiniCPU Workspace Pointer Register)
            MiniCPU_YReg.v          (MiniCPU Non-Local Pointer Register)
        MiniCPU_ALU.v               (MiniCPU Arithmetic/Logic Unit)
        
    tb_MiniCPU_EU.v                 - MiniCPU Execution Unit testbench

    MiniCPU_uPROM.txt               - MiniCPU Microprogram ROM Source File)

The implementation is microprogrammed. I would typically use a Block RAM for 
the microprogram store, but that solution is prohibited by the rules of the 
challenge. So for this project, a single port distributed RAM microprogram 
store is used. An infered ROM was the first approach, but the ISE synthesizer 
kept optimizing it and placing it into a Block RAM. The inferred distributed 
RAM used in the implementation essentially forces the synthesizer to keep the 
microprogram store in a distributed RAM.

Using a ROM generated by the ISE Core Generator tool would have been possible, 
but the process of updating the contents of the microprogram during 
development and simulation proved to be less than satisfactory. Therefore, a 
distributed RAM implementation, with the write enable defined by an illegal 
opcode, was used to make updating the microprogram easy during its development 
with the ISim simulator and the Simple Microprogram ROM Tool (SMRTool) used 
for the M65C02, M65C02A, and RTFIFO projects.

MiniCPU Synthesis, Map, Place and Route Results
-----------------------------------------------

The following is the Place and Route results for the project when targeted to 
the FPGA defined in the challenge rules:

    Device Utilization Summary:
    
    Slice Logic Utilization:
      Number of Slice Registers:                   164 out of   4,800    3%
        Number used as Flip Flops:                 163
        Number used as Latches:                      0
        Number used as Latch-thrus:                  0
        Number used as AND/OR logics:                1
      Number of Slice LUTs:                        276 out of   2,400   11%
        Number used as logic:                      232 out of   2,400    9%
          Number using O6 output only:             184
          Number using O5 output only:              19
          Number using O5 and O6:                   29
          Number used as ROM:                        0
        Number used as Memory:                      42 out of   1,200    3%
          Number used as Dual Port RAM:              0
          Number used as Single Port RAM:           42
            Number using O6 output only:            42
            Number using O5 output only:             0
            Number using O5 and O6:                  0
          Number used as Shift Register:             0
        Number used exclusively as route-thrus:      2
          Number with same-slice register load:      1
          Number with same-slice carry load:         1
          Number with other load:                    0
    
    Slice Logic Distribution:
      Number of occupied Slices:                    75 out of     600   12%
      Number of MUXCYs used:                        40 out of   1,200    3%
      Number of LUT Flip Flop pairs used:          277
        Number with an unused Flip Flop:           114 out of     277   41%
        Number with an unused LUT:                   1 out of     277    1%
        Number of fully used LUT-FF pairs:         162 out of     277   58%
        Number of slice register sites lost
          to control set restrictions:               0 out of   4,800    0%
    
    Specific Feature Utilization:
      Number of RAMB16BWERs:                         0 out of      12    0%
      Number of RAMB8BWERs:                          0 out of      24    0%
      Number of BUFIO2/BUFIO2_2CLKs:                 0 out of      32    0%
      Number of BUFIO2FB/BUFIO2FB_2CLKs:             0 out of      32    0%
      Number of BUFG/BUFGMUXs:                       1 out of      16    6%
        Number used as BUFGs:                        1
        Number used as BUFGMUX:                      0
      Number of DCM/DCM_CLKGENs:                     0 out of       4    0%
      Number of ILOGIC2/ISERDES2s:                   0 out of     200    0%
      Number of IODELAY2/IODRP2/IODRP2_MCBs:         0 out of     200    0%
      Number of OLOGIC2/OSERDES2s:                   0 out of     200    0%
      Number of BSCANs:                              0 out of       4    0%
      Number of BUFHs:                               0 out of     128    0%
      Number of BUFPLLs:                             0 out of       8    0%
      Number of BUFPLL_MCBs:                         0 out of       4    0%
      Number of DSP48A1s:                            0 out of       8    0%
      Number of ICAPs:                               0 out of       1    0%
      Number of PCILOGICSEs:                         0 out of       2    0%
      Number of PLL_ADVs:                            0 out of       2    0%
      Number of PMVs:                                0 out of       1    0%
      Number of STARTUPs:                            0 out of       1    0%
      Number of SUSPEND_SYNCs:                       0 out of       1    0%


    ----------------------------------------------------------------------------------------------------------
    |  Constraint                                |    Check    | Worst Case |  Best Case | Timing |   Timing   
    |                                            |             |    Slack   | Achievable | Errors |    Score   
    ----------------------------------------------------------------------------------------------------------
    |  TS_Clk = PERIOD TIMEGRP "Clk" 10.25 ns HI | SETUP       |     0.357ns|     9.536ns|       0|          0
    |  GH 50%                                    | HOLD        |     0.444ns|            |       0|          0
    ----------------------------------------------------------------------------------------------------------
    
Per the rules, no Block RAMs are used, and less than 128 Spartan 6 logic 
slices are used in the implementation of the core. The core as supplied maps 
to 71-75 Spartan 6 slices, and is reported to support 104 MHz operation in the 
XC6SLX4-3TQG144 FPGA. The User Constraint File (UCF) in the ISE14.7i 
subdirectory sets the clock period constraint for the core to 10.25 ns, and 
the tools report the final performance as 9.536 ns. The UCF also constrains 
the placement into clock region X0Y0, i.e. the lower left corner of the LX4 
device. That clock region is an area of 6 x 14 slices, or 84 total slices.

Status
------

The core is complete. Simulation has been completed on the Execution unit. 
Simulation of the completed core should be completed in the next week. A 
simulation model is C is currently being developed, and should be available in 
the next few weeks. Following those efforts, an assembler will be developed 
using AWK, Lua, or Python. Modification of the Mak-Pascal compiler for the 
M65C02A is also being considered.

Future enhancements would be to modify the pointer register stack to directly 
support FORTH VM operations. Another modification is to modify the workspace 
pointer into a dual pointer stack to more easily support multiple workspaces. 
Another modification is to add a LIFO return stack to reduce subroutine calls 
and returns to single cycle operations.

