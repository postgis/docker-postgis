#!/bin/bash
set -Eeuo pipefail

# https://github.com/wagoodman/dive/releases/tag/v0.13.1
version="0.13.1"

# Determine IMAGE_ARCH based on the machine architecture
if [[ "$(uname -m)" == "x86_64" ]]; then
    IMAGE_ARCH=amd64
    checksum="0970549eb4a306f8825a84145a2534153badb4d7dcf3febd1967c706367c3d0e  tools/dive_0.13.1_linux_amd64.tar.gz"
elif [[ "$(uname -m)" == "aarch64" ]]; then
    IMAGE_ARCH=arm64
    checksum="2fcd2cf20f634ccdb41efac44048b204bfc867c115641f37a7420693ed480a18  tools/dive_0.13.1_linux_arm64.tar.gz"
else
    echo "Architecture not supported: $(uname -m)"
    exit 1
fi

# Download wagoodman/dive tool
rm -f "tools/dive"
rm -f "tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz"
wget https://github.com/wagoodman/dive/releases/download/v${version}/dive_${version}_linux_${IMAGE_ARCH}.tar.gz -O tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz
echo "${checksum}" | sha256sum --check
tar -xzf "tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz" -C "tools/"
chmod +x "tools/dive"
rm -f "tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz"

# Check dive version
tools/dive -v
