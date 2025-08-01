// RUN: %clang_min_runtime -fsanitize=implicit-unsigned-integer-truncation %s -o %t && %run %t 2>&1 | FileCheck %s --check-prefixes=CHECK

#include <stdint.h>

int main() {
// CHECK-NOT: implicit-conversion

  // Negative tests. Even if they produce unexpected results, this sanitizer does not care.
  int8_t n0 = (~((uint32_t)(0))); // ~0 -> -1, but do not warn.
  uint8_t n2 = 128;
  uint8_t n3 = 255;
  // Bools do not count
  _Bool b0 = (~((uint32_t)(0)));
  _Bool b1 = 255;

  // Explicit and-ing of bits will silence it.
  uint8_t nc0 = ((~((uint32_t)(0))) & 255);

  // Positive tests.
  uint8_t t0 = (~((uint32_t)(0)));
// CHECK: implicit-conversion by 0x{{[[:xdigit:]]+$}}
// CHECK-NOT: implicit-conversion

  return 0;
}
