#!/bin/bash
set -e

image="$1"

# buildx debug:
uname -a
uname -m
cat /proc/cpuinfo

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

: ${POSTGRES_TEST_TRIES:=10}
: ${POSTGRES_TEST_SLEEP:=2}

tries="$POSTGRES_TEST_TRIES"
while ! echo 'SELECT 1' | psql &> /dev/null; do
	(( tries-- ))
	if [ $tries -le 0 ]; then
		echo >&2 'postgres failed to accept connections in a reasonable amount of time!'
		echo 'SELECT 1' | psql # to hopefully get a useful error message
		false
	fi
	sleep "$POSTGRES_TEST_SLEEP"
done

echo 'SELECT PostGIS_Version()' | psql
[ "$(echo 'SELECT ST_X(ST_Point(0,0))' | psql)" = 0 ]


## test address_standardizer extension
echo 'CREATE EXTENSION address_standardizer;' | psql
response=$(echo $'SELECT zip FROM parse_address(\'1 Devonshire Place, Boston, MA 02109-1234\') AS a;' | psql)
if [ $response  = 02109 ]; then 
	echo "address_standardizer extension installed and works!"
else 
	echo "address_standardizer extension test failed, returned response is $response"
	exit 1
fi

