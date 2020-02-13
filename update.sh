#!/bin/bash
# Derived from https://github.com/docker-library/postgres/blob/master/update.sh
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */Dockerfile )
fi
versions=( "${versions[@]%/Dockerfile}" )

packagesUrlStretch='http://apt.postgresql.org/pub/repos/apt/dists/stretch-pgdg/main/binary-amd64/Packages'
packagesStretch="$(echo "$packagesUrlStretch" | sed -r 's/[^a-zA-Z.-]+/-/g')"
curl -sSL "${packagesUrlStretch}.bz2" | bunzip2 > "$packagesStretch"

packagesUrlBuster='http://apt.postgresql.org/pub/repos/apt/dists/buster-pgdg/main/binary-amd64/Packages'
packagesBuster="$(echo "$packagesUrlBuster" | sed -r 's/[^a-zA-Z.-]+/-/g')"
curl -sSL "${packagesUrlBuster}.bz2" | bunzip2 > "$packagesBuster"

travisEnv=
for version in "${versions[@]}"; do
	IFS=- read pg_major postgis_major <<< "$version"
	if [[ $pg_major = 12 ]]; then
		packages="$packagesBuster"
	else
		packages="$packagesStretch"
	fi

	fullVersion="$(grep -m1 -A10 "^Package: postgresql-$pg_major-postgis-$postgis_major\$" "$packages" | grep -m1 '^Version: ' | cut -d' ' -f2)"
	[ -z "$fullVersion" ] && { echo >&2 "Unable to find package for PostGIS $postgis_major on Postgres $pg_major"; exit 1; }
	(
		set -x
		cp Dockerfile.template initdb-postgis.sh update-postgis.sh README.md "$version/"
		mv "$version/Dockerfile.template" "$version/Dockerfile"
		sed -i 's/%%PG_MAJOR%%/'$pg_major'/g; s/%%POSTGIS_MAJOR%%/'$postgis_major'/g; s/%%POSTGIS_VERSION%%/'$fullVersion'/g' "$version/Dockerfile"
	)

	srcVersion="${fullVersion%%+*}"
	srcSha256="$(curl -sSL "https://github.com/postgis/postgis/archive/$srcVersion.tar.gz" | sha256sum | awk '{ print $1 }')"
	for variant in alpine; do
		if [ ! -d "$version/$variant" ]; then
			continue
		fi
		(
			set -x
			cp Dockerfile.alpine.template initdb-postgis.sh update-postgis.sh "$version/$variant/"
			mv "$version/$variant/Dockerfile.alpine.template" "$version/$variant/Dockerfile"
			sed -i 's/%%PG_MAJOR%%/'"$pg_major"'/g; s/%%POSTGIS_VERSION%%/'"$srcVersion"'/g; s/%%POSTGIS_SHA256%%/'"$srcSha256"'/g' "$version/$variant/Dockerfile"
		)
		travisEnv="\n  - VERSION=$version VARIANT=$variant$travisEnv"
	done

	travisEnv='\n  - VERSION='"$version$travisEnv"
done
travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml

rm "$packagesStretch"
rm "$packagesBuster"
