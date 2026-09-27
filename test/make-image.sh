#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)

assert_one_image_build() {
	expected=$1
	shift
	output=$(cd "$repo_root" && make -n image "$@")
	grep -Fq "$expected" <<<"$output"
	[ "$(grep -o 'docker build --pull' <<<"$output" | wc -l)" -eq 1 ]
}

assert_one_image_build \
	'docker build --pull -t postgis/postgis:18-3.6-alpine 18-3.6/alpine' \
	18 3.6 alpine
assert_one_image_build \
	'docker build --pull -t postgis/postgis:18-3.6 18-3.6' \
	18 3.6

if (cd "$repo_root" && make -n image 18 3.6 invalid >/dev/null 2>&1); then
	echo "Expected an invalid image variant to fail" >&2
	exit 1
fi

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir "$fixture/18-3.6"
touch "$fixture/18-3.6/Dockerfile" "$fixture/initdb-postgis.sh" "$fixture/update-postgis.sh"
cat > "$fixture/docker" <<'EOF'
#!/bin/sh
# A failed build must fail make, even when listing existing images succeeds.
[ "$1" != build ]
EOF
chmod +x "$fixture/docker"
if (cd "$fixture" && make -f "$repo_root/Makefile" VERSION=18-3.6 VARIANT=default \
    DOCKER="$fixture/docker" build-18-3.6 >/dev/null 2>&1); then
	echo "Expected a failed Docker build to fail make" >&2
	exit 1
fi

echo "make image checks passed"
