#!/bin/bash
# shellcheck disable=SC2119,SC2120
set -eo pipefail

#for debug:
#set -x

image="$1"

export POSTGRES_USER='my cool postgis user'
export POSTGRES_PASSWORD='my cool postgis password'
export POSTGRES_DB='my cool postgis database'

cname="postgis-container-$RANDOM-$RANDOM"
cid="$(docker run -d -e POSTGRES_USER -e POSTGRES_PASSWORD -e POSTGRES_DB --name "$cname" "$image")"
trap 'docker rm -vf "$cid" > /dev/null' EXIT

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

# Set default values for POSTGRES_TEST_TRIES and POSTGRES_TEST_SLEEP if they are not set.
# You can change the default value of POSTGRES_TEST_TRIES and the POSTGRES_TEST_SLEEP in the CI build settings.
# For special cases like Buildx/qemu tests, you may need to set POSTGRES_TEST_TRIES to 42.
: "${POSTGRES_TEST_TRIES:=15}"
: "${POSTGRES_TEST_SLEEP:=2}"
tries="$POSTGRES_TEST_TRIES"
while ! echo 'SELECT 1' | psql &>/dev/null; do
    ((tries--))
    if [ $tries -le 0 ]; then
        echo >&2 'postgres failed to accept connections in a reasonable amount of time!'
        echo 'SELECT 1' | psql # to hopefully get a useful error message
        false
    fi
    sleep "$POSTGRES_TEST_SLEEP"
done

## Minimal create extension test
echo "
create extension if not exists asn1oid cascade;
create extension if not exists ddlx cascade;
create extension if not exists gzip cascade;
create extension if not exists h3 cascade;
create extension if not exists h3_postgis cascade;
create extension if not exists hstore_plpython3u cascade;
create extension if not exists http cascade;
create extension if not exists mobilitydb cascade;
create extension if not exists ogr_fdw cascade;
create extension if not exists pg_curl cascade;
create extension if not exists pg_uuidv7 cascade;
create extension if not exists pgrouting cascade;
create extension if not exists pgtap cascade;
create extension if not exists plpython3u cascade;
create extension if not exists prioritize cascade;
create extension if not exists q3c cascade;
create extension if not exists vector cascade;
" | psql

echo "
SELECT h3_get_extension_version();
SELECT mobilitydb_full_version();
SELECT pgr_full_version();
" | psql

imagetag=$(echo "${1}" | cut -d':' -f2)
mkdir -p ./tmp

echo "
COPY (
  SELECT
     name, default_version, comment
  FROM pg_available_extensions ORDER BY 1
) TO STDOUT WITH CSV HEADER;
" | psql >./tmp/"${imagetag}"__pg_available_extensions.csv
