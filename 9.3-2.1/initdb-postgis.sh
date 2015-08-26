#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
psql <<EOSQL
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# Populate 'template_postgis'
cd /usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR
psql --dbname template_postgis < postgis.sql
psql --dbname template_postgis < topology.sql
psql --dbname template_postgis < spatial_ref_sys.sql
