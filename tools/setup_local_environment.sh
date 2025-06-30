#!/usr/bin/env bash
set -Eeuo pipefail

echo "=============================================="
echo "Docker PostGIS - Local Development Environment Setup"
echo "=============================================="
echo ""

# Check if running on Ubuntu/Debian
if ! command -v apt-get &> /dev/null; then
    echo "Error: This script is designed for Ubuntu/Debian systems with apt-get package manager."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    echo "Please install Docker first from: https://docs.docker.com/engine/install/ubuntu/"
    exit 1
fi

# Check if running as root (not recommended for development)
if [[ $EUID -eq 0 ]]; then
    echo "Warning: Running as root is not recommended for development environment setup."
    echo "Consider running this script as a regular user with sudo privileges."
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Updating system packages..."
sudo apt-get update || true

echo ""
echo "Step 2: Installing system dependencies..."
# Install required system packages (compatible with Ubuntu 20.04-25.04)
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    jq \
    gawk \
    git \
    make

echo ""
echo "Step 3: Setting up Python virtual environment..."
# Create virtual environment if it doesn't exist
if [[ ! -d "venv-docker-postgis" ]]; then
    python3 -m venv venv-docker-postgis
    echo "Created Python virtual environment in ./venv-docker-postgis"
else
    echo "Python virtual environment already exists in ./venv-docker-postgis"
fi

# Activate virtual environment
# shellcheck source=/dev/null
source venv-docker-postgis/bin/activate
echo "Activated Python virtual environment"

echo ""
echo "Step 4: Installing Python packages..."
# Upgrade pip and install required Python packages
pip3 install --upgrade pip
pip3 install --upgrade lastversion check-jsonschema

echo ""
echo "Step 5: Installing manifest-tool..."
if ! command -v manifest-tool &> /dev/null; then
    ./tools/install_manifest-tool.sh
    echo "manifest-tool installed successfully"
else
    echo "manifest-tool is already installed"
    manifest-tool -v
fi

echo ""
echo "Step 6: Installing dive tool..."
if [[ ! -f "tools/dive" ]]; then
    ./tools/install_dive.sh
    echo "dive tool installed successfully"
else
    echo "dive tool already exists"
    ./tools/dive -v
fi

echo ""
echo "Step 7: Initializing environment..."
# shellcheck source=/dev/null
source ./tools/environment_init.sh

echo ""
echo "Step 8: Running version check..."
make check_version

echo ""
echo "=============================================="
echo "Setup completed successfully!"
echo "=============================================="
echo ""
echo "To use this environment in the future:"
echo "  1. cd $(pwd)"
echo "  2. source venv-docker-postgis/bin/activate"
echo "  3. source ./tools/environment_init.sh"
echo ""
echo "Available commands:"
echo "  make build              # Build all images"
echo "  make test               # Test all images"
echo "  make lint               # Run shellcheck"
echo "  ./update.sh             # Update all configurations"
echo "  ./tools/versions.sh     # Check for new versions"
echo ""
echo "For more information, see the Makefile targets:"
echo "  make help"
echo ""