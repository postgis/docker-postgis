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
    [9.6]='stretch-slim'
    [10]='stretch-slim'
    [11]='stretch-slim'
    [12]='buster-slim'
    [13]='buster-slim'
)

defaultPostgisDebPkgNameVersionSuffix='3'
declare -A postgisDebPkgNameVersionSuffixes=(
    [2.5]='2.5'
    [3.0]='3'    
    [3.1]='3'
)

packagesBase='http://apt.postgresql.org/pub/repos/apt/dists/'

sfcgalGitHash="$(git ls-remote https://gitlab.com/Oslandia/SFCGAL.git heads/master | awk '{ print $1}')"
projGitHash="$(git ls-remote https://github.com/OSGeo/PROJ.git heads/master | awk '{ print $1}')"
gdalGitHash="$(git ls-remote https://github.com/OSGeo/gdal.git refs/heads/master | grep '\srefs/heads/master' | awk '{ print $1}')"
geosGitHash="$(git ls-remote https://github.com/libgeos/geos.git heads/main | awk '{ print $1}')"
postgisGitHash="$(git ls-remote https://git.osgeo.org/gitea/postgis/postgis.git heads/master | awk '{ print $1}')"

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

    if [ "$suite" = "stretch" ]; then
        boostVersion="1.62.0"
        cdalVersion="12"
    else
        boostVersion="1.67.0"
        cdalVersion="13"
    fi

    if [ "master" == "$postgisVersion" ]; then
        postgisPackageName=""
        postgisFullVersion="$postgisVersion"
        postgisMajor=""
    else
        postgisPackageName="postgresql-${postgresVersion}-postgis-${postgisDebPkgNameVersionSuffixes[${postgisVersion}]}"
        postgisFullVersion="$(echo "$versionList" | awk -F ': ' '$1 == "Package" { pkg = $2 } $1 == "Version" && pkg == "'"$postgisPackageName"'" { print $2; exit }' || true)"
        postgisMajor="${postgisDebPkgNameVersionSuffixes[${postgisVersion}]}"
    fi
    (
        set -x
        cp -p Dockerfile.template initdb-postgis.sh update-postgis.sh README.md "$version/"
        if [ "master" == "$postgisVersion" ]; then
          cp -p Dockerfile.master.template "$version/Dockerfile.template"
        fi
        mv "$version/Dockerfile.template" "$version/Dockerfile"
        sed -i 's/%%PG_MAJOR%%/'$postgresVersion'/g; s/%%POSTGIS_MAJOR%%/'$postgisMajor'/g; s/%%POSTGIS_VERSION%%/'$postgisFullVersion'/g; s/%%POSTGIS_GIT_HASH%%/'$postgisGitHash'/g; s/%%SFCGAL_GIT_HASH%%/'$sfcgalGitHash'/g; s/%%PROJ_GIT_HASH%%/'$projGitHash'/g; s/%%GDAL_GIT_HASH%%/'$gdalGitHash'/g; s/%%GEOS_GIT_HASH%%/'$geosGitHash'/g; s/%%BOOST_VERSION%%/'"$boostVersion"'/g; s/%%CDAL_VERSION%%/'"$cdalVersion"'/g;' "$version/Dockerfile"
    )

    if [ "master" == "$postgisVersion" ]; then
        srcVersion=""
        srcSha256=""
    else
        srcVersion="${postgisFullVersion%%+*}"
        srcSha256="$(curl -sSL "https://github.com/postgis/postgis/archive/$srcVersion.tar.gz" | sha256sum | awk '{ print $1 }')"
    fi
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
#travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"

# *** TRAVIS IS DISABLED FOR NOW ***
#echo "$travis" > .travis.yml

