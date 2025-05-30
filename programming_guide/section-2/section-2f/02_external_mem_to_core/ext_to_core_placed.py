#
# This file is licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
# (c) Copyright 2024 AMD Inc.
import sys
import numpy as np
from aie.dialects.aie import *
from aie.dialects.aiex import *
from aie.helpers.dialects.ext.scf import _for as range_
from aie.extras.context import mlir_mod_ctx

if len(sys.argv) > 1:
    if sys.argv[1] == "npu":
        dev = AIEDevice.npu1_1col
    elif sys.argv[1] == "npu2":
        dev = AIEDevice.npu2_1col
    else:
        raise ValueError("[ERROR] Device name {} is unknown".format(sys.argv[1]))


def external_mem_to_core():
    with mlir_mod_ctx() as ctx:

        @device(dev)
        def device_body():
            tile_ty = np.ndarray[(24,), np.dtype[np.int32]]

            # Tile declarations
            ShimTile = tile(0, 0)
            ComputeTile2 = tile(0, 2)

            # AIE-array data movement with object fifos
            # Input
            of_in = object_fifo("in", ShimTile, ComputeTile2, 2, tile_ty)

            # Output
            of_out = object_fifo("out", ComputeTile2, ShimTile, 2, tile_ty)

            # Set up compute tiles

            # Compute tile 2
            @core(ComputeTile2)
            def core_body():
                # Effective while(1)
                for _ in range_(2):
                    elem_in = of_in.acquire(ObjectFifoPort.Consume, 1)
                    elem_out = of_out.acquire(ObjectFifoPort.Produce, 1)
                    for i in range_(24):
                        elem_out[i] = elem_in[i] + 1
                    of_in.release(ObjectFifoPort.Consume, 1)
                    of_out.release(ObjectFifoPort.Produce, 1)

            # To/from AIE-array data movement

            data_ty = np.ndarray[(48,), np.dtype[np.int32]]

            @runtime_sequence(data_ty, data_ty, data_ty)
            def sequence(inTensor, notUsed, outTensor):
                npu_dma_memcpy_nd(
                    metadata=of_in, bd_id=1, mem=inTensor, sizes=[1, 1, 1, 48]
                )
                npu_dma_memcpy_nd(
                    metadata=of_out, bd_id=0, mem=outTensor, sizes=[1, 1, 1, 48]
                )
                # of_out will only complete after of_in completes, so we can just wait on of_out instead of both
                dma_wait(of_out)

    res = ctx.module.operation.verify()
    if res == True:
        print(ctx.module)
    else:
        print(res)


external_mem_to_core()
