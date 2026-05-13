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

tag_args=""
for tag in $tags; do
  tag_args+=" -t ${repo}:${tag}"
done

log_info "Creating multi-arch manifest with tags:${tag_args}"

# shellcheck disable=SC2046,SC2086
docker buildx imagetools create $tag_args \
  $(printf "${repo}@sha256:%s " "${digests[@]}")

log_info "[OK] Manifest created and pushed"
