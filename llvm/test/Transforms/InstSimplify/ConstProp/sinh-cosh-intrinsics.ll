; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S -passes=instsimplify < %s | FileCheck %s

define double @test_sinh_0() {
; CHECK-LABEL: define double @test_sinh_0() {
; CHECK-NEXT:    ret double 0.000000e+00
;
  %result = call double @llvm.sinh.f64(double 0.0)
  ret double %result
}

define double @test_sinh_ln2() {
; CHECK-LABEL: define double @test_sinh_ln2() {
; CHECK-NEXT:    ret double 7.500000e-01
;
  %res = call double @llvm.sinh.f64(double 0x3fe62e42fefa39ef)
  ret double %res
}

define <2 x double> @test_sinh_v2() {
; CHECK-LABEL: define <2 x double> @test_sinh_v2() {
; CHECK-NEXT:    ret <2 x double> zeroinitializer
;
  %result = call <2 x double> @llvm.sinh.v2f64(<2 x double> zeroinitializer)
  ret <2 x double> %result
}

define double @test_sinh_neg0() {
; CHECK-LABEL: define double @test_sinh_neg0() {
; CHECK-NEXT:    ret double -0.000000e+00
;
  %res = call double @llvm.sinh.f64(double -0.0)
  ret double %res
}

define double @test_sinh_poison() {
; CHECK-LABEL: define double @test_sinh_poison() {
; CHECK-NEXT:    ret double poison
;
  %res = call double @llvm.sinh.f64(double poison)
  ret double %res
}

define double @test_sinh_undef() {
; CHECK-LABEL: define double @test_sinh_undef() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.sinh.f64(double undef)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.sinh.f64(double undef)
  ret double %res
}

define double @test_sinh_snan() {
; CHECK-LABEL: define double @test_sinh_snan() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.sinh.f64(double 0x7FF0000000000001)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.sinh.f64(double 0x7ff0000000000001)
  ret double %res
}

define double @test_sinh_qnan() {
; CHECK-LABEL: define double @test_sinh_qnan() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.sinh.f64(double 0x7FF8000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.sinh.f64(double 0x7ff8000000000000)
  ret double %res
}

define double @test_sinh_pos_inf() {
; CHECK-LABEL: define double @test_sinh_pos_inf() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.sinh.f64(double 0x7FF0000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.sinh.f64(double 0x7ff0000000000000)
  ret double %res
}

define double @test_sinh_neg_inf() {
; CHECK-LABEL: define double @test_sinh_neg_inf() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.sinh.f64(double 0xFFF0000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.sinh.f64(double 0xfff0000000000000)
  ret double %res
}

define double @test_cosh_0() {
; CHECK-LABEL: define double @test_cosh_0() {
; CHECK-NEXT:    ret double 1.000000e+00
;
  %result = call double @llvm.cosh.f64(double 0.0)
  ret double %result
}

define double @test_cosh_ln2() {
; CHECK-LABEL: define double @test_cosh_ln2() {
; CHECK-NEXT:    ret double 1.250000e+00
;
  %res = call double @llvm.cosh.f64(double 0x3fe62e42fefa39ef)
  ret double %res
}

define <2 x double> @test_cosh_v2() {
; CHECK-LABEL: define <2 x double> @test_cosh_v2() {
; CHECK-NEXT:    ret <2 x double> splat (double 1.000000e+00)
;
  %result = call <2 x double> @llvm.cosh.v2f64(<2 x double> zeroinitializer)
  ret <2 x double> %result
}

define double @test_cosh_neg0() {
; CHECK-LABEL: define double @test_cosh_neg0() {
; CHECK-NEXT:    ret double 1.000000e+00
;
  %res = call double @llvm.cosh.f64(double -0.0)
  ret double %res
}

define double @test_cosh_poison() {
; CHECK-LABEL: define double @test_cosh_poison() {
; CHECK-NEXT:    ret double poison
;
  %res = call double @llvm.cosh.f64(double poison)
  ret double %res
}

define double @test_cosh_undef() {
; CHECK-LABEL: define double @test_cosh_undef() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.cosh.f64(double undef)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.cosh.f64(double undef)
  ret double %res
}

define double @test_cosh_snan() {
; CHECK-LABEL: define double @test_cosh_snan() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.cosh.f64(double 0x7FF0000000000001)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.cosh.f64(double 0x7ff0000000000001)
  ret double %res
}

define double @test_cosh_qnan() {
; CHECK-LABEL: define double @test_cosh_qnan() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.cosh.f64(double 0x7FF8000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.cosh.f64(double 0x7ff8000000000000)
  ret double %res
}

define double @test_cosh_pos_inf() {
; CHECK-LABEL: define double @test_cosh_pos_inf() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.cosh.f64(double 0x7FF0000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.cosh.f64(double 0x7ff0000000000000)
  ret double %res
}

define double @test_cosh_neg_inf() {
; CHECK-LABEL: define double @test_cosh_neg_inf() {
; CHECK-NEXT:    [[RES:%.*]] = call double @llvm.cosh.f64(double 0xFFF0000000000000)
; CHECK-NEXT:    ret double [[RES]]
;
  %res = call double @llvm.cosh.f64(double 0xfff0000000000000)
  ret double %res
}
