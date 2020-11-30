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


pip install --no-cache-dir pybind11 pyangbind

cd $PACKAGE_DIR
package=scipy
version=$SCIPY_VERSION
src_host=https://github.com/scipy
src_repo=scipy

rm -rf scipy
git clone ${src_host}/${src_repo}.git
cd ${src_repo}
git checkout v$version -b v$version

export BLAS_LIB='armpl_lp64'
export BLAS_DIR=$ARMPL_DIR
#export BLAS_LDFLAGS="-lgfortran"
export BLAS_LDFLAGS=""

cp $PACKAGE_DIR/site.cfg .


#export CFLAGS="${BASE_CFLAGS} -O3"
#export LDFLAGS="${BASE_LDFLAGS}"
export CFLAGS=""
export LDFLAGS=""

echo $CFLAGS
echo $LDFLAGS

CC=cc python3 setup.py install --prefix=$VENV

cd $PACKAGE_DIR

python3 -c 'import scipy; scipy.show_config()'
