#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#       source: "Dockerfile.debian.template"
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM postgres:14-bookworm

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.4.0+dfsg-1.pgdg120+1 spatial database extension with PostgreSQL 14 bookworm" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.4.0+dfsg-1.pgdg120+1

RUN set -eux \
      && apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
           ca-certificates \
           \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
