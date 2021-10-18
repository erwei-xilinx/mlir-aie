//===- round_trip.mlir -----------------------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2021 Xilinx Inc.
//
//===----------------------------------------------------------------------===//

// RUN: aie-opt --aie-create-pathfinder-flows --aie-find-flows %s |& FileCheck %s
// CHECK: %[[T00:.*]] = AIE.tile(0, 0)
// CHECK: %[[T03:.*]] = AIE.tile(0, 3)
// CHECK: %[[T20:.*]] = AIE.tile(2, 0)
// CHECK: %[[T60:.*]] = AIE.tile(6, 0)
// CHECK: %[[T80:.*]] = AIE.tile(8, 0)
// CHECK: %[[T83:.*]] = AIE.tile(8, 3)
//
// CHECK: AIE.switchbox(%[[T00]])  {
// CHECK-NEXT: AIE.connect<East : 0, North : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T03]])  {
// CHECK-NEXT: AIE.connect<South : 0, East : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T83]])  {
// CHECK-NEXT: AIE.connect<West : 0, South : 0>
// CHECK-NEXT: }
// CHECK: AIE.flow(%[[T20]], DMA : 0, %[[T60]], DMA : 0)

module {
%t00 = AIE.tile(0, 0)
%t03 = AIE.tile(0, 3)
%t20 = AIE.tile(2, 0)
%t60 = AIE.tile(6, 0)
%t80 = AIE.tile(8, 0)
%t83 = AIE.tile(8, 3)

%a01 = AIE.flowAttribute() {
    AIE.boundingBox("keep-in", %t00, [1][4])
    AIE.boundingBox("keep-in", %t03, [9][1])
    AIE.boundingBox("keep-in", %t80, [1][4])
    AIE.boundingBox("keep-in", %t00, [3][1])
    AIE.boundingBox("keep-in", %t60, [3][1])
}
AIE.flowRegion(%a01) {
    AIE.flow(%t20, DMA : 0, %t60, DMA : 0)
}

}