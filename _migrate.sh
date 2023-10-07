#!/bin/sh

# temporary files, only for the migration.
# will be removed...

debian_move() {
    mkdir -p "$1/bullseye"
    mkdir -p "$1/bookworm"

    git mv "$1/Dockerfile" "$1/bullseye/Dockerfile"
    git mv "$1/initdb-postgis.sh" "$1/bullseye/initdb-postgis.sh"
    git mv "$1/update-postgis.sh" "$1/bullseye/update-postgis.sh"

    cp "$1/bullseye/Dockerfile" "$1/bookworm/Dockerfile"
    cp "$1/bullseye/initdb-postgis.sh" "$1/bookworm/initdb-postgis.sh"
    cp "$1/bullseye/update-postgis.sh" "$1/bookworm/update-postgis.sh"

    git add "$1/bookworm/Dockerfile"
    git add "$1/bookworm/initdb-postgis.sh"
    git add "$1/bookworm/update-postgis.sh"
}

bookworm_move() {
    mkdir -p "$1/bookworm"
    git mv "$1/Dockerfile" "$1/bookworm/Dockerfile"
    git mv "$1/initdb-postgis.sh" "$1/bookworm/initdb-postgis.sh"
    git mv "$1/update-postgis.sh" "$1/bookworm/update-postgis.sh"
}

alpine_move() {
    git mv "$1/alpine" "$1/alpine3.18"
}

debian_move 11-3.3
debian_move 12-3.4
debian_move 13-3.4
debian_move 14-3.4
debian_move 15-3.4
debian_move 16beta3-3.4

bookworm_move 14-master
bookworm_move 15-master
bookworm_move 16beta3-master

alpine_move 11-3.3
alpine_move 12-3.4
alpine_move 13-3.4
alpine_move 14-3.4
alpine_move 15-3.4
alpine_move 16beta3-3.4

git mv 16beta3-3.4 16-3.4
git mv 16beta3-master 16-master

git mv Dockerfile.template Dockerfile.debian.template

mkdir -p 12-3.4-bundle
mkdir -p 13-3.4-bundle
mkdir -p 14-3.4-bundle
mkdir -p 15-3.4-bundle

mkdir -p 12-3.4-bundle/bookworm
mkdir -p 13-3.4-bundle/bookworm
mkdir -p 14-3.4-bundle/bookworm
mkdir -p 15-3.4-bundle/bookworm

touch 12-3.4-bundle/bookworm/Dockerfile
touch 13-3.4-bundle/bookworm/Dockerfile
touch 14-3.4-bundle/bookworm/Dockerfile
touch 15-3.4-bundle/bookworm/Dockerfile
