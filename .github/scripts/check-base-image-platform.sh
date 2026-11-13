#!/usr/bin/env bash
#
# Check that every base image used by a Dockerfile is published for the
# native platform of the local Docker daemon (e.g. linux/arm64).
#
# Why: if a base image has no manifest for the native platform, Docker does
# NOT fail. It silently pulls a "compatible" one instead (for example
# linux/arm/v7 on an arm64 host) and only prints an InvalidBaseImagePlatform
# warning. The build then fails much later with confusing errors.
#
# Usage: check-base-image-platform.sh <path/to/Dockerfile>

set -euo pipefail

dockerfile="${1:?Usage: $0 <path/to/Dockerfile>}"


# Print the external base images referenced by FROM lines.
#  - ARG default values are substituted, e.g. FROM ${BASE_IMAGE}
#  - references to earlier build stages (FROM builder) are skipped
list_base_images() {
    local -A arg_defaults=()
    local -A stage_names=()
    local keyword value as_keyword stage_name name image

    while read -r keyword value as_keyword stage_name _; do
        case "${keyword^^}" in
            ARG)
                # ARG NAME=default
                if [[ "$value" == *=* ]]; then
                    arg_defaults["${value%%=*}"]="${value#*=}"
                fi
                ;;
            FROM)
                # FROM image [AS stage_name]
                image="$value"
                for name in "${!arg_defaults[@]}"; do
                    image="${image//\$\{$name\}/${arg_defaults[$name]}}"
                done

                if [[ -z "${stage_names[$image]:-}" ]]; then
                    echo "$image"
                fi

                if [[ "${as_keyword^^}" == "AS" ]]; then
                    stage_names["$stage_name"]=1
                fi
                ;;
        esac
    done < "$dockerfile"
}


# Return success if the image's manifest list contains the given os/arch.
image_has_platform() {
    local image="$1" os="$2" arch="$3"

    docker buildx imagetools inspect --raw "$image" \
        | jq --exit-status --arg os "$os" --arg arch "$arch" \
            '.manifests[]? | select(.platform.os == $os and .platform.architecture == $arch)' \
        > /dev/null
}


native_os=$(docker version --format '{{.Server.Os}}')
native_arch=$(docker version --format '{{.Server.Arch}}')
echo "Dockerfile:      $dockerfile"
echo "Native platform: $native_os/$native_arch"

missing=0
for image in $(list_base_images | sort -u); do
    if image_has_platform "$image" "$native_os" "$native_arch"; then
        echo "OK:      $image is available for $native_os/$native_arch"
    else
        echo "::error::Base image $image is not available for $native_os/$native_arch" \
             "(Docker would silently fall back to another platform, e.g. linux/arm/v7)"
        missing=1
    fi
done

exit "$missing"
