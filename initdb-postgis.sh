#!/bin/bash
# shellcheck disable=SC2154

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
		BEGIN
			-- Tiger is bundled before PostGIS 3.7 and standalone afterward.
			IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'postgis_tiger_geocoder') THEN
				CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
				CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
			END IF;
		END
		$$;
EOSQL
done
