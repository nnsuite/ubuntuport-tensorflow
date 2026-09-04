#
# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(TARGET xnnpack OR xnnpack_POPULATED)
  return()
endif()

include(OverridableFetchContent)

OverridableFetchContent_Declare(
  cpuinfo-xnnpack
  URL "${TENSORFLOW_SOURCE_DIR}/externals/cpuinfo-xnnpack.tar.gz"
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/cpuinfo-xnnpack"
)
OverridableFetchContent_GetProperties(cpuinfo-xnnpack)
if(NOT cpuinfo-xnnpack_POPULATED)
  OverridableFetchContent_Populate(cpuinfo-xnnpack)
endif()
set(CPUINFO_SOURCE_DIR "${CMAKE_BINARY_DIR}/cpuinfo-xnnpack")

OverridableFetchContent_Declare(
  fp16
  URL "${TENSORFLOW_SOURCE_DIR}/externals/fp16.tar.gz"
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/fp16"
)
OverridableFetchContent_GetProperties(fp16)
if(NOT fp16_POPULATED)
  OverridableFetchContent_Populate(fp16)
endif()
set(FP16_SOURCE_DIR "${CMAKE_BINARY_DIR}/fp16")

OverridableFetchContent_Declare(
  psimd
  URL "${TENSORFLOW_SOURCE_DIR}/externals/psimd.tar.gz"
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/psimd"
)
OverridableFetchContent_GetProperties(psimd)
if(NOT psimd_POPULATED)
  OverridableFetchContent_Populate(psimd)
endif()
set(PSIMD_SOURCE_DIR "${CMAKE_BINARY_DIR}/psimd")

OverridableFetchContent_Declare(
  fxdiv
  URL "${TENSORFLOW_SOURCE_DIR}/externals/fxdiv.tar.gz"
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/fxdiv"
)
OverridableFetchContent_GetProperties(fxdiv)
if(NOT fxdiv_POPULATED)
  OverridableFetchContent_Populate(fxdiv)
endif()
set(FXDIV_SOURCE_DIR "${CMAKE_BINARY_DIR}/fxdiv")

OverridableFetchContent_Declare(
  pthreadpool
  URL "${TENSORFLOW_SOURCE_DIR}/externals/pthreadpool.tar.gz"
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/pthreadpool-xnnpack"
)
OverridableFetchContent_GetProperties(pthreadpool)
if(NOT pthreadpool_POPULATED)
  OverridableFetchContent_Populate(pthreadpool)
endif()
set(PTHREADPOOL_SOURCE_DIR "${CMAKE_BINARY_DIR}/pthreadpool-xnnpack")

OverridableFetchContent_Declare(
  xnnpack
  URL "${TENSORFLOW_SOURCE_DIR}/externals/xnnpack.tar.gz"
  # GIT_REPOSITORY https://github.com/google/XNNPACK
  # # Sync with tensorflow/workspace2.bzl
  # GIT_TAG bbbaa7352a3ea729987d3e654d37be93e8009691
  # GIT_PROGRESS TRUE
  PREFIX "${CMAKE_BINARY_DIR}"
  SOURCE_DIR "${CMAKE_BINARY_DIR}/xnnpack"
)
OverridableFetchContent_GetProperties(xnnpack)
if(NOT xnnpack_POPULATED)
  OverridableFetchContent_Populate(xnnpack)
endif()

# May consider setting XNNPACK_USE_SYSTEM_LIBS if we want to control all
# dependencies by TFLite.
set(XNNPACK_BUILD_TESTS OFF CACHE BOOL "Disable XNNPACK test.")
set(XNNPACK_BUILD_BENCHMARKS OFF CACHE BOOL "Disable XNNPACK benchmarks.")

# The following line adds project of PTHREADPOOL, FP16 and XNNPACK which are
# needed to compile XNNPACK delegate of TFLite.
# Note, we introduce an intermediate subdirectory, see ${TFLITE_SOURCE_DIR}/tools/cmake/modules/xnnpack/CMakeLists.txt
# for details.
add_subdirectory(${TFLITE_SOURCE_DIR}/tools/cmake/modules/xnnpack)

include_directories(
  AFTER
   "${PTHREADPOOL_SOURCE_DIR}/include"
   "${FP16_SOURCE_DIR}/include"
   "${XNNPACK_SOURCE_DIR}/include"
   "${CPUINFO-XNNPACK_SOURCE_DIR}/"
)
