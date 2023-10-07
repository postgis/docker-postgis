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

# ----- 11-3.3-alpine3.18 -----

echo "manifest: ${dockername}:11-3.3-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3-alpine3.18 \
    --target ${dockername}:11-3.3-alpine3.18 || true

echo "manifest: ${dockername}:11-3.3.4-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3.4-alpine3.18 \
    --target ${dockername}:11-3.3.4-alpine3.18 || true

echo "manifest: ${dockername}:11-3.3-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3-alpine \
    --target ${dockername}:11-3.3-alpine || true

# ----- 11-3.3-bookworm -----

echo "manifest: ${dockername}:11-3.3-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3-bookworm \
    --target ${dockername}:11-3.3-bookworm || true

echo "manifest: ${dockername}:11-3.3.4-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3.4-bookworm \
    --target ${dockername}:11-3.3.4-bookworm || true

echo "manifest: ${dockername}:11-3.3"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3 \
    --target ${dockername}:11-3.3 || true

# ----- 11-3.3-bullseye -----

echo "manifest: ${dockername}:11-3.3-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3-bullseye \
    --target ${dockername}:11-3.3-bullseye || true

echo "manifest: ${dockername}:11-3.3.4-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:11-3.3.4-bullseye \
    --target ${dockername}:11-3.3.4-bullseye || true

# ----- 12-3.4-alpine3.18 -----

echo "manifest: ${dockername}:12-3.4-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4-alpine3.18 \
    --target ${dockername}:12-3.4-alpine3.18 || true

echo "manifest: ${dockername}:12-3.4.0-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4.0-alpine3.18 \
    --target ${dockername}:12-3.4.0-alpine3.18 || true

echo "manifest: ${dockername}:12-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4-alpine \
    --target ${dockername}:12-3.4-alpine || true

# ----- 12-3.4-bookworm -----

echo "manifest: ${dockername}:12-3.4-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4-bookworm \
    --target ${dockername}:12-3.4-bookworm || true

echo "manifest: ${dockername}:12-3.4.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4.0-bookworm \
    --target ${dockername}:12-3.4.0-bookworm || true

echo "manifest: ${dockername}:12-3.4"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4 \
    --target ${dockername}:12-3.4 || true

# ----- 12-3.4-bullseye -----

echo "manifest: ${dockername}:12-3.4-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4-bullseye \
    --target ${dockername}:12-3.4-bullseye || true

echo "manifest: ${dockername}:12-3.4.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:12-3.4.0-bullseye \
    --target ${dockername}:12-3.4.0-bullseye || true

# ----- 13-3.4-alpine3.18 -----

echo "manifest: ${dockername}:13-3.4-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-alpine3.18 \
    --target ${dockername}:13-3.4-alpine3.18 || true

echo "manifest: ${dockername}:13-3.4.0-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4.0-alpine3.18 \
    --target ${dockername}:13-3.4.0-alpine3.18 || true

echo "manifest: ${dockername}:13-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-alpine \
    --target ${dockername}:13-3.4-alpine || true

# ----- 13-3.4-bookworm -----

echo "manifest: ${dockername}:13-3.4-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-bookworm \
    --target ${dockername}:13-3.4-bookworm || true

echo "manifest: ${dockername}:13-3.4.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4.0-bookworm \
    --target ${dockername}:13-3.4.0-bookworm || true

echo "manifest: ${dockername}:13-3.4"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4 \
    --target ${dockername}:13-3.4 || true

# ----- 13-3.4-bullseye -----

echo "manifest: ${dockername}:13-3.4-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-bullseye \
    --target ${dockername}:13-3.4-bullseye || true

echo "manifest: ${dockername}:13-3.4.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4.0-bullseye \
    --target ${dockername}:13-3.4.0-bullseye || true

# ----- 13-3.4-bundle-bookworm -----

echo "manifest: ${dockername}:13-3.4-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-bundle-bookworm \
    --target ${dockername}:13-3.4-bundle-bookworm || true

echo "manifest: ${dockername}:13-3.4.0-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4.0-bundle-bookworm \
    --target ${dockername}:13-3.4.0-bundle-bookworm || true

echo "manifest: ${dockername}:13-3.4-bundle"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:13-3.4-bundle \
    --target ${dockername}:13-3.4-bundle || true

# ----- 14-3.4-alpine3.18 -----

echo "manifest: ${dockername}:14-3.4-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-alpine3.18 \
    --target ${dockername}:14-3.4-alpine3.18 || true

echo "manifest: ${dockername}:14-3.4.0-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4.0-alpine3.18 \
    --target ${dockername}:14-3.4.0-alpine3.18 || true

echo "manifest: ${dockername}:14-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-alpine \
    --target ${dockername}:14-3.4-alpine || true

# ----- 14-3.4-bookworm -----

echo "manifest: ${dockername}:14-3.4-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-bookworm \
    --target ${dockername}:14-3.4-bookworm || true

echo "manifest: ${dockername}:14-3.4.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4.0-bookworm \
    --target ${dockername}:14-3.4.0-bookworm || true

echo "manifest: ${dockername}:14-3.4"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4 \
    --target ${dockername}:14-3.4 || true

# ----- 14-3.4-bullseye -----

echo "manifest: ${dockername}:14-3.4-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-bullseye \
    --target ${dockername}:14-3.4-bullseye || true

echo "manifest: ${dockername}:14-3.4.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4.0-bullseye \
    --target ${dockername}:14-3.4.0-bullseye || true

# ----- 14-3.4-bundle-bookworm -----

echo "manifest: ${dockername}:14-3.4-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-bundle-bookworm \
    --target ${dockername}:14-3.4-bundle-bookworm || true

echo "manifest: ${dockername}:14-3.4.0-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4.0-bundle-bookworm \
    --target ${dockername}:14-3.4.0-bundle-bookworm || true

echo "manifest: ${dockername}:14-3.4-bundle"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:14-3.4-bundle \
    --target ${dockername}:14-3.4-bundle || true

# ----- 15-3.4-alpine3.18 -----

echo "manifest: ${dockername}:15-3.4-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-alpine3.18 \
    --target ${dockername}:15-3.4-alpine3.18 || true

echo "manifest: ${dockername}:15-3.4.0-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4.0-alpine3.18 \
    --target ${dockername}:15-3.4.0-alpine3.18 || true

echo "manifest: ${dockername}:15-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-alpine \
    --target ${dockername}:15-3.4-alpine || true

echo "manifest: ${dockername}:alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:alpine \
    --target ${dockername}:alpine || true

# ----- 15-3.4-bookworm -----

echo "manifest: ${dockername}:15-3.4-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-bookworm \
    --target ${dockername}:15-3.4-bookworm || true

echo "manifest: ${dockername}:15-3.4.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4.0-bookworm \
    --target ${dockername}:15-3.4.0-bookworm || true

echo "manifest: ${dockername}:15-3.4"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4 \
    --target ${dockername}:15-3.4 || true

echo "manifest: ${dockername}:latest"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:latest \
    --target ${dockername}:latest || true

# ----- 15-3.4-bullseye -----

echo "manifest: ${dockername}:15-3.4-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-bullseye \
    --target ${dockername}:15-3.4-bullseye || true

echo "manifest: ${dockername}:15-3.4.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4.0-bullseye \
    --target ${dockername}:15-3.4.0-bullseye || true

# ----- 15-3.4-bundle-bookworm -----

echo "manifest: ${dockername}:15-3.4-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-bundle-bookworm \
    --target ${dockername}:15-3.4-bundle-bookworm || true

echo "manifest: ${dockername}:15-3.4.0-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4.0-bundle-bookworm \
    --target ${dockername}:15-3.4.0-bundle-bookworm || true

echo "manifest: ${dockername}:15-3.4-bundle"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-3.4-bundle \
    --target ${dockername}:15-3.4-bundle || true

echo "manifest: ${dockername}:bundle"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:bundle \
    --target ${dockername}:bundle || true

# ----- 15-master-bookworm -----

echo "manifest: ${dockername}:15-master-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-master-bookworm \
    --target ${dockername}:15-master-bookworm || true

echo "manifest: ${dockername}:15-master"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-master \
    --target ${dockername}:15-master || true

# ----- 15-recentstack-bookworm -----

echo "manifest: ${dockername}:15-recentstack-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-recentstack-bookworm \
    --target ${dockername}:15-recentstack-bookworm || true

echo "manifest: ${dockername}:15-recentstack"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:15-recentstack \
    --target ${dockername}:15-recentstack || true

# ----- 16-3.4-alpine3.18 -----

echo "manifest: ${dockername}:16-3.4-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-alpine3.18 \
    --target ${dockername}:16-3.4-alpine3.18 || true

echo "manifest: ${dockername}:16-3.4.0-alpine3.18"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4.0-alpine3.18 \
    --target ${dockername}:16-3.4.0-alpine3.18 || true

echo "manifest: ${dockername}:16-3.4-alpine"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-alpine \
    --target ${dockername}:16-3.4-alpine || true

# ----- 16-3.4-bookworm -----

echo "manifest: ${dockername}:16-3.4-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-bookworm \
    --target ${dockername}:16-3.4-bookworm || true

echo "manifest: ${dockername}:16-3.4.0-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4.0-bookworm \
    --target ${dockername}:16-3.4.0-bookworm || true

echo "manifest: ${dockername}:16-3.4"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4 \
    --target ${dockername}:16-3.4 || true

# ----- 16-3.4-bullseye -----

echo "manifest: ${dockername}:16-3.4-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-bullseye \
    --target ${dockername}:16-3.4-bullseye || true

echo "manifest: ${dockername}:16-3.4.0-bullseye"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4.0-bullseye \
    --target ${dockername}:16-3.4.0-bullseye || true

# ----- 16-3.4-bundle-bookworm -----

echo "manifest: ${dockername}:16-3.4-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-bundle-bookworm \
    --target ${dockername}:16-3.4-bundle-bookworm || true

echo "manifest: ${dockername}:16-3.4.0-bundle-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4.0-bundle-bookworm \
    --target ${dockername}:16-3.4.0-bundle-bookworm || true

echo "manifest: ${dockername}:16-3.4-bundle"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-3.4-bundle \
    --target ${dockername}:16-3.4-bundle || true

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

# ----- 16-recentstack-bookworm -----

echo "manifest: ${dockername}:16-recentstack-bookworm"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-recentstack-bookworm \
    --target ${dockername}:16-recentstack-bookworm || true

echo "manifest: ${dockername}:16-recentstack"
manifest-tool push from-args \
    --platforms linux/amd64,linux/arm64 \
    --template ${dockername}-ARCHVARIANT:16-recentstack \
    --target ${dockername}:16-recentstack || true
