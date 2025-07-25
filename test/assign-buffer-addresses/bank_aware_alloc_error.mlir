//===- bank_aware_alloc_error.mlir -----------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2024, Advanced Micro Devices, Inc.
//
//===----------------------------------------------------------------------===//

// RUN: not aie-opt --aie-assign-buffer-addresses="alloc-scheme=bank-aware" %s 2>&1 | FileCheck %s
// CHECK:   warning: Failed to allocate buffer: "b" with size: 32768 bytes.
// CHECK:   %1 = aie.buffer(%0) { sym_name = "b" } : memref<8192xi32>
// CHECK: note: see current operation: %b = aie.buffer(%tile_3_3) {sym_name = "b"} : memref<8192xi32>
// CHECK: warning: Not all requested buffers fit in the available memory.
// CHECK: note: see current operation: %tile_3_3 = aie.tile(3, 3)
// CHECK: note: Current configuration of buffers in bank(s) : MemoryMap:
// CHECK:                 (stack)         : 0x0-0x3FF     (1024 bytes)
// CHECK:         bank : 0        0x0-0x1FFF
// CHECK:         bank : 1        0x2000-0x3FFF
// CHECK:         bank : 2        0x4000-0x5FFF
// CHECK:         bank : 3        0x6000-0x7FFF
// CHECK: error: 'aie.tile' op Bank-aware allocation failed.

module @test {
  aie.device(xcvc1902) {
    %0 = aie.tile(3, 3)
    %b1 = aie.buffer(%0) { sym_name = "a" } : memref<16xi8>
    %1 = aie.buffer(%0) { sym_name = "b" } : memref<8192xi32>
    %b2 = aie.buffer(%0) { sym_name = "c" } : memref<16xi16>
    %3 = aie.tile(4, 4)
    %4 = aie.buffer(%3) : memref<500xi32>
    aie.core(%0) {
      aie.end
    }
    aie.core(%3) {
      aie.end
    }
  }
}
