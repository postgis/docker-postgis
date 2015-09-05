#!/bin/bash
set -e

image="$1"

export POSTGRES_USER='my cool postgres user'
export POSTGRES_PASSWORD='my cool postgres password'
export POSTGRES_DB='my cool postgres database'

cname="postgis-container-$RANDOM-$RANDOM"
cid="$(docker run -d -e POSTGRES_USER -e POSTGRES_PASSWORD -e POSTGRES_DB --name "$cname" "$image")"
trap "docker rm -vf $cid > /dev/null" EXIT

psql() {
	docker run --rm -i \
		--link "$cname":postgis \
		--entrypoint psql \
		-e PGPASSWORD="$POSTGRES_PASSWORD" \
		"$image" \
		--host postgis \
		--username "$POSTGRES_USER" \
		--dbname "$POSTGRES_DB" \
		--quiet --no-align --tuples-only \
		"$@"
}

tries=10
while ! echo 'SELECT 1' | psql &> /dev/null; do
	(( tries-- ))
	if [ $tries -le 0 ]; then
		echo >&2 'postgres failed to accept connections in a reasonable amount of time!'
		echo 'SELECT 1' | psql # to hopefully get a useful error message
		false
	fi
	sleep 2
done

echo 'SELECT PostGIS_Version()' | psql
[ "$(echo 'SELECT ST_X(ST_Point(0,0))' | psql)" = 0 ]
