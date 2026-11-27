#!/bin/bash

set -euxo pipefail

sed -i "s:\${BUILD_PREFIX}:${BUILD_PREFIX}:" protobuf.BUILD

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Compiler activation may set tool basenames only. bazel-toolchain embeds them as
# paths under //bazel_toolchain, so relative names become missing sandbox files.
if [[ "${target_platform}" == linux-* ]]; then
    export GCC="$(command -v "${GCC}")"
    export LD="$(command -v "${LD}")"
    export NM="$(command -v "${NM}")"
    export STRIP="$(command -v "${STRIP}")"
fi

source gen-bazel-toolchain

pushd compiler
chmod +x ../bazel
../bazel build --logging=6 --subcommands --verbose_failures --crosstool_top=//bazel_toolchain:toolchain --cpu ${TARGET_CPU} grpc_java_plugin
popd
mkdir -p $PREFIX/bin
cp bazel-bin/compiler/grpc_java_plugin $PREFIX/bin
