#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#       source: "Dockerfile.bundle.template"
# PLEASE DO NOT EDIT IT DIRECTLY.
#


# Experimental Geo Bundle package.
# This is a work in progress and not yet ready for production.
# Some packages will be removed from this bundle and others will be added.
# The goal is to have a bundle that includes all the most popular extensions with PostGIS

# set the base image ,  make build-* is overwriting with the actual value !

ARG REGISTRY=docker.io
ARG REPO_NAME=imresamu
ARG IMAGE_NAME=postgis-amd64

ARG PGIS_V1_BASE_IMAGE=${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:15-3.4-bookworm

ARG PGIS_V1_MOBILITYDB_REPOSITORY=https://github.com/MobilityDB/MobilityDB.git
ARG PGIS_V1_MOBILITYDB_CHECKOUT=tags/v1.1.0-alpha
ARG PGIS_V1_MOBILITYDB_CHECKOUT_SHA1=ae74a3f12757a768942c6a38ed774323bcd446ec

ARG PGIS_V1_PGSQL_HTTP_REPOSITORY=https://github.com/pramsey/pgsql-http.git
ARG PGIS_V1_PGSQL_HTTP_CHECKOUT=tags/v1.6.0
ARG PGIS_V1_PGSQL_HTTP_CHECKOUT_SHA1=d0ca28df6121f10cd3868744d219904c7923c5be

ARG PGIS_V1_PGSQL_GZIP_REPOSITORY=https://github.com/pramsey/pgsql-gzip.git
ARG PGIS_V1_PGSQL_GZIP_CHECKOUT=tags/v1.0.0
ARG PGIS_V1_PGSQL_GZIP_CHECKOUT_SHA1=7c26e8b0056631ec0bb7c8fdd9bf2a24076e4a49

ARG PGIS_V1_TIMESCALEDB_APACHE_ONLY=false
ARG PGIS_V1_TIMESCALEDB_REPOSITORY=https://github.com/timescale/timescaledb.git
ARG PGIS_V1_TIMESCALEDB_CHECKOUT=tags/2.12.0
ARG PGIS_V1_TIMESCALEDB_CHECKOUT_SHA1=ec99b00f18a6cc636fc7ff6e4bcff870d4201c90

FROM ${PGIS_V1_BASE_IMAGE} AS builder

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      autotools-dev \
      bison \
      build-essential \
      cmake \
      g++ \
      git \
      make \
      pgxnclient \
      postgresql-server-dev-$PG_MAJOR \
      unzip \
      wget \
      # MobilityDB
      libgeos++-dev \
      libgsl-dev \
      libjson-c-dev \
      libproj-dev \
      # TimescaleDB
      libkrb5-dev \
      # pgsql-http
      libcurl4-gnutls-dev \
      #  pgsql-gzip
      zlib1g-dev \
      # sqlite_fdw
      sqlite3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ARG PGIS_V1_MOBILITYDB_REPOSITORY
ARG PGIS_V1_MOBILITYDB_CHECKOUT
ARG PGIS_V1_MOBILITYDB_CHECKOUT_SHA1

ARG PGIS_V1_PGSQL_HTTP_REPOSITORY
ARG PGIS_V1_PGSQL_HTTP_CHECKOUT
ARG PGIS_V1_PGSQL_HTTP_CHECKOUT_SHA1

ARG PGIS_V1_PGSQL_GZIP_REPOSITORY
ARG PGIS_V1_PGSQL_GZIP_CHECKOUT
ARG PGIS_V1_PGSQL_GZIP_CHECKOUT_SHA1

ARG PGIS_V1_TIMESCALEDB_APACHE_ONLY
ARG PGIS_V1_TIMESCALEDB_REPOSITORY
ARG PGIS_V1_TIMESCALEDB_CHECKOUT
ARG PGIS_V1_TIMESCALEDB_CHECKOUT_SHA1

RUN set -ex \
    && mkdir -p /pgsql-gzip \
    && cd pgsql-gzip \
    && git init \
    && git remote add origin ${PGIS_V1_PGSQL_GZIP_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS_V1_PGSQL_GZIP_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS_V1_PGSQL_GZIP_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_pgsql_gzip_last_commit.txt \
    && make -j$(nproc) \
    && make install

RUN set -ex \
    && mkdir -p /pgsql-http \
    && cd pgsql-http \
    && git init \
    && git remote add origin ${PGIS_V1_PGSQL_HTTP_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS_V1_PGSQL_HTTP_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS_V1_PGSQL_HTTP_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_pgsql_http_last_commit.txt \
    && make -j$(nproc) \
    && make install


# Install TimescaleDB; no Arm64 apt support, so build from source
RUN set -ex \
    && mkdir -p /timescaledb \
    && cd timescaledb \
    && git init \
    && git remote add origin ${PGIS_V1_TIMESCALEDB_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS_V1_TIMESCALEDB_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS_V1_TIMESCALEDB_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_timescaledb_last_commit.txt \
    && ./bootstrap \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
            -DCMAKE_POLICY_DEFAULT_CMP0069=NEW \
            \
            -DAPACHE_ONLY=${PGIS_V1_TIMESCALEDB_APACHE_ONLY} \
            -DREGRESS_CHECKS=OFF \
            -DSEND_TELEMETRY_DEFAULT=NO \
            -DTAP_CHECKS=OFF \
            -DWARNINGS_AS_ERRORS=OFF \
            -DENABLE_DEBUG_UTILS=OFF \
    && cd build \
    && make -j$(nproc) \
    && make install



# Install MobilityDB
RUN set -ex \
    && mkdir -p /MobilityDB \
    && cd MobilityDB \
    && git init \
    && git remote add origin ${PGIS_V1_MOBILITYDB_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS_V1_MOBILITYDB_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS_V1_MOBILITYDB_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_MobilityDB_last_commit.txt \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
             -DCMAKE_POLICY_DEFAULT_CMP0069=NEW \
             .. \
    && make -j$(nproc) \
    && make install

RUN pgxn install ddlx
RUN pgxn install h3        # https://github.com/zachasme/h3-pg
RUN pgxn install json_accessors
RUN pgxn install lostgis
RUN pgxn install parray_gin
RUN pgxn install pg_curl   # https://github.com/RekGRpth/pg_curl
RUN pgxn install pg_roaringbitmap
RUN pgxn install pg_rowalesce
RUN pgxn install pg_uuidv7
RUN pgxn install pg_xenophile
RUN pgxn install pg_xxhash
RUN pgxn install pgsql_tweaks

RUN USE_PGXS=1 pgxn install sqlite_fdw

RUN git clone --depth 1 https://github.com/NikolayS/postgres_dba.git \
    && cd postgres_dba  \
    && rm -rf .git


#TODO: add https://github.com/hydradatabase/hydra
#          https://github.com/powa-team/pg_qualstats
#          https://github.com/darold/pgtt
#          https://github.com/apache/arrow-flight-sql-postgresql
#          https://github.com/neondatabase/pg_embedding/
# pgrust ; "pg-graphql
#          https://github.com/kelvich/pg_tiktoken
#
# --------------------------------------------------------------


FROM ${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:15-3.4-bookworm

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS Bundle - 15-3.4-bookworm " \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

# install all utf8 locales;
# helping: https://github.com/docker-library/docs/tree/master/postgres#locale-customization
#TODO - uncomment
RUN set -ex \
    && sed -i -e 's/# \(.*\.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        \
        bzip2 \
        curl \
        jq \
        unzip \
        wget \
        \
        gdal-bin \
        proj-bin \
        sqlite3 \
        \
        pipx \
        python-is-python3 \
        python3 \
        python3-geoalchemy2 \
        python3-pglast \
        python3-pip \
        python3-psycopg2 \
        python3-setuptools \
        python3-sqlalchemy \
        \
        postgis \
        postgresql \
        postgresql-$PG_MAJOR-ogr-fdw \
        postgresql-$PG_MAJOR-pgrouting \
        postgresql-$PG_MAJOR-pgrouting-scripts \
        postgresql-$PG_MAJOR-pgvector \
        postgresql-client-common \
        postgresql-common \
        postgresql-contrib \
        postgresql-plpython3-$PG_MAJOR \
        postgresql-postgis \
        postgresql-postgis-scripts \
        \
        pgbackrest \
        pgbadger \
        pgtap \
        pgtop \
        pspg \
        \
        postgresql-$PG_MAJOR-asn1oid \
        postgresql-$PG_MAJOR-cron \
        postgresql-$PG_MAJOR-decoderbufs \
        postgresql-$PG_MAJOR-extra-window-functions \
        postgresql-$PG_MAJOR-first-last-agg \
        postgresql-$PG_MAJOR-hll \
        postgresql-$PG_MAJOR-hypopg \
        postgresql-$PG_MAJOR-icu-ext \
        postgresql-$PG_MAJOR-jsquery \
        postgresql-$PG_MAJOR-numeral \
        postgresql-$PG_MAJOR-pg-failover-slots \
        postgresql-$PG_MAJOR-pg-stat-kcache \
        postgresql-$PG_MAJOR-pgaudit \
        postgresql-$PG_MAJOR-pgmp \
        postgresql-$PG_MAJOR-pgpcre \
        postgresql-$PG_MAJOR-pgq3 \
        postgresql-$PG_MAJOR-pgsphere \
        postgresql-$PG_MAJOR-pgtap \
        postgresql-$PG_MAJOR-pldebugger \
        postgresql-$PG_MAJOR-prefix \
        postgresql-$PG_MAJOR-prefix \
        postgresql-$PG_MAJOR-prioritize \
        postgresql-$PG_MAJOR-q3c \
        postgresql-$PG_MAJOR-repack \
        postgresql-$PG_MAJOR-rum \
        \
        postgresql-$PG_MAJOR-partman \
        postgresql-$PG_MAJOR-pg-fact-loader \
        postgresql-$PG_MAJOR-pglogical \
        postgresql-$PG_MAJOR-plpgsql-check \
        postgresql-$PG_MAJOR-pointcloud \
        postgresql-$PG_MAJOR-squeeze \
        #
        # add MobilityDb missing dependency from libgsl-dev
        libgsl27 \
    \
    # && pip3 install --upgrade pip \
    \
#    && pipx install geopy \
#    && pipx install plpygis \
#    && pipx install pygml \
#    && pipx install shapely \
    \
    && rm -Rf /root/.cache/pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Install MobilityDB,Timescaledb,h3,etc from builder
COPY --from=builder /usr/share/postgresql/$PG_MAJOR/extension/ /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib          /usr/lib/postgresql/$PG_MAJOR/lib
COPY --from=builder /postgres_dba                              /postgres_dba

# check any missing dependencies
RUN set -ex \
    && ldd /usr/lib/postgresql/$PG_MAJOR/lib/*.so | grep 'not found' && exit 1 || true

# multiple LLVM existance is not allowed.
RUN llvm_count=$(dpkg -l | grep llvm | wc -l) \
    && if [ "$llvm_count" -ne 1 ]; then \
        echo "More than one llvm package or none at all found. Stopping."; \
        dpkg -l | grep llvm ; \
        exit 1; \
       fi

# add MobilityDB requirements
RUN set -eux; \
	cp -v /usr/share/postgresql/postgresql.conf.sample /usr/share/postgresql/postgresql.conf.sample.orig; \
    # add MobilityDB and TimescaleDB requirements
	echo "shared_preload_libraries = 'postgis-3,timescaledb,pg_cron,pg_stat_statements'" >>  /usr/share/postgresql/postgresql.conf.sample; \
    # MobilityDB recomendation
	echo "max_locks_per_transaction = 128" >>  /usr/share/postgresql/postgresql.conf.sample; \
    echo "timescaledb.telemetry_level=off" >>  /usr/share/postgresql/postgresql.conf.sample

# for postgres_dba Use ":dba" to see menu
RUN printf "%s %s %s %s\n" \\set dba \'\\\\i /postgres_dba/start.psql\' >> ~/.psqlrc
