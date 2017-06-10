--
--  Fibonacci Series Generator Program for 8-bit Minimal CPU (MiniCPU)
--
_Start: ldc #240
        xab
        ldc #255
        xch
--
--  Initialize Fibonacci Series: F[0] = 1; F[1] = 1
--
        ldc #0
        stl 3
        stl 2
        stl 1
        ldc #1
        stl 0
--
--  Initialize Loop Counter
--
        ldc #23
        stl -1
--
--  Computation Loop: F[n] = F[n-1] + F[n-2]
--
_Loop:  ldl -1
        bne _Cont   -- if(LpCntr <> 0) calculate next fibonacci number
        clc
        bnc _Start  -- Repeat Program
--
--  Decrement Loop Count, allocate space on stack and save Loop Count
--
_Cont:  xab         -- Put current loop count in bnc
        ldc #0
        xab         -- Put Loop Count in A and 0 in bnc
        clc         -- Decrement Loop Count
        sbc
        adj #-2     -- allocate space for new fibonacci number
        stl -1      -- store Loop Count below workspace pointer
--
--  Calculate new Fibonacci number
--
        ldl 4       -- load B with lo(F[n-2])
        xab
        ldl 2       -- load A with lo(F[n-1])
        clc         -- add lo(F[n-1]) + lo(F[n-2])
        adc
        stl 0       -- save lo(F[n])
        ldl 5       -- load B with hi(F[n-2])
        xab
        ldl 3       -- load A with hi(F[n-1])
        adc         -- add hi(F[n-1]) + hi(F[n-2])
        stl 1       -- save hi(F[n])
--
--  End of Loop
--
        clc
        bnc _Loop
        