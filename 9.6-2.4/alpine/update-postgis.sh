#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
    echo "Updating PostGIS extensions $DB to $POSTGIS_VERSION"
    psql --dbname="$DB" -c "
        -- Upgrade PostGIS (includes raster)
        ALTER EXTENSION postgis  UPDATE TO '$POSTGIS_VERSION';
        -- Upgrade Topology
        ALTER EXTENSION postgis_topology UPDATE TO '$POSTGIS_VERSION';
        -- Upgrade US Tiger Geocoder
        ALTER EXTENSION postgis_tiger_geocoder UPDATE TO '$POSTGIS_VERSION';
    "
done
