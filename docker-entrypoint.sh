#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
  chown -R postgres "$PGDATA"
  
  if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb

    pg_createcluster $PG_MAJOR main

    gosu postgres \
      sh -c '/etc/init.d/postgresql start && \
             createdb template_postgis && \
             psql template_postgis -c "UPDATE pg_database SET datistemplate = TRUE WHERE datname = '\''template_postgis'\''" && \
             psql template_postgis < /usr/share/postgresql/'$PG_MAJOR'/contrib/postgis-'$POSTGIS_MAJOR'/postgis.sql && \
             psql template_postgis < /usr/share/postgresql/'$PG_MAJOR'/contrib/postgis-'$POSTGIS_MAJOR'/spatial_ref_sys.sql && \
             /etc/init.d/postgresql stop'
    
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    
    { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf
  fi
  
  exec gosu postgres "$@"
fi

exec "$@"
