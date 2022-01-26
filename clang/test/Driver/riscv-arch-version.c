// RUN: %clang -target riscv32-unknown-elf -march=rv32e1p9  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-E1P9 %s
// RV32-E1P9: "-target-feature" "+e"

// RUN: %clang -target riscv32-unknown-elf -march=rv32im2p0  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-M2P0 %s
// RV32-M2P0: "-target-feature" "+m"
// RUN: %clang -target riscv32-unknown-elf -march=rv32ia2p0  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-A2P0 %s
    // RV32-A2P0: "-target-feature" "+a"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32if2p0  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-F2P0 %s
    // RV32-F2P0: "-target-feature" "+f"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32ifd2p0  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-D2P0 %s
    // RV32-D2P0: "-target-feature" "+f" "-target-feature" "+d"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32ic2p0  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-C2P0 %s
    // RV32-C2P0: "-target-feature" "+c"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32iv0p10 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-V0P10 %s
    // RV32-EXPERIMENTAL-V0P10: "-target-feature" "+experimental-v"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izba1p0 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBA1P0 %s
    // RV32-EXPERIMENTAL-ZBA1P0: "-target-feature" "+experimental-zba"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbb1p0 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBB1P0 %s
    // RV32-EXPERIMENTAL-ZBB1P0: "-target-feature" "+experimental-zbb"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbc1p0 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBC1P0 %s
    // RV32-EXPERIMENTAL-ZBC1P0: "-target-feature" "+experimental-zbc"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbe0p93 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBE0P93 %s
    // RV32-EXPERIMENTAL-ZBE0P93: "-target-feature" "+experimental-zbe"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbf0p93 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBF0P93 %s
    // RV32-EXPERIMENTAL-ZBF0P93: "-target-feature" "+experimental-zbf"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbm0p93 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBM0P93 %s
    // RV32-EXPERIMENTAL-ZBM0P93: "-target-feature" "+experimental-zbm"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbp0p93 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBP0P93 %s
    // RV32-EXPERIMENTAL-ZBP0P93: "-target-feature" "+experimental-zbp"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbr0p93 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBR0P93 %s
    // RV32-EXPERIMENTAL-ZBR0P93: "-target-feature" "+experimental-zbr"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbs1p0 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBS1P0 %s
    // RV32-EXPERIMENTAL-ZBS1P0: "-target-feature" "+experimental-zbs"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbt0p93 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBT0P93 %s
    // RV32-EXPERIMENTAL-ZBT0P93: "-target-feature" "+experimental-zbt"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izvlsseg0p10 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZVLSSEG0P10 %s
    // RV32-EXPERIMENTAL-ZVLSSEG0P10: "-target-feature" "+experimental-zvlsseg"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izfhmin0p1 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZFHMIN0P1 %s
    // RV32-EXPERIMENTAL-ZFHMIN0P1: "-target-feature" "+experimental-zfhmin"

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izfh0p1 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZFH0P1 %s
    // RV32-EXPERIMENTAL-ZFH0P1: "-target-feature" "+experimental-zfh"

    // Error Check Blow.

    // RUN: %clang -target riscv32-unknown-elf -march=rv32e2p0  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-E2P0 %s
    // RV32-E2P0: error: invalid arch name 'rv32e2p0'
    // RV32-E2P0: unsupported version number 2.0 for extension 'e'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32im2p1  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-M2P1 %s
    // RV32-M2P1: error: invalid arch name 'rv32im2p1'
    // RV32-M2P1: unsupported version number 2.1 for extension 'm'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32ia2p1  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-A2P1 %s
    // RV32-A2P1: error: invalid arch name 'rv32ia2p1'
    // RV32-A2P1: unsupported version number 2.1 for extension 'a'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32if2p1  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-F2P1 %s
    // RV32-F2P1: error: invalid arch name 'rv32if2p1'
    // RV32-F2P1: unsupported version number 2.1 for extension 'f'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32id2p1  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-D2P1 %s
    // RV32-D2P1: error: invalid arch name 'rv32id2p1'
    // RV32-D2P1: unsupported version number 2.1 for extension 'd'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32ic2p1  -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-C2P1 %s
    // RV32-C2P1: error: invalid arch name 'rv32ic2p1'
    // RV32-C2P1: unsupported version number 2.1 for extension 'c'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32iv0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-V0P7 %s
    // RV32-EXPERIMENTAL-V0P7: error: invalid arch name 'rv32iv0p7'
    // RV32-EXPERIMENTAL-V0P7: unsupported version number 0.7 for experimental extension 'v'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izba0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBA0P7 %s
    // RV32-EXPERIMENTAL-ZBA0P7: error: invalid arch name 'rv32izba0p7'
    // RV32-EXPERIMENTAL-ZBA0P7: unsupported version number 0.7 for experimental extension 'zba'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbb0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBB0P7 %s
    // RV32-EXPERIMENTAL-ZBB0P7: error: invalid arch name 'rv32izbb0p7'
    // RV32-EXPERIMENTAL-ZBB0P7: unsupported version number 0.7 for experimental extension 'zbb'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbc0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBC0P7 %s
    // RV32-EXPERIMENTAL-ZBC0P7: error: invalid arch name 'rv32izbc0p7'
    // RV32-EXPERIMENTAL-ZBC0P7: unsupported version number 0.7 for experimental extension 'zbc'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbe0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBE0P7 %s
    // RV32-EXPERIMENTAL-ZBE0P7: error: invalid arch name 'rv32izbe0p7'
    // RV32-EXPERIMENTAL-ZBE0P7: unsupported version number 0.7 for experimental extension 'zbe'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbf0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBF0P7 %s
    // RV32-EXPERIMENTAL-ZBF0P7: error: invalid arch name 'rv32izbf0p7'
    // RV32-EXPERIMENTAL-ZBF0P7: unsupported version number 0.7 for experimental extension 'zbf'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbm0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBM0P7 %s
    // RV32-EXPERIMENTAL-ZBM0P7: error: invalid arch name 'rv32izbm0p7'
    // RV32-EXPERIMENTAL-ZBM0P7: unsupported version number 0.7 for experimental extension 'zbm'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbp0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBP0P7 %s
    // RV32-EXPERIMENTAL-ZBP0P7: error: invalid arch name 'rv32izbp0p7'
    // RV32-EXPERIMENTAL-ZBP0P7: unsupported version number 0.7 for experimental extension 'zbp'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbr0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBR0P7 %s
    // RV32-EXPERIMENTAL-ZBR0P7: error: invalid arch name 'rv32izbr0p7'
    // RV32-EXPERIMENTAL-ZBR0P7: unsupported version number 0.7 for experimental extension 'zbr'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbs0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBS0P7 %s
    // RV32-EXPERIMENTAL-ZBS0P7: error: invalid arch name 'rv32izbs0p7'
    // RV32-EXPERIMENTAL-ZBS0P7: unsupported version number 0.7 for experimental extension 'zbs'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izbt0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZBT0P7 %s
    // RV32-EXPERIMENTAL-ZBT0P7: error: invalid arch name 'rv32izbt0p7'
    // RV32-EXPERIMENTAL-ZBT0P7: unsupported version number 0.7 for experimental extension 'zbt'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izvlsseg0p1 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZVLSSEG0P1 %s
    // RV32-EXPERIMENTAL-ZVLSSEG0P1: error: invalid arch name 'rv32izvlsseg0p1'
    // RV32-EXPERIMENTAL-ZVLSSEG0P1: unsupported version number 0.1 for experimental extension 'zvlsseg'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izfhmin0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZFHMIN0P7 %s
    // RV32-EXPERIMENTAL-ZFHMIN0P7: error: invalid arch name 'rv32izfhmin0p7'
    // RV32-EXPERIMENTAL-ZFHMIN0P7: unsupported version number 0.7 for experimental extension 'zfhmin'

    // RUN: %clang -target riscv32-unknown-elf -march=rv32izfh0p7 -menable-experimental-extensions -### %s -c 2>&1 | \
// RUN:   FileCheck -check-prefix=RV32-EXPERIMENTAL-ZFH0P7 %s
    // RV32-EXPERIMENTAL-ZFH0P7: error: invalid arch name 'rv32izfh0p7'
    // RV32-EXPERIMENTAL-ZFH0P7: unsupported version number 0.7 for experimental extension 'zfh'