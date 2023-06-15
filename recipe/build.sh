#!/bin/bash

set -euxo pipefail

sed -i "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" protobuf.BUILD

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

source gen-bazel-toolchain

pushd compiler
chmod +x ../bazel
../bazel build --logging=6 --subcommands --verbose_failures --crosstool_top=//bazel_toolchain:toolchain --cpu ${TARGET_CPU} grpc_java_plugin
popd
mkdir -p $PREFIX/bin
cp bazel-bin/compiler/grpc_java_plugin $PREFIX/bin
