#!/usr/bin/env bash
#
# prepare-dockerhub-readme.sh - Prepare a README suitable for Docker Hub description
#
# Called by: .github/workflows/*.yml
# Docker Hub has a 25000 character limit; this script trims if needed.
#
set -Eeuo pipefail

# --- Logging (CI-only, no colors) ---
log_info()  { echo "[INFO] $*" >&2; }
log_warn()  { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }
die()       { log_error "$1"; exit "${2:-1}"; }

usage() {
  cat <<'EOF'
Usage: ci/prepare-dockerhub-readme.sh [source-readme] [output-readme]

Writes a Docker Hub compatible README, optionally prefixing it via:
  DOCKERHUB_README_PREFIX

Defaults:
  source-readme: README.md
  output-readme: _DOCKER-HUB-README.md
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

src_readme="${1:-README.md}"
out_readme="${2:-_DOCKER-HUB-README.md}"
prefix="${DOCKERHUB_README_PREFIX:-}"

if [[ ! -f "$src_readme" ]]; then
  die "Source README not found: $src_readme"
fi

mkdir -p "$(dirname "$out_readme")"

tmp_file="$(mktemp)"
if [[ -n "$prefix" ]]; then
  printf '%b\n' "$prefix" > "$tmp_file"
  cat "$src_readme" >> "$tmp_file"
else
  cat "$src_readme" > "$tmp_file"
fi
mv "$tmp_file" "$out_readme"
chmod 644 "$out_readme"

readme_path="$out_readme"

# Docker Hub README limit is 25000 chars; use 24600 to leave margin for warning text
readonly DOCKERHUB_CHAR_LIMIT=24600
size="$(wc -c < "$readme_path" | tr -d '[:space:]')"

if [[ "$size" -ge "$DOCKERHUB_CHAR_LIMIT" ]]; then
  repo="${GITHUB_REPO:-${GITHUB_REPOSITORY:-unknown/unknown}}"
  warning_text=$'Note: the description for this image is longer than the Hub length limit of 25000, so has been trimmed. The full description can be found at\n"https://github.com/'"${repo}"$'/README.md"'

  start_block="${warning_text}"$'\n\n'
  end_block=$'\n...\n'"${warning_text}"$'\n'

  start_len="$(printf '%s' "$start_block" | wc -c | tr -d '[:space:]')"
  end_len="$(printf '%s' "$end_block" | wc -c | tr -d '[:space:]')"
  avail=$(( DOCKERHUB_CHAR_LIMIT - start_len - end_len ))

  if (( avail < 0 )); then
    log_error "Trimming blocks exceed limit ${DOCKERHUB_CHAR_LIMIT}"
    avail=0
  fi

  # Truncate content line-by-line to fit within available space
  content_tmp="$(mktemp)"
  current=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_with_nl="${line}"$'\n'
    line_len="$(printf '%s' "$line_with_nl" | wc -c | tr -d '[:space:]')"
    if (( current + line_len > avail )); then
      break
    fi
    printf '%s' "$line_with_nl" >> "$content_tmp"
    current=$(( current + line_len ))
  done < "$readme_path"

  final_tmp="$(mktemp)"
  printf '%s' "$start_block" > "$final_tmp"
  cat "$content_tmp" >> "$final_tmp"
  printf '%s' "$end_block" >> "$final_tmp"
  rm -f "$content_tmp"
  mv "$final_tmp" "$readme_path"
  chmod 644 "$readme_path"
fi

log_info "[OK] Docker Hub README prepared: $out_readme"
