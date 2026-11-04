#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"

# The *-master images do not set POSTGIS_VERSION, use the version they provide
if [ -z "$POSTGIS_VERSION" ]; then
    POSTGIS_VERSION="$(psql --dbname=template1 -Atc "SELECT default_version FROM pg_available_extensions WHERE name = 'postgis'")"
fi

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB" "${@}"; do
    echo "Updating PostGIS extensions '$DB' to $POSTGIS_VERSION"
    psql --dbname="$DB" -c "
        -- Upgrade PostGIS (includes raster)
        CREATE EXTENSION IF NOT EXISTS postgis VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis UPDATE TO '$POSTGIS_VERSION';

        -- Upgrade Topology
        CREATE EXTENSION IF NOT EXISTS postgis_topology VERSION '$POSTGIS_VERSION';
        ALTER EXTENSION postgis_topology UPDATE TO '$POSTGIS_VERSION';

        DO \$\$
        DECLARE
            orphan text;
        BEGIN
            -- PostGIS 3.7 and later no longer provide the US Tiger Geocoder
            IF EXISTS (
                SELECT FROM pg_available_extension_versions
                WHERE name = 'postgis_tiger_geocoder' AND version = '$POSTGIS_VERSION'
            ) THEN
                -- Install Tiger dependencies in case not already installed
                CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
                -- Upgrade US Tiger Geocoder
                CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder VERSION '$POSTGIS_VERSION';
                ALTER EXTENSION postgis_tiger_geocoder UPDATE TO '$POSTGIS_VERSION';
            END IF;

            -- Installed earlier, but this image can no longer upgrade them
            FOR orphan IN
                SELECT e.extname FROM pg_extension e
                WHERE e.extname IN ('postgis_tiger_geocoder', 'address_standardizer', 'address_standardizer_data_us')
                  AND NOT EXISTS (SELECT FROM pg_available_extensions a WHERE a.name = e.extname)
            LOOP
                RAISE WARNING 'extension \"%\" is installed in database \"%\", but this image does not provide it: not upgraded', orphan, current_database();
            END LOOP;
        END
        \$\$;
    "
done
