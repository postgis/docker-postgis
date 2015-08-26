#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
psql <<EOSQL
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
cd "/usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR"
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS into $DB"

	psql --dbname="$DB" < postgis.sql
	psql --dbname="$DB" < topology.sql
	psql --dbname="$DB" < spatial_ref_sys.sql
done
