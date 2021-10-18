//===- attribute_inheritance.mlir ------------------------------*- MLIR -*-===//
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
// CHECK: %[[T11:.*]] = AIE.tile(1, 1)
// CHECK: %[[T20:.*]] = AIE.tile(2, 0)
// CHECK: %[[T23:.*]] = AIE.tile(2, 3)
// CHECK: %[[T30:.*]] = AIE.tile(3, 0)
// CHECK: %[[T43:.*]] = AIE.tile(4, 3)
// CHECK: %[[T51:.*]] = AIE.tile(5, 1)
// CHECK: %[[T60:.*]] = AIE.tile(6, 0)
// CHECK: %[[T63:.*]] = AIE.tile(6, 3)
// CHECK: %[[T70:.*]] = AIE.tile(7, 0)
// CHECK: %[[T81:.*]] = AIE.tile(8, 1)
// CHECK: %[[T83:.*]] = AIE.tile(8, 3)
//
// CHECK: AIE.switchbox(%[[T00]])  {
// CHECK-NEXT: AIE.connect<North : 0, East : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T20]])  {
// CHECK-NEXT: AIE.connect<West : 0, North : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T23]])  {
// CHECK-NEXT: AIE.connect<South : 0, East : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T43]])  {
// CHECK-NEXT: AIE.connect<West : 0, South : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T60]])  {
// CHECK-NEXT: AIE.connect<West : 0, North : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T63]])  {
// CHECK-NEXT: AIE.connect<South : 0, East : 0>
// CHECK-NEXT: }
// CHECK: AIE.switchbox(%[[T83]])  {
// CHECK-NEXT: AIE.connect<West : 0, South : 0>
// CHECK-NEXT: }
// CHECK: AIE.flow(%[[T03]], DMA : 0, %[[T81]], DMA : 0)

module {
%t00 = AIE.tile(0, 0)
%t03 = AIE.tile(0, 3)
%t11 = AIE.tile(1, 1)
%t20 = AIE.tile(2, 0)
%t23 = AIE.tile(2, 3)
%t30 = AIE.tile(3, 0)
%t43 = AIE.tile(4, 3)
%t51 = AIE.tile(5, 1)
%t60 = AIE.tile(6, 0)
%t63 = AIE.tile(6, 3)
%t70 = AIE.tile(7, 0)
%t81 = AIE.tile(8, 1)
%t83 = AIE.tile(8, 3)

%a01 = AIE.flowAttribute() {
    AIE.boundingBox("keep-in", %t00, [9][4])
}
%a02 = AIE.flowAttribute(%a01) {
    AIE.boundingBox("keep-out", %t11, [1][3])
}
%a03 = AIE.flowAttribute(%a02) {
    AIE.boundingBox("keep-out", %t30, [1][3])
}
%a04 = AIE.flowAttribute(%a03) {
    AIE.boundingBox("keep-out", %t51, [1][3])
}
%a05 = AIE.flowAttribute(%a04) {
    AIE.boundingBox("keep-out", %t70, [1][3])
}
AIE.flowRegion(%a05) {
    AIE.flow(%t03, DMA : 0, %t81, DMA : 0)
}

}