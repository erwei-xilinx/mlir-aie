//===- tetris.mlir ---------------------------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2021 Xilinx Inc.
//
//===----------------------------------------------------------------------===//

// RUN: aie-opt --aie-create-pathfinder-flows --aie-find-flows %s |& FileCheck %s
// CHECK: %[[T01:.*]] = AIE.tile(0, 1)
// CHECK: %[[T02:.*]] = AIE.tile(0, 2)
// CHECK: %[[T21:.*]] = AIE.tile(2, 1)
// CHECK: %[[T22:.*]] = AIE.tile(2, 2)
// CHECK: %[[T41:.*]] = AIE.tile(4, 1)
// CHECK: %[[T42:.*]] = AIE.tile(4, 2)
// CHECK: %[[T61:.*]] = AIE.tile(6, 1)
// CHECK: %[[T62:.*]] = AIE.tile(6, 2)
// CHECK: %[[T81:.*]] = AIE.tile(8, 1)
// CHECK: %[[T82:.*]] = AIE.tile(8, 2)
//
// CHECK: AIE.flow(%[[T01]], DMA : 0, %[[T22]], DMA : 0)
// CHECK: AIE.flow(%[[T21]], DMA : 0, %[[T42]], DMA : 0)
// CHECK: AIE.flow(%[[T41]], DMA : 0, %[[T62]], DMA : 0)
// CHECK: AIE.flow(%[[T61]], DMA : 0, %[[T82]], DMA : 0)

module {
%t01 = AIE.tile(0, 1)
%t02 = AIE.tile(0, 2)
%t21 = AIE.tile(2, 1)
%t22 = AIE.tile(2, 2)
%t41 = AIE.tile(4, 1)
%t42 = AIE.tile(4, 2)
%t61 = AIE.tile(6, 1)
%t62 = AIE.tile(6, 2)
%t81 = AIE.tile(8, 1)
%t82 = AIE.tile(8, 2)

%a01 = AIE.flowAttribute() {
    AIE.boundingBox("keep-in", %t01, [3][2])
    AIE.boundingBox("keep-out", %t02, [1][1])
    AIE.boundingBox("keep-out", %t21, [1][1])
}
AIE.flowRegion(%a01) {
    AIE.flow(%t01, DMA : 0, %t22, DMA : 0)
}
%a02 = AIE.flowAttribute() {
    AIE.boundingBox("keep-in", %t21, [3][2])
    AIE.boundingBox("keep-out", %t22, [1][1])
    AIE.boundingBox("keep-out", %t41, [1][1])
}
AIE.flowRegion(%a02) {
    AIE.flow(%t21, DMA : 0, %t42, DMA : 0)
}
%a03 = AIE.flowAttribute() {
    AIE.boundingBox("keep-in", %t41, [3][2])
    AIE.boundingBox("keep-out", %t42, [1][1])
    AIE.boundingBox("keep-out", %t61, [1][1])
}
AIE.flowRegion(%a03) {
    AIE.flow(%t41, DMA : 0, %t62, DMA : 0)
}
%a04 = AIE.flowAttribute() {
    AIE.boundingBox("keep-in", %t61, [3][2])
    AIE.boundingBox("keep-out", %t62, [1][1])
    AIE.boundingBox("keep-out", %t81, [1][1])
}
AIE.flowRegion(%a04) {
    AIE.flow(%t61, DMA : 0, %t82, DMA : 0)
}

}