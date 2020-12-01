#!/usr/bin/env bash

# *******************************************************************************
# Copyright 2020 Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# *******************************************************************************

set -u


cd $PACKAGE_DIR
rm -rf oneDNN
package=onednn
version=$ONEDNN_VERSION
tf_id=$TF_VERSION_ID
src_host=https://github.com/oneapi-src
src_repo=oneDNN

# Clone oneDNN
echo "oneDNN VERSION" $version
git clone ${src_host}/${src_repo}.git
cd ${src_repo}
git checkout $version
mkdir -p build install

# Apply patch to add AArch64 flags, and OpenBLAS lib
# This patch is for version 1.4+
patch -p1 < $PACKAGE_DIR/patches/oneDNN.patch

cmake_options="-DCMAKE_BUILD_TYPE=release \
  -DDNNL_CPU_RUNTIME=OMP \
  -DCMAKE_INSTALL_PREFIX=$PACKAGE_DIR/$src_repo/install"

cxx_flags="${BASE_CFLAGS} -O3"
blas_flags=""
blas_libs=""

blas_flags="-DUSE_CBLAS -I${ARMPL_DIR}/include"
blas_libs="-L${ARMPL_DIR}/lib -larmpl_lp64_mp -lgfortran -lamath -lm"

echo "CMake options: $cmake_options"
echo "Compiler flags: $cxx_flags"
echo "BLAS flags: $blas_libs $blas_flags"

cd build

APPEND_SHARED_LIBS="$blas_libs" CXXFLAGS="$cxx_flags $blas_flags" \
  cmake ../. $cmake_options

make -j $NP_MAKE VERBOSE=1
make install

cd $PACKAGE_DIR
