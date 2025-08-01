; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -global-isel -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1031 < %s | FileCheck %s

define hidden <2 x i64> @icmp_v2i32_sext_to_v2i64(<2 x i32> %arg) {
; CHECK-LABEL: icmp_v2i32_sext_to_v2i64:
; CHECK:       ; %bb.0:
; CHECK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; CHECK-NEXT:    v_cmp_eq_u32_e32 vcc_lo, 0, v0
; CHECK-NEXT:    v_cndmask_b32_e64 v0, 0, 1, vcc_lo
; CHECK-NEXT:    v_cmp_eq_u32_e32 vcc_lo, 0, v1
; CHECK-NEXT:    v_bfe_i32 v0, v0, 0, 1
; CHECK-NEXT:    v_cndmask_b32_e64 v1, 0, 1, vcc_lo
; CHECK-NEXT:    v_bfe_i32 v2, v1, 0, 1
; CHECK-NEXT:    v_ashrrev_i32_e32 v1, 31, v0
; CHECK-NEXT:    v_ashrrev_i32_e32 v3, 31, v2
; CHECK-NEXT:    s_setpc_b64 s[30:31]
  %cmp = icmp eq <2 x i32> %arg, zeroinitializer
  %sext = sext <2 x i1> %cmp to <2 x i64>
  ret <2 x i64> %sext
}

define hidden <2 x i64> @icmp_v2i32_zext_to_v2i64(<2 x i32> %arg) {
; CHECK-LABEL: icmp_v2i32_zext_to_v2i64:
; CHECK:       ; %bb.0:
; CHECK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; CHECK-NEXT:    v_cmp_eq_u32_e32 vcc_lo, 0, v0
; CHECK-NEXT:    v_mov_b32_e32 v3, 0
; CHECK-NEXT:    v_cndmask_b32_e64 v0, 0, 1, vcc_lo
; CHECK-NEXT:    v_cmp_eq_u32_e32 vcc_lo, 0, v1
; CHECK-NEXT:    v_mov_b32_e32 v1, 0
; CHECK-NEXT:    v_cndmask_b32_e64 v2, 0, 1, vcc_lo
; CHECK-NEXT:    s_setpc_b64 s[30:31]
  %cmp = icmp eq <2 x i32> %arg, zeroinitializer
  %sext = zext <2 x i1> %cmp to <2 x i64>
  ret <2 x i64> %sext
}
