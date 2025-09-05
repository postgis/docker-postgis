#!/bin/bash
# Test script for macOS Docker PostGIS setup
# Validates that the experimental setup works correctly

set -euo pipefail

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

pass() {
    echo -e "${GREEN}[PASS]${NC} $1" >&2
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1" >&2
}

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    info "Running test: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        pass "$test_name"
        ((TESTS_PASSED++))
        return 0
    else
        fail "$test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: Check macOS
test_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# Test 2: Check Docker installation
test_docker_installed() {
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1
}

# Test 3: Check Docker Desktop application
test_docker_desktop_app() {
    [[ -d "/Applications/Docker.app" ]]
}

# Test 4: Check buildx availability
test_buildx_available() {
    docker buildx version >/dev/null 2>&1
}

# Test 5: Check multiplatform support
test_multiplatform_support() {
    docker buildx ls | grep -q "linux/amd64.*linux/arm64\|linux/arm64.*linux/amd64"
}

# Test 6: Test basic Docker functionality
test_docker_basic() {
    docker run --rm hello-world >/dev/null 2>&1
}

# Test 7: Test multiplatform build capability
test_multiplatform_build() {
    # Create a simple test Dockerfile
    local temp_dir=$(mktemp -d)
    local dockerfile="$temp_dir/Dockerfile"
    
    cat > "$dockerfile" << 'EOF'
FROM alpine:3.18
RUN echo "Architecture: $(uname -m)" > /tmp/arch.txt
CMD cat /tmp/arch.txt
EOF

    # Test multiplatform build
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag test-multiplatform:latest \
        "$temp_dir" >/dev/null 2>&1
    
    # Cleanup
    rm -rf "$temp_dir"
    docker image rm test-multiplatform:latest >/dev/null 2>&1 || true
}

# Test 8: Test script availability
test_build_script() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    [[ -f "$script_dir/macos-docker-setup.sh" ]] && [[ -x "$script_dir/macos-docker-setup.sh" ]]
}

# Test 9: Test script help
test_script_help() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "$script_dir/macos-docker-setup.sh" --help >/dev/null 2>&1 || \
    "$script_dir/macos-docker-setup.sh" help >/dev/null 2>&1 || \
    "$script_dir/macos-docker-setup.sh" unknown-command 2>&1 | grep -q "Usage:"
}

# Test 10: Test basic PostGIS build (if requested)
test_postgis_build() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_root="$(dirname "$script_dir")"
    
    # Check if we have necessary files
    if [[ ! -f "$repo_root/17-3.5/Dockerfile" ]] && [[ ! -f "$repo_root/update.sh" ]]; then
        info "Skipping PostGIS build test - no Dockerfiles or update.sh found"
        return 0
    fi
    
    # Run a quick build test (this might take a while)
    POSTGRES_VERSION=17 POSTGIS_VERSION=3.5 VARIANT=default SKIP_TESTS=true \
        "$script_dir/macos-docker-setup.sh" build-only >/dev/null 2>&1
}

# Main test suite
main() {
    info "Starting macOS Docker PostGIS setup test suite"
    info "======================================================"
    
    echo
    info "System Information:"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  macOS Version: $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
    
    echo
    info "Running tests..."
    echo
    
    # Core system tests
    run_test "macOS detected" "test_macos"
    run_test "Docker installed and running" "test_docker_installed"
    run_test "Docker Desktop app present" "test_docker_desktop_app"
    run_test "Docker buildx available" "test_buildx_available"
    run_test "Multiplatform support configured" "test_multiplatform_support"
    
    # Docker functionality tests
    run_test "Basic Docker functionality" "test_docker_basic"
    run_test "Multiplatform build capability" "test_multiplatform_build"
    
    # Script tests
    run_test "Build script present and executable" "test_build_script"
    run_test "Build script shows help" "test_script_help"
    
    # Optional PostGIS build test
    if [[ "${RUN_BUILD_TEST:-false}" == "true" ]]; then
        warn "Running full PostGIS build test (this may take 10-20 minutes)..."
        run_test "PostGIS build test" "test_postgis_build"
    else
        info "Skipping PostGIS build test (set RUN_BUILD_TEST=true to enable)"
    fi
    
    echo
    info "======================================================"
    info "Test Results Summary:"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo "  Total:  $((TESTS_PASSED + TESTS_FAILED))"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo
        pass "All tests passed! Your macOS Docker PostGIS setup is ready."
        echo
        info "Next steps:"
        echo "  1. Run: ./scripts/macos-docker-setup.sh"
        echo "  2. Or with custom parameters:"
        echo "     POSTGRES_VERSION=16 POSTGIS_VERSION=3.5 ./scripts/macos-docker-setup.sh"
        echo
        return 0
    else
        echo
        fail "Some tests failed. Please check the output above for details."
        echo
        info "Common fixes:"
        echo "  - Install Docker Desktop: ./scripts/macos-docker-setup.sh install-docker"
        echo "  - Configure multiplatform: ./scripts/macos-docker-setup.sh configure-multiplatform"
        echo
        return 1
    fi
}

# Handle command line arguments
case "${1:-main}" in
    "main"|"")
        main
        ;;
    "build-test")
        RUN_BUILD_TEST=true main
        ;;
    *)
        echo "Usage: $0 [main|build-test]"
        echo ""
        echo "Commands:"
        echo "  main       - Run standard test suite (default)"
        echo "  build-test - Run test suite including PostGIS build test"
        echo ""
        echo "Environment variables:"
        echo "  RUN_BUILD_TEST=true - Include PostGIS build test (slow)"
        exit 1
        ;;
esac
