#!/bin/bash
set -Eeuo pipefail

# https://github.com/wagoodman/dive/releases/tag/v0.11.0
version="0.11.0"

# Determine IMAGE_ARCH based on the machine architecture
if [[ "$(uname -m)" == "x86_64" ]]; then
    IMAGE_ARCH=amd64
    checksum="80835d3320292c4ab761d03c1fd33745ddb9b6064c035b65f77825f18f407d28  tools/dive_0.11.0_linux_amd64.tar.gz"
elif [[ "$(uname -m)" == "aarch64" ]]; then
    IMAGE_ARCH=arm64
    checksum="656aa45f618c30f02a30fa256e429ba1afafd9e39e3757e52a30764494c71b7a  tools/dive_0.11.0_linux_arm64.tar.gz"
else
    echo "Architecture not supported: $(uname -m)"
    exit 1
fi

# Download wagoodman/dive tool
rm -f "tools/dive"
rm -f "tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz"
wget https://github.com/wagoodman/dive/releases/download/v${version}/dive_${version}_linux_${IMAGE_ARCH}.tar.gz -O tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz
echo "${checksum}"| sha256sum --check 
tar -xzf "tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz" -C "tools/"
chmod +x "tools/dive"
rm -f "tools/dive_${version}_linux_${IMAGE_ARCH}.tar.gz"

# Check dive version
tools/dive -v
