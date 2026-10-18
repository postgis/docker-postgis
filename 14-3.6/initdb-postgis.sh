#!/bin/bash

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_postgis IS_TEMPLATE true;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		-- Reconnect to update pg_setting.resetval
		-- See https://github.com/postgis/docker-postgis/issues/288
		\c
		--
		DO $$
		DECLARE
			postgis_major integer;
			postgis_minor integer;
		BEGIN
			SELECT substring(postgis_lib_version() from '^([0-9]+)')::integer,
				substring(postgis_lib_version() from '^[0-9]+\.([0-9]+)')::integer
			INTO postgis_major, postgis_minor;

			-- Install the legacy tiger geocoder stack only for PostGIS versions before 3.7.
			-- fuzzystrmatch is required by postgis_tiger_geocoder, which PostGIS 3.7 and later no longer provide.
			IF postgis_major < 3 OR (postgis_major = 3 AND postgis_minor < 7) THEN
				CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
				CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
			END IF;
		END
		$$;
EOSQL
done
