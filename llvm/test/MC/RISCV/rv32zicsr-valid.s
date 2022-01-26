# RUN: llvm-mc %s -triple=riscv32 -mattr=+zicsr -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc %s -triple riscv64 -mattr=+zicsr -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s

# CHECK-ASM-AND-OBJ: csrrw t0, 4095, t1
# CHECK-ASM: encoding: [0xf3,0x12,0xf3,0xff]
csrrw t0, 0xfff, t1
# CHECK-ASM-AND-OBJ: csrrw s0, 4095, s1
# CHECK-ASM: encoding: [0x73,0x94,0xf4,0xff]
csrrw s0, ~(-4096), s1
# CHECK-ASM-AND-OBJ: csrrw s0, fflags, s1
# CHECK-ASM: encoding: [0x73,0x94,0x14,0x00]
csrrw s0, !0, s1
# CHECK-ASM-AND-OBJ: csrrs s0, cycle, zero
# CHECK-ASM: encoding: [0x73,0x24,0x00,0xc0]
csrrs s0, 0xc00, x0
# CHECK-ASM-AND-OBJ: csrrs s3, fflags, s5
# CHECK-ASM: encoding: [0xf3,0xa9,0x1a,0x00]
csrrs s3, 0x001, s5
# CHECK-ASM-AND-OBJ: csrrc sp, ustatus, ra
# CHECK-ASM: encoding: [0x73,0xb1,0x00,0x00]
csrrc sp, 0x000, ra
# CHECK-ASM-AND-OBJ: csrrwi a5, ustatus, 0
# CHECK-ASM: encoding: [0xf3,0x57,0x00,0x00]
csrrwi a5, 0x000, 0
# CHECK-ASM-AND-OBJ: csrrsi t2, 4095, 31
# CHECK-ASM: encoding: [0xf3,0xe3,0xff,0xff]
csrrsi t2, 0xfff, 31
# CHECK-ASM-AND-OBJ: csrrci t1, sscratch, 5
# CHECK-ASM: encoding: [0x73,0xf3,0x02,0x14]
csrrci t1, 0x140, 5
