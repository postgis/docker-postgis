#!/bin/bash
# Docker Desktop for macOS Setup Script
# Can be run locally or in GitHub Actions with Apple Silicon runners
# Supports multiplatform builds using Docker Desktop and Rosetta2

set -euo pipefail

# Configuration variables
DOCKER_DESKTOP_VERSION=${DOCKER_DESKTOP_VERSION:-"4.36.0"}  # Latest version as of time of writing
POSTGRES_VERSION=${POSTGRES_VERSION:-"17"}
POSTGIS_VERSION=${POSTGIS_VERSION:-"3.5"}
VARIANT=${VARIANT:-"default"}
BUILD_PLATFORM=${BUILD_PLATFORM:-"linux/arm64,linux/amd64"}

# Color output functions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        error "This script is designed for macOS only"
        exit 1
    fi
    
    local arch=$(uname -m)
    info "Running on macOS $(uname -r) on ${arch} architecture"
    
    if [[ "$arch" == "arm64" ]]; then
        info "Apple Silicon detected - Rosetta2 will be available for multiplatform builds"
    else
        warn "Intel Mac detected - multiplatform builds may be slower"
    fi
}

# Check if Docker Desktop is installed
check_docker_installed() {
    if [[ -d "/Applications/Docker.app" ]]; then
        info "Docker Desktop is already installed"
        return 0
    else
        info "Docker Desktop not found"
        return 1
    fi
}

# Install Docker Desktop for macOS
install_docker_desktop() {
    info "Installing Docker Desktop for macOS version ${DOCKER_DESKTOP_VERSION}"
    
    # Determine the appropriate download URL based on architecture
    local arch=$(uname -m)
    local download_url
    
    if [[ "$arch" == "arm64" ]]; then
        download_url="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
        info "Downloading Docker Desktop for Apple Silicon"
    else
        download_url="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
        info "Downloading Docker Desktop for Intel"
    fi
    
    # Download Docker Desktop
    local temp_dmg="/tmp/Docker.dmg"
    info "Downloading from ${download_url}"
    curl -L -o "${temp_dmg}" "${download_url}"
    
    # Mount the DMG
    info "Mounting Docker.dmg"
    local mount_point=$(hdiutil attach "${temp_dmg}" | grep "/Volumes" | awk '{print $3}')
    
    # Copy Docker.app to Applications
    info "Installing Docker Desktop to /Applications"
    sudo cp -R "${mount_point}/Docker.app" /Applications/
    
    # Unmount the DMG
    hdiutil detach "${mount_point}"
    rm "${temp_dmg}"
    
    info "Docker Desktop installation completed"
}

# Start Docker Desktop and wait for it to be ready
start_docker_desktop() {
    info "Starting Docker Desktop"
    
    # Start Docker Desktop
    open -a Docker
    
    # Wait for Docker to start (check every 5 seconds, timeout after 5 minutes)
    local timeout=60  # 5 minutes
    local count=0
    
    info "Waiting for Docker Desktop to start..."
    while ! docker info >/dev/null 2>&1; do
        if [[ $count -ge $timeout ]]; then
            error "Timeout waiting for Docker Desktop to start"
            exit 1
        fi
        sleep 5
        ((count++))
        echo -n "."
    done
    echo
    
    info "Docker Desktop is running"
    docker version
}

# Configure Docker for multiplatform builds
configure_multiplatform() {
    info "Configuring Docker for multiplatform builds"
    
    # Enable experimental features (if not already enabled)
    local docker_config_dir="$HOME/.docker"
    local docker_config_file="$docker_config_dir/config.json"
    
    mkdir -p "$docker_config_dir"
    
    # Create or update Docker config to enable experimental features
    if [[ -f "$docker_config_file" ]]; then
        # Update existing config
        local temp_config="/tmp/docker_config.json"
        jq '.experimental = "enabled"' "$docker_config_file" > "$temp_config"
        mv "$temp_config" "$docker_config_file"
    else
        # Create new config
        cat > "$docker_config_file" << EOF
{
  "experimental": "enabled"
}
EOF
    fi
    
    # Create a new buildx builder instance for multiplatform builds
    info "Setting up buildx builder for multiplatform builds"
    
    # Remove existing builder if it exists
    docker buildx rm multiplatform-builder 2>/dev/null || true
    
    # Create new builder with multiplatform support
    docker buildx create --name multiplatform-builder --driver docker-container --bootstrap
    docker buildx use multiplatform-builder
    
    # Verify multiplatform capabilities
    info "Available platforms:"
    docker buildx ls
    
    # Test multiplatform support
    info "Testing multiplatform build capability"
    docker buildx inspect --bootstrap
}

# Setup build environment
setup_build_env() {
    info "Setting up build environment"
    
    # Set environment variables for the build
    export VERSION="${POSTGRES_VERSION}-${POSTGIS_VERSION}"
    export VARIANT="${VARIANT}"
    export REPO_NAME="postgis"
    export IMAGE_NAME="postgis"
    
    info "Build configuration:"
    info "  PostgreSQL version: ${POSTGRES_VERSION}"
    info "  PostGIS version: ${POSTGIS_VERSION}"
    info "  Variant: ${VARIANT}"
    info "  Target platforms: ${BUILD_PLATFORM}"
    info "  Full version string: ${VERSION}"
}

# Build Docker images using multiplatform
build_images() {
    info "Building Docker images for ${VERSION} ${VARIANT}"
    
    # Change to repository root
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_root="$(dirname "$script_dir")"
    cd "$repo_root"
    
    # Build using the existing Makefile, but with multiplatform support
    if [[ "$VARIANT" == "default" ]]; then
        local dockerfile_path="${VERSION}"
    else
        local dockerfile_path="${VERSION}/${VARIANT}"
    fi
    
    # Check if the Dockerfile exists
    if [[ ! -f "${dockerfile_path}/Dockerfile" ]]; then
        error "Dockerfile not found at ${dockerfile_path}/Dockerfile"
        error "You may need to run './update.sh' first to generate Dockerfiles"
        exit 1
    fi
    
    # Build the image with multiplatform support
    local tag_suffix=""
    if [[ "$VARIANT" != "default" ]]; then
        tag_suffix="-${VARIANT}"
    fi
    
    local image_tag="${REPO_NAME}/${IMAGE_NAME}:${VERSION}${tag_suffix}"
    
    info "Building multiplatform image: ${image_tag}"
    info "Dockerfile path: ${dockerfile_path}/Dockerfile"
    info "Build context: ${dockerfile_path}"
    
    # Use buildx for multiplatform build
    docker buildx build \
        --platform "${BUILD_PLATFORM}" \
        --tag "${image_tag}" \
        --load \
        "${dockerfile_path}"
    
    # Verify the image was built
    docker images | grep "${REPO_NAME}/${IMAGE_NAME}" | grep "${VERSION}"
    
    info "Build completed successfully for ${image_tag}"
}

# Run tests (if available)
run_tests() {
    info "Running tests"
    
    # Change to repository root
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_root="$(dirname "$script_dir")"
    cd "$repo_root"
    
    # Use the existing test infrastructure
    if command -v make >/dev/null 2>&1; then
        # Run the standard test suite
        make test VERSION="${VERSION}" VARIANT="${VARIANT}"
    else
        warn "Make not found, skipping tests"
    fi
}

# Main execution flow
main() {
    info "Starting Docker PostGIS build on macOS"
    info "Configuration: ${POSTGRES_VERSION}-${POSTGIS_VERSION} (${VARIANT})"
    
    # Check prerequisites
    check_macos
    
    # Install Docker Desktop if not present
    if ! check_docker_installed; then
        install_docker_desktop
    fi
    
    # Start Docker Desktop
    if ! docker info >/dev/null 2>&1; then
        start_docker_desktop
    else
        info "Docker is already running"
        docker version
    fi
    
    # Configure multiplatform builds
    configure_multiplatform
    
    # Setup build environment
    setup_build_env
    
    # Build images
    build_images
    
    # Run tests
    if [[ "${SKIP_TESTS:-false}" != "true" ]]; then
        run_tests
    else
        info "Skipping tests (SKIP_TESTS=true)"
    fi
    
    info "Build process completed successfully!"
    info "Built image: ${REPO_NAME}/${IMAGE_NAME}:${VERSION}$([ "$VARIANT" != "default" ] && echo "-${VARIANT}")"
}

# Handle script arguments
case "${1:-main}" in
    "install-docker")
        check_macos
        install_docker_desktop
        start_docker_desktop
        ;;
    "configure-multiplatform")
        configure_multiplatform
        ;;
    "build-only")
        setup_build_env
        build_images
        ;;
    "test-only")
        run_tests
        ;;
    "main"|"")
        main
        ;;
    *)
        echo "Usage: $0 [install-docker|configure-multiplatform|build-only|test-only|main]"
        echo ""
        echo "Environment variables:"
        echo "  POSTGRES_VERSION    - PostgreSQL version (default: 17)"
        echo "  POSTGIS_VERSION     - PostGIS version (default: 3.5)"
        echo "  VARIANT             - Variant to build (default: default, options: default, alpine)"
        echo "  BUILD_PLATFORM      - Target platforms (default: linux/arm64,linux/amd64)"
        echo "  SKIP_TESTS          - Skip tests (default: false)"
        echo ""
        echo "Commands:"
        echo "  install-docker        - Only install and start Docker Desktop"
        echo "  configure-multiplatform - Only configure Docker for multiplatform builds"
        echo "  build-only           - Only build images (skip setup)"
        echo "  test-only            - Only run tests"
        echo "  main                 - Full workflow (default)"
        exit 1
        ;;
esac
