#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#       source: "Dockerfile.bundle0.template"
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

ARG PGIS1_BASE_IMAGE=${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:16-3.4-bookworm

ARG PGIS1_MOBILITYDB_REPOSITORY=https://github.com/MobilityDB/MobilityDB.git
ARG PGIS1_MOBILITYDB_CHECKOUT=tags/v1.1.0-beta1
ARG PGIS1_MOBILITYDB_CHECKOUT_SHA1=641d0818542acbfadbfbb54b131a3af75f8dc809

ARG PGIS1_PGSQL_HTTP_REPOSITORY=https://github.com/pramsey/pgsql-http.git
ARG PGIS1_PGSQL_HTTP_CHECKOUT=tags/v1.6.0
ARG PGIS1_PGSQL_HTTP_CHECKOUT_SHA1=d0ca28df6121f10cd3868744d219904c7923c5be

ARG PGIS1_PGSQL_GZIP_REPOSITORY=https://github.com/pramsey/pgsql-gzip.git
ARG PGIS1_PGSQL_GZIP_CHECKOUT=tags/v1.0.0
ARG PGIS1_PGSQL_GZIP_CHECKOUT_SHA1=7c26e8b0056631ec0bb7c8fdd9bf2a24076e4a49

ARG PGIS1_TIMESCALEDB_APACHE_ONLY=false
ARG PGIS1_TIMESCALEDB_REPOSITORY=https://github.com/timescale/timescaledb.git
ARG PGIS1_TIMESCALEDB_CHECKOUT=tags/2.13.0
ARG PGIS1_TIMESCALEDB_CHECKOUT_SHA1=96f81a3106683f186f091ad88339c8c223f4363c

ARG PGIS1_PG_HINT_PLAN_REPOSITORY=https://github.com/ossc-db/pg_hint_plan.git
ARG PGIS1_PG_HINT_PLAN_CHECKOUT=tags/REL16_1_6_0
ARG PGIS1_PG_HINT_PLAN_CHECKOUT_SHA1=fa0a461af929c06f7c96956369458456c26e7ad9

FROM ${PGIS1_BASE_IMAGE} AS builder

RUN set -eux \
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
      # hydra (columnar)
      liblz4-dev \
      #  pgsql-gzip
      zlib1g-dev \
      # sqlite_fdw
      sqlite3 \
      # plv8
      ninja-build \
      pkg-config \
      # bytemagic
      libmagic-dev \
      # pgsoudium \
      libsodium-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


FROM builder as builder-http-gzip

ARG PGIS1_PGSQL_HTTP_REPOSITORY
ARG PGIS1_PGSQL_HTTP_CHECKOUT
ARG PGIS1_PGSQL_HTTP_CHECKOUT_SHA1

ARG PGIS1_PGSQL_GZIP_REPOSITORY
ARG PGIS1_PGSQL_GZIP_CHECKOUT
ARG PGIS1_PGSQL_GZIP_CHECKOUT_SHA1

RUN set -eux \
    && mkdir -p /pgsql-gzip \
    && cd pgsql-gzip \
    && git init \
    && git remote add origin ${PGIS1_PGSQL_GZIP_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_PGSQL_GZIP_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS1_PGSQL_GZIP_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_pgsql_gzip_last_commit.txt \
    && make -j$(nproc) \
    && make install

RUN set -eux \
    && mkdir -p /pgsql-http \
    && cd pgsql-http \
    && git init \
    && git remote add origin ${PGIS1_PGSQL_HTTP_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_PGSQL_HTTP_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS1_PGSQL_HTTP_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_pgsql_http_last_commit.txt \
    && make -j$(nproc) \
    && make install


FROM builder as builder-timescaledb

ARG PGIS1_TIMESCALEDB_APACHE_ONLY
ARG PGIS1_TIMESCALEDB_REPOSITORY
ARG PGIS1_TIMESCALEDB_CHECKOUT
ARG PGIS1_TIMESCALEDB_CHECKOUT_SHA1

#  Timescaledb not supported on pg16 yet


FROM builder as builder-mobilitydb

ARG PGIS1_MOBILITYDB_REPOSITORY
ARG PGIS1_MOBILITYDB_CHECKOUT
ARG PGIS1_MOBILITYDB_CHECKOUT_SHA1

# Install MobilityDB
RUN set -eux \
    && mkdir -p /MobilityDB \
    && cd MobilityDB \
    && git init \
    && git remote add origin ${PGIS1_MOBILITYDB_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_MOBILITYDB_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS1_MOBILITYDB_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_MobilityDB_last_commit.txt \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
             -DCMAKE_POLICY_DEFAULT_CMP0069=NEW \
             .. \
    && make -j$(nproc) \
    && make install


FROM builder as builder-pgxn

RUN pgxn install --verbose byteamagic
RUN pgxn install --verbose ddlx
RUN pgxn install --verbose dsef
RUN pgxn install --verbose json_accessors
RUN pgxn install --verbose lostgis

#RUN pgxn install --verbose parray_gin # not working on CircleCI arm .. yet
RUN pgxn install --verbose permuteseq
RUN pgxn install --verbose pg_curl   # https://github.com/RekGRpth/pg_curl
RUN pgxn install --verbose pg_roaringbitmap
RUN pgxn install --verbose pg_rowalesce
RUN pgxn install --verbose pg_uuidv7
RUN pgxn install --verbose pg_xenophile
RUN pgxn install --verbose pg_xxhash
RUN pgxn install --verbose pgsodium
RUN pgxn install --verbose pgsql_tweaks
RUN USE_PGXS=1 pgxn install sqlite_fdw

#TODO
# add https://github.com/bosth/geofdw
# RUN pgxn install --verbose plv8 # todo: need to fix build
# RUN USE_PGXS=1 pgxn install sqlite_fdw : todo check
# RUN pgxn install --verbose pg_bm25  # need rust
# RUN pgxn install --verbose orafce : todo check
# add?? libpgosm ; https://github.com/developmentseed/osm-seed/blob/develop/images/db/lib/quad_tile/quad_tile.c

FROM builder as builder-other

ARG PGIS1_PG_HINT_PLAN_REPOSITORY
ARG PGIS1_PG_HINT_PLAN_CHECKOUT
ARG PGIS1_PG_HINT_PLAN_CHECKOUT_SHA1

# PG16 + hydra not supperted https://github.com/hydradatabase/hydra

# install pg_hint_plan
RUN set -eux \
    && mkdir pg_hint_plan \
    && cd pg_hint_plan \
    && git init \
    && git remote add origin ${PGIS1_PG_HINT_PLAN_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_PG_HINT_PLAN_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS1_PG_HINT_PLAN_CHECKOUT_SHA1" ]; then exit 1; fi \
    && make -j$(nproc) \
    && make install

RUN set -eux \
    && git clone --depth 1 https://github.com/NikolayS/postgres_dba.git \
    && cd postgres_dba  \
    && rm -rf .git


FROM ${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:16-3.4-bookworm

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS Bundle - 16-3.4-bookworm " \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

# install all utf8 locales;
# helping: https://github.com/docker-library/docs/tree/master/postgres#locale-customization
RUN set -eux \
    && sed -i -e 's/# \(.*\.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen

RUN set -eux \
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
        pg-activity \
        pgbackrest \
        pgbadger \
        pgtap \
        pgtop \
        pspg \
        vip-manager \
        \
        postgresql-$PG_MAJOR-asn1oid \
        postgresql-$PG_MAJOR-cron \
        postgresql-$PG_MAJOR-decoderbufs \
        postgresql-$PG_MAJOR-extra-window-functions \
        postgresql-$PG_MAJOR-first-last-agg \
        postgresql-$PG_MAJOR-h3 \
        postgresql-$PG_MAJOR-hll \
        postgresql-$PG_MAJOR-hypopg \
        postgresql-$PG_MAJOR-icu-ext \
        postgresql-$PG_MAJOR-jsquery \
        postgresql-$PG_MAJOR-numeral \
        postgresql-$PG_MAJOR-partman \
        postgresql-$PG_MAJOR-periods \
        postgresql-$PG_MAJOR-pg-fact-loader \
        postgresql-$PG_MAJOR-pg-failover-slots \
        postgresql-$PG_MAJOR-pg-stat-kcache \
        postgresql-$PG_MAJOR-pg-wait-sampling \
        postgresql-$PG_MAJOR-pgaudit \
#       postgresql-$PG_MAJOR-pgdg-pgroonga \  # todo: check
        postgresql-$PG_MAJOR-pgl-ddl-deploy \
        postgresql-$PG_MAJOR-pglogical \
        postgresql-$PG_MAJOR-pgmp \
        postgresql-$PG_MAJOR-pgpcre \
        postgresql-$PG_MAJOR-pgq3 \
        postgresql-$PG_MAJOR-pgsphere \
        postgresql-$PG_MAJOR-pgtap \
        postgresql-$PG_MAJOR-pldebugger \
        postgresql-$PG_MAJOR-plpgsql-check \
        postgresql-$PG_MAJOR-prefix \
        postgresql-$PG_MAJOR-prioritize \
        postgresql-$PG_MAJOR-q3c \
        postgresql-$PG_MAJOR-repack \
        postgresql-$PG_MAJOR-rum \
        postgresql-$PG_MAJOR-show-plans \
        postgresql-$PG_MAJOR-squeeze \
#
#  not yet available for 16
#        postgresql-$PG_MAJOR-pointcloud \
#        postgresql-$PG_MAJOR-age \
        #
        # add MobilityDb missing dependency from libgsl-dev
        libgsl27 \
        # MeCab based tokenizer for pgdg-pgroonga
        groonga-tokenizer-mecab \
        # bytemagic
        libmagic1 libmagic-mgc \
        # pgsodium
        libsodium23 \
    \
#    && pip3 install --upgrade pip \
    \
#    && pipx install geopy \
#    && pipx install plpygis \
#    && pipx install pygml \
#    && pipx install shapely \
    \
    && rm -Rf /root/.cache/pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install from stages
COPY --from=builder-http-gzip   /usr/share/postgresql/$PG_MAJOR/extension/ /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder-http-gzip   /usr/lib/postgresql/$PG_MAJOR/lib          /usr/lib/postgresql/$PG_MAJOR/lib

COPY --from=builder-mobilitydb  /usr/share/postgresql/$PG_MAJOR/extension/ /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder-mobilitydb  /usr/lib/postgresql/$PG_MAJOR/lib          /usr/lib/postgresql/$PG_MAJOR/lib

COPY --from=builder-timescaledb /usr/share/postgresql/$PG_MAJOR/extension/ /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder-timescaledb /usr/lib/postgresql/$PG_MAJOR/lib          /usr/lib/postgresql/$PG_MAJOR/lib

COPY --from=builder-pgxn        /usr/share/postgresql/$PG_MAJOR/extension/ /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder-pgxn        /usr/lib/postgresql/$PG_MAJOR/lib          /usr/lib/postgresql/$PG_MAJOR/lib

COPY --from=builder-other       /usr/share/postgresql/$PG_MAJOR/extension/ /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder-other       /usr/lib/postgresql/$PG_MAJOR/lib          /usr/lib/postgresql/$PG_MAJOR/lib

COPY --from=builder-other /postgres_dba                              /postgres_dba

# check any missing dependencies
RUN set -eux \
    && ldd /usr/lib/postgresql/$PG_MAJOR/lib/*.so | grep 'not found' && exit 1 || true

# multiple LLVM existance is not optimal; so we give a warning.
# known problem: duplicated LLVM
RUN set -eux \
    && dpkg -l | grep llvm \
    && llvm_count=$(dpkg -l | grep llvm | wc -l) \
    && if [ "$llvm_count" -ne 1 ]; then \
        echo "WARNING: More than one llvm package or none at all found!"; \
        dpkg -l | grep llvm ; \
       fi

# add MobilityDB requirements
RUN set -eux \
    && cp -v /usr/share/postgresql/postgresql.conf.sample /usr/share/postgresql/postgresql.conf.sample.orig; \
    # add MobilityDB requirements;  ( TimescaleDB not yet supported on pg16 )
	echo "shared_preload_libraries = 'pg_hint_plan,postgis-3,pg_cron,pg_stat_statements'" >>  /usr/share/postgresql/postgresql.conf.sample; \
    # MobilityDB recomendation
	echo "max_locks_per_transaction = 128" >>  /usr/share/postgresql/postgresql.conf.sample; \
    echo "timescaledb.telemetry_level=off" >>  /usr/share/postgresql/postgresql.conf.sample

# for postgres_dba Use ":dba" to see menu
RUN printf "%s %s %s %s\n" \\set dba \'\\\\i /postgres_dba/start.psql\' >> ~/.psqlrc
