// +build arm64,go1.16

// Taken from https://github.com/bwesterb/armed-keccak

#include "textflag.h"

// func f1600x2ARM(state *uint64, rc *[24]uint64, turbo bool)
TEXT ·f1600x2ARM(SB), NOSPLIT, $0-17
    MOVD state+0(FP), R0
    MOVD rc+8(FP), R1
    MOVD R0, R2
    MOVD $24, R3

    VLD1.P 64(R0), [ V0.B16,  V1.B16,  V2.B16,  V3.B16]
    VLD1.P 64(R0), [ V4.B16,  V5.B16,  V6.B16,  V7.B16]
    VLD1.P 64(R0), [ V8.B16,  V9.B16, V10.B16, V11.B16]
    VLD1.P 64(R0), [V12.B16, V13.B16, V14.B16, V15.B16]
    VLD1.P 64(R0), [V16.B16, V17.B16, V18.B16, V19.B16]
    VLD1.P 64(R0), [V20.B16, V21.B16, V22.B16, V23.B16]
    VLD1.P (R0),   [V24.B16]

    MOVBU turbo+16(FP), R4
    CBZ R4, loop

    SUB  $12, R3, R3
    ADD  $96, R1, R1

loop:
    // Execute theta but without xorring into the state yet.
    VEOR3 V10.B16, V5.B16, V0.B16, V25.B16
    VEOR3 V11.B16, V6.B16, V1.B16, V26.B16
    VEOR3 V12.B16, V7.B16, V2.B16, V27.B16
    VEOR3 V13.B16, V8.B16, V3.B16, V28.B16
    VEOR3 V14.B16, V9.B16, V4.B16, V29.B16

    VEOR3 V20.B16, V15.B16, V25.B16, V25.B16
    VEOR3 V21.B16, V16.B16, V26.B16, V26.B16
    VEOR3 V22.B16, V17.B16, V27.B16, V27.B16
    VEOR3 V23.B16, V18.B16, V28.B16, V28.B16
    VEOR3 V24.B16, V19.B16, V29.B16, V29.B16

    // Xor parities from step theta into the state at the same time as
    // exeuting rho and pi.   
    VRAX1 V26.D2, V29.D2, V30.D2
    VRAX1 V29.D2, V27.D2, V29.D2
    VRAX1 V27.D2, V25.D2, V27.D2
    VRAX1 V25.D2, V28.D2, V25.D2
    VRAX1 V28.D2, V26.D2, V28.D2

    VEOR V30.B16, V0.B16, V0.B16
    VMOV V1.B16, V31.B16

    VXAR $20, V27.D2,  V6.D2,  V1.D2   
    VXAR $44, V25.D2,  V9.D2,  V6.D2   
    VXAR $3 , V28.D2, V22.D2,  V9.D2   
    VXAR $25, V25.D2, V14.D2, V22.D2  
    VXAR $46, V30.D2, V20.D2, V14.D2  
    VXAR $2 , V28.D2,  V2.D2, V20.D2  
    VXAR $21, V28.D2, V12.D2,  V2.D2  
    VXAR $39, V29.D2, V13.D2, V12.D2  
    VXAR $56, V25.D2, V19.D2, V13.D2  
    VXAR $8 , V29.D2, V23.D2, V19.D2  
    VXAR $23, V30.D2, V15.D2, V23.D2  
    VXAR $37, V25.D2,  V4.D2, V15.D2  
    VXAR $50, V25.D2, V24.D2,  V4.D2   
    VXAR $62, V27.D2, V21.D2, V24.D2  
    VXAR $9 , V29.D2,  V8.D2, V21.D2  
    VXAR $19, V27.D2, V16.D2,  V8.D2   
    VXAR $28, V30.D2,  V5.D2, V16.D2  
    VXAR $36, V29.D2,  V3.D2,  V5.D2   
    VXAR $43, V29.D2, V18.D2,  V3.D2   
    VXAR $49, V28.D2, V17.D2, V18.D2  
    VXAR $54, V27.D2, V11.D2, V17.D2  
    VXAR $58, V28.D2,  V7.D2, V11.D2  
    VXAR $61, V30.D2, V10.D2,  V7.D2   
    VXAR $63, V27.D2, V31.D2, V10.D2  

    // Chi
    VBCAX V1.B16, V2.B16, V0.B16, V25.B16
    VBCAX V2.B16, V3.B16, V1.B16, V26.B16
    VBCAX V3.B16, V4.B16, V2.B16,  V2.B16
    VBCAX V4.B16, V0.B16, V3.B16,  V3.B16
    VBCAX V0.B16, V1.B16, V4.B16,  V4.B16
    VMOV V25.B16, V0.B16
    VMOV V26.B16, V1.B16

    VBCAX V6.B16, V7.B16, V5.B16, V25.B16
    VBCAX V7.B16, V8.B16, V6.B16, V26.B16
    VBCAX V8.B16, V9.B16, V7.B16,  V7.B16
    VBCAX V9.B16, V5.B16, V8.B16,  V8.B16
    VBCAX V5.B16, V6.B16, V9.B16,  V9.B16
    VMOV V25.B16, V5.B16
    VMOV V26.B16, V6.B16

    VBCAX V11.B16, V12.B16, V10.B16, V25.B16
    VBCAX V12.B16, V13.B16, V11.B16, V26.B16
    VBCAX V13.B16, V14.B16, V12.B16, V12.B16
    VBCAX V14.B16, V10.B16, V13.B16, V13.B16
    VBCAX V10.B16, V11.B16, V14.B16, V14.B16
    VMOV V25.B16, V10.B16
    VMOV V26.B16, V11.B16

    VBCAX V16.B16, V17.B16, V15.B16, V25.B16
    VBCAX V17.B16, V18.B16, V16.B16, V26.B16
    VBCAX V18.B16, V19.B16, V17.B16, V17.B16
    VBCAX V19.B16, V15.B16, V18.B16, V18.B16
    VBCAX V15.B16, V16.B16, V19.B16, V19.B16
    VMOV V25.B16, V15.B16
    VMOV V26.B16, V16.B16

    VBCAX V21.B16, V22.B16, V20.B16, V25.B16
    VBCAX V22.B16, V23.B16, V21.B16, V26.B16
    VBCAX V23.B16, V24.B16, V22.B16, V22.B16
    VBCAX V24.B16, V20.B16, V23.B16, V23.B16
    VBCAX V20.B16, V21.B16, V24.B16, V24.B16
    VMOV V25.B16, V20.B16
    VMOV V26.B16, V21.B16

    // Iota
    VLD1R.P 8(R1), [V25.D2]
    VEOR V25.B16, V0.B16, V0.B16

    SUBS $1, R3, R3
    CBNZ R3, loop

    MOVD R2, R0

    VST1.P [ V0.B16,  V1.B16,  V2.B16,  V3.B16], 64(R0) 
    VST1.P [ V4.B16,  V5.B16,  V6.B16,  V7.B16], 64(R0)
    VST1.P [ V8.B16,  V9.B16, V10.B16, V11.B16], 64(R0)
    VST1.P [V12.B16, V13.B16, V14.B16, V15.B16], 64(R0)
    VST1.P [V16.B16, V17.B16, V18.B16, V19.B16], 64(R0)
    VST1.P [V20.B16, V21.B16, V22.B16, V23.B16], 64(R0)
    VST1.P [V24.B16], (R0)

    RET
