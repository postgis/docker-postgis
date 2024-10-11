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

ARG PGIS1_BASE_IMAGE=${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:15-3.4-bookworm

ARG PGIS1_MOBILITYDB_REPOSITORY=https://github.com/MobilityDB/MobilityDB.git
ARG PGIS1_MOBILITYDB_CHECKOUT=tags/v1.1.2
ARG PGIS1_MOBILITYDB_CHECKOUT_SHA1=6088e7bc10a31dee34fbc3e3139288a218e4ec65

ARG PGIS1_PGSQL_HTTP_REPOSITORY=https://github.com/pramsey/pgsql-http.git
ARG PGIS1_PGSQL_HTTP_CHECKOUT=tags/v1.6.1
ARG PGIS1_PGSQL_HTTP_CHECKOUT_SHA1=5e2bd270a9ce2b0e8e1fdf8e46b85396bd4125cd

ARG PGIS1_PGSQL_GZIP_REPOSITORY=https://github.com/pramsey/pgsql-gzip.git
ARG PGIS1_PGSQL_GZIP_CHECKOUT=tags/v1.0.0
ARG PGIS1_PGSQL_GZIP_CHECKOUT_SHA1=7c26e8b0056631ec0bb7c8fdd9bf2a24076e4a49

ARG PGIS1_TIMESCALEDB_APACHE_ONLY=false
ARG PGIS1_TIMESCALEDB_REPOSITORY=https://github.com/timescale/timescaledb.git
ARG PGIS1_TIMESCALEDB_CHECKOUT=tags/2.17.0
ARG PGIS1_TIMESCALEDB_CHECKOUT_SHA1=43ef9b7bda813c10f845fe55f7fc6113bbd47b07

ARG PGIS1_PG_HINT_PLAN_REPOSITORY=https://github.com/ossc-db/pg_hint_plan.git
ARG PGIS1_PG_HINT_PLAN_CHECKOUT=tags/REL15_1_5_2
ARG PGIS1_PG_HINT_PLAN_CHECKOUT_SHA1=fabd97bd76361051b91c0e772eb819a45f3fd095

ARG PGIS1_DUCKDB_CHECKOUT=tags/v1.1.1

FROM ${PGIS1_BASE_IMAGE} AS builder

ARG PGIS1_DUCKDB_CHECKOUT

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      autotools-dev \
      bison \
      build-essential \
      cmake \
      curl \
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

# Install TimescaleDB; no Arm64 apt support, so build from source
RUN set -eux \
    && mkdir -p /timescaledb \
    && cd timescaledb \
    && git init \
    && git remote add origin ${PGIS1_TIMESCALEDB_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_TIMESCALEDB_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS1_TIMESCALEDB_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_timescaledb_last_commit.txt \
    && ./bootstrap \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
            -DCMAKE_POLICY_DEFAULT_CMP0069=NEW \
            \
            -DAPACHE_ONLY=${PGIS1_TIMESCALEDB_APACHE_ONLY} \
            -DREGRESS_CHECKS=OFF \
            -DSEND_TELEMETRY_DEFAULT=NO \
            -DTAP_CHECKS=OFF \
            -DWARNINGS_AS_ERRORS=OFF \
            -DENABLE_DEBUG_UTILS=OFF \
    && cd build \
    && make -j$(nproc) \
    && make install

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

FROM builder as builder-other

ARG PGIS1_PG_HINT_PLAN_REPOSITORY
ARG PGIS1_PG_HINT_PLAN_CHECKOUT
ARG PGIS1_PG_HINT_PLAN_CHECKOUT_SHA1

# Add hydradatabase
# TODO hydradatabase version!
RUN set -eux \
    && git clone --depth 1 https://github.com/hydradatabase/hydra  \
    && cd hydra/columnar \
    && git checkout main \
    && export COLUMNAR_O3=1 \
    && ./configure \
    && make -j$(nproc) \
    && make install

#  #  # add pg_quack: PG 14 and PG 15 only (PG 16 is not yet supported)
#  # TODO: add pg_quack version!
#  RUN set -eux \
#      && git clone --depth 1  https://github.com/hydradatabase/pg_quack  \
#      && cd pg_quack \
#      && make -j$(nproc) \
#      && make install
#  
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

RUN set -eux \
    && git clone --depth 1 https://github.com/dr-jts/pg_svg.git \
    && cd pg_svg  \
    && rm -rf .git
    #install:  psql < /pg_svg/pg-svg-lib.sql

FROM ${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:15-3.4-bookworm

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS Bundle - 15-3.4-bookworm " \
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
        postgresql-$PG_MAJOR-age \
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
        postgresql-$PG_MAJOR-ogr-fdw \
        postgresql-$PG_MAJOR-partman \
        postgresql-$PG_MAJOR-periods \
        postgresql-$PG_MAJOR-pg-fact-loader \
        postgresql-$PG_MAJOR-pg-failover-slots \
        postgresql-$PG_MAJOR-pg-stat-kcache \
        postgresql-$PG_MAJOR-pg-wait-sampling \
        postgresql-$PG_MAJOR-pgaudit \
        postgresql-$PG_MAJOR-pgl-ddl-deploy \
        postgresql-$PG_MAJOR-pglogical \
        postgresql-$PG_MAJOR-pgmp \
        postgresql-$PG_MAJOR-pgpcre \
        postgresql-$PG_MAJOR-pgq3 \
        postgresql-$PG_MAJOR-pgrouting \
        postgresql-$PG_MAJOR-pgrouting-scripts \
        postgresql-$PG_MAJOR-pgsphere \
        postgresql-$PG_MAJOR-pgtap \
        postgresql-$PG_MAJOR-pgvector \
        postgresql-$PG_MAJOR-pldebugger \
        postgresql-$PG_MAJOR-plpgsql-check \
        postgresql-$PG_MAJOR-pointcloud \
        postgresql-$PG_MAJOR-prefix \
        postgresql-$PG_MAJOR-prioritize \
        postgresql-$PG_MAJOR-q3c \
        postgresql-$PG_MAJOR-repack \
        postgresql-$PG_MAJOR-rum \
        postgresql-$PG_MAJOR-show-plans \
        postgresql-$PG_MAJOR-squeeze \
        # add MobilityDb missing dependency from libgsl-dev
        libgsl27 \
        # MeCab based tokenizer for pgdg-pgroonga
        groonga-tokenizer-mecab \
        # bytemagic
        libmagic1 libmagic-mgc \
        # pgsodium
        libsodium23 \
    \
    && rm -Rf /root/.cache/pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG PGIS1_DUCKDB_CHECKOUT
ENV PGIS1_DUCKDB_CHECKOUT=${PGIS1_DUCKDB_CHECKOUT}
RUN arch=$(uname -m) \
    && DUCKDB_VERSION=$(echo "$PGIS1_DUCKDB_CHECKOUT" | sed 's/tags\///') \
    && echo "DUCKDB_VERSION=${DUCKDB_VERSION}" \
    && echo "PGIS1_DUCKDB_CHECKOUT=${PGIS1_DUCKDB_CHECKOUT}" \
    && case "$arch" in \
        x86_64) \
            duck_binary="duckdb_cli-linux-amd64.zip" ;; \
        aarch64) \
            duck_binary="duckdb_cli-linux-aarch64.zip" ;; \
        *) \
            echo "Unsupported architecture: $arch"; exit 1 ;; \
    esac \
    && wget https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/$duck_binary \
    && unzip $duck_binary -d /usr/local/bin \
    && rm $duck_binary \
    && duckdb --version

# install extensions
# https://duckdb.org/docs/extensions/overview.html
ENV DUCKDB_EXTENSIONS="arrow autocomplete excel fts httpfs icu inet json parquet postgres_scanner spatial sqlite_scanner substrait tpcds tpch visualizer"
RUN for e in ${DUCKDB_EXTENSIONS} ; do \
        echo "Installing $e ..."; \
        duckdb -c "INSTALL $e;"; \
        echo "LOAD $e;" >> $HOME/.duckdbrc; \
    done

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

COPY --from=builder-other /postgres_dba    /postgres_dba
COPY --from=builder-other /pg_svg          /pg_svg

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
    # add MobilityDB and TimescaleDB requirements
	echo "shared_preload_libraries = 'pg_hint_plan,postgis-3,timescaledb,pg_cron,pg_stat_statements'" >>  /usr/share/postgresql/postgresql.conf.sample; \
    # MobilityDB recomendation
	echo "max_locks_per_transaction = 128" >>  /usr/share/postgresql/postgresql.conf.sample; \
    echo "timescaledb.telemetry_level=off" >>  /usr/share/postgresql/postgresql.conf.sample

# for postgres_dba Use ":dba" to see menu
RUN printf "%s %s %s %s\n" \\set dba \'\\\\i /postgres_dba/start.psql\' >> ~/.psqlrc

COPY ./initdb-bundle0.sh /docker-entrypoint-initdb.d/11_bundle0.sh
