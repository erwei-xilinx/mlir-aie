//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2024 AMD Inc.

// RUN: aie-opt --verify-diagnostics --aie-dma-tasks-to-npu %s 

// This test ensures that the correct error is emitted if an illegal data layout transformation is specified
// in a `aie.dma_bd` operation inside the runtime sequence.

module {
  aie.device(npu1) {
    %tile_0_0 = aie.tile(0, 0)
    %tile_0_2 = aie.tile(0, 2)

    aiex.runtime_sequence(%arg0: memref<32xi8>) {
      %t1 = aiex.dma_configure_task(%tile_0_0, MM2S, 0) {
          // expected-error@+1 {{Stride 0 must be a positive integer}}
          aie.dma_bd(%arg0 : memref<32xi8>, 4, 32,
                     [<size=4, stride=0>]) {bd_id = 0 : i32}
          aie.end
      }
    }
  }
}

