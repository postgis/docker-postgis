#!/usr/bin/env bash
#
# push-manifest.sh - Create and push multi-arch Docker manifest
#
# Called by: .github/workflows/*.yml
#
set -Eeuo pipefail

# --- Logging (CI-only, no colors) ---
log_info()  { echo "[INFO] $*" >&2; }
log_warn()  { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }
die()       { log_error "$1"; exit "${2:-1}"; }

repo="${1:-}"
tags="${2:-}"
digests_dir="${3:-.}"
expected_platforms_json="${4:-${EXPECTED_IMAGE_PLATFORMS_JSON:-}}"

if [[ -z "$repo" || -z "$tags" ]]; then
  die "Usage: ci/push-manifest.sh <dockerhub-repo> <tags> [digests-dir]" 2
fi

cd "$digests_dir"

shopt -s nullglob
digests=( * )
shopt -u nullglob
if [[ "${#digests[@]}" -eq 0 ]]; then
  die "No digest files found in $digests_dir"
fi

tag_args=()
for tag in $tags; do
  tag_args+=(--tag "${repo}:${tag}")
done

image_refs=()
for digest in "${digests[@]}"; do
  image_refs+=("${repo}@sha256:${digest}")
done

log_info "Creating multi-arch manifest with tags: ${tags}"

docker buildx imagetools create "${tag_args[@]}" "${image_refs[@]}"

if [[ -n "$expected_platforms_json" ]]; then
  if ! command -v jq >/dev/null 2>&1; then
    die "jq is required to verify pushed manifest platforms"
  fi

  for tag in $tags; do
    image_ref="${repo}:${tag}"
    log_info "Verifying pushed manifest ${image_ref}"
    raw_manifest="$(docker buildx imagetools inspect --raw "$image_ref")"

    missing_platforms="$(jq -r --argjson expected "$expected_platforms_json" '
      def split_platform($platform):
        ($platform | split("/")) as $parts
        | {os: $parts[0], architecture: $parts[1], variant: ($parts[2] // null)};

      [ .manifests[]?.platform
        | select(.os != null and .architecture != null)
        | {os, architecture, variant: (.variant // null)}
      ] as $actual
      | $expected
      | map(select(
          split_platform(.) as $expected_platform
          | ($actual | any(
              .os == $expected_platform.os
              and .architecture == $expected_platform.architecture
              and ($expected_platform.variant == null or .variant == $expected_platform.variant)
            ))
          | not
        ))
      | .[]
    ' <<< "$raw_manifest")"

    if [[ -n "$missing_platforms" ]]; then
      log_error "Manifest ${image_ref} is missing expected platform(s):"
      echo "$missing_platforms" >&2
      docker buildx imagetools inspect "$image_ref" >&2 || true
      exit 1
    fi

    log_info "[OK] ${image_ref} contains expected platforms: ${expected_platforms_json}"
  done
fi

log_info "[OK] Manifest created, pushed, and verified"
