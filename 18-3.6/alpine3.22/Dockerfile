#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "./tools/apply-templates.sh"
#       source: "./templates/Dockerfile.alpine.template"
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG PGIS1_BASE_IMAGE=postgres:18beta1-alpine3.22
ARG PGIS1_POSTGIS_REPOSITORY=https://github.com/postgis/postgis.git
ARG PGIS1_POSTGIS_CHECKOUT=tags/3.6.0alpha1
ARG PGIS1_POSTGIS_CHECKOUT_SHA1=b32829d707ef65515df1224361b9f2d5889db348

# usable for forking the image
ARG PGIS1_OPTIMIZATION_FLAGS=" -O3 -mtune=generic "
ARG PGIS1_SOURCE_REPO="https://github.com/postgis/docker-postgis"
ARG PGIS1_MAINTAINER="PostGIS Project - https://postgis.net - ${PGIS1_SOURCE_REPO}/issues"

FROM ${PGIS1_BASE_IMAGE}

ARG PGIS1_POSTGIS_REPOSITORY
ARG PGIS1_POSTGIS_CHECKOUT
ARG PGIS1_POSTGIS_CHECKOUT_SHA1
ARG PGIS1_OPTIMIZATION_FLAGS
ARG PGIS1_SOURCE_REPO
ARG PGIS1_MAINTAINER
ARG PGIS1_BASE_IMAGE

LABEL maintainer="${PGIS1_MAINTAINER}" \
      org.opencontainers.image.description="PostGIS ${PGIS1_POSTGIS_CHECKOUT} spatial database extension with PostgreSQL 18 alpine3.22" \
      org.opencontainers.image.source="${PGIS1_SOURCE_REPO}" \
      org.opencontainers.image.version="3.6.0alpha1" \
      org.opencontainers.image.revision="${PGIS1_POSTGIS_CHECKOUT_SHA1}" \
      org.opencontainers.image.created="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
      org.opencontainers.image.base.name="${PGIS1_BASE_IMAGE}" \
      \
      # child friendly image labels, so some duplacted labels expected
      org.postgis.base.maintainer="${PGIS1_MAINTAINER}" \
      org.postgis.base.description="PostGIS ${PGIS1_POSTGIS_CHECKOUT} spatial database extension with PostgreSQL 18 alpine3.22" \
      org.postgis.base.source="${PGIS1_SOURCE_REPO}" \
      org.postgis.base.version="3.6.0alpha1" \
      org.postgis.base.revision="${PGIS1_POSTGIS_CHECKOUT_SHA1}" \
      org.postgis.base.created="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
      org.postgis.base.extensions="postgis,postgis_raster,postgis_sfcgal,postgis_topology,postgis_tiger_geocoder,address_standardizer" \
      org.postgis.base.name="${PGIS1_BASE_IMAGE}" \
      org.postgis.base.optimization.flags="${PGIS1_OPTIMIZATION_FLAGS}" \
      org.postgis.base.source.repository="${PGIS1_POSTGIS_REPOSITORY}"


RUN set -eux \
    # Update package cache first
    && apk update \
    # Get exact versions of available packages
    && GDAL_VERSION=$(apk list --available gdal-dev | grep 'gdal-dev-' | head -1 | awk '{print $1}' | cut -d'-' -f3-) \
    && GEOS_VERSION=$(apk list --available geos-dev | grep 'geos-dev-' | head -1 | awk '{print $1}' | cut -d'-' -f3-) \
    && PROJ_VERSION=$(apk list --available proj-dev | grep 'proj-dev-' | head -1 | awk '{print $1}' | cut -d'-' -f3-) \
    && SFCGAL_VERSION=$(apk list --available sfcgal-dev | grep 'sfcgal-dev-' | head -1 | awk '{print $1}' | cut -d'-' -f3-) \
    && JSON_C_VERSION=$(apk list --available json-c | grep 'json-c-' | head -1 | awk '{print $1}' | cut -d'-' -f3-) \
    && PROTOBUF_C_VERSION=$(apk list --available protobuf-c | grep 'protobuf-c-' | head -1 | awk '{print $1}' | cut -d'-' -f3-) \
    && PCRE_VERSION=$(apk list --available pcre | grep '^pcre-' | head -1 | awk '{print $1}' | cut -d'-' -f2-) \
    && PERL_VERSION=$(apk list --available perl | grep '^perl-' | head -1 | awk '{print $1}' | cut -d'-' -f2-) \
    \
    # Export build environment for child images ( see example in the end of this file )
    && echo "export GDAL_VERSION=${GDAL_VERSION}" > /usr/local/share/docker-postgis-env.sh \
    && echo "export GEOS_VERSION=${GEOS_VERSION}" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PROJ_VERSION=${PROJ_VERSION}" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export SFCGAL_VERSION=${SFCGAL_VERSION}" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export JSON_C_VERSION=${JSON_C_VERSION}" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PROTOBUF_C_VERSION=${PROTOBUF_C_VERSION}" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PCRE_VERSION=${PCRE_VERSION}" >> /usr/local/share/docker-postgis-env.sh \
    && echo "export PERL_VERSION=${PERL_VERSION}" >> /usr/local/share/docker-postgis-env.sh \
    && chmod +x /usr/local/share/docker-postgis-env.sh \
    \
    && apk add --no-cache --virtual .build-deps \
        ca-certificates \
        gdal-dev=${GDAL_VERSION} \
        geos-dev=${GEOS_VERSION} \
        proj-dev=${PROJ_VERSION} \
        proj-util=${PROJ_VERSION} \
        sfcgal-dev=${SFCGAL_VERSION} \
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
    && if [ "$(git rev-parse HEAD)" != "$PGIS1_POSTGIS_CHECKOUT_SHA1" ]; then \
        echo "ERROR: SHA1 mismatch. Expected: $PGIS1_POSTGIS_CHECKOUT_SHA1, Got: $(git rev-parse HEAD)"; \
        exit 1; \
    fi \
    && git log -1 > /_pgis_last_commit.txt \
    # build PostGIS - with Link Time Optimization (LTO) enabled
    && cd /usr/src/postgis \
    && gettextize \
    && ./autogen.sh \
    && ./configure \
        --enable-lto \
        --with-optimization-flags="${PGIS1_OPTIMIZATION_FLAGS}" \
        --disable-debug \
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
    && make -j$(nproc) check RUNTESTFLAGS="--extension --verbose" PGUSER=postgres \
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
        gdal=${GDAL_VERSION} \
        geos=${GEOS_VERSION} \
        proj=${PROJ_VERSION} \
        sfcgal=${SFCGAL_VERSION} \
        json-c=${JSON_C_VERSION} \
        protobuf-c=${PROTOBUF_C_VERSION} \
        pcre=${PCRE_VERSION} \
        # for postgis_restore.pl ; ref: https://github.com/postgis/docker-postgis/issues/373
        perl=${PERL_VERSION} \
        # no locking, system componenets
        libstdc++ \
        # ca-certificates: for accessing remote raster files ; need the latest, no locking
        #   fix https://github.com/postgis/docker-postgis/issues/307
        ca-certificates \
    # clean
    && cd / \
    && rm -rf \
         /usr/src/postgis \
     	 /usr/local/share/doc \
	  	 /usr/local/share/man \
    && apk del .build-deps \
    # Add system package versions to version report
    && apk list --installed | grep -E "(geos|proj|gdal|sfcgal)" >> /_pgis_full_version.txt \
    && echo "Optimization flags: ${PGIS1_OPTIMIZATION_FLAGS}" >> /_pgis_full_version.txt \
    # At the end of the build, we print the collected information
    # from the '/_pgis_full_version.txt' file. This is for experimental and internal purposes.
    && cat /_pgis_full_version.txt

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin


# Draft child image example ( pgrouting )
#========================================================
#  FROM postgis/postgis:17-3.5-alpine3.22
#  LABEL \
#      # overwrite all org.opencontainers - labels
#      maintainer="pgrouting maintainers" \
#      org.opencontainers.image.description="PostGIS with pgrouting" \
#      org.opencontainers.image.source="..." \
#      org.opencontainers.image.version="..." \
#      org.opencontainers.image.revision="..." \
#      org.opencontainers.image.created="..." \
#      org.opencontainers.image.base.name="postgis/postgis:17-3.5-alpine3.22" \
#      # add your org labels
#      org.pgrouting.base.maintainer="..." \
#      org.pgrouting.base.optimization="...."
#
#  # Install development packages with same versions
#  RUN source /usr/local/share/docker-postgis-env.sh \
#      && apk add --no-cache --virtual .pgrouting-build-deps \
#          gdal-dev=${GDAL_VERSION} \
#          geos-dev=${GEOS_VERSION} \
#          $DOCKER_PG_LLVM_DEPS \
#          cmake \
#          boost-dev \
#          g++ \
#          gcc
#          ....
