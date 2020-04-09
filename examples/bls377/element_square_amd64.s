// Code generated by goff (v0.2.0) DO NOT EDIT

#include "textflag.h"

// func SquareElement(res,x *Element)
// montgomery squaring of x
// stores the result in res
TEXT ·SquareElement(SB), NOSPLIT, $0-16
    
    // dereference x
    MOVQ x+8(FP), R9
    
    // the algorithm is described here
    // https://hackmd.io/@zkteam/modular_multiplication
    // for i=0 to N-1
    // A, t[i] = x[i] * x[i] + t[i]
    // p = 0
    // for j=i+1 to N-1
    //     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
    // m = t[0] * q'[0]
    // C, _ = t[0] + q[0]*m
    // for j=1 to N-1
    //     C, t[j-1] = q[j]*m +  t[j] + C
    // t[N-1] = C + A
    
    // check if we support adx and mulx
    CMPB ·supportAdx(SB), $1
    JNE no_adx
    
    // for i=0 to N-1
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 0
    
    // clear up the carry flags
    XORQ R14, R14
    
    // A, t[0] = x[0] * x[0] + t[0]
    MOVQ 0(R9), DX
    
    MULXQ DX, CX , BX   // x[0] * x[0]
    
    // for j=i+1 to N-1
    //     A,t[j] = x[j]*x[i] + t[j] + A
    MOVQ $0, R11
    
    // MOVQ R10, BX
    MULXQ 8(R9), AX,BP
    MOVQ BP, R12 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, BP
    ADOXQ AX, BX
    
    // MOVQ R10, BP
    MULXQ 16(R9), AX,SI
    MOVQ SI, R13 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, SI
    ADOXQ AX, BP
    
    // MOVQ R10, SI
    MULXQ 24(R9), AX,DI
    MOVQ DI, R14 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, DI
    ADOXQ AX, SI
    
    // MOVQ R10, DI
    MULXQ 32(R9), AX,R8
    MOVQ R8, R15 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R8
    ADOXQ AX, DI
    
    // MOVQ R10, R8
    MULXQ 40(R9), AX,R10
    MOVQ R10, DX // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, R8
    
    // add the last carries to R10
    ADCXQ R11, R10
    ADOXQ R11, R10
    
    ADDQ R12, BP
    ADCQ R13, SI
    ADCQ R14, DI
    ADCQ R15, R8
    ADCQ DX, R10
    
    // m := t[0]*q'[0] mod W
    MOVQ $0x8508bfffffffffff, DX
    MULXQ CX,R12, DX
    
    // clear the carry flags
    XORQ DX, DX
    
    // C,_ := t[0] + m*q[0]
    MOVQ $0x8508c00000000001, DX
    MULXQ R12, AX, DX
    ADCXQ CX ,AX
    MOVQ DX, CX
    
    // for j=1 to N-1
    //    (C,t[j-1]) := t[j] + m*q[j] + C
    MOVQ $0x170b5d4430000000, DX
    ADCXQ  BX, CX
    MULXQ R12, AX, BX
    ADOXQ AX, CX
    MOVQ $0x1ef3622fba094800, DX
    ADCXQ  BP, BX
    MULXQ R12, AX, BP
    ADOXQ AX, BX
    MOVQ $0x1a22d9f300f5138f, DX
    ADCXQ  SI, BP
    MULXQ R12, AX, SI
    ADOXQ AX, BP
    MOVQ $0xc63b05c06ca1493b, DX
    ADCXQ  DI, SI
    MULXQ R12, AX, DI
    ADOXQ AX, SI
    MOVQ $0x01ae3a4617c510ea, DX
    ADCXQ  R8, DI
    MULXQ R12, AX, R8
    ADOXQ AX, DI
    MOVQ $0, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 1
    
    // clear up the carry flags
    XORQ R14, R14
    
    // A, t[1] = x[1] * x[1] + t[1]
    MOVQ 8(R9), DX
    
    MULXQ DX, AX, R10   // x[1] * x[1]
    ADCXQ AX, BX
    
    // for j=i+1 to N-1
    //     A,t[j] = x[j]*x[i] + t[j] + A
    MOVQ $0, R11
    
    ADCXQ R10, BP
    MULXQ 16(R9), AX, R10
    MOVQ R10, R12 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, BP
    
    ADCXQ R10, SI
    MULXQ 24(R9), AX, R10
    MOVQ R10, R13 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, SI
    
    ADCXQ R10, DI
    MULXQ 32(R9), AX, R10
    MOVQ R10, R14 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, DI
    
    ADCXQ R10, R8
    MULXQ 40(R9), AX, R10
    MOVQ R10, DX // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, R8
    
    // add the last carries to R10
    ADCXQ R11, R10
    ADOXQ R11, R10
    
    ADDQ R12, SI
    ADCQ R13, DI
    ADCQ R14, R8
    ADCQ DX, R10
    
    // m := t[0]*q'[0] mod W
    MOVQ $0x8508bfffffffffff, DX
    MULXQ CX,R12, DX
    
    // clear the carry flags
    XORQ DX, DX
    
    // C,_ := t[0] + m*q[0]
    MOVQ $0x8508c00000000001, DX
    MULXQ R12, AX, DX
    ADCXQ CX ,AX
    MOVQ DX, CX
    
    // for j=1 to N-1
    //    (C,t[j-1]) := t[j] + m*q[j] + C
    MOVQ $0x170b5d4430000000, DX
    ADCXQ  BX, CX
    MULXQ R12, AX, BX
    ADOXQ AX, CX
    MOVQ $0x1ef3622fba094800, DX
    ADCXQ  BP, BX
    MULXQ R12, AX, BP
    ADOXQ AX, BX
    MOVQ $0x1a22d9f300f5138f, DX
    ADCXQ  SI, BP
    MULXQ R12, AX, SI
    ADOXQ AX, BP
    MOVQ $0xc63b05c06ca1493b, DX
    ADCXQ  DI, SI
    MULXQ R12, AX, DI
    ADOXQ AX, SI
    MOVQ $0x01ae3a4617c510ea, DX
    ADCXQ  R8, DI
    MULXQ R12, AX, R8
    ADOXQ AX, DI
    MOVQ $0, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 2
    
    // clear up the carry flags
    XORQ R14, R14
    
    // A, t[2] = x[2] * x[2] + t[2]
    MOVQ 16(R9), DX
    
    MULXQ DX, AX, R10   // x[2] * x[2]
    ADCXQ AX, BP
    
    // for j=i+1 to N-1
    //     A,t[j] = x[j]*x[i] + t[j] + A
    MOVQ $0, R11
    
    ADCXQ R10, SI
    MULXQ 24(R9), AX, R10
    MOVQ R10, R12 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, SI
    
    ADCXQ R10, DI
    MULXQ 32(R9), AX, R10
    MOVQ R10, R13 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, DI
    
    ADCXQ R10, R8
    MULXQ 40(R9), AX, R10
    MOVQ R10, DX // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, R8
    
    // add the last carries to R10
    ADCXQ R11, R10
    ADOXQ R11, R10
    
    ADDQ R12, DI
    ADCQ R13, R8
    ADCQ DX, R10
    
    // m := t[0]*q'[0] mod W
    MOVQ $0x8508bfffffffffff, DX
    MULXQ CX,R12, DX
    
    // clear the carry flags
    XORQ DX, DX
    
    // C,_ := t[0] + m*q[0]
    MOVQ $0x8508c00000000001, DX
    MULXQ R12, AX, DX
    ADCXQ CX ,AX
    MOVQ DX, CX
    
    // for j=1 to N-1
    //    (C,t[j-1]) := t[j] + m*q[j] + C
    MOVQ $0x170b5d4430000000, DX
    ADCXQ  BX, CX
    MULXQ R12, AX, BX
    ADOXQ AX, CX
    MOVQ $0x1ef3622fba094800, DX
    ADCXQ  BP, BX
    MULXQ R12, AX, BP
    ADOXQ AX, BX
    MOVQ $0x1a22d9f300f5138f, DX
    ADCXQ  SI, BP
    MULXQ R12, AX, SI
    ADOXQ AX, BP
    MOVQ $0xc63b05c06ca1493b, DX
    ADCXQ  DI, SI
    MULXQ R12, AX, DI
    ADOXQ AX, SI
    MOVQ $0x01ae3a4617c510ea, DX
    ADCXQ  R8, DI
    MULXQ R12, AX, R8
    ADOXQ AX, DI
    MOVQ $0, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 3
    
    // clear up the carry flags
    XORQ R14, R14
    
    // A, t[3] = x[3] * x[3] + t[3]
    MOVQ 24(R9), DX
    
    MULXQ DX, AX, R10   // x[3] * x[3]
    ADCXQ AX, SI
    
    // for j=i+1 to N-1
    //     A,t[j] = x[j]*x[i] + t[j] + A
    MOVQ $0, R11
    
    ADCXQ R10, DI
    MULXQ 32(R9), AX, R10
    MOVQ R10, R12 // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, DI
    
    ADCXQ R10, R8
    MULXQ 40(R9), AX, R10
    MOVQ R10, DX // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, R8
    
    // add the last carries to R10
    ADCXQ R11, R10
    ADOXQ R11, R10
    
    ADDQ R12, R8
    ADCQ DX, R10
    
    // m := t[0]*q'[0] mod W
    MOVQ $0x8508bfffffffffff, DX
    MULXQ CX,R12, DX
    
    // clear the carry flags
    XORQ DX, DX
    
    // C,_ := t[0] + m*q[0]
    MOVQ $0x8508c00000000001, DX
    MULXQ R12, AX, DX
    ADCXQ CX ,AX
    MOVQ DX, CX
    
    // for j=1 to N-1
    //    (C,t[j-1]) := t[j] + m*q[j] + C
    MOVQ $0x170b5d4430000000, DX
    ADCXQ  BX, CX
    MULXQ R12, AX, BX
    ADOXQ AX, CX
    MOVQ $0x1ef3622fba094800, DX
    ADCXQ  BP, BX
    MULXQ R12, AX, BP
    ADOXQ AX, BX
    MOVQ $0x1a22d9f300f5138f, DX
    ADCXQ  SI, BP
    MULXQ R12, AX, SI
    ADOXQ AX, BP
    MOVQ $0xc63b05c06ca1493b, DX
    ADCXQ  DI, SI
    MULXQ R12, AX, DI
    ADOXQ AX, SI
    MOVQ $0x01ae3a4617c510ea, DX
    ADCXQ  R8, DI
    MULXQ R12, AX, R8
    ADOXQ AX, DI
    MOVQ $0, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 4
    
    // clear up the carry flags
    XORQ R14, R14
    
    // A, t[4] = x[4] * x[4] + t[4]
    MOVQ 32(R9), DX
    
    MULXQ DX, AX, R10   // x[4] * x[4]
    ADCXQ AX, DI
    
    // for j=i+1 to N-1
    //     A,t[j] = x[j]*x[i] + t[j] + A
    MOVQ $0, R11
    
    ADCXQ R10, R8
    MULXQ 40(R9), AX, R10
    MOVQ R10, DX // saving hi bits
    
    ADOXQ AX, AX // doubling lo bits
    ADOXQ R11, R10
    ADOXQ AX, R8
    
    // add the last carries to R10
    ADCXQ R11, R10
    ADOXQ R11, R10
    
    ADCQ DX, R10
    
    // m := t[0]*q'[0] mod W
    MOVQ $0x8508bfffffffffff, DX
    MULXQ CX,R12, DX
    
    // clear the carry flags
    XORQ DX, DX
    
    // C,_ := t[0] + m*q[0]
    MOVQ $0x8508c00000000001, DX
    MULXQ R12, AX, DX
    ADCXQ CX ,AX
    MOVQ DX, CX
    
    // for j=1 to N-1
    //    (C,t[j-1]) := t[j] + m*q[j] + C
    MOVQ $0x170b5d4430000000, DX
    ADCXQ  BX, CX
    MULXQ R12, AX, BX
    ADOXQ AX, CX
    MOVQ $0x1ef3622fba094800, DX
    ADCXQ  BP, BX
    MULXQ R12, AX, BP
    ADOXQ AX, BX
    MOVQ $0x1a22d9f300f5138f, DX
    ADCXQ  SI, BP
    MULXQ R12, AX, SI
    ADOXQ AX, BP
    MOVQ $0xc63b05c06ca1493b, DX
    ADCXQ  DI, SI
    MULXQ R12, AX, DI
    ADOXQ AX, SI
    MOVQ $0x01ae3a4617c510ea, DX
    ADCXQ  R8, DI
    MULXQ R12, AX, R8
    ADOXQ AX, DI
    MOVQ $0, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 5
    
    // clear up the carry flags
    XORQ R14, R14
    
    // A, t[5] = x[5] * x[5] + t[5]
    MOVQ 40(R9), DX
    
    MULXQ DX, AX, R10   // x[5] * x[5]
    ADCXQ AX, R8
    
    // for j=i+1 to N-1
    //     A,t[j] = x[j]*x[i] + t[j] + A
    MOVQ $0, R11
    
    // add the last carries to R10
    ADCXQ R11, R10
    ADOXQ R11, R10
    
    // m := t[0]*q'[0] mod W
    MOVQ $0x8508bfffffffffff, DX
    MULXQ CX,R12, DX
    
    // clear the carry flags
    XORQ DX, DX
    
    // C,_ := t[0] + m*q[0]
    MOVQ $0x8508c00000000001, DX
    MULXQ R12, AX, DX
    ADCXQ CX ,AX
    MOVQ DX, CX
    
    // for j=1 to N-1
    //    (C,t[j-1]) := t[j] + m*q[j] + C
    MOVQ $0x170b5d4430000000, DX
    ADCXQ  BX, CX
    MULXQ R12, AX, BX
    ADOXQ AX, CX
    MOVQ $0x1ef3622fba094800, DX
    ADCXQ  BP, BX
    MULXQ R12, AX, BP
    ADOXQ AX, BX
    MOVQ $0x1a22d9f300f5138f, DX
    ADCXQ  SI, BP
    MULXQ R12, AX, SI
    ADOXQ AX, BP
    MOVQ $0xc63b05c06ca1493b, DX
    ADCXQ  DI, SI
    MULXQ R12, AX, DI
    ADOXQ AX, SI
    MOVQ $0x01ae3a4617c510ea, DX
    ADCXQ  R8, DI
    MULXQ R12, AX, R8
    ADOXQ AX, DI
    MOVQ $0, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    
    reduce:
    // dereference result
    MOVQ res+0(FP), AX
    // reduce, constant time version
    // first we copy registers storing t in a separate set of registers
    // as SUBQ modifies the 2nd operand
    MOVQ CX, DX
    MOVQ BX, R9
    MOVQ BP, R10
    MOVQ SI, R11
    MOVQ DI, R12
    MOVQ R8, R13
    MOVQ $0x8508c00000000001, R14
    SUBQ  R14, DX
    MOVQ $0x170b5d4430000000, R14
    SBBQ  R14, R9
    MOVQ $0x1ef3622fba094800, R14
    SBBQ  R14, R10
    MOVQ $0x1a22d9f300f5138f, R14
    SBBQ  R14, R11
    MOVQ $0xc63b05c06ca1493b, R14
    SBBQ  R14, R12
    MOVQ $0x01ae3a4617c510ea, R14
    SBBQ  R14, R13
    JCS t_is_smaller // no borrow, we return t
    
    // borrow is set, we return u
    MOVQ DX, (AX)
    MOVQ R9, 8(AX)
    MOVQ R10, 16(AX)
    MOVQ R11, 24(AX)
    MOVQ R12, 32(AX)
    MOVQ R13, 40(AX)
    RET
    
    t_is_smaller:
    MOVQ CX, 0(AX)
    MOVQ BX, 8(AX)
    MOVQ BP, 16(AX)
    MOVQ SI, 24(AX)
    MOVQ DI, 32(AX)
    MOVQ R8, 40(AX)
    RET
    
    no_adx:
    // for i=0 to N-1
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 0
    
    // A, t[0] = x[0] * x[0] + t[0]
    MOVQ 0(R9), R13
    MOVQ R13, AX
    MULQ AX // x[0] * x[0]
    
    MOVQ AX, CX
    
    MOVQ DX, R10
    XORQ R14, R14
    
    // for j=i+1 to N-1
    //     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
    XORQ R15, R15
    MOVQ 8(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, BX
    XORQ R15, R15
    MOVQ 16(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, BP
    XORQ R15, R15
    MOVQ 24(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, SI
    XORQ R15, R15
    MOVQ 32(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, DI
    XORQ R15, R15
    MOVQ 40(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, R8
    
    // m = t[0] * q'[0]
    MOVQ $0x8508bfffffffffff, R12
    IMULQ CX , R12
    
    // C, _ = t[0] + q[0]*m
    MOVQ $0x8508c00000000001, AX
    MULQ R12
    ADDQ CX ,AX
    ADCQ $0, DX
    MOVQ  DX, R11
    
    // for j=1 to N-1
    //     C, t[j-1] = q[j]*m +  t[j] + C
    MOVQ $0x170b5d4430000000, AX
    MULQ R12
    ADDQ  BX, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, CX
    MOVQ DX, R11
    MOVQ $0x1ef3622fba094800, AX
    MULQ R12
    ADDQ  BP, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BX
    MOVQ DX, R11
    MOVQ $0x1a22d9f300f5138f, AX
    MULQ R12
    ADDQ  SI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BP
    MOVQ DX, R11
    MOVQ $0xc63b05c06ca1493b, AX
    MULQ R12
    ADDQ  DI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, SI
    MOVQ DX, R11
    MOVQ $0x01ae3a4617c510ea, AX
    MULQ R12
    ADDQ  R8, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, DI
    MOVQ DX, R11
    
    // t[N-1] = C + A
    ADDQ R11, R10
    MOVQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 1
    
    // A, t[1] = x[1] * x[1] + t[1]
    MOVQ 8(R9), R13
    MOVQ R13, AX
    MULQ AX // x[1] * x[1]
    
    ADDQ AX, BX
    ADCQ $0, DX
    
    MOVQ DX, R10
    XORQ R14, R14
    
    // for j=i+1 to N-1
    //     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
    XORQ R15, R15
    MOVQ 16(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ BP, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, BP
    XORQ R15, R15
    MOVQ 24(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ SI, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, SI
    XORQ R15, R15
    MOVQ 32(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ DI, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, DI
    XORQ R15, R15
    MOVQ 40(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ R8, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, R8
    
    // m = t[0] * q'[0]
    MOVQ $0x8508bfffffffffff, R12
    IMULQ CX , R12
    
    // C, _ = t[0] + q[0]*m
    MOVQ $0x8508c00000000001, AX
    MULQ R12
    ADDQ CX ,AX
    ADCQ $0, DX
    MOVQ  DX, R11
    
    // for j=1 to N-1
    //     C, t[j-1] = q[j]*m +  t[j] + C
    MOVQ $0x170b5d4430000000, AX
    MULQ R12
    ADDQ  BX, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, CX
    MOVQ DX, R11
    MOVQ $0x1ef3622fba094800, AX
    MULQ R12
    ADDQ  BP, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BX
    MOVQ DX, R11
    MOVQ $0x1a22d9f300f5138f, AX
    MULQ R12
    ADDQ  SI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BP
    MOVQ DX, R11
    MOVQ $0xc63b05c06ca1493b, AX
    MULQ R12
    ADDQ  DI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, SI
    MOVQ DX, R11
    MOVQ $0x01ae3a4617c510ea, AX
    MULQ R12
    ADDQ  R8, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, DI
    MOVQ DX, R11
    
    // t[N-1] = C + A
    ADDQ R11, R10
    MOVQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 2
    
    // A, t[2] = x[2] * x[2] + t[2]
    MOVQ 16(R9), R13
    MOVQ R13, AX
    MULQ AX // x[2] * x[2]
    
    ADDQ AX, BP
    ADCQ $0, DX
    
    MOVQ DX, R10
    XORQ R14, R14
    
    // for j=i+1 to N-1
    //     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
    XORQ R15, R15
    MOVQ 24(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ SI, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, SI
    XORQ R15, R15
    MOVQ 32(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ DI, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, DI
    XORQ R15, R15
    MOVQ 40(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ R8, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, R8
    
    // m = t[0] * q'[0]
    MOVQ $0x8508bfffffffffff, R12
    IMULQ CX , R12
    
    // C, _ = t[0] + q[0]*m
    MOVQ $0x8508c00000000001, AX
    MULQ R12
    ADDQ CX ,AX
    ADCQ $0, DX
    MOVQ  DX, R11
    
    // for j=1 to N-1
    //     C, t[j-1] = q[j]*m +  t[j] + C
    MOVQ $0x170b5d4430000000, AX
    MULQ R12
    ADDQ  BX, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, CX
    MOVQ DX, R11
    MOVQ $0x1ef3622fba094800, AX
    MULQ R12
    ADDQ  BP, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BX
    MOVQ DX, R11
    MOVQ $0x1a22d9f300f5138f, AX
    MULQ R12
    ADDQ  SI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BP
    MOVQ DX, R11
    MOVQ $0xc63b05c06ca1493b, AX
    MULQ R12
    ADDQ  DI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, SI
    MOVQ DX, R11
    MOVQ $0x01ae3a4617c510ea, AX
    MULQ R12
    ADDQ  R8, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, DI
    MOVQ DX, R11
    
    // t[N-1] = C + A
    ADDQ R11, R10
    MOVQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 3
    
    // A, t[3] = x[3] * x[3] + t[3]
    MOVQ 24(R9), R13
    MOVQ R13, AX
    MULQ AX // x[3] * x[3]
    
    ADDQ AX, SI
    ADCQ $0, DX
    
    MOVQ DX, R10
    XORQ R14, R14
    
    // for j=i+1 to N-1
    //     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
    XORQ R15, R15
    MOVQ 32(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ DI, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, DI
    XORQ R15, R15
    MOVQ 40(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ R8, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, R8
    
    // m = t[0] * q'[0]
    MOVQ $0x8508bfffffffffff, R12
    IMULQ CX , R12
    
    // C, _ = t[0] + q[0]*m
    MOVQ $0x8508c00000000001, AX
    MULQ R12
    ADDQ CX ,AX
    ADCQ $0, DX
    MOVQ  DX, R11
    
    // for j=1 to N-1
    //     C, t[j-1] = q[j]*m +  t[j] + C
    MOVQ $0x170b5d4430000000, AX
    MULQ R12
    ADDQ  BX, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, CX
    MOVQ DX, R11
    MOVQ $0x1ef3622fba094800, AX
    MULQ R12
    ADDQ  BP, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BX
    MOVQ DX, R11
    MOVQ $0x1a22d9f300f5138f, AX
    MULQ R12
    ADDQ  SI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BP
    MOVQ DX, R11
    MOVQ $0xc63b05c06ca1493b, AX
    MULQ R12
    ADDQ  DI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, SI
    MOVQ DX, R11
    MOVQ $0x01ae3a4617c510ea, AX
    MULQ R12
    ADDQ  R8, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, DI
    MOVQ DX, R11
    
    // t[N-1] = C + A
    ADDQ R11, R10
    MOVQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 4
    
    // A, t[4] = x[4] * x[4] + t[4]
    MOVQ 32(R9), R13
    MOVQ R13, AX
    MULQ AX // x[4] * x[4]
    
    ADDQ AX, DI
    ADCQ $0, DX
    
    MOVQ DX, R10
    XORQ R14, R14
    
    // for j=i+1 to N-1
    //     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
    XORQ R15, R15
    MOVQ 40(R9), AX
    MULQ R13
    ADDQ AX, AX
    ADCQ DX, DX
    ADCQ $0, R15
    ADDQ R8, R10
    ADCQ $0, DX
    
    ADDQ R10, AX
    ADCQ R14, DX
    
    MOVQ R15, R14
    MOVQ DX, R10
    MOVQ AX, R8
    
    // m = t[0] * q'[0]
    MOVQ $0x8508bfffffffffff, R12
    IMULQ CX , R12
    
    // C, _ = t[0] + q[0]*m
    MOVQ $0x8508c00000000001, AX
    MULQ R12
    ADDQ CX ,AX
    ADCQ $0, DX
    MOVQ  DX, R11
    
    // for j=1 to N-1
    //     C, t[j-1] = q[j]*m +  t[j] + C
    MOVQ $0x170b5d4430000000, AX
    MULQ R12
    ADDQ  BX, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, CX
    MOVQ DX, R11
    MOVQ $0x1ef3622fba094800, AX
    MULQ R12
    ADDQ  BP, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BX
    MOVQ DX, R11
    MOVQ $0x1a22d9f300f5138f, AX
    MULQ R12
    ADDQ  SI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BP
    MOVQ DX, R11
    MOVQ $0xc63b05c06ca1493b, AX
    MULQ R12
    ADDQ  DI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, SI
    MOVQ DX, R11
    MOVQ $0x01ae3a4617c510ea, AX
    MULQ R12
    ADDQ  R8, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, DI
    MOVQ DX, R11
    
    // t[N-1] = C + A
    ADDQ R11, R10
    MOVQ R10, R8
    
    // ---------------------------------------------------------------------------------------------
    // outter loop 5
    
    // A, t[5] = x[5] * x[5] + t[5]
    MOVQ 40(R9), R13
    MOVQ R13, AX
    MULQ AX // x[5] * x[5]
    
    ADDQ AX, R8
    ADCQ $0, DX
    
    MOVQ DX, R10
    XORQ R14, R14
    
    // for j=i+1 to N-1
    //     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
    
    // m = t[0] * q'[0]
    MOVQ $0x8508bfffffffffff, R12
    IMULQ CX , R12
    
    // C, _ = t[0] + q[0]*m
    MOVQ $0x8508c00000000001, AX
    MULQ R12
    ADDQ CX ,AX
    ADCQ $0, DX
    MOVQ  DX, R11
    
    // for j=1 to N-1
    //     C, t[j-1] = q[j]*m +  t[j] + C
    MOVQ $0x170b5d4430000000, AX
    MULQ R12
    ADDQ  BX, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, CX
    MOVQ DX, R11
    MOVQ $0x1ef3622fba094800, AX
    MULQ R12
    ADDQ  BP, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BX
    MOVQ DX, R11
    MOVQ $0x1a22d9f300f5138f, AX
    MULQ R12
    ADDQ  SI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, BP
    MOVQ DX, R11
    MOVQ $0xc63b05c06ca1493b, AX
    MULQ R12
    ADDQ  DI, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, SI
    MOVQ DX, R11
    MOVQ $0x01ae3a4617c510ea, AX
    MULQ R12
    ADDQ  R8, R11
    ADCQ $0, DX
    ADDQ AX, R11
    ADCQ $0, DX
    
    MOVQ R11, DI
    MOVQ DX, R11
    
    // t[N-1] = C + A
    ADDQ R11, R10
    MOVQ R10, R8
    
    JMP reduce