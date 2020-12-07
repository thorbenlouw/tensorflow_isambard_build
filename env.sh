#!/bin/bash

set -u

module swap PrgEnv-cray/6.0.6 PrgEnv-gnu/6.0.7
module load cray-python/3.8.2.1
module load cray-hdf5
export ARMPL_DIR=/opt/allinea/20.0.0.0/armpl-20.0.0_ThunderX2CN99_SUSE-12_gcc_9.2.0_aarch64-linux/
export LD_LIBRARY_PATH=$PACKAGE_DIR/oneDNN/install/lib:$LD_LIBRRAY_PATH
export LD_LIBRARY_PATH=$ARMPL_DIR/lib/:$LD_LIBRARY_PATH
export CRAYPE_LINK_TYPE=dynamic

export CC=cc
export CXX=CC

export JAVA_HOME=~/installations/jdk1.8.0_251/

export PACKAGE_DIR=$PWD

export NP_MAKE=64
export cpu="thunderx2t99"
export CPU="thunderx2t99"
export BASE_CFLAGS="-mcpu=thunderx2t99"
export BASE_LDFLAGS="-L$ARMPL_DIR/lib -lamath -lm"


export PY_VERSION=3.8.2.1
export ARMPL_VERSION=20.0

export TF_VERSION_ID=2
export tf_version=2
export TF_VERSION="v2.3.0"

export bazel_version=3.4.0
export PATH=$PACKAGE_DIR/bazel/output:$PATH
export ONEDNN_VERSION="v1.7"
export onednn="armpl"

export NUMPY_VERSION=1.17.5
#export NUMPY_VERSION=1.19.4
export SCIPY_VERSION=1.4.1

cd $PACKAGE_DIR
echo "[openblas]" > site.cfg
echo "libraries = armpl_lp64" >> site.cfg
echo "library_dirs = $ARMPL_DIR/lib" >> site.cfg
echo "include_dirs = $ARMPL_DIR/include" >> site.cfg
echo "runtime_library_dirs = $ARMPL_DIR/lib" >> site.cfg

export VENV=$PACKAGE_DIR/TF-$tf_version-gcc-env
virtualenv --python=python3.8 $VENV
source $VENV/bin/activate
export PATH="$VENV/bin:$PATH"

# Update patches
sed -i 's~/opt/onednn/release/~'"${PACKAGE_DIR}"'/~' patches/tf2_onednn_decoupling.patch
sed -i 's~/opt/armpl/armpl_20.2.1_gcc-9.3~/opt/allinea/20.0.0.0/armpl-20.0.0_ThunderX2CN99_SUSE-12_arm-linux-compiler_20.0_aarch64-linux~' patches/tf2-armpl.patch
