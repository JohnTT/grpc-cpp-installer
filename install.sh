#!/bin/bash
export MY_INSTALL_DIR=$HOME/.local
if [ -d "$MY_INSTALL_DIR" ]; then
    echo "Error: gRPC install directory $MY_INSTALL_DIR exists."
    exit 1
fi

echo "Installing gRPC C++ to $MY_INSTALL_DIR"
sudo mkdir -p $MY_INSTALL_DIR
export PATH="$MY_INSTALL_DIR/bin:$PATH"

echo "Installing gRPC C++ dependencies (cmake build-essential autoconf libtool pkg-config)"
sudo apt install -y cmake build-essential autoconf libtool pkg-config
sudo -k

GRPC_VERSION=$(git ls-remote --tags https://github.com/grpc/grpc | \
    grep 'refs/tags/v[0-9]*\.[0-9]*\.[0-9]*$' | \
    sort -t '/' -k 3 -V | tail -n 1 | awk -F'/' '{print $3}')
echo "Cloning gRPC repository at version $GRPC_VERSION"
git clone --recurse-submodules -b $GRPC_VERSION --depth 1 --shallow-submodules https://github.com/grpc/grpc

echo "Building gRPC C++"
cd grpc
mkdir -p cmake/build
pushd cmake/build
cmake -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
      ../..
make -j $(nproc)
make install
popd
