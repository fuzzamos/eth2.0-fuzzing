#!/bin/bash

curl https://sh.rustup.rs -sSf | sh -s -- -y
rustup default nightly
source $HOME/.cargo/env

cd /eth2

export CC=clang-6.0
export CXX=clang++-6.0

# Set env variables for using Golang
export GOROOT=`realpath go`
export GOPATH=$GOROOT/packages
mkdir $GOPATH
export PATH=$GOROOT/bin:$PATH
export PATH=$GOROOT/packages/bin:$PATH

# Get custom go-fuzz
mkdir -p $GOPATH/src/github.com/dvyukov
cd $GOPATH/src/github.com/dvyukov
git clone https://github.com/guidovranken/go-fuzz.git
cd go-fuzz
git checkout libfuzzer-extensions

mkdir -p $GOPATH/src/github.com/protolambda

cd $GOPATH/src/github.com/protolambda
git clone https://github.com/ethereum/eth2.0-specs
cd eth2.0-specs
git checkout v0.6.0

# Get and configure zrnt
cd $GOPATH/src/github.com/protolambda
git clone https://github.com/protolambda/zrnt.git
# Dependency of zrnt
go get gopkg.in/yaml.v2
cd zrnt/eth2/core/
go generate
cd /eth2

go get github.com/prysmaticlabs/go-ssz

# Get eth2.0-specs
git clone --depth 1 https://github.com/ethereum/eth2.0-specs.git
export ETH2_SPECS_PATH=`realpath eth2.0-specs/`
cd /eth2

go get golang.org/x/tools/go/packages
go build github.com/dvyukov/go-fuzz/go-fuzz-build
export GO_FUZZ_BUILD_PATH=`realpath go-fuzz-build`

# CPython
mkdir cpython-install
export CPYTHON_INSTALL_PATH=`realpath cpython-install`
cd cpython
./configure --prefix=$CPYTHON_INSTALL_PATH
make -j$(nproc)
make install

cd /eth2/lib
make

cd /eth2/fuzzers
# Recursively make all fuzzers
make all

# Find fuzzers, copy them over
#find . -type f ! -name '*.*' -executable -exec cp {} /eth2/out \;
