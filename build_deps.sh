#!/bin/bash

source clean.sh
source env.sh
source $PACKAGE_DIR/build_onednn.sh
source $PACKAGE_DIR/build_numpy.sh
source $PACKAGE_DIR/build_opencv.sh
source $PACKAGE_DIR/build_scipy.sh
source $PACKAGE_DIR/build_bazel.sh
source $PACKAGE_DIR/build_tensorflow.sh
