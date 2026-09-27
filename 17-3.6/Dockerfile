#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker.io/postgres:17-trixie

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.6.4+dfsg-2.pgdg13+1 spatial database extension with PostgreSQL 17 trixie" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_MAJOR=3
ENV POSTGIS_VERSION=3.6.4+dfsg-2.pgdg13+1
ENV H3_VERSION=4.2.3-4.pgdg13+1
ENV PGROUTING_VERSION=4.0.1-1.pgdg13+1

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
           ca-certificates \
           \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
       && if [ -n "$H3_VERSION" ]; then \
            apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-h3=$H3_VERSION; \
          fi \
       && if [ -n "$PGROUTING_VERSION" ]; then \
            apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-pgrouting=$PGROUTING_VERSION; \
          fi \
       && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

USER postgres
