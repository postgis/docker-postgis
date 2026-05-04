#!/usr/bin/env bash
#
# matrix.sh - Parse matrix.yml and output build targets for CI workflows
#
# Called by: .github/workflows/*.yml
# Outputs: BUILD_TARGETS and BUILD_INCLUDE for GitHub Actions matrix strategy
#
set -Eeuo pipefail

# --- Logging (CI-only, no colors) ---
log_info()  { echo "[INFO] $*" >&2; }
log_warn()  { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }
die()       { log_error "$1"; exit "${2:-1}"; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

readonly MATRIX_FILE="matrix.yml"

# Environment variables (set by CI workflow)
runner_platforms_json="${RUNNER_PLATFORMS_JSON:-}"
github_output_file="${GITHUB_OUTPUT:-}"

# Write a line to GitHub Actions output file, or stdout if not in CI
set_github_output() {
    local output_line="$1"
    if [[ -n "$github_output_file" ]]; then
        echo "$output_line" >> "$github_output_file"
    else
        echo "$output_line"
    fi
}

# --- Input Validation ---
if [[ ! -f "$MATRIX_FILE" ]]; then
    die "$MATRIX_FILE not found in repo root"
fi

if [[ -z "$runner_platforms_json" ]]; then
    die "RUNNER_PLATFORMS_JSON environment variable is required"
fi

if ! command -v ruby >/dev/null 2>&1; then
    die "ruby is required to parse ${MATRIX_FILE}"
fi

# --- Parse Matrix File ---
build_targets="$(
    ruby -ryaml -rjson -e '
        matrix = YAML.load_file(ARGV.fetch(0))
        targets = matrix.fetch("build_targets")
        puts JSON.generate(targets)
    ' "$MATRIX_FILE"
)"
set_github_output "BUILD_TARGETS=$build_targets"

# Expand build_targets with runner platforms to create full build matrix.
# Each target is combined with each platform to create BUILD_INCLUDE entries.
runner_platforms="$(jq -c '.' <<< "$runner_platforms_json")"
build_include="$(jq -c --argjson platforms "$runner_platforms" '
    [ .[] as $combo | $platforms[] | $combo + {"runner-platform": .} ]
' <<< "$build_targets")"
set_github_output "BUILD_INCLUDE=$build_include"

target_count="$(jq 'length' <<< "$build_targets")"
include_count="$(jq 'length' <<< "$build_include")"
log_info "Loaded BUILD_TARGETS with ${target_count} entries"
log_info "Expanded BUILD_INCLUDE with ${include_count} entries (targets x platforms)"

# --- Validation ---
log_info "Validating ./${MATRIX_FILE}..."

# 1. Check build_targets is not empty
if [[ "$target_count" -eq 0 ]]; then
    die "matrix.yml has no build_targets"
fi

# 2. Check required fields: postgres, postgis, variant, tags (all must be non-empty)
invalid_entries="$(jq -c '
    [ .[] | select(
        .postgres == null or .postgres == "" or
        .postgis == null or .postgis == "" or
        .variant == null or .variant == "" or
        .tags == null or .tags == ""
    )]
' <<< "$build_targets")"

invalid_count="$(jq 'length' <<< "$invalid_entries")"
if [[ "$invalid_count" -gt 0 ]]; then
    log_error "Found ${invalid_count} entries with missing or empty required fields (postgres/postgis/variant/tags):"
    jq '.' <<< "$invalid_entries" >&2
    exit 1
fi

# 3. Verify exactly one entry has 'latest' tag (prevents accidental duplicate latest)
latest_count="$(jq '
    [ .[] | select(.tags | tostring | test("(^| )latest( |$)")) ] | length
' <<< "$build_targets")"

if [[ "$latest_count" -ne 1 ]]; then
    log_error "Expected exactly 1 entry with 'latest' tag, found: $latest_count"
    jq -r '.[] | select(.tags | tostring | test("(^| )latest( |$)"))' <<< "$build_targets" >&2
    exit 1
fi

# 4. Verify exactly one entry has 'alpine' tag (the alpine equivalent of 'latest')
alpine_count="$(jq '
    [ .[] | select(.tags | tostring | test("(^| )alpine( |$)")) ] | length
' <<< "$build_targets")"

if [[ "$alpine_count" -ne 1 ]]; then
    log_error "Expected exactly 1 entry with 'alpine' tag, found: $alpine_count"
    jq -r '.[] | select(.tags | tostring | test("(^| )alpine( |$)"))' <<< "$build_targets" >&2
    exit 1
fi

log_info "[OK] matrix.yml valid: ${target_count} targets, all have required fields, 1 'latest' tag, 1 'alpine' tag"
