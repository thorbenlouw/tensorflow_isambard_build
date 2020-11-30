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


set -u pipefail

cd $PACKAGE_DIR
package=tensorflow
version=$TF_VERSION
tf_id=$TF_VERSION_ID
src_host=https://github.com/tensorflow
src_repo=tensorflow

# Clone tensorflow and benchmarks
rm -rf ${src_repo}
git clone ${src_host}/${src_repo}.git
cd ${src_repo}
git checkout $version -b $version


if [[ $tf_id == '2' ]]; then
   echo "Building tensorflow 2"
   git checkout 00dbf072dbe69521ae2170a9fac4052187d187d6 -- tensorflow/core/kernels/mkl_matmul_op.cc
fi

# Apply path to allow use of newer Bazel build.
if [[ $tf_id == '1' ]]; then
   echo "Building tensorflow 1"
   if [[ $ONEDNN_BUILD ]]; then
      patch -p1 < $PACKAGE_DIR/patches/tf_dnnl_decoupling.patch
   fi
   patch -p1 < ../tensorflow.patch
elif [[ $tf_id == '2' ]]; then
   echo "Building tensorflow 2"
   patch -p1 < $PACKAGE_DIR/patches/tf2_onednn_decoupling.patch
   patch -p1 < $PACKAGE_DIR/patches/oneDNN-header.patch
   patch -p1 < $PACKAGE_DIR/patches/tensorflow2.patch
else
   echo 'Invalid TensorFlow version when applying patches to the TensorFlow repository'
   exit 1
fi

# Env vars used to avoid interactive elements of the build.
export HOST_C_COMPILER=(which cc)
export HOST_CXX_COMPILER=(which CC)
export PYTHON_BIN_PATH=(which python)
export USE_DEFAULT_PYTHON_LIB_PATH=1
export CC_OPT_FLAGS=""
export TF_ENABLE_XLA=0
export TF_NEED_GCP=0
export TF_NEED_S3=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_CUDA=0
export TF_DOWNLOAD_CLANG=0
export TF_NEED_MPI=0
export TF_SET_ANDROID_WORKSPACE=0
export TF_NEED_ROCM=0

./configure

extra_args=""
if [[ $NP_MAKE ]]; then extra_args="$extra_args --jobs=$NP_MAKE"; fi

if [[ $tf_id == '1' ]]; then
    bazel build $extra_args \
      --define=build_with_mkl_dnn_only=true --define=build_with_mkl=true \
      --define=tensorflow_mkldnn_contraction_kernel=1 \
      --copt="-mtune=${CPU}" --copt="-march=armv8-a" --copt="-moutline-atomics" \
      --cxxopt="-mtune=${CPU}" --cxxopt="-march=armv8-a" --cxxopt="-moutline-atomics" \
      --linkopt="-L$ARMPL_DIR/lib -lamath -lm" --linkopt="-fopenmp" \
      --config=noaws --config=v$tf_id  --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
      //tensorflow/tools/pip_package:build_pip_package
elif [[ $tf_id == '2' ]]; then
    bazel build $extra_args \
       --define=build_with_mkl_dnn_v1_only=true --define=build_with_mkl=true \
       --define=tensorflow_mkldnn_contraction_kernel=1 \
       --copt="-mcpu=${CPU}" --copt="-flax-vector-conversions" --copt="-moutline-atomics" --copt="-O3" \
       --cxxopt="-mcpu=${CPU}" --cxxopt="-flax-vector-conversions" --cxxopt="-moutline-atomics" --cxxopt="-O3" \
       --linkopt="-L$ARMPL_DIR/lib -lamath -lm" --linkopt="-fopenmp" \
       --config=noaws --config=v$tf_id  --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
       //tensorflow/tools/pip_package:build_pip_package
else
    echo 'Invalid TensorFlow version when building tensorflow'
    exit 1
fi
./bazel-bin/tensorflow/tools/pip_package/build_pip_package ./wheel-TF$TF_VERSION-py$PY_VERSION-$CC

pip install $(ls -tr wheel-TF$TF_VERSION-py$PY_VERSION-$CC/*.whl | tail)

# Check the installation was sucessfull
cd $PACKAGE_DIR

python -c 'import tensorflow; print(tensorflow.__version__)'
