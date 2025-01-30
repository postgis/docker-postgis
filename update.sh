#!/usr/bin/env bash
set -Eeuo pipefail
# Source environment variables and necessary configurations
source tools/environment_init.sh
[ -f ./versions.json ]

# This code derived from:
#   - URL: https://github.com/docker-library/postgres/blob/master/versions.sh
#   - Copyright: (c) Docker PostgreSQL Authors
#   - MIT License, https://github.com/docker-library/postgres/blob/master/LICENSE

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

echo " "

# Generate versions.json metadata file
./tools/versions.sh "$@"

# apply version.json - generate Dockerfiles
./tools/apply-templates.sh "$@"

# apply version.json - generate .github/workflows/main.yml and .circleci/config.yml
./tools/apply-ci.sh "$@"

# apply version.json - generate manifest.sh
./tools/apply-manifest.sh "$@"

# apply version.json - generate README.md
./tools/apply-readme.sh "$@"
