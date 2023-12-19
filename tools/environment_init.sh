#!/usr/bin/env bash
set -Eeuo pipefail

# Check if IMAGE_VERSION_ID is already set
if [ -n "${IMAGE_VERSION_ID:-}" ]; then
    # note: Script already ran, exiting early.
    return 0
fi

# Load .env files config.
set -a
if [[ "${TEST:-}" == "true" ]]; then
    # shellcheck disable=SC1091
    source .env.test
    echo "TEST MODE!"
else
    # shellcheck disable=SC1091
    source .env
fi
set +a

if [ -z "$REGISTRY" ] || [ -z "$REPO_NAME" ] || [ -z "$IMAGE_NAME" ]; then
    echo "Error: REGISTRY,REPO_NAME and IMAGE_NAME must be set" >&2
    exit 1
fi

# Determine IMAGE_ARCH based on the machine architecture
if [[ "$(uname -m)" == "x86_64" ]]; then
    IMAGE_ARCH=amd64
elif [[ "$(uname -m)" == "aarch64" ]]; then
    IMAGE_ARCH=arm64
else
    echo "Architecture not supported: $(uname -m)"
    exit 1
fi
export IMAGE_ARCH

# Modify IMAGE_NAME if ENABLE_IMAGE_ARCH is set to true
if [[ "${ENABLE_IMAGE_ARCH:-}" == "true" ]]; then
    IMAGE_NAME="${IMAGE_NAME}-${IMAGE_ARCH}"
fi
export IMAGE_NAME

# Override the default values of variables
# by setting the corresponding environment variables, if needed.
if [[ "$REGISTRY" == "docker.io" ]]; then
    dockername="${REPO_NAME}/${IMAGE_NAME}"
else
    dockername="${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}"

fi
export dockername

# Initialize IMAGE_VERSION_ID as an empty string
IMAGE_VERSION_ID=""
# Generate IMAGE_VERSION_ID if ENABLE_IMAGE_VERSION_ID is set to true
if [[ "${ENABLE_IMAGE_VERSION_ID:-}" == "true" ]]; then
    # Note: Make sure to keep this synchronized with the corresponding section in Makefile
    COMMIT_DATE=$(git log -1 --format=%cd --date=format:%Y%m%d)
    COMMIT_HASH=$(git log -1 --pretty=format:%h)
    BUILD_WEEK=$(date '+%Yw%V')
    IMAGE_VERSION_ID="-ver${COMMIT_DATE}-${COMMIT_HASH}-${BUILD_WEEK}"
fi
export IMAGE_VERSION_ID

echo " ----  .env file loaded ----"
echo " - REGISTRY        : $REGISTRY"
echo " - REPO_NAME       : $REPO_NAME"
echo " - IMAGE_NAME      : $IMAGE_NAME"
echo " - IMAGE_ARCH      : $IMAGE_ARCH"
echo " - dockername      : ${dockername}"
echo " - IMAGE_VERSION_ID: ${IMAGE_VERSION_ID}"
echo " "

# Verify that the required command-line tools (jq, gawk, python3, .. ) are available in the system's PATH.
# Exit with an error message if any of them are missing.
for cmd in docker jq gawk curl python3 manifest-tool lastversion; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# Ensure that the necessary Python modules (yaml, json) are installed and can be imported.
# Exit with an error message if any of them are missing.
if ! python3 -c 'import yaml, json' &>/dev/null; then
    echo "Error: Required python3 modules (yaml or json) are not installed."
    echo "       Please install them using 'pip3 install yaml json'."
    exit 1
fi

# Define a function to check for the existence of a Docker image tag.
# Usage:
#   check_image_exists "tag"
#
# This function uses `manifest-tool` to inspect the image manifest. It is a more reliable way to check
# for image existence across different platforms and registries without requiring the image to be pulled locally.
#
# The function prints a message indicating whether the image-tag exists and returns an exit code.
# Exit code 0 indicates that the image-tag exists, while 1 indicates non-existence.
function check_image_exists() {
    local image_name="${dockername}:$1"
    local output
    local secure_opt=""

    # Check if dockername contains 'localhost:5000'
    if [[ $dockername == *"localhost:5000"* ]]; then
        echo "The name contains 'localhost:5000' ; insecure and plain-http mode is enabled !"
        secure_opt=" --insecure --plain-http "
    else
        secure_opt=""
    fi

    # Attempt to inspect the image using manifest-tool. Capture the output, including any errors.
    output=$(manifest-tool "${secure_opt}" inspect "$image_name" 2>&1 || true)
    # Check the output for a "not found" message, which indicates the image does not exist.
    if echo "$output" | grep -q "not found"; then
        echo "The Docker image '$image_name' does not exist."
        return 1 # Return an exit code of 1 to signify the image does not exist.
    else
        echo "The Docker image '$image_name' exists."
        return 0 # # Return an exit code of 0 to signify the image exists.
    fi
}

export -f check_image_exists
