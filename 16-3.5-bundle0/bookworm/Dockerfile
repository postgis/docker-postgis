#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "./tools/apply-templates.sh"
#       source: "./templates/Dockerfile.bundle0.template"
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

ARG PGIS1_BASE_IMAGE=${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:16-3.5-bookworm

ARG PGIS1_PGSQL_GZIP_REPOSITORY=https://github.com/pramsey/pgsql-gzip.git
ARG PGIS1_PGSQL_GZIP_CHECKOUT=tags/v1.0.0
ARG PGIS1_PGSQL_GZIP_CHECKOUT_SHA1=7c26e8b0056631ec0bb7c8fdd9bf2a24076e4a49

ARG PGIS1_PG_HINT_PLAN_REPOSITORY=https://github.com/ossc-db/pg_hint_plan.git
ARG PGIS1_PG_HINT_PLAN_CHECKOUT=tags/REL16_1_6_1
ARG PGIS1_PG_HINT_PLAN_CHECKOUT_SHA1=54b4b0358a6c96dc80b2b836bba50937415753b6

ARG PGIS1_DUCKDB_CHECKOUT=tags/v1.3.1

# usable for forking the image
ARG PGIS1_OPTIMIZATION_FLAGS=" -O3 -mtune=generic "
ARG PGIS1_SOURCE_REPO="https://github.com/postgis/docker-postgis"
ARG PGIS1_MAINTAINER="PostGIS Project - https://postgis.net - ${PGIS1_SOURCE_REPO}/issues"

FROM ${PGIS1_BASE_IMAGE} AS builder

ARG PGIS1_DUCKDB_CHECKOUT
ARG PGIS1_OPTIMIZATION_FLAGS

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
      flex \
      g++ \
      git \
      make \
      pgxnclient \
      postgresql-server-dev-$PG_MAJOR \
      unzip \
      wget \
      #  pgsql-gzip
      zlib1g-dev \
      # sqlite_fdw
      sqlite3 \
      # bytemagic
      libmagic-dev \
      # pgsoudium \
      libsodium-dev \
      # pg_curl
      libcurl4-gnutls-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM builder as builder-gzip

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


FROM builder as builder-pgxn

RUN pgxn install --verbose byteamagic
RUN pgxn install --verbose ddlx
RUN pgxn install --verbose dsef
RUN pgxn install --verbose json_accessors
RUN pgxn install --verbose lostgis
RUN pgxn install --verbose permuteseq
RUN pgxn install --verbose pg_curl   # https://github.com/RekGRpth/pg_curl
RUN pgxn install --verbose pg_roaringbitmap
RUN pgxn install --verbose pg_rowalesce
RUN pgxn install --verbose pg_uuidv7
RUN pgxn install --verbose pg_xenophile
RUN pgxn install --verbose pg_xxhash
RUN pgxn install --verbose pgsodium
RUN pgxn install --verbose pgsql_tweaks
# RUN pgxn install --verbose sqlite_fdw

# pg_duckdb
RUN set -eux \
    && curl -sfL https://install.pgx.sh -o /tmp/pgx-install.sh \
    && chmod +x /tmp/pgx-install.sh \
    && /tmp/pgx-install.sh \
    && rm /tmp/pgx-install.sh
RUN pgxman install pg_duckdb

#RUN pgxman install hydra_columnar
#RUN pgxman install pgvectorscale
#RUN pgxman install pg_quack

FROM builder as builder-other

ARG PGIS1_PG_HINT_PLAN_REPOSITORY
ARG PGIS1_PG_HINT_PLAN_CHECKOUT
ARG PGIS1_PG_HINT_PLAN_CHECKOUT_SHA1

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

FROM ${REGISTRY}/${REPO_NAME}/${IMAGE_NAME}:16-3.5-bookworm

ARG PGIS1_OPTIMIZATION_FLAGS
ARG PGIS1_SOURCE_REPO
ARG PGIS1_MAINTAINER
ARG PGIS1_TIMESCALEDB_TELEMETRY

# Export build environment for child images (enterprise-grade package version locking)
RUN set -eux \
    # Ensure docker-postgis-env.sh exists (create empty if missing)
    && touch /usr/local/share/docker-postgis-env.sh \
    # Export bundle-specific build versions for child images
    && echo "# Bundle0 Extension Versions" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PGIS1_OPTIMIZATION_FLAGS='${PGIS1_OPTIMIZATION_FLAGS}'" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PGIS1_PG_HINT_PLAN_CHECKOUT='tags/REL16_1_6_1'" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PGIS1_DUCKDB_CHECKOUT='tags/v1.3.1'" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PGIS1_PGSQL_GZIP_CHECKOUT='tags/v1.0.0'" >> /usr/local/share/docker-postgis-env.sh \
    && chmod +x /usr/local/share/docker-postgis-env.sh \
    # Source the environment after populating it
    && . /usr/local/share/docker-postgis-env.sh

# Only override opencontainers labels for bundle-specific info
# org.postgis.base.* labels are inherited from base image and should NOT be overridden
LABEL maintainer="${PGIS1_MAINTAINER}" \
      org.opencontainers.image.description="PostGIS Bundle - 16-3.5-bookworm with MobilityDB, TimescaleDB, DuckDB and 40+ extensions" \
      org.opencontainers.image.source="${PGIS1_SOURCE_REPO}" \
      org.opencontainers.image.version="3.5.3+dfsg-1~exp1.pgdg120+1-bundle0" \
      org.opencontainers.image.created="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
      org.opencontainers.image.base.name="${PGIS1_BASE_IMAGE}" \
      \
      # Bundle-specific additional extensions (base PostGIS extensions inherited from org.postgis.base.extensions)
      org.postgis.bundle0.additional.extensions="timescaledb,mobilitydb,pgsql_http,pgsql_gzip,pgrouting,pgvector,h3,pointcloud,pgaudit,byteamagic,ddlx,dsef,json_accessors,lostgis,permuteseq,pg_curl,pg_roaringbitmap,pg_rowalesce,pg_uuidv7,pg_xenophile,pg_xxhash,pgsodium,pgsql_tweaks,sqlite_fdw,age,decoderbufs,asn1oid,extra_window_functions,first_last_agg,hll,hypopg,icu_ext,jsquery,numeral,ogr_fdw,partman,periods,pg_fact_loader,pg_failover_slots,pg_stat_kcache,pg_wait_sampling,pgl_ddl_deploy,pglogical,pgmp,pgpcre,pgq3,pgsphere,pgtap,pldebugger,plpgsql_check,prefix,prioritize,q3c,repack,rum,show_plans,squeeze" \
      org.postgis.bundle0.permanently.excluded="parray_gin,pg_quack" \
      org.postgis.bundle0.optimization.flags="${PGIS1_OPTIMIZATION_FLAGS}" \
      org.postgis.bundle0.timescaledb.telemetry="${PGIS1_TIMESCALEDB_TELEMETRY}" \
      org.postgis.bundle0.duckdb.version="tags/v1.3.1"

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
        # add any exceptions for PG17 or PPG16 here
        # PostgreSQL 16 and earlier packages
        \
        postgresql-$PG_MAJOR-age \
        postgresql-$PG_MAJOR-asn1oid \
        postgresql-$PG_MAJOR-auto-failover \
        postgresql-$PG_MAJOR-credcheck \
        postgresql-$PG_MAJOR-cron \
        postgresql-$PG_MAJOR-decoderbufs \
        postgresql-$PG_MAJOR-extra-window-functions \
        postgresql-$PG_MAJOR-first-last-agg \
        postgresql-$PG_MAJOR-h3 \
        postgresql-$PG_MAJOR-hll \
        postgresql-$PG_MAJOR-http \
        postgresql-$PG_MAJOR-hypopg \
        postgresql-$PG_MAJOR-icu-ext \
        postgresql-$PG_MAJOR-jsquery \
        postgresql-$PG_MAJOR-mobilitydb \
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
        postgresql-$PG_MAJOR-timescaledb \
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
    && DUCKDB_VERSION=$(echo "$PGIS1_DUCKDB_CHECKOUT" | sed -E 's|^.*/||; s|^tags/||; s|^v||') \
    && echo "DUCKDB_VERSION=${DUCKDB_VERSION}" \
    && echo "PGIS1_DUCKDB_CHECKOUT=${PGIS1_DUCKDB_CHECKOUT}" \
    && case "$arch" in \
        x86_64) \
            duck_binary="duckdb_cli-linux-amd64.zip" ;; \
        aarch64) \
            duck_binary="duckdb_cli-linux-arm64.zip" ;; \
        *) \
            echo "Unsupported architecture: $arch"; exit 1 ;; \
    esac \
    && wget https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/$duck_binary \
    && unzip $duck_binary -d /usr/local/bin \
    && rm $duck_binary \
    && duckdb --version

# install duckdb extensions
ENV DUCKDB_EXTENSIONS="excel fts httpfs inet postgres_scanner spatial sqlite_scanner tpcds tpch"
RUN for e in ${DUCKDB_EXTENSIONS} ; do \
        echo "Installing $e ..."; \
        if duckdb -c "INSTALL $e;" 2>&1 | tee /tmp/duckdb-install-$e.log; then \
            echo "Successfully installed $e"; \
            echo "LOAD $e;" >> $HOME/.duckdbrc; \
        else \
            echo "Failed to install $e, check /tmp/duckdb-install-$e.log"; \
        fi; \
    done \
    # Add core extensions to .duckdbrc (these are built-in)
    && echo "LOAD autocomplete;" >> $HOME/.duckdbrc \
    && echo "LOAD icu;" >> $HOME/.duckdbrc \
    && echo "LOAD json;" >> $HOME/.duckdbrc \
    && echo "LOAD parquet;" >> $HOME/.duckdbrc

# Install from stages
COPY --from=builder-gzip   /usr/share/postgresql/$PG_MAJOR/extension/ /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder-gzip   /usr/lib/postgresql/$PG_MAJOR/lib          /usr/lib/postgresql/$PG_MAJOR/lib

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
    echo "shared_preload_libraries = 'postgis-3,pg_stat_statements,timescaledb'" >>  /usr/share/postgresql/postgresql.conf.sample ; \
    # MobilityDB recomendation
	echo "max_locks_per_transaction = 128" >>  /usr/share/postgresql/postgresql.conf.sample; \
    echo "timescaledb.telemetry_level=off" >>  /usr/share/postgresql/postgresql.conf.sample

# for postgres_dba Use ":dba" to see menu
RUN printf "%s %s %s %s\n" \\set dba \'\\\\i /postgres_dba/start.psql\' >> ~/.psqlrc

COPY ./initdb-bundle0.sh /docker-entrypoint-initdb.d/11_bundle0.sh
