# RUN: not llvm-mc -triple riscv32 -mattr=+zicsr < %s 2>&1 | FileCheck %s

# Out of range immediates
## uimm5
csrrwi a1, 0x1, -1 # CHECK: :[[@LINE]]:17: error: immediate must be an integer in the range [0, 31]
csrrsi t1, 999, 32 # CHECK: :[[@LINE]]:17: error: immediate must be an integer in the range [0, 31]
csrrci x0, 43, -90 # CHECK: :[[@LINE]]:16: error: immediate must be an integer in the range [0, 31]

## uimm12
csrrw a0, -1, a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrs a0, 4096, a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrs a0, -0xf, a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrc a0, 0x1000, a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrwi a0, -50, 0 # CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [0, 4095]
csrrsi a0, 4097, a0 # CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [0, 4095]
csrrci a0, 0xffff, a0 # CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [0, 4095]

# Illegal operand modifier
## uimm5
csrrwi a1, 0x1, %hi(b) # CHECK: :[[@LINE]]:17: error: immediate must be an integer in the range [0, 31]
csrrsi t1, 999, %pcrel_hi(3) # CHECK: :[[@LINE]]:17: error: immediate must be an integer in the range [0, 31]
csrrci x0, 43, %pcrel_hi(c) # CHECK: :[[@LINE]]:16: error: immediate must be an integer in the range [0, 31]
csrrsi t1, 999, %pcrel_lo(4) # CHECK: :[[@LINE]]:17: error: immediate must be an integer in the range [0, 31]
csrrci x0, 43, %pcrel_lo(d) # CHECK: :[[@LINE]]:16: error: immediate must be an integer in the range [0, 31]

## uimm12
csrrw a0, %lo(1), a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrs a0, %lo(a), a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrs a0, %hi(2), a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrc a0, %hi(b), a0 # CHECK: :[[@LINE]]:11: error: immediate must be an integer in the range [0, 4095]
csrrwi a0, %pcrel_hi(3), 0 # CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [0, 4095]
csrrsi a0, %pcrel_hi(c), a0 # CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [0, 4095]
csrrwi a0, %pcrel_lo(4), 0 # CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [0, 4095]
csrrsi a0, %pcrel_lo(d), a0 # CHECK: :[[@LINE]]:12: error: immediate must be an integer in the range [0, 4095]

## named csr in place of uimm12
csrrw a0, foos, a0 # CHECK: :[[@LINE]]:11: error: operand must be a valid system register name or an integer in the range [0, 4095]
csrrs a0, mstatusx, a0 # CHECK: :[[@LINE]]:11: error: operand must be a valid system register name or an integer in the range [0, 4095]
csrrs a0, xmstatus, a0 # CHECK: :[[@LINE]]:11: error: operand must be a valid system register name or an integer in the range [0, 4095]
csrrc a0, m12status, a0 # CHECK: :[[@LINE]]:11: error: operand must be a valid system register name or an integer in the range [0, 4095]
csrrwi a0, mstatus12, 0 # CHECK: :[[@LINE]]:12: error: operand must be a valid system register name or an integer in the range [0, 4095]
csrrsi a0, mhpm12counter, a0 # CHECK: :[[@LINE]]:12: error: operand must be a valid system register name or an integer in the range [0, 4095]
csrrwi a0, mhpmcounter32, 0 # CHECK: :[[@LINE]]:12: error: operand must be a valid system register name or an integer in the range [0, 4095]
csrrsi a0, A, a0 # CHECK: :[[@LINE]]:12: error: operand must be a valid system register name or an integer in the range [0, 4095]
