#!/usr/bin/env bash
#
# test-image.sh - Run official-images test suite against a PostGIS image
#
# Called by: .github/workflows/*.yml, ci/local-test.sh
#
set -Eeuo pipefail

# --- Logging (CI-only, no colors) ---
log_info()  { echo "[INFO] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }
die()       { log_error "$1"; exit "${2:-1}"; }

cd "$(dirname "${BASH_SOURCE[0]}")/.."

image_tag="${1:-${CI_IMAGE_TAG:-}}"
log_file="${TEST_LOG_FILE:-test.log}"
official_images_dir="official-images"
official_run="./${official_images_dir}/test/run.sh"
official_config="./${official_images_dir}/test/config.sh"

if [[ -z "$image_tag" ]]; then
  die "Usage: ci/test-image.sh <image-tag>" 2
fi

# Local development: auto-update official-images checkout (CI handles this via workflow)
if [[ "${GITHUB_ACTIONS:-}" != "true" ]]; then
  if [[ -d "${official_images_dir}/.git" ]]; then
    log_info "Local run: updating ./${official_images_dir}..."
    git -C "$official_images_dir" fetch origin master
    git -C "$official_images_dir" reset --hard origin/master
  elif [[ ! -d "$official_images_dir" ]]; then
    log_info "Local run: cloning docker-library/official-images..."
    git clone --depth 1 https://github.com/docker-library/official-images.git "${official_images_dir}"
  fi
fi

if [[ ! -x "$official_run" ]]; then
  die "${official_run} not found or not executable."
fi
if [[ ! -f "$official_config" ]]; then
  die "${official_config} not found."
fi

"$official_run" -c "$official_config" -c test/postgis-config.sh "$image_tag" | tee "$log_file"

# These tests must pass for a valid PostGIS image
required_tests=("postgres-basics" "postgres-initdb" "postgis-basics")
for test_name in "${required_tests[@]}"; do
  if ! grep -q "'${test_name}'.*passed" "$log_file"; then
    die "Required test '${test_name}' did not pass!"
  fi
done

log_info "[OK] All required tests passed"
