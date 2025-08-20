#
# NOTE: THIS DOCKERFILE IS A TEMPORARY FILE AS DEFAULT TEMPLATING
# DOES NOT WORK WITH PG 18beta3, FOR THE MOMENT
#
# AFTER COMPLETION OF ./update.sh, RUN:
#      cp Dockerfile.manual Dockerfile 
#

FROM postgres:18beta3-trixie

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.5.2+dfsg-1.pgdg110+1 spatial database extension with PostgreSQL 18 beta trixie" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.5.3+dfsg-1~exp1.pgdg130+1

# Get pg_repack extension version
# RUN  apt-get update && \
#       apt-get update && \
#       apt list | grep postgresql | grep repack

RUN apt-get update \
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
