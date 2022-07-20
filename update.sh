#!/bin/bash
# Derived from https://github.com/docker-library/postgres/blob/master/update.sh
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */Dockerfile )
fi
versions=( "${versions[@]%/Dockerfile}" )

for optimized in debian alpine test; do
    rm -f      _dockerlists_${optimized}.md
    echo " " > _dockerlists_${optimized}.md
    echo "| DockerHub image | Dockerfile | OS | Postgres | PostGIS |" >> _dockerlists_${optimized}.md
    echo "| --------------- | ---------- | -- | -------- | ------- |" >> _dockerlists_${optimized}.md
done

dockerhublink="https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name="
githubrepolink="https://github.com/postgis/docker-postgis/blob/master"

# sort version numbers with highest last (so it goes first in .travis.yml)
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -V) ); unset IFS

defaultDebianSuite='bullseye-slim'
declare -A debianSuite=(
    # https://github.com/docker-library/postgres/issues/582
    [9.6]='bullseye-slim'
    [10]='bullseye-slim'
    [11]='bullseye-slim'
    [12]='bullseye-slim'
    [13]='bullseye-slim'
    [14]='bullseye-slim'
    [15]='bullseye-slim'
)

defaultPostgisDebPkgNameVersionSuffix='3'
declare -A postgisDebPkgNameVersionSuffixes=(
    [2.5]='2.5'
    [3.0]='3'
    [3.1]='3'
    [3.2]='3'
    [3.3]='3'
)

packagesBase='http://apt.postgresql.org/pub/repos/apt/dists/'

sfcgalGitHash="$(git ls-remote https://gitlab.com/Oslandia/SFCGAL.git heads/master | awk '{ print $1}')"
projGitHash="$(git ls-remote https://github.com/OSGeo/PROJ.git heads/master | awk '{ print $1}')"
gdalGitHash="$(git ls-remote https://github.com/OSGeo/gdal.git refs/heads/master | grep '\srefs/heads/master' | awk '{ print $1}')"
geosGitHash="$(git ls-remote https://github.com/libgeos/geos.git heads/main | awk '{ print $1}')"
postgisGitHash="$(git ls-remote https://github.com/postgis/postgis.git heads/master | awk '{ print $1}')"

declare -A suitePackageList=() suiteArches=()
for version in "${versions[@]}"; do
    IFS=- read postgresVersion postgisVersion <<< "$version"

    echo " "
    echo "---- generate Dockerfile for $version ----"
    echo "postgresVersion=$postgresVersion"
    echo "postgisVersion=$postgisVersion"

    if [ "2.5" == "$postgisVersion" ]; then
        # posgis 2.5 only in the stretch ; no bullseye version
        tag='stretch-slim'
    else
        tag="${debianSuite[$postgresVersion]:-$defaultDebianSuite}"
    fi
    suite="${tag%%-slim}"

    if [ -z "${suitePackageList["$suite"]:+isset}" ]; then
        suitePackageList["$suite"]="$(curl -fsSL "${packagesBase}/${suite}-pgdg/main/binary-amd64/Packages.bz2" | bunzip2)"
    fi
    if [ -z "${suiteArches["$suite"]:+isset}" ]; then
        suiteArches["$suite"]="$(curl -fsSL "${packagesBase}/${suite}-pgdg/Release" | awk -F ':[[:space:]]+' '$1 == "Architectures" { gsub(/[[:space:]]+/, "|", $2); print $2 }')"
    fi

    postgresVersionMain="$(echo "$postgresVersion" | awk -F 'alpha|beta|rc' '{print $1}')"
    versionList="$(echo "${suitePackageList["$suite"]}"; curl -fsSL "${packagesBase}/${suite}-pgdg/${postgresVersionMain}/binary-amd64/Packages.bz2" | bunzip2)"
    fullVersion="$(echo "$versionList" | awk -F ': ' '$1 == "Package" { pkg = $2 } $1 == "Version" && pkg == "postgresql-'"$postgresVersionMain"'" { print $2; exit }' || true)"

    if [ "$suite" = "bullseye" ]; then
        boostVersion="1.74.0"
    elif [ "$suite" = "buster" ]; then
        boostVersion="1.67.0"
    elif [ "$suite" = "stretch" ]; then
        boostVersion="1.62.0"
    else
        echo "Unknown debian version; stop"
        exit 1
    fi


    optimized=""
    if [[ "$version" =~ "alpha" || "$version" =~ "beta" || "$version" =~ "rc" || "$version" =~ "master" ]];
    then
        optimized="test"
    else
        optimized="debian"
    fi
    echo "optimized=$optimized"

    debianPostgisMajMin=""
    if [ "master" == "$postgisVersion" ]; then
        postgisPackageName=""
        postgisFullVersion="$postgisVersion"
        postgisMajor=""
        postgisDocSrc="development: postgis, geos, proj, gdal"
    else
        postgisMajMin="$( echo "${postgisVersion}" | cut -d. -f1 ).$( echo "${postgisVersion}" | cut -d. -f2 )"
        echo "postgisMajMin=${postgisMajMin}"

        postgisPackageName="postgresql-${postgresVersionMain}-postgis-${postgisDebPkgNameVersionSuffixes[${postgisMajMin}]}"
        postgisFullVersion="$(echo "$versionList" | awk -F ': ' '$1 == "Package" { pkg = $2 } $1 == "Version" && pkg == "'"$postgisPackageName"'" { print $2; exit }' || true)"
        echo "postgisPackageName=${postgisPackageName}"
        echo "postgisFullVersion=${postgisFullVersion}"

        debianPostgisMajMin="$( echo "${postgisFullVersion}" | cut -d. -f1 ).$( echo "${postgisFullVersion}" | cut -d. -f2 )"

        if [ "$debianPostgisMajMin" == "$postgisMajMin" ]; then
            echo "debian postgis version is OK "
            postgisMajor="${postgisDebPkgNameVersionSuffixes[${postgisMajMin}]}"
            postgisDocSrc="${postgisFullVersion%%+*}"
        else
            echo "debian postgis is not updated, different .. "
            postgisFullVersion=""
            postgisMajor=""
            postgisDocSrc=""
        fi
    fi

    if [ -z "$postgisFullVersion" ]
    then
        echo "skip debain version";
        # debain version not found;
        echo " # placeholder Dockerfile"                                         > "$version/Dockerfile"
        echo " # Debian version of postgis $postgisFullVersion is not detected!">> "$version/Dockerfile"
        echo " # This is an autogenerated message of ./update.sh "              >> "$version/Dockerfile"
        rm -f "$version/*.sh"
        rm -f "$version/*.md"
        # use the default for the alpine version
        postgisFullVersion=$postgisVersion
        postgisDocSrc=$postgisVersion
    else
        (
            set -x
            cp -p initdb-postgis.sh update-postgis.sh "$version/"
            if [ "master" == "$postgisVersion" ]; then
              cat Dockerfile.master.template > "$version/Dockerfile"
            else
              cat Dockerfile.template        > "$version/Dockerfile"
            fi
            sed -i 's/%%PG_MAJOR%%/'$postgresVersion'/g; s/%%POSTGIS_MAJOR%%/'$postgisMajor'/g; s/%%POSTGIS_VERSION%%/'$postgisFullVersion'/g; s/%%POSTGIS_GIT_HASH%%/'$postgisGitHash'/g; s/%%SFCGAL_GIT_HASH%%/'$sfcgalGitHash'/g; s/%%PROJ_GIT_HASH%%/'$projGitHash'/g; s/%%GDAL_GIT_HASH%%/'$gdalGitHash'/g; s/%%GEOS_GIT_HASH%%/'$geosGitHash'/g; s/%%BOOST_VERSION%%/'"$boostVersion"'/g; s/%%DEBIAN_VERSION%%/'"$suite"'/g;' "$version/Dockerfile"

            echo "| [postgis/postgis:${version}](${dockerhublink}${version}) | [Dockerfile](${githubrepolink}/${version}/Dockerfile) | debian:${suite} | ${postgresVersion} | ${postgisDocSrc} |" >> _dockerlists_${optimized}.md
        )
    fi

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
            if [ "$optimized" != "test" ]; then
              optimized="alpine"
            fi
            cp -p Dockerfile.alpine.template initdb-postgis.sh update-postgis.sh "$version/$variant/"
            mv "$version/$variant/Dockerfile.alpine.template" "$version/$variant/Dockerfile"
            sed -i 's/%%PG_MAJOR%%/'"$postgresVersion"'/g; s/%%POSTGIS_VERSION%%/'"$srcVersion"'/g; s/%%POSTGIS_SHA256%%/'"$srcSha256"'/g' "$version/$variant/Dockerfile"

            echo "| [postgis/postgis:${version}-${variant}](${dockerhublink}${version}-${variant}) | [Dockerfile](${githubrepolink}/${version}/${variant}/Dockerfile) | alpine:3.16 | ${postgresVersion} | ${postgisDocSrc} |" >> _dockerlists_${optimized}.md
        )
    done
done

echo "|-------------------------|"
echo "|-   Generated images    -|"
echo "|-------------------------|"

for optimized in debian alpine test; do
    echo " "
    echo "---- ${optimized} ----"
    cat _dockerlists_${optimized}.md
done

echo " "
echo "Postprocessing todo:"
echo "- add the new versions to README.md ( manually )"
ls -la  _dockerlists_*.md
echo " "
echo " - done - "
