#!/usr/bin/env bash
set -Eeuo pipefail

# Enable TEST mode and use the local registry at localhost:5000 (as specified in the .env.test file).
export TEST=true
# Source environment variables and necessary configurations
source tools/environment_init.sh
[ -f ./versions.json ]

# Check if the container with name "registry" is already running
# https://docs.docker.com/registry/deploying/

docker ps -a

testregistry="postgistestregistry"
testregistry_cid=$(docker ps -q -f name="$testregistry")
echo "testregistry_cid=$testregistry_cid"

if [ -z "$testregistry_cid" ]; then
    # Not running - start registry
    docker pull registry:2
    docker run -d -p 5000:5000 --restart=always --name "$testregistry" registry:2
    # -v /mnt/registry:/var/lib/registry \
else
    # If running, output a message
    echo "Container with name: $testregistry is already running"
fi

# check update code
./update.sh

check-jsonschema --schemafile versions.schema.json versions.json

test_tag=17-3.5-bookworm

# check commands
make -n test-${test_tag}
make -n push-${test_tag}
make -n manifest-${test_tag}

# run commands
make test-${test_tag}
make push-${test_tag}
make manifest-${test_tag}

# check images
echo " "
echo " ---- generated images ---- "
make dockerlist

# check images
echo " "
echo " ---- check images exists ---- "
image_to_check="$test_tag"
if check_image_exists "$image_to_check"; then
    echo "Image '$image_to_check' is available."
else
    echo "Image '$image_to_check' does not exist."
    echo "Unexpected error .. STOP"
    exit 1
fi

# should not exists ....
if check_image_exists "99-9.9.9"; then
    echo "exist - Unexpected error .. STOP"
    exit 1
else
    echo "OK: not found check is OK"
fi

# check registy
echo " --- registry --- "
make lregistryinfo

echo " "
echo "WARNING:  Be carefull and not push the .localtest.sh script generated Dockerfiles,"
echo "          because contains reference to the test REGISTRY, REPO_NAME and IMAGE_NAME!"
echo " "
echo "done."
