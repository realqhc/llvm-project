# RUN: llvm-mc %s -triple=riscv32  -mattr=+zifencei -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc %s -triple riscv64 -mattr=+zifencei -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s

# CHECK-ASM-AND-OBJ: fence.i
# CHECK-ASM: encoding: [0x0f,0x10,0x00,0x00]
fence.i
