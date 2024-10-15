#!/usr/bin/env bash
set -Eeuo pipefail
# Source environment variables and necessary configurations
source tools/environment_init.sh

#
# Updating the docker manifest for the postgis image.
# This script uses the version.json metadata file as input to create the updated manifest.
#   manifest-tool doc : https://github.com/estesp/manifest-tool
#
# NOTE: THIS FILE IS GENERATED VIA "./apply-manifest.sh"
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# ----- 12-3.3-alpine3.20 -----

echo "manifest: ${dockername}:12-3.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.3-alpine3.20 \
    --target ${dockername}:12-3.3-alpine3.20 || true

echo "manifest: ${dockername}:12-3.3.7-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.3.7-alpine3.20 \
    --target ${dockername}:12-3.3.7-alpine3.20 || true

echo "manifest: ${dockername}:12-3.3-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.3-alpine \
    --target ${dockername}:12-3.3-alpine || true

# ----- 12-3.4-alpine3.19 -----

echo "manifest: ${dockername}:12-3.4-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4-alpine3.19 \
    --target ${dockername}:12-3.4-alpine3.19 || true

echo "manifest: ${dockername}:12-3.4.3-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4.3-alpine3.19 \
    --target ${dockername}:12-3.4.3-alpine3.19 || true

# ----- 12-3.4-alpine3.20 -----

echo "manifest: ${dockername}:12-3.4-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4-alpine3.20 \
    --target ${dockername}:12-3.4-alpine3.20 || true

echo "manifest: ${dockername}:12-3.4.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4.3-alpine3.20 \
    --target ${dockername}:12-3.4.3-alpine3.20 || true

echo "manifest: ${dockername}:12-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4-alpine \
    --target ${dockername}:12-3.4-alpine || true

# ----- 12-3.5-alpine3.19 -----

echo "manifest: ${dockername}:12-3.5-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5-alpine3.19 \
    --target ${dockername}:12-3.5-alpine3.19 || true

echo "manifest: ${dockername}:12-3.5.0-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5.0-alpine3.19 \
    --target ${dockername}:12-3.5.0-alpine3.19 || true

# ----- 12-3.5-alpine3.20 -----

echo "manifest: ${dockername}:12-3.5-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5-alpine3.20 \
    --target ${dockername}:12-3.5-alpine3.20 || true

echo "manifest: ${dockername}:12-3.5.0-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5.0-alpine3.20 \
    --target ${dockername}:12-3.5.0-alpine3.20 || true

echo "manifest: ${dockername}:12-3.5-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5-alpine \
    --target ${dockername}:12-3.5-alpine || true

# ----- 12-3.5-bookworm -----

echo "manifest: ${dockername}:12-3.5-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5-bookworm \
    --target ${dockername}:12-3.5-bookworm || true

echo "manifest: ${dockername}:12-3.5.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5.0-bookworm \
    --target ${dockername}:12-3.5.0-bookworm || true

echo "manifest: ${dockername}:12-3.5"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5 \
    --target ${dockername}:12-3.5 || true

# ----- 12-3.5-bullseye -----

echo "manifest: ${dockername}:12-3.5-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5-bullseye \
    --target ${dockername}:12-3.5-bullseye || true

echo "manifest: ${dockername}:12-3.5.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.5.0-bullseye \
    --target ${dockername}:12-3.5.0-bullseye || true

# ----- 13-3.3-alpine3.20 -----

echo "manifest: ${dockername}:13-3.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.3-alpine3.20 \
    --target ${dockername}:13-3.3-alpine3.20 || true

echo "manifest: ${dockername}:13-3.3.7-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.3.7-alpine3.20 \
    --target ${dockername}:13-3.3.7-alpine3.20 || true

echo "manifest: ${dockername}:13-3.3-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.3-alpine \
    --target ${dockername}:13-3.3-alpine || true

# ----- 13-3.4-alpine3.19 -----

echo "manifest: ${dockername}:13-3.4-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-alpine3.19 \
    --target ${dockername}:13-3.4-alpine3.19 || true

echo "manifest: ${dockername}:13-3.4.3-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4.3-alpine3.19 \
    --target ${dockername}:13-3.4.3-alpine3.19 || true

# ----- 13-3.4-alpine3.20 -----

echo "manifest: ${dockername}:13-3.4-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-alpine3.20 \
    --target ${dockername}:13-3.4-alpine3.20 || true

echo "manifest: ${dockername}:13-3.4.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4.3-alpine3.20 \
    --target ${dockername}:13-3.4.3-alpine3.20 || true

echo "manifest: ${dockername}:13-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-alpine \
    --target ${dockername}:13-3.4-alpine || true

# ----- 13-3.5-alpine3.19 -----

echo "manifest: ${dockername}:13-3.5-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5-alpine3.19 \
    --target ${dockername}:13-3.5-alpine3.19 || true

echo "manifest: ${dockername}:13-3.5.0-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5.0-alpine3.19 \
    --target ${dockername}:13-3.5.0-alpine3.19 || true

# ----- 13-3.5-alpine3.20 -----

echo "manifest: ${dockername}:13-3.5-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5-alpine3.20 \
    --target ${dockername}:13-3.5-alpine3.20 || true

echo "manifest: ${dockername}:13-3.5.0-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5.0-alpine3.20 \
    --target ${dockername}:13-3.5.0-alpine3.20 || true

echo "manifest: ${dockername}:13-3.5-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5-alpine \
    --target ${dockername}:13-3.5-alpine || true

# ----- 13-3.5-bookworm -----

echo "manifest: ${dockername}:13-3.5-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5-bookworm \
    --target ${dockername}:13-3.5-bookworm || true

echo "manifest: ${dockername}:13-3.5.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5.0-bookworm \
    --target ${dockername}:13-3.5.0-bookworm || true

echo "manifest: ${dockername}:13-3.5"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5 \
    --target ${dockername}:13-3.5 || true

# ----- 13-3.5-bullseye -----

echo "manifest: ${dockername}:13-3.5-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5-bullseye \
    --target ${dockername}:13-3.5-bullseye || true

echo "manifest: ${dockername}:13-3.5.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.5.0-bullseye \
    --target ${dockername}:13-3.5.0-bullseye || true

# ----- 14-3.3-alpine3.20 -----

echo "manifest: ${dockername}:14-3.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.3-alpine3.20 \
    --target ${dockername}:14-3.3-alpine3.20 || true

echo "manifest: ${dockername}:14-3.3.7-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.3.7-alpine3.20 \
    --target ${dockername}:14-3.3.7-alpine3.20 || true

echo "manifest: ${dockername}:14-3.3-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.3-alpine \
    --target ${dockername}:14-3.3-alpine || true

# ----- 14-3.4-alpine3.19 -----

echo "manifest: ${dockername}:14-3.4-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-alpine3.19 \
    --target ${dockername}:14-3.4-alpine3.19 || true

echo "manifest: ${dockername}:14-3.4.3-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4.3-alpine3.19 \
    --target ${dockername}:14-3.4.3-alpine3.19 || true

# ----- 14-3.4-alpine3.20 -----

echo "manifest: ${dockername}:14-3.4-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-alpine3.20 \
    --target ${dockername}:14-3.4-alpine3.20 || true

echo "manifest: ${dockername}:14-3.4.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4.3-alpine3.20 \
    --target ${dockername}:14-3.4.3-alpine3.20 || true

echo "manifest: ${dockername}:14-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-alpine \
    --target ${dockername}:14-3.4-alpine || true

# ----- 14-3.5-alpine3.19 -----

echo "manifest: ${dockername}:14-3.5-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5-alpine3.19 \
    --target ${dockername}:14-3.5-alpine3.19 || true

echo "manifest: ${dockername}:14-3.5.0-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5.0-alpine3.19 \
    --target ${dockername}:14-3.5.0-alpine3.19 || true

# ----- 14-3.5-alpine3.20 -----

echo "manifest: ${dockername}:14-3.5-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5-alpine3.20 \
    --target ${dockername}:14-3.5-alpine3.20 || true

echo "manifest: ${dockername}:14-3.5.0-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5.0-alpine3.20 \
    --target ${dockername}:14-3.5.0-alpine3.20 || true

echo "manifest: ${dockername}:14-3.5-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5-alpine \
    --target ${dockername}:14-3.5-alpine || true

# ----- 14-3.5-bookworm -----

echo "manifest: ${dockername}:14-3.5-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5-bookworm \
    --target ${dockername}:14-3.5-bookworm || true

echo "manifest: ${dockername}:14-3.5.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5.0-bookworm \
    --target ${dockername}:14-3.5.0-bookworm || true

echo "manifest: ${dockername}:14-3.5"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5 \
    --target ${dockername}:14-3.5 || true

# ----- 14-3.5-bullseye -----

echo "manifest: ${dockername}:14-3.5-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5-bullseye \
    --target ${dockername}:14-3.5-bullseye || true

echo "manifest: ${dockername}:14-3.5.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.5.0-bullseye \
    --target ${dockername}:14-3.5.0-bullseye || true

# ----- 14-l3.1.9gcp-bookworm -----

echo "manifest: ${dockername}:14-l3.1.9gcp-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-l3.1.9gcp-bookworm \
    --target ${dockername}:14-l3.1.9gcp-bookworm || true

echo "manifest: ${dockername}:14-l3.1.9gcp-postgis3.1.9-geos3.6.6-proj6.3.1-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-l3.1.9gcp-postgis3.1.9-geos3.6.6-proj6.3.1-bookworm \
    --target ${dockername}:14-l3.1.9gcp-postgis3.1.9-geos3.6.6-proj6.3.1-bookworm || true

# ----- 15-3.3-alpine3.20 -----

echo "manifest: ${dockername}:15-3.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.3-alpine3.20 \
    --target ${dockername}:15-3.3-alpine3.20 || true

echo "manifest: ${dockername}:15-3.3.7-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.3.7-alpine3.20 \
    --target ${dockername}:15-3.3.7-alpine3.20 || true

echo "manifest: ${dockername}:15-3.3-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.3-alpine \
    --target ${dockername}:15-3.3-alpine || true

# ----- 15-3.4-alpine3.19 -----

echo "manifest: ${dockername}:15-3.4-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-alpine3.19 \
    --target ${dockername}:15-3.4-alpine3.19 || true

echo "manifest: ${dockername}:15-3.4.3-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4.3-alpine3.19 \
    --target ${dockername}:15-3.4.3-alpine3.19 || true

# ----- 15-3.4-alpine3.20 -----

echo "manifest: ${dockername}:15-3.4-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-alpine3.20 \
    --target ${dockername}:15-3.4-alpine3.20 || true

echo "manifest: ${dockername}:15-3.4.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4.3-alpine3.20 \
    --target ${dockername}:15-3.4.3-alpine3.20 || true

echo "manifest: ${dockername}:15-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-alpine \
    --target ${dockername}:15-3.4-alpine || true

# ----- 15-3.5-alpine3.19 -----

echo "manifest: ${dockername}:15-3.5-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5-alpine3.19 \
    --target ${dockername}:15-3.5-alpine3.19 || true

echo "manifest: ${dockername}:15-3.5.0-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5.0-alpine3.19 \
    --target ${dockername}:15-3.5.0-alpine3.19 || true

# ----- 15-3.5-alpine3.20 -----

echo "manifest: ${dockername}:15-3.5-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5-alpine3.20 \
    --target ${dockername}:15-3.5-alpine3.20 || true

echo "manifest: ${dockername}:15-3.5.0-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5.0-alpine3.20 \
    --target ${dockername}:15-3.5.0-alpine3.20 || true

echo "manifest: ${dockername}:15-3.5-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5-alpine \
    --target ${dockername}:15-3.5-alpine || true

# ----- 15-3.5-bookworm -----

echo "manifest: ${dockername}:15-3.5-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5-bookworm \
    --target ${dockername}:15-3.5-bookworm || true

echo "manifest: ${dockername}:15-3.5.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5.0-bookworm \
    --target ${dockername}:15-3.5.0-bookworm || true

echo "manifest: ${dockername}:15-3.5"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5 \
    --target ${dockername}:15-3.5 || true

# ----- 15-3.5-bullseye -----

echo "manifest: ${dockername}:15-3.5-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5-bullseye \
    --target ${dockername}:15-3.5-bullseye || true

echo "manifest: ${dockername}:15-3.5.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.5.0-bullseye \
    --target ${dockername}:15-3.5.0-bullseye || true

# ----- 16-3.3-alpine3.20 -----

echo "manifest: ${dockername}:16-3.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.3-alpine3.20 \
    --target ${dockername}:16-3.3-alpine3.20 || true

echo "manifest: ${dockername}:16-3.3.7-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.3.7-alpine3.20 \
    --target ${dockername}:16-3.3.7-alpine3.20 || true

echo "manifest: ${dockername}:16-3.3-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.3-alpine \
    --target ${dockername}:16-3.3-alpine || true

# ----- 16-3.4-alpine3.19 -----

echo "manifest: ${dockername}:16-3.4-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-alpine3.19 \
    --target ${dockername}:16-3.4-alpine3.19 || true

echo "manifest: ${dockername}:16-3.4.3-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4.3-alpine3.19 \
    --target ${dockername}:16-3.4.3-alpine3.19 || true

# ----- 16-3.4-alpine3.20 -----

echo "manifest: ${dockername}:16-3.4-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-alpine3.20 \
    --target ${dockername}:16-3.4-alpine3.20 || true

echo "manifest: ${dockername}:16-3.4.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4.3-alpine3.20 \
    --target ${dockername}:16-3.4.3-alpine3.20 || true

echo "manifest: ${dockername}:16-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-alpine \
    --target ${dockername}:16-3.4-alpine || true

# ----- 16-3.5-alpine3.19 -----

echo "manifest: ${dockername}:16-3.5-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5-alpine3.19 \
    --target ${dockername}:16-3.5-alpine3.19 || true

echo "manifest: ${dockername}:16-3.5.0-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5.0-alpine3.19 \
    --target ${dockername}:16-3.5.0-alpine3.19 || true

# ----- 16-3.5-alpine3.20 -----

echo "manifest: ${dockername}:16-3.5-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5-alpine3.20 \
    --target ${dockername}:16-3.5-alpine3.20 || true

echo "manifest: ${dockername}:16-3.5.0-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5.0-alpine3.20 \
    --target ${dockername}:16-3.5.0-alpine3.20 || true

echo "manifest: ${dockername}:16-3.5-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5-alpine \
    --target ${dockername}:16-3.5-alpine || true

# ----- 16-3.5-bookworm -----

echo "manifest: ${dockername}:16-3.5-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5-bookworm \
    --target ${dockername}:16-3.5-bookworm || true

echo "manifest: ${dockername}:16-3.5.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5.0-bookworm \
    --target ${dockername}:16-3.5.0-bookworm || true

echo "manifest: ${dockername}:16-3.5"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5 \
    --target ${dockername}:16-3.5 || true

# ----- 16-3.5-bullseye -----

echo "manifest: ${dockername}:16-3.5-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5-bullseye \
    --target ${dockername}:16-3.5-bullseye || true

echo "manifest: ${dockername}:16-3.5.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5.0-bullseye \
    --target ${dockername}:16-3.5.0-bullseye || true

# ----- 16-3.5-bundle0-bookworm -----

echo "manifest: ${dockername}:16-3.5-bundle0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5-bundle0-bookworm \
    --target ${dockername}:16-3.5-bundle0-bookworm || true

echo "manifest: ${dockername}:16-3.5.0-bundle0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5.0-bundle0-bookworm \
    --target ${dockername}:16-3.5.0-bundle0-bookworm || true

echo "manifest: ${dockername}:16-3.5-bundle0"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.5-bundle0 \
    --target ${dockername}:16-3.5-bundle0 || true

# ----- 16-master-bookworm -----

echo "manifest: ${dockername}:16-master-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-master-bookworm \
    --target ${dockername}:16-master-bookworm || true

echo "manifest: ${dockername}:16-master"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-master \
    --target ${dockername}:16-master || true

# ----- 16-recent-bookworm -----

echo "manifest: ${dockername}:16-recent-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-recent-bookworm \
    --target ${dockername}:16-recent-bookworm || true

echo "manifest: ${dockername}:16-recent-postgis3.5.0-geos3.13.0-proj9.5.0-gdal3.9.3-cgal6.0-sfcgal2.0.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-recent-postgis3.5.0-geos3.13.0-proj9.5.0-gdal3.9.3-cgal6.0-sfcgal2.0.0-bookworm \
    --target ${dockername}:16-recent-postgis3.5.0-geos3.13.0-proj9.5.0-gdal3.9.3-cgal6.0-sfcgal2.0.0-bookworm || true

echo "manifest: ${dockername}:16-recent-postgis3.5-geos3.13-proj9.5-gdal3.9-cgal6.0-sfcgal2.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-recent-postgis3.5-geos3.13-proj9.5-gdal3.9-cgal6.0-sfcgal2.0-bookworm \
    --target ${dockername}:16-recent-postgis3.5-geos3.13-proj9.5-gdal3.9-cgal6.0-sfcgal2.0-bookworm || true

echo "manifest: ${dockername}:16-recent"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-recent \
    --target ${dockername}:16-recent || true

# ----- 17-3.4-alpine3.20 -----

echo "manifest: ${dockername}:17-3.4-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.4-alpine3.20 \
    --target ${dockername}:17-3.4-alpine3.20 || true

echo "manifest: ${dockername}:17-3.4.3-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.4.3-alpine3.20 \
    --target ${dockername}:17-3.4.3-alpine3.20 || true

echo "manifest: ${dockername}:17-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.4-alpine \
    --target ${dockername}:17-3.4-alpine || true

# ----- 17-3.5-alpine3.19 -----

echo "manifest: ${dockername}:17-3.5-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5-alpine3.19 \
    --target ${dockername}:17-3.5-alpine3.19 || true

echo "manifest: ${dockername}:17-3.5.0-alpine3.19"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5.0-alpine3.19 \
    --target ${dockername}:17-3.5.0-alpine3.19 || true

# ----- 17-3.5-alpine3.20 -----

echo "manifest: ${dockername}:17-3.5-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5-alpine3.20 \
    --target ${dockername}:17-3.5-alpine3.20 || true

echo "manifest: ${dockername}:17-3.5.0-alpine3.20"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5.0-alpine3.20 \
    --target ${dockername}:17-3.5.0-alpine3.20 || true

echo "manifest: ${dockername}:17-3.5-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5-alpine \
    --target ${dockername}:17-3.5-alpine || true

echo "manifest: ${dockername}:alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:alpine \
    --target ${dockername}:alpine || true

# ----- 17-3.5-bookworm -----

echo "manifest: ${dockername}:17-3.5-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5-bookworm \
    --target ${dockername}:17-3.5-bookworm || true

echo "manifest: ${dockername}:17-3.5.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5.0-bookworm \
    --target ${dockername}:17-3.5.0-bookworm || true

echo "manifest: ${dockername}:17-3.5"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5 \
    --target ${dockername}:17-3.5 || true

echo "manifest: ${dockername}:latest"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:latest \
    --target ${dockername}:latest || true

# ----- 17-3.5-bullseye -----

echo "manifest: ${dockername}:17-3.5-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5-bullseye \
    --target ${dockername}:17-3.5-bullseye || true

echo "manifest: ${dockername}:17-3.5.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-3.5.0-bullseye \
    --target ${dockername}:17-3.5.0-bullseye || true

# ----- 17-master-bookworm -----

echo "manifest: ${dockername}:17-master-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-master-bookworm \
    --target ${dockername}:17-master-bookworm || true

echo "manifest: ${dockername}:17-master"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-master \
    --target ${dockername}:17-master || true

# ----- 17-recent-bookworm -----

echo "manifest: ${dockername}:17-recent-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-recent-bookworm \
    --target ${dockername}:17-recent-bookworm || true

echo "manifest: ${dockername}:17-recent-postgis3.5.0-geos3.13.0-proj9.5.0-gdal3.9.3-cgal6.0-sfcgal2.0.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-recent-postgis3.5.0-geos3.13.0-proj9.5.0-gdal3.9.3-cgal6.0-sfcgal2.0.0-bookworm \
    --target ${dockername}:17-recent-postgis3.5.0-geos3.13.0-proj9.5.0-gdal3.9.3-cgal6.0-sfcgal2.0.0-bookworm || true

echo "manifest: ${dockername}:17-recent-postgis3.5-geos3.13-proj9.5-gdal3.9-cgal6.0-sfcgal2.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-recent-postgis3.5-geos3.13-proj9.5-gdal3.9-cgal6.0-sfcgal2.0-bookworm \
    --target ${dockername}:17-recent-postgis3.5-geos3.13-proj9.5-gdal3.9-cgal6.0-sfcgal2.0-bookworm || true

echo "manifest: ${dockername}:17-recent"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:17-recent \
    --target ${dockername}:17-recent || true

echo "manifest: ${dockername}:recent"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:recent \
    --target ${dockername}:recent || true
