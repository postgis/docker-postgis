#!/bin/bash
set -Eeuo pipefail

# https://github.com/estesp/manifest-tool
version="2.1.9"

# Determine IMAGE_ARCH based on the machine architecture
if [[ "$(uname -m)" == "x86_64" ]]; then
    IMAGE_ARCH=amd64
elif [[ "$(uname -m)" == "aarch64" ]]; then
    IMAGE_ARCH=arm64
else
    echo "Architecture not supported: $(uname -m)"
    exit 1
fi
export IMAGE_ARCH

# Download manifest-tool
wget https://github.com/estesp/manifest-tool/releases/download/v${version}/binaries-manifest-tool-${version}.tar.gz
mkdir -p manifest-tool
tar -xvzf binaries-manifest-tool-${version}.tar.gz -C manifest-tool
sudo mv manifest-tool/manifest-tool-linux-${IMAGE_ARCH} /usr/local/bin/manifest-tool
rm -f binaries-manifest-tool-${version}.tar.gz
rm -rf ./manifest-tool/manifest-tool-* # remove other archs

# Check manifest-tool version
manifest-tool -v
