#!/bin/bash
set -Eeuo pipefail

# https://github.com/wagoodman/dive/releases/tag/v0.12.0
version="0.12.0"

# Determine IMAGE_ARCH based on the machine architecture
if [[ "$(uname -m)" == "x86_64" ]]; then
    IMAGE_ARCH=amd64
    checksum="20a7966523a0905f950c4fbf26471734420d6788cfffcd4a8c4bc972fded3e96  tools/dive_0.12.0_linux_amd64.tar.gz"
elif [[ "$(uname -m)" == "aarch64" ]]; then
    IMAGE_ARCH=arm64
    checksum="a2a1470302cdfa367a48f80b67bbf11c0cd8039af9211e39515bd2bbbda58fea  tools/dive_0.12.0_linux_arm64.tar.gz"
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
