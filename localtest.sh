#!/usr/bin/env bash
set -Eeuo pipefail

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

# Enable TEST mode and use the local registry at localhost:5000 (as specified in the .env.test file).
export TEST=true
set -a
# shellcheck disable=SC1091
source .env.test
set +a

echo " "
echo "Test mode = $TEST ; Reading from the .env.test file !"
echo " ------- .env.test -------- "
cat .env.test
echo " -------------------------- "

./update.sh

# check commands
make -n test-15-3.4-bundle0-bookworm
make -n push-15-3.4-bundle0-bookworm
make -n manifest-15-3.4-bundle0-bookworm

# run commands
make test-15-3.4-bundle0-bookworm
make push-15-3.4-bundle0-bookworm
make manifest-15-3.4-bundle0-bookworm

# check images
echo " "
echo " ---- generated images ---- "
make dockerlist

# check registy
echo " "
make lregistryinfo

echo " "
echo "WARNING:  Be carefull and not push the .localtest.sh script generated Dockerfiles,"
echo "          because contains reference to the test REGISTRY, REPO_NAME and IMAGE_NAME!"
echo " "
echo "done."

#  manual tests cheetsheets:
#  ----------------------------
#  REGISTRY=localhost:5000  make push-15-3.4-bundle0
#  REGISTRY=localhost:5000  make push-15-3.4-bundle0-bookworm
#  TEST=true                make push-15-3.4-bundle0-bookworm
#
