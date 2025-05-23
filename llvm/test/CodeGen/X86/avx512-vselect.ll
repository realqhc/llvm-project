; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mcpu=skx | FileCheck %s --check-prefixes=CHECK,CHECK-SKX
; RUN: llc < %s -mcpu=knl | FileCheck %s --check-prefixes=CHECK,CHECK-KNL

target triple = "x86_64-unknown-unknown"

define <8 x i64> @test1(<8 x i64> %m, <8 x i64> %a, <8 x i64> %b) {
; CHECK-SKX-LABEL: test1:
; CHECK-SKX:       # %bb.0: # %entry
; CHECK-SKX-NEXT:    vpsllq $63, %zmm0, %zmm0
; CHECK-SKX-NEXT:    vpmovq2m %zmm0, %k1
; CHECK-SKX-NEXT:    vpblendmq %zmm1, %zmm2, %zmm0 {%k1}
; CHECK-SKX-NEXT:    retq
;
; CHECK-KNL-LABEL: test1:
; CHECK-KNL:       # %bb.0: # %entry
; CHECK-KNL-NEXT:    vpsllq $63, %zmm0, %zmm0
; CHECK-KNL-NEXT:    vptestmq %zmm0, %zmm0, %k1
; CHECK-KNL-NEXT:    vpblendmq %zmm1, %zmm2, %zmm0 {%k1}
; CHECK-KNL-NEXT:    retq
entry:
  %m.trunc = trunc <8 x i64> %m to <8 x i1>
  %ret = select <8 x i1> %m.trunc, <8 x i64> %a, <8 x i64> %b
  ret <8 x i64> %ret
}

; This is a very contrived test case to trick the legalizer into splitting the
; v16i1 masks in the select during type legalization, and in so doing extend them
; into two v8i64 types. This lets us ensure that the lowering code can handle
; both formulations of vselect. All of this trickery is because we can't
; directly form an SDAG input to the lowering.
define <16 x double> @test2(<16 x float> %x, <16 x float> %y, <16 x double> %a, <16 x double> %b) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    vxorps %xmm6, %xmm6, %xmm6
; CHECK-NEXT:    vcmpltps %zmm0, %zmm6, %k0
; CHECK-NEXT:    vcmpltps %zmm6, %zmm1, %k1
; CHECK-NEXT:    korw %k1, %k0, %k1
; CHECK-NEXT:    vblendmpd %zmm2, %zmm4, %zmm0 {%k1}
; CHECK-NEXT:    kshiftrw $8, %k1, %k1
; CHECK-NEXT:    vblendmpd %zmm3, %zmm5, %zmm1 {%k1}
; CHECK-NEXT:    retq
entry:
  %gt.m = fcmp ogt <16 x float> %x, zeroinitializer
  %lt.m = fcmp olt <16 x float> %y, zeroinitializer
  %m.or = or <16 x i1> %gt.m, %lt.m
  %ret = select <16 x i1> %m.or, <16 x double> %a, <16 x double> %b
  ret <16 x double> %ret
}

define <16 x i64> @test3(<16 x i8> %x, <16 x i64> %a, <16 x i64> %b) {
; CHECK-SKX-LABEL: test3:
; CHECK-SKX:       # %bb.0:
; CHECK-SKX-NEXT:    vptestnmb %xmm0, %xmm0, %k1
; CHECK-SKX-NEXT:    vpblendmq %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-SKX-NEXT:    kshiftrw $8, %k1, %k1
; CHECK-SKX-NEXT:    vpblendmq %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-SKX-NEXT:    retq
;
; CHECK-KNL-LABEL: test3:
; CHECK-KNL:       # %bb.0:
; CHECK-KNL-NEXT:    vpxor %xmm5, %xmm5, %xmm5
; CHECK-KNL-NEXT:    vpcmpeqb %xmm5, %xmm0, %xmm0
; CHECK-KNL-NEXT:    vpmovsxbd %xmm0, %zmm0
; CHECK-KNL-NEXT:    vptestmd %zmm0, %zmm0, %k1
; CHECK-KNL-NEXT:    vpblendmq %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-KNL-NEXT:    kshiftrw $8, %k1, %k1
; CHECK-KNL-NEXT:    vpblendmq %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-KNL-NEXT:    retq
  %c = icmp eq <16 x i8> %x, zeroinitializer
  %ret = select <16 x i1> %c, <16 x i64> %a, <16 x i64> %b
  ret <16 x i64> %ret
}

define <16 x i64> @test4(<16 x i16> %x, <16 x i64> %a, <16 x i64> %b) {
; CHECK-SKX-LABEL: test4:
; CHECK-SKX:       # %bb.0:
; CHECK-SKX-NEXT:    vptestnmw %ymm0, %ymm0, %k1
; CHECK-SKX-NEXT:    vpblendmq %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-SKX-NEXT:    kshiftrw $8, %k1, %k1
; CHECK-SKX-NEXT:    vpblendmq %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-SKX-NEXT:    retq
;
; CHECK-KNL-LABEL: test4:
; CHECK-KNL:       # %bb.0:
; CHECK-KNL-NEXT:    vpxor %xmm5, %xmm5, %xmm5
; CHECK-KNL-NEXT:    vpcmpeqw %ymm5, %ymm0, %ymm0
; CHECK-KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; CHECK-KNL-NEXT:    vptestmd %zmm0, %zmm0, %k1
; CHECK-KNL-NEXT:    vpblendmq %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-KNL-NEXT:    kshiftrw $8, %k1, %k1
; CHECK-KNL-NEXT:    vpblendmq %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-KNL-NEXT:    retq
  %c = icmp eq <16 x i16> %x, zeroinitializer
  %ret = select <16 x i1> %c, <16 x i64> %a, <16 x i64> %b
  ret <16 x i64> %ret
}

define <16 x i64> @test5(<16 x i32> %x, <16 x i64> %a, <16 x i64> %b) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vptestnmd %zmm0, %zmm0, %k1
; CHECK-NEXT:    vpblendmq %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-NEXT:    kshiftrw $8, %k1, %k1
; CHECK-NEXT:    vpblendmq %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-NEXT:    retq
  %c = icmp eq <16 x i32> %x, zeroinitializer
  %ret = select <16 x i1> %c, <16 x i64> %a, <16 x i64> %b
  ret <16 x i64> %ret
}

define <32 x i32> @test6(<32 x i8> %x, <32 x i32> %a, <32 x i32> %b) {
; CHECK-SKX-LABEL: test6:
; CHECK-SKX:       # %bb.0:
; CHECK-SKX-NEXT:    vptestnmb %ymm0, %ymm0, %k1
; CHECK-SKX-NEXT:    vpblendmd %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-SKX-NEXT:    kshiftrd $16, %k1, %k1
; CHECK-SKX-NEXT:    vpblendmd %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-SKX-NEXT:    retq
;
; CHECK-KNL-LABEL: test6:
; CHECK-KNL:       # %bb.0:
; CHECK-KNL-NEXT:    vpxor %xmm5, %xmm5, %xmm5
; CHECK-KNL-NEXT:    vpcmpeqb %ymm5, %ymm0, %ymm0
; CHECK-KNL-NEXT:    vextracti128 $1, %ymm0, %xmm5
; CHECK-KNL-NEXT:    vpmovsxbd %xmm5, %zmm5
; CHECK-KNL-NEXT:    vptestmd %zmm5, %zmm5, %k1
; CHECK-KNL-NEXT:    vpmovsxbd %xmm0, %zmm0
; CHECK-KNL-NEXT:    vptestmd %zmm0, %zmm0, %k2
; CHECK-KNL-NEXT:    vpblendmd %zmm1, %zmm3, %zmm0 {%k2}
; CHECK-KNL-NEXT:    vpblendmd %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-KNL-NEXT:    retq
  %c = icmp eq <32 x i8> %x, zeroinitializer
  %ret = select <32 x i1> %c, <32 x i32> %a, <32 x i32> %b
  ret <32 x i32> %ret
}

define <32 x i32> @test7(<32 x i16> %x, <32 x i32> %a, <32 x i32> %b) {
; CHECK-SKX-LABEL: test7:
; CHECK-SKX:       # %bb.0:
; CHECK-SKX-NEXT:    vptestnmw %zmm0, %zmm0, %k1
; CHECK-SKX-NEXT:    vpblendmd %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-SKX-NEXT:    kshiftrd $16, %k1, %k1
; CHECK-SKX-NEXT:    vpblendmd %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-SKX-NEXT:    retq
;
; CHECK-KNL-LABEL: test7:
; CHECK-KNL:       # %bb.0:
; CHECK-KNL-NEXT:    vextracti64x4 $1, %zmm0, %ymm5
; CHECK-KNL-NEXT:    vpxor %xmm6, %xmm6, %xmm6
; CHECK-KNL-NEXT:    vpcmpeqw %ymm6, %ymm5, %ymm5
; CHECK-KNL-NEXT:    vpmovsxwd %ymm5, %zmm5
; CHECK-KNL-NEXT:    vptestmd %zmm5, %zmm5, %k1
; CHECK-KNL-NEXT:    vpcmpeqw %ymm6, %ymm0, %ymm0
; CHECK-KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; CHECK-KNL-NEXT:    vptestmd %zmm0, %zmm0, %k2
; CHECK-KNL-NEXT:    vpblendmd %zmm1, %zmm3, %zmm0 {%k2}
; CHECK-KNL-NEXT:    vpblendmd %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-KNL-NEXT:    retq
  %c = icmp eq <32 x i16> %x, zeroinitializer
  %ret = select <32 x i1> %c, <32 x i32> %a, <32 x i32> %b
  ret <32 x i32> %ret
}

define <64 x i16> @test8(<64 x i8> %x, <64 x i16> %a, <64 x i16> %b) {
; CHECK-SKX-LABEL: test8:
; CHECK-SKX:       # %bb.0:
; CHECK-SKX-NEXT:    vptestnmb %zmm0, %zmm0, %k1
; CHECK-SKX-NEXT:    vpblendmw %zmm1, %zmm3, %zmm0 {%k1}
; CHECK-SKX-NEXT:    kshiftrq $32, %k1, %k1
; CHECK-SKX-NEXT:    vpblendmw %zmm2, %zmm4, %zmm1 {%k1}
; CHECK-SKX-NEXT:    retq
;
; CHECK-KNL-LABEL: test8:
; CHECK-KNL:       # %bb.0:
; CHECK-KNL-NEXT:    vextracti64x4 $1, %zmm0, %ymm5
; CHECK-KNL-NEXT:    vpxor %xmm6, %xmm6, %xmm6
; CHECK-KNL-NEXT:    vpcmpeqb %ymm6, %ymm5, %ymm5
; CHECK-KNL-NEXT:    vpcmpeqb %ymm6, %ymm0, %ymm0
; CHECK-KNL-NEXT:    vpmovsxbw %xmm0, %ymm6
; CHECK-KNL-NEXT:    vextracti128 $1, %ymm0, %xmm0
; CHECK-KNL-NEXT:    vpmovsxbw %xmm0, %ymm0
; CHECK-KNL-NEXT:    vinserti64x4 $1, %ymm0, %zmm6, %zmm0
; CHECK-KNL-NEXT:    vpternlogq {{.*#+}} zmm0 = zmm3 ^ (zmm0 & (zmm1 ^ zmm3))
; CHECK-KNL-NEXT:    vpmovsxbw %xmm5, %ymm1
; CHECK-KNL-NEXT:    vextracti128 $1, %ymm5, %xmm3
; CHECK-KNL-NEXT:    vpmovsxbw %xmm3, %ymm3
; CHECK-KNL-NEXT:    vinserti64x4 $1, %ymm3, %zmm1, %zmm1
; CHECK-KNL-NEXT:    vpternlogq {{.*#+}} zmm1 = zmm4 ^ (zmm1 & (zmm2 ^ zmm4))
; CHECK-KNL-NEXT:    retq
  %c = icmp eq <64 x i8> %x, zeroinitializer
  %ret = select <64 x i1> %c, <64 x i16> %a, <64 x i16> %b
  ret <64 x i16> %ret
}
