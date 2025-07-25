; RUN: llc -mtriple=amdgcn -mcpu=tahiti < %s | FileCheck -check-prefix=GCN %s

; Test fcmp pred (fneg x), c -> fcmp (swapped pred) x, -c combine.

; GCN-LABEL: {{^}}multi_use_fneg_src:
; GCN: buffer_load_dword [[A:v[0-9]+]]
; GCN: buffer_load_dword [[B:v[0-9]+]]
; GCN: buffer_load_dword [[C:v[0-9]+]]

; GCN: v_mul_f32_e32 [[MUL:v[0-9]+]], [[A]], [[B]]
; GCN: v_cmp_eq_f32_e32 vcc, -4.0, [[MUL]]
; GCN: buffer_store_dword [[MUL]]
define amdgpu_kernel void @multi_use_fneg_src() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %b = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison

  %mul = fmul float %a, %b
  %neg.mul = fsub float -0.0, %mul
  %cmp = fcmp oeq float %neg.mul, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  store volatile float %mul, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}multi_foldable_use_fneg_src:
; GCN: buffer_load_dword [[A:v[0-9]+]]
; GCN: buffer_load_dword [[B:v[0-9]+]]
; GCN: buffer_load_dword [[C:v[0-9]+]]

; GCN: v_mul_f32_e32 [[MUL:v[0-9]+]], [[A]], [[B]]
; GCN: v_cmp_eq_f32_e32 vcc, -4.0, [[A]]
; GCN: v_mul_f32_e64 [[USE1:v[0-9]+]], [[MUL]], -[[MUL]]
define amdgpu_kernel void @multi_foldable_use_fneg_src() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %b = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison

  %mul = fmul float %a, %b
  %neg.mul = fsub float -0.0, %mul
  %use1 = fmul float %mul, %neg.mul
  %cmp = fcmp oeq float %neg.mul, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y

  store volatile i32 %select, ptr addrspace(1) poison
  store volatile float %use1, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}multi_use_fneg:
; GCN: buffer_load_dword [[A:v[0-9]+]]
; GCN: buffer_load_dword [[B:v[0-9]+]]
; GCN: buffer_load_dword [[C:v[0-9]+]]

; GCN: v_mul_f32_e64 [[MUL:v[0-9]+]], [[A]], -[[B]]
; GCN-NEXT: v_cmp_eq_f32_e32 vcc, 4.0, [[MUL]]
; GCN-NOT: xor
; GCN: buffer_store_dword [[MUL]]
define amdgpu_kernel void @multi_use_fneg() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %b = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison

  %mul = fmul float %a, %b
  %neg.mul = fsub float -0.0, %mul
  %cmp = fcmp oeq float %neg.mul, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  store volatile float %neg.mul, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}multi_foldable_use_fneg:
; GCN: buffer_load_dword [[A:v[0-9]+]]
; GCN: buffer_load_dword [[B:v[0-9]+]]

; GCN: v_mul_f32_e32 [[MUL0:v[0-9]+]], [[A]], [[B]]
; GCN: v_cmp_eq_f32_e32 vcc, -4.0, [[MUL0]]
; GCN: v_mul_f32_e64 [[MUL1:v[0-9]+]], -[[MUL0]], [[MUL0]]
; GCN: buffer_store_dword [[MUL1]]
define amdgpu_kernel void @multi_foldable_use_fneg() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %b = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %z = load volatile i32, ptr addrspace(1) poison

  %mul = fmul float %a, %b
  %neg.mul = fsub float -0.0, %mul
  %cmp = fcmp oeq float %neg.mul, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  %use1 = fmul float %neg.mul, %mul
  store volatile i32 %select, ptr addrspace(1) poison
  store volatile float %use1, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_oeq_posk_f32:
; GCN: v_cmp_eq_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_oeq_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp oeq float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_ogt_posk_f32:
; GCN: v_cmp_gt_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_ogt_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp ogt float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_oge_posk_f32:
; GCN: v_cmp_ge_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_oge_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp oge float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_olt_posk_f32:
; GCN: v_cmp_lt_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_olt_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp olt float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_ole_posk_f32:
; GCN: v_cmp_le_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_ole_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp ole float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_one_posk_f32:
; GCN: v_cmp_lg_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_one_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp one float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_ueq_posk_f32:
; GCN: v_cmp_nlg_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_ueq_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp ueq float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_ugt_posk_f32:
; GCN: v_cmp_nle_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_ugt_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp ugt float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_uge_posk_f32:
; GCN: v_cmp_nlt_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_uge_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp uge float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_ult_posk_f32:
; GCN: v_cmp_nge_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_ult_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp ult float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_ule_posk_f32:
; GCN: v_cmp_ngt_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_ule_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp ule float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

; GCN-LABEL: {{^}}test_setcc_fneg_une_posk_f32:
; GCN: v_cmp_neq_f32_e32 vcc, -4.0, v{{[0-9]+}}
define amdgpu_kernel void @test_setcc_fneg_une_posk_f32() #0 {
  %a = load volatile float, ptr addrspace(1) poison
  %x = load volatile i32, ptr addrspace(1) poison
  %y = load volatile i32, ptr addrspace(1) poison
  %neg.a = fsub float -0.0, %a
  %cmp = fcmp une float %neg.a, 4.0
  %select = select i1 %cmp, i32 %x, i32 %y
  store volatile i32 %select, ptr addrspace(1) poison
  ret void
}

attributes #0 = { nounwind }
