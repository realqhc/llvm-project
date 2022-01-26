; Generate ELF attributes from llc.

; RUN: llc -mtriple=riscv32 -mattr=+m %s -o - | FileCheck --check-prefix=RV32M %s
; RUN: llc -mtriple=riscv32 -mattr=+a %s -o - | FileCheck --check-prefix=RV32A %s
; RUN: llc -mtriple=riscv32 -mattr=+f %s -o - | FileCheck --check-prefix=RV32F %s
; RUN: llc -mtriple=riscv32 -mattr=+d %s -o - | FileCheck --check-prefix=RV32D %s
; RUN: llc -mtriple=riscv32 -mattr=+c %s -o - | FileCheck --check-prefix=RV32C %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zfhmin %s -o - | FileCheck --check-prefix=RV32ZFHMIN %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zfh %s -o - | FileCheck --check-prefix=RV32ZFH %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zba %s -o - | FileCheck --check-prefix=RV32ZBA %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbb %s -o - | FileCheck --check-prefix=RV32ZBB %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbc %s -o - | FileCheck --check-prefix=RV32ZBC %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbe %s -o - | FileCheck --check-prefix=RV32ZBE %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbf %s -o - | FileCheck --check-prefix=RV32ZBF %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbm %s -o - | FileCheck --check-prefix=RV32ZBM %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbp %s -o - | FileCheck --check-prefix=RV32ZBP %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbr %s -o - | FileCheck --check-prefix=RV32ZBR %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbs %s -o - | FileCheck --check-prefix=RV32ZBS %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbt %s -o - | FileCheck --check-prefix=RV32ZBT %s


; RV32M: .attribute 5, "rv32i2p0_m2p0"
; RV32A: .attribute 5, "rv32i2p0_a2p0"
; RV32F: .attribute 5, "rv32i2p0_f2p0"
; RV32D: .attribute 5, "rv32i2p0_f2p0_d2p0"
; RV32C: .attribute 5, "rv32i2p0_c2p0"
; RV32V: .attribute 5, "rv32i2p0_v0p10_zvlsseg0p10"
; RV32ZFHMIN: .attribute 5, "rv32i2p0_f2p0_zfhmin0p1"
; RV32ZFH: .attribute 5, "rv32i2p0_f2p0_zfh0p1_zfhmin0p1"
; RV32ZBA: .attribute 5, "rv32i2p0_zba1p0"
; RV32ZBB: .attribute 5, "rv32i2p0_zbb1p0"
; RV32ZBC: .attribute 5, "rv32i2p0_zbc1p0"
; RV32ZBE: .attribute 5, "rv32i2p0_zbe0p93"
; RV32ZBF: .attribute 5, "rv32i2p0_zbf0p93"
; RV32ZBM: .attribute 5, "rv32i2p0_zbm0p93"
; RV32ZBP: .attribute 5, "rv32i2p0_zbp0p93"
; RV32ZBR: .attribute 5, "rv32i2p0_zbr0p93"
; RV32ZBS: .attribute 5, "rv32i2p0_zbs1p0"
; RV32ZBT: .attribute 5, "rv32i2p0_zbt0p93"


; RUN: llc -mtriple=riscv32 -mattr=+m0p7 < %s 2>&1 | FileCheck --check-prefix=RV32M0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+a0p7 < %s 2>&1 | FileCheck --check-prefix=RV32A0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+f0p7 < %s 2>&1 | FileCheck --check-prefix=RV32F0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+d0p7 < %s 2>&1 | FileCheck --check-prefix=RV32D0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+c0p7 < %s 2>&1 | FileCheck --check-prefix=RV32C0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zfhmin0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZFHMIN0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zfh0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZFH0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zba0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBA0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbb0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBB0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbc0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBC0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbe0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBE0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbf0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBF0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbm0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBM0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbp0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBP0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbr0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBR0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbs0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBS0P7 %s
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbt0p7 < %s 2>&1 | FileCheck --check-prefix=RV32ZBT0P7 %s

; RV32M0P7: '+m0p7' is not a recognized feature for this target
; RV32A0P7: '+a0p7' is not a recognized feature for this target
; RV32F0P7: '+f0p7' is not a recognized feature for this target
; RV32D0P7: '+d0p7' is not a recognized feature for this target
; RV32C0P7: '+c0p7' is not a recognized feature for this target
; RV32ZFHMIN0P7: '+experimental-zfhmin0p7' is not a recognized feature for this target
; RV32ZFH0P7: '+experimental-zfh0p7' is not a recognized feature for this target
; RV32ZBA0P7: '+experimental-zba0p7' is not a recognized feature for this target
; RV32ZBB0P7: '+experimental-zbb0p7' is not a recognized feature for this target
; RV32ZBC0P7: '+experimental-zbc0p7' is not a recognized feature for this target
; RV32ZBE0P7: '+experimental-zbe0p7' is not a recognized feature for this target
; RV32ZBF0P7: '+experimental-zbf0p7' is not a recognized feature for this target
; RV32ZBM0P7: '+experimental-zbm0p7' is not a recognized feature for this target
; RV32ZBP0P7: '+experimental-zbp0p7' is not a recognized feature for this target
; RV32ZBR0P7: '+experimental-zbr0p7' is not a recognized feature for this target
; RV32ZBS0P7: '+experimental-zbs0p7' is not a recognized feature for this target
; RV32ZBT0P7: '+experimental-zbt0p7' is not a recognized feature for this target

define i32 @addi(i32 %a) {
  %1 = add i32 %a, 1
  ret i32 %1
}
