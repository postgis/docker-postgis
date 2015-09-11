#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
psql --dbname="$POSTGRES_DB" <<- 'EOSQL'
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
cd "/usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR"
for DB in template_postgis "$POSTGRES_DB"; do
	if awk "BEGIN { exit $PG_MAJOR >= 9.1 ? 0 : 1 }"; then
		echo "Loading PostGIS into $DB via CREATE EXTENSION"
		psql --dbname="$DB" <<-'EOSQL'
			CREATE EXTENSION postgis;
			CREATE EXTENSION postgis_topology;
			CREATE EXTENSION fuzzystrmatch;
			CREATE EXTENSION postgis_tiger_geocoder;
		EOSQL
	else
		echo "Loading PostGIS into $DB via files"
		files='
			postgis
			postgis_comments
			topology
			topology_comments
			rtpostgis
			raster_comments
		'
		for file in $files; do
			psql --dbname="$DB" < "${file}.sql"
		done
	fi
done
