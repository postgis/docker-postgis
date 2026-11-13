#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker.io/postgres:16-trixie

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.7.0+dfsg-1.pgdg13+2 spatial database extension with PostgreSQL 16 trixie" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_MAJOR=3
ENV POSTGIS_VERSION=3.7.0+dfsg-1.pgdg13+2
ENV H3_VERSION=4.2.3-5.pgdg13+3
ENV PGROUTING_VERSION=4.0.2-1.pgdg13+2
ENV ADDRESS_PACKAGE_VERSION=3.7.0-1.pgdg13+2
ENV TIGER_PACKAGE_VERSION=2025.2-1.pgdg13+2

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
           ca-certificates \
           \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
       && if [ -n "$H3_VERSION" ]; then \
            apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-h3=$H3_VERSION; \
          fi \
       && if [ -n "$PGROUTING_VERSION" ]; then \
            apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-pgrouting=$PGROUTING_VERSION; \
          fi \
       && if [ -n "$ADDRESS_PACKAGE_VERSION" ]; then \
            apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-address-standardizer=$ADDRESS_PACKAGE_VERSION; \
          fi \
       && if [ -n "$TIGER_PACKAGE_VERSION" ]; then \
            apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-postgis-tiger-geocoder=$TIGER_PACKAGE_VERSION; \
          fi \
       && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

USER postgres
