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

pip install --no-cache-dir keras_applications==1.0.8 --no-deps
pip install --no-cache-dir keras_preprocessing==1.1.0 --no-deps
MPI_DIR=$MPICH_DIR pip install h5py
pip install --no-cache-dir ck absl-py pycocotools

cd $PACKAGE_DIR
package=opencv
src_host=https://github.com/opencv
src_repo=opencv
num_cpus=64

rm -rf opencv
git clone ${src_host}/${src_repo}.git
cd $PACKAGE_DIR/$package
mkdir -p build
cd build
export CFLAGS="${BASE_CFLAGS} -O3"
export LDFLAGS="${BASE_LDFLAGS}"

py_inc=/opt/python/3.8.2.1/include/python3.8/

py_bin=$VENV/bin/python3
py_site_packages=$VENV/TF-2-gcc-env/lib64/python3.8/site-packages/
install_dir=$VENV

cmake -DPYTHON3_EXECUTABLE=$py_bin -DCMAKE_C_COMPILER=CC -DBUILD_opencv_python2=NO -DBUILD_opencv_python3=YES -DPYTHON3_INCLUDE_DIR=$py_inc -DPYTHON3_PACKAGES_PATH=$py_site_packages \
  -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$install_dir ..

make -j $num_cpus 
make install

cd $PACKAGE_DIR
$VENV/bin/python3 -c 'import cv2 as cv; print(cv.__version__)'
