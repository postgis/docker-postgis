#!/bin/bash
# Derived from https://github.com/docker-library/postgres/blob/master/update.sh
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */Dockerfile )
fi
versions=( "${versions[@]%/Dockerfile}" )

# sort version numbers with highest last (so it goes first in .travis.yml)
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -V) ); unset IFS

defaultDebianSuite='buster-slim'
declare -A debianSuite=(
    # https://github.com/docker-library/postgres/issues/582
    [9.5]='stretch-slim'
    [9.6]='stretch-slim'
    [10]='stretch-slim'
    [11]='stretch-slim'
)
defaultAlpineVersion='3.11'
declare -A alpineVersion=(
    #[9.6]='3.5'
)

defaultPostgisDebPkgNameVersionSuffix='3'
declare -A postgisDebPkgNameVersionSuffixes=(
    [2.5]='2.5'
    [3.0]='3'
)

packagesBase='http://apt.postgresql.org/pub/repos/apt/dists/'

declare -A suitePackageList=() suiteArches=()
travisEnv=
for version in "${versions[@]}"; do
    IFS=- read postgresVersion postgisVersion <<< "$version"

    tag="${debianSuite[$postgresVersion]:-$defaultDebianSuite}"
    suite="${tag%%-slim}"

    if [ -z "${suitePackageList["$suite"]:+isset}" ]; then
        suitePackageList["$suite"]="$(curl -fsSL "${packagesBase}/${suite}-pgdg/main/binary-amd64/Packages.bz2" | bunzip2)"
    fi
    if [ -z "${suiteArches["$suite"]:+isset}" ]; then
        suiteArches["$suite"]="$(curl -fsSL "${packagesBase}/${suite}-pgdg/Release" | awk -F ':[[:space:]]+' '$1 == "Architectures" { gsub(/[[:space:]]+/, "|", $2); print $2 }')"
    fi

    versionList="$(echo "${suitePackageList["$suite"]}"; curl -fsSL "${packagesBase}/${suite}-pgdg/${postgresVersion}/binary-amd64/Packages.bz2" | bunzip2)"
    fullVersion="$(echo "$versionList" | awk -F ': ' '$1 == "Package" { pkg = $2 } $1 == "Version" && pkg == "postgresql-'"$postgresVersion"'" { print $2; exit }' || true)"
    majorVersion="${postgresVersion%%.*}"

    postgisPackageName="postgresql-${postgresVersion}-postgis-${postgisDebPkgNameVersionSuffixes[${postgisVersion}]}"
    postgisFullVersion="$(echo "$versionList" | awk -F ': ' '$1 == "Package" { pkg = $2 } $1 == "Version" && pkg == "'"$postgisPackageName"'" { print $2; exit }' || true)"
    (
        set -x
        cp -p Dockerfile.template initdb-postgis.sh update-postgis.sh README.md "$version/"
        mv "$version/Dockerfile.template" "$version/Dockerfile"
        sed -i 's/%%PG_MAJOR%%/'$postgresVersion'/g; s/%%POSTGIS_MAJOR%%/'${postgisDebPkgNameVersionSuffixes[${postgisVersion}]}'/g; s/%%POSTGIS_VERSION%%/'$postgisFullVersion'/g' "$version/Dockerfile"
    )

    srcVersion="${postgisFullVersion%%+*}"
    srcSha256="$(curl -sSL "https://github.com/postgis/postgis/archive/$srcVersion.tar.gz" | sha256sum | awk '{ print $1 }')"
    for variant in alpine; do
        if [ ! -d "$version/$variant" ]; then
            continue
        fi
        (
            set -x
            cp -p Dockerfile.alpine.template initdb-postgis.sh update-postgis.sh "$version/$variant/"
            mv "$version/$variant/Dockerfile.alpine.template" "$version/$variant/Dockerfile"
            sed -i 's/%%PG_MAJOR%%/'"$postgresVersion"'/g; s/%%POSTGIS_VERSION%%/'"$srcVersion"'/g; s/%%POSTGIS_SHA256%%/'"$srcSha256"'/g' "$version/$variant/Dockerfile"
        )
        travisEnv="\n  - VERSION=$version VARIANT=$variant$travisEnv"
    done
    travisEnv='\n  - VERSION='"$version$travisEnv"

done
travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml

