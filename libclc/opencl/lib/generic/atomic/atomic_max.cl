//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <clc/opencl/atomic/atomic_max.h>

#define IMPL(TYPE, AS, OP)                                                     \
  _CLC_OVERLOAD _CLC_DEF TYPE atomic_max(volatile AS TYPE *p, TYPE val) {      \
    return __sync_fetch_and_##OP(p, val);                                      \
  }

IMPL(int, global, max)
IMPL(unsigned int, global, umax)
IMPL(int, local, max)
IMPL(unsigned int, local, umax)
#undef IMPL
