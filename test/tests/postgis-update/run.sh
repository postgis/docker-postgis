#!/bin/bash
# shellcheck disable=SC2119,SC2120
set -e

image="$1"

export POSTGRES_USER='my cool postgres user'
export POSTGRES_PASSWORD='my cool postgres password'
export POSTGRES_DB='my cool postgres database'

cname="postgis-container-$RANDOM-$RANDOM"
network="$(docker network create "$cname")"
cid=''
cleanup() {
	[ -z "$cid" ] || docker rm -vf "$cid" >/dev/null 2>&1 || true
	docker network rm "$network" >/dev/null 2>&1 || true
}
trap cleanup EXIT
cid="$(docker run -d --network "$network" --network-alias postgis \
	-e POSTGRES_USER -e POSTGRES_PASSWORD -e POSTGRES_DB --name "$cname" "$image")"

psql() {
	docker run --rm -i \
		--network "$network" \
		--entrypoint psql \
		-e PGPASSWORD="$POSTGRES_PASSWORD" \
		"$image" \
		--host postgis \
		--username "$POSTGRES_USER" \
		--dbname "$POSTGRES_DB" \
		-v ON_ERROR_STOP=1 \
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

# Run twice: update-postgis.sh must be idempotent.
docker exec "$cid" update-postgis.sh
docker exec "$cid" update-postgis.sh

## test postgis extensions are at the version provided by the image
outdated="$(
	psql <<-'EOSQL'
	SELECT name
	FROM pg_available_extensions
	WHERE name IN ('postgis', 'postgis_topology')
	  AND installed_version IS DISTINCT FROM default_version;
	EOSQL
)"
if [ -n "$outdated" ]; then
	echo >&2 "extensions not updated: $outdated"
	exit 1
fi

## test postgis_tiger_geocoder extension
# Tiger must be installed when the image provides it.
tiger_state="$(
	psql <<-'EOSQL'
	SELECT CASE
		WHEN available = installed THEN 'ok'
		ELSE 'missing'
	END
	FROM (
		SELECT EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'postgis_tiger_geocoder') AS available,
		       EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis_tiger_geocoder') AS installed
	) AS postgis_version;
	EOSQL
)"
if [ "$tiger_state" != ok ]; then
	echo >&2 "postgis_tiger_geocoder extension test failed: $tiger_state"
	exit 1
fi

echo "update-postgis.sh works!"
