#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#
ARG BASE_IMAGE=postgres:16-alpine3.24
FROM ${BASE_IMAGE}

ARG NPROC=

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.7.0rc3 spatial database extension with PostgreSQL 16 Alpine" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_VERSION=3.7.0rc3
ENV POSTGIS_SOURCE_VERSION=3.7.0rc3
ENV POSTGIS_SHA256=77a63e7aa49665764974ddd3c904235ae344267452ce26e1ff7b6f048527dfd3
ENV PGROUTING_VERSION=4.0.2
ENV PGROUTING_SHA256=2faf31b178db969637c1f392ba3ba18fba8d5aed15bdc73fbb4a53a72c5d0f71
ENV ADDRESS_STANDARDIZER_GIT_HASH=fa11ff53eb49b863d9ffff37f6afd5ff9299c581
ENV TIGER_GEOCODER_VERSION=2025.2
ENV TIGER_GEOCODER_SHA256=c33cfbfb40785db8754a36be66060e8d023773e7e1be8fb8a622bb3c48db9f54

RUN set -eux \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    \
    && wget -q -t 5 -O postgis.tar.gz "https://github.com/postgis/postgis/archive/${POSTGIS_SOURCE_VERSION}.tar.gz" \
    && echo "${POSTGIS_SHA256} *postgis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz \
    \
    && apk add --no-cache --virtual .build-deps \
        \
        gdal-dev \
        geos-dev \
        proj-dev \
        proj-util \
        sfcgal-dev \
        gmp-dev \
        \
        # The upstream variable, '$DOCKER_PG_LLVM_DEPS' contains
        #  the correct versions of 'llvm-dev' and 'clang' for the current version of PostgreSQL.
        # This improvement has been discussed in https://github.com/docker-library/postgres/pull/1077
        $DOCKER_PG_LLVM_DEPS \
        \
        autoconf \
        automake \
        cunit-dev \
        file \
        g++ \
        gcc \
        gettext-dev \
        git \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        pcre2-dev \
        perl \
        protobuf-c-dev \
    \
    && if [ -n "$PGROUTING_VERSION" ]; then \
        apk add --no-cache --virtual .pgrouting-build-deps \
            boost-dev \
            cmake \
            postgresql-dev; \
    fi \
    \
# Build PostGIS with Link Time Optimization (LTO) enabled.
    && cd /usr/src/postgis \
    && gettextize \
    && ./autogen.sh \
    && ./configure \
        --enable-lto \
    && make -j${NPROC:-$(nproc)} \
    && make install \
    && if [ -n "$PGROUTING_VERSION" ]; then \
        wget -q -t 5 -O pgrouting.tar.gz "https://github.com/pgRouting/pgrouting/releases/download/v${PGROUTING_VERSION}/pgrouting-${PGROUTING_VERSION}.tar.gz" \
        && echo "${PGROUTING_SHA256} *pgrouting.tar.gz" | sha256sum -c - \
        && mkdir -p /usr/src/pgrouting \
        && tar \
            --extract \
            --file pgrouting.tar.gz \
            --directory /usr/src/pgrouting \
            --strip-components 1 \
        && rm pgrouting.tar.gz \
        && cmake \
            -S /usr/src/pgrouting \
            -B /usr/src/pgrouting/build \
            -DBUILD_DOXY=OFF \
            -DBUILD_HTML=OFF \
        && cmake --build /usr/src/pgrouting/build -j${NPROC:-$(nproc)} \
        && cmake --install /usr/src/pgrouting/build; \
    fi \
    # The standalone Tiger release requires PostgreSQL 16+.
    && if [ "$POSTGIS_VERSION" = "master" ]; then \
        postgis_minor=7; \
    else \
        postgis_minor="${POSTGIS_VERSION#*.}" \
        && postgis_minor="${postgis_minor%%.*}"; \
    fi \
    # PostGIS 3.7+ requires the standalone address standardizer.
    && if [ "$postgis_minor" -ge 7 ]; then \
        cd /usr/src \
        && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/postgis/address_standardizer.git \
        && cd address_standardizer \
        && git checkout ${ADDRESS_STANDARDIZER_GIT_HASH} \
        && make PG_CONFIG="$(command -v pg_config)" PG_CFLAGS=-Wno-error with_llvm=no \
        && make PG_CONFIG="$(command -v pg_config)" PG_CFLAGS=-Wno-error with_llvm=no install \
        && cd /usr/src/postgis; \
    fi \
    && if [ "$postgis_minor" -ge 7 ] && [ "$PG_MAJOR" -ge 16 ]; then \
        wget -q -t 5 -O postgis_tiger_geocoder.tar.gz "https://download.osgeo.org/postgis/source/postgis_tiger_geocoder/postgis_tiger_geocoder-${TIGER_GEOCODER_VERSION}.tar.gz" \
        && echo "${TIGER_GEOCODER_SHA256} *postgis_tiger_geocoder.tar.gz" | sha256sum -c - \
        && tar -xzf postgis_tiger_geocoder.tar.gz -C /usr/src \
        && cd /usr/src/postgis_tiger_geocoder \
        && make PG_CONFIG="$(command -v pg_config)" \
        && make PG_CONFIG="$(command -v pg_config)" install \
        && rm -f /usr/src/postgis/postgis_tiger_geocoder.tar.gz; \
    fi \
    && cd /usr/src/postgis \
    \
# Refresh PROJ data required by the regression tests.
# It serves as a workaround for an issue documented at https://trac.osgeo.org/postgis/ticket/5316
# This increases the Docker image size by about 1 MB.
    && projsync --system-directory --file ch_swisstopo_CHENyx06_ETRS \
    && projsync --system-directory --file us_noaa_eshpgn \
    && projsync --system-directory --file us_noaa_prvi \
    && projsync --system-directory --file us_noaa_wmhpgn \
# Run the PostGIS regression suite.
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb -c -l /tempdb/logfile -o '-F' start ' \
    && cd regress \
    && make -j${NPROC:-$(nproc)} check RUNTESTFLAGS="--extension --verbose" PGUSER=postgres \
    \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;"' \
    # Tiger is bundled through PostGIS 3.6; standalone Tiger requires PostgreSQL 16+. \
    && if [ "$postgis_minor" -lt 7 ]; then \
        su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch; --needed for postgis_tiger_geocoder "' \
        && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer;"' \
        && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us;"' \
        && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;"' \
    ; else \
        su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"' \
        && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer;"' \
        && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us;"' \
        && if [ "$PG_MAJOR" -ge 16 ]; then \
            su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;"'; \
        fi \
    ; fi \
    && if [ "$postgis_minor" -ge 7 ] && [ "$PG_MAJOR" -ge 16 ]; then \
        cd /usr/src/postgis_tiger_geocoder \
        && PGUSER=postgres make PG_CONFIG="$(command -v pg_config)" installcheck; \
    fi \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"' \
    && su postgres -c 'psql -t -c "SELECT version();"'              >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "SELECT PostGIS_Full_Version();"' >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "\dx"' >> /_pgis_full_version.txt \
    \
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
    && if [ -n "$PGROUTING_VERSION" ]; then \
        apk add --no-cache --virtual .pgrouting-rundeps \
            boost1.84-atomic \
            boost1.84-chrono \
            boost1.84-date_time \
            boost1.84-graph \
            boost1.84-program_options \
            boost1.84-system \
            boost1.84-thread; \
    fi \
# Install runtime dependencies.
    && apk add --no-cache --virtual .postgis-rundeps \
        \
        gdal \
        geos \
        gmp \
        proj \
        sfcgal \
        \
        json-c \
        libstdc++ \
        pcre2 \
        protobuf-c \
        \
        # ca-certificates: for accessing remote raster files
        #   fix https://github.com/postgis/docker-postgis/issues/307
        ca-certificates \
# Clean build files and dependencies.
    && cd / \
    && rm -rf /usr/src/postgis \
    && rm -rf /usr/src/address_standardizer \
    && rm -rf /usr/src/postgis_tiger_geocoder \
    && if [ -n "$PGROUTING_VERSION" ]; then \
        apk del .pgrouting-build-deps; \
    fi \
    && apk del .fetch-deps .build-deps \
# Report build metadata.
    && cat /_pgis_full_version.txt

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

USER postgres
