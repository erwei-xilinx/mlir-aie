//===- routing_congestion_err_test.mlir ------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2021 Xilinx Inc.
//
//===----------------------------------------------------------------------===//

// RUN: aie-opt --aie-create-pathfinder-flows --aie-find-flows %s |& FileCheck %s
// CHECK: error: Unable to find a legal routing

module {
%t01 = AIE.tile(0, 1)
%t11 = AIE.tile(1, 1)
%t21 = AIE.tile(2, 1)
%t31 = AIE.tile(3, 1)
%t41 = AIE.tile(4, 1)
%t51 = AIE.tile(5, 1)
%t61 = AIE.tile(6, 1)
%t71 = AIE.tile(7, 1)
%t81 = AIE.tile(8, 1)

%a01 = AIE.flowAttribute() {
    AIE.boundingBox("keep-in", %t01, [9][1])
}
AIE.flowRegion(%a01) {
    AIE.flow(%t01, DMA : 0, %t81, DMA : 0)
    AIE.flow(%t11, DMA : 0, %t71, DMA : 0)
    AIE.flow(%t21, DMA : 0, %t61, DMA : 0)  
    AIE.flow(%t31, DMA : 0, %t51, DMA : 0)  
    AIE.flow(%t41, DMA : 0, %t81, DMA : 1)
}

}