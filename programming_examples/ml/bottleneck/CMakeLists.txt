# This file is licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
# Copyright (C) 2024, Advanced Micro Devices, Inc.

# parameters
# -DOpenCV_DIR: Path to OpenCV install
# -DXRT_INC_DIR: Full path to src/runtime_src/core/include in XRT cloned repo
# -DXRT_LIB_DIR: Path to xrt_coreutil.lib
# -DTARGET_NAME: Target name to be built

# cmake needs this line
cmake_minimum_required(VERSION 3.1)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

find_program(WSL NAMES powershell.exe)

if (NOT WSL)
    set(OpenCV_DIR /usr/include/opencv4 CACHE STRING "Path to OpenCV install")
    set(XRT_INC_DIR /opt/xilinx/xrt/include CACHE STRING "Path to XRT cloned repo")
    set(XRT_LIB_DIR /opt/xilinx/xrt/lib CACHE STRING "Path to xrt_coreutil.lib")
else()
    set(OpenCV_DIR C:/Technical/thirdParty/opencv/build CACHE STRING "Path to OpenCV install")
    set(XRT_INC_DIR C:/Technical/XRT/src/runtime_src/core/include CACHE STRING "Path to XRT cloned repo")
    set(XRT_LIB_DIR C:/Technical/xrtNPUfromDLL CACHE STRING "Path to xrt_coreutil.lib")
endif ()

set(EDGEDETECT_WIDTH 1920 CACHE STRING "image width")
set(EDGEDETECT_HEIGHT 1080 CACHE STRING "image height")

set(TARGET_NAME test CACHE STRING "Target to be built")

SET (ProjectName ${TARGET_NAME})
SET (currentTarget ${TARGET_NAME})

if ( WSL )
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR})
    add_compile_options(/Zc:__cplusplus)
endif ()

project(${ProjectName})

# Find packages
find_package(OpenCV REQUIRED)
message("opencv library paht: ${OpenCV_LIB_PATH}")
message("opencv libs: ${OpenCV_LIBS}")


add_executable(${currentTarget}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../utils/OpenCVUtils.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../utils/xrtUtils.cpp
    test.cpp
)

target_compile_definitions(${currentTarget} PUBLIC
        EDGEDETECT_WIDTH=${EDGEDETECT_WIDTH}
        EDGEDETECT_HEIGHT=${EDGEDETECT_HEIGHT}
        DISABLE_ABI_CHECK=1
        )

target_include_directories (${currentTarget} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../utils
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../../runtime_lib
    ${XRT_INC_DIR}
    ${OpenCV_INCLUDE_DIRS}
)

target_link_directories(${currentTarget} PUBLIC
    ${XRT_LIB_DIR}
    ${OpenCV_LIB_PATH}
)


target_link_libraries(${currentTarget} PUBLIC
    xrt_coreutil
    ${OpenCV_LIBS}
)
