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




pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir "setuptools>=41.0.0" six mock wheel cython




package=numpy
version=$NUMPY_VERSION
src_host=https://github.com/numpy
src_repo=numpy

rm -rf numpy
git clone ${src_host}/${src_repo}.git
cd ${src_repo}
git checkout v$version -b v$version

# Arm Performance Libaries are used by default unless "openblas" is selected
# for the oneDNN build.
export BLAS_LIB='armpl_lp64'
export BLAS_DIR=$ARMPL_DIR
export BLAS_LDFLAGS="-lgfortran"

cp $PACKAGE_DIR/site.cfg .

export CFLAGS="${BASE_CFLAGS} -O3"
export LDFLAGS="${BASE_LDFLAGS}"

CC=cc CXX=CC FC=ftn python3 setup.py install --prefix=$VENV

cd $PACKAGE_DIR
python3 -c 'import numpy; numpy.show_config()'
