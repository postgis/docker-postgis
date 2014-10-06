#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
  chown -R postgres "$PGDATA"
  
  if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb

    gosu postgres postgres --single -E <<EOSQL
      CREATE DATABASE template_postgis
      UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis'
EOSQL

    POSTGIS_CONTRIB=/usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR
    gosu postgres postgres --single template_postgis -j < $POSTGIS_CONTRIB/postgis.sql
    gosu postgres postgres --single template_postgis -j < $POSTGIS_CONTRIB/spatial_ref_sys.sql

    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    
    { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf
  fi
  
  exec gosu postgres "$@"
fi

exec "$@"
