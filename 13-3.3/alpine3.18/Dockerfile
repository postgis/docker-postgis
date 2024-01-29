#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#       source: "Dockerfile.alpine.template"
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG PGIS1_BASE_IMAGE=postgres:13-alpine3.18
ARG PGIS1_POSTGIS_REPOSITORY=https://github.com/postgis/postgis.git
ARG PGIS1_POSTGIS_CHECKOUT=tags/3.3.5
ARG PGIS1_POSTGIS_CHECKOUT_SHA1=97969989e8a1cbfa424b305f5c99c157921c9650

FROM ${PGIS1_BASE_IMAGE}

ARG PGIS1_POSTGIS_REPOSITORY
ARG PGIS1_POSTGIS_CHECKOUT
ARG PGIS1_POSTGIS_CHECKOUT_SHA1

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS ${PGIS1_POSTGIS_CHECKOUT} spatial database extension with PostgreSQL 13 alpine3.18" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

RUN set -eux \
    && apk add --no-cache --virtual .build-deps \
        \
        ca-certificates \
        gdal-dev \
        geos-dev \
        proj-dev \
        proj-util \
        sfcgal-dev \
        \
        # The upstream variable, '$DOCKER_PG_LLVM_DEPS' contains
        #  the correct versions of 'llvm-dev' and 'clang' for the current version of PostgreSQL.
        # This improvement has been discussed in https://github.com/docker-library/postgres/pull/1077
        $DOCKER_PG_LLVM_DEPS \
        \
        autoconf \
        automake \
        bison \
        cunit-dev \
        file \
        g++ \
        gcc \
        gettext-dev \
        git \
        json-c-dev \
        libtool \
        libxml2-dev \
        libxml2-utils \
        make \
        # Note: PCRE2 is not supported in older versions of PostGIS.
        # To ensure compatibility with PostGIS version 3.0, PCRE 1 is required.
        # If PCRE2 support is needed, please submit an issue on the docker-postgis GitHub repository.
        pcre-dev \
        perl \
        protobuf-c-dev \
    \
    # postgis
    && cd /usr/src \
    && mkdir postgis \
    && cd postgis \
    && git init \
    && git remote add origin ${PGIS1_POSTGIS_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_POSTGIS_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Verify that the commit hash matches the known good one
    && if [ "$(git rev-parse HEAD)" != "$PGIS1_POSTGIS_CHECKOUT_SHA1" ]; then exit 1; fi \
    && git log -1 > /_pgis_last_commit.txt \
# build PostGIS - with Link Time Optimization (LTO) enabled
    && cd /usr/src/postgis \
    && gettextize \
    && ./autogen.sh \
    && ./configure \
        --enable-lto \
    && make -j$(nproc) \
    && make install \
    \
# This section is for refreshing the proj data for the regression tests.
# It serves as a workaround for an issue documented at https://trac.osgeo.org/postgis/ticket/5316
# This increases the Docker image size by about 1 MB.
    && projsync --system-directory --file ch_swisstopo_CHENyx06_ETRS \
    && projsync --system-directory --file us_noaa_eshpgn \
    && projsync --system-directory --file us_noaa_prvi \
    && projsync --system-directory --file us_noaa_wmhpgn \
# This section performs a regression check.
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb -c -l /tmp/logfile -o '-F' start ' \
    && cd regress \
    && make -j$(nproc) check RUNTESTFLAGS=--extension PGUSER=postgres \
    \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch; --needed for postgis_tiger_geocoder "' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"' \
    && su postgres -c 'psql -t -c "SELECT version();"'              >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "SELECT PostGIS_Full_Version();"' >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "\dx"' >> /_pgis_full_version.txt \
    \
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
    && rm -rf /tmp/logfile \
    && rm -rf /tmp/pgis_reg \
# add .postgis-rundeps
    && apk add --no-cache --virtual .postgis-rundeps \
        \
        gdal \
        geos \
        proj \
        sfcgal \
        \
        json-c \
        libstdc++ \
        pcre \
        protobuf-c \
        \
        # for postgis_restore.pl ; ref: https://github.com/postgis/docker-postgis/issues/373
        perl \
        # ca-certificates: for accessing remote raster files
        #   fix https://github.com/postgis/docker-postgis/issues/307
        ca-certificates \
# clean
    && cd / \
    && rm -rf \
         /usr/src/postgis \
     	 /usr/local/share/doc \
	  	 /usr/local/share/man \
    && apk del .build-deps \
    #&& apk del .fetch-deps \
# At the end of the build, we print the collected information
# from the '/_pgis_full_version.txt' file. This is for experimental and internal purposes.
    && cat /_pgis_full_version.txt

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
