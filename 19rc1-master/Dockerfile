#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#

# Build development PostGIS with stable releases of its build libraries.
# This is a multi-stage Dockerfile, requiring a minimum Docker version of 17.05.

ARG DOCKER_CMAKE_BUILD_TYPE=Release
ARG DOCKER_ENABLE_IPO=OFF
ARG CGAL_GIT_BRANCH=v6.2.1
ARG NPROC=
FROM debian:trixie-slim AS master-deps

ARG NPROC
ARG DOCKER_ENABLE_IPO

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS master build dependencies" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

WORKDIR /
ENV LD_LIBRARY_PATH=/usr/local/lib

# Install runtime libraries needed by source-built components and build tools.
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      # Keep runtime Boost packages aligned with the Boost development series
      # selected by libboost-all-dev for this Debian suite.
      libboost-atomic1.83.0 \
      libboost-chrono1.83.0t64 \
      libboost-date-time1.83.0 \
      libboost-filesystem1.83.0 \
      libboost-program-options1.83.0 \
      libboost-serialization1.83.0 \
      libboost-system1.83.0 \
      libboost-test1.83.0 \
      libboost-thread1.83.0 \
      libboost-timer1.83.0 \
      libcurl3t64-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c5 \
      libmpfr6 \
      libprotobuf-c1 \
      libtiff6 \
      libxml2 \
      sqlite3 \
      # Build dependencies.
      autoconf \
      automake \
      autotools-dev \
      bison \
      build-essential \
      ca-certificates \
      cmake \
      g++ \
      git \
      libboost-all-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
      libpcre2-dev \
      libpq-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
      make \
      pkg-config \
      protobuf-c-compiler \
      xsltproc \
      # Optional GDAL driver dependencies.
      libblosc-dev \
      libcfitsio-dev \
      libeigen3-dev \
      libfreexl-dev \
      libfyba-dev \
      libhdf5-dev \
      libkml-dev \
      liblz4-dev \
      liblzma-dev \
      libopenjp2-7-dev \
      libqhull-dev \
      libwebp-dev \
      libzstd-dev

ARG DOCKER_CMAKE_BUILD_TYPE
ENV DOCKER_CMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE}
ENV DOCKER_ENABLE_IPO=${DOCKER_ENABLE_IPO}
ARG NLOHMANN_JSON_VERSION=3.12.0

# nlohmann/json - header-only library for SFCGAL (with CMake support)
RUN set -ex \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && echo "Installing nlohmann/json version: ${NLOHMANN_JSON_VERSION}" \
    # Use the full source archive; the single-header package has no CMake config.
    && curl --fail --silent --show-error --location --retry 5 --retry-delay 2 --retry-connrefused "https://github.com/nlohmann/json/archive/refs/tags/v${NLOHMANN_JSON_VERSION}.tar.gz" -o nlohmann-json.tar.gz \
    && tar -xzf nlohmann-json.tar.gz \
    && cd "json-${NLOHMANN_JSON_VERSION}" \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DJSON_BuildTests=OFF \
    && make install \
    && cd /usr/src \
    && rm -rf "json-${NLOHMANN_JSON_VERSION}" nlohmann-json.tar.gz \
    && echo "nlohmann/json ${NLOHMANN_JSON_VERSION} installed with CMake support" > /_pgis_nlohmann_json_version.txt

# CGAL and SFCGAL.
ARG CGAL_GIT_BRANCH
ENV CGAL_GIT_BRANCH=${CGAL_GIT_BRANCH}
ENV CGAL_GIT_HASH=28811b671a12b5caa9e3688569dadbc6b3728fe6
ENV SFCGAL_GIT_HASH=137203dae01faab4a1287934f9457e925e3b4383
RUN set -ex \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet --depth 1 --branch ${CGAL_GIT_BRANCH} https://github.com/CGAL/cgal  \
    && cd cgal \
    && git checkout ${CGAL_GIT_HASH} \
    && git log -1 > /_pgis_cgal_last_commit.txt \
    && cd /usr/src \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://gitlab.com/SFCGAL/SFCGAL.git \
    && cd SFCGAL \
    && git checkout ${SFCGAL_GIT_HASH} \
    && git log -1 > /_pgis_sfcgal_last_commit.txt \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. \
       -DCGAL_DIR=/usr/src/cgal \
       -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} \
       -DSFCGAL_BUILD_BENCH=OFF \
       -DSFCGAL_BUILD_EXAMPLES=OFF \
       -DSFCGAL_BUILD_TESTS=OFF \
       -DSFCGAL_WITH_OSG=OFF \
    && make -j${NPROC:-$(nproc)} \
    && make install \
    #
    # Optional SFCGAL test hook; disabled by default because the final image
    # creates and checks the postgis_sfcgal extension downstream.
    # && CTEST_OUTPUT_ON_FAILURE=TRUE ctest \
    #
    # Clean CGAL/SFCGAL source trees.
    && rm -fr /usr/src/SFCGAL \
    && rm -fr /usr/src/cgal

# PROJ.
ENV PROJ_GIT_HASH=1df2be61c0e4732aa1326126113776b291ae7657
RUN set -ex \
    && cd /usr/src \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/OSGeo/PROJ.git \
    && cd PROJ \
    && git checkout ${PROJ_GIT_HASH} \
    && git log -1 > /_pgis_proj_last_commit.txt \
    # Keep the legacy autotools fallback for old PROJ revisions; current PROJ uses CMake.
    && if [ -f "autogen.sh" ] ; then \
        set -eux \
        && echo "autotools version: 'autogen.sh' exists! Older version!"  \
        && ./autogen.sh \
        && ./configure --disable-static \
        && make -j${NPROC:-$(nproc)} \
        && make install \
        ; \
    else \
        set -eux \
        && echo "cmake version: 'autogen.sh' does not exists! Newer version!" \
        && mkdir build \
        && cd build \
        && cmake .. -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
            -DENABLE_IPO=${DOCKER_ENABLE_IPO} \
            -DEMBED_RESOURCE_FILES=ON \
            -DUSE_ONLY_EMBEDDED_RESOURCE_FILES=OFF \
        && make -j${NPROC:-$(nproc)} \
        && make install \
        ; \
    fi \
    \
    && rm -fr /usr/src/PROJ

# GEOS.
ENV GEOS_GIT_HASH=d0228513abb0c29c185443cf2bfb06c9281024b5
RUN set -ex \
    && cd /usr/src \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/libgeos/geos.git \
    && cd geos \
    && git checkout ${GEOS_GIT_HASH} \
    && git log -1 > /_pgis_geos_last_commit.txt \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
    && make -j${NPROC:-$(nproc)} \
    && make install \
    && cd / \
    && rm -fr /usr/src/geos

# GDAL.
ENV GDAL_GIT_HASH=c8b4c45fca87d3e6fbf80e7a7898b8a661ad0edc
RUN set -ex \
    && cd /usr/src \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/OSGeo/gdal.git \
    && cd gdal \
    && git checkout ${GDAL_GIT_HASH} \
    && git log -1 > /_pgis_gdal_last_commit.txt \
    \
    # Support both the old nested gdal/ source layout and the current repository layout.
    && if [ -d "gdal" ] ; then \
        echo "Directory 'gdal' dir exists -> older version!" ; \
        cd gdal ; \
    else \
        echo "Directory 'gdal' does not exists! Newer version! " ; \
    fi \
    \
    && if [ -f "./autogen.sh" ]; then \
        # Legacy autoconf build path for old GDAL revisions.
        set -eux \
        && ./autogen.sh \
        && ./configure --disable-static \
        ; \
    else \
        # Current GDAL CMake build path.
        set -eux \
        && mkdir build \
        && cd build \
        # Keep the enabled GDAL dependencies explicit so source builds do not silently
        # change feature coverage when Debian package dependencies change.
        && cmake .. -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
            -DENABLE_IPO=${DOCKER_ENABLE_IPO} \
            -DBUILD_DOCS=OFF \
            \
            -DGDAL_HIDE_INTERNAL_SYMBOLS=ON \
            -DRENAME_INTERNAL_TIFF_SYMBOLS=ON \
            -DGDAL_USE_BLOSC=ON \
            -DGDAL_USE_CFITSIO=ON \
            -DGDAL_USE_CURL=ON \
            -DGDAL_USE_DEFLATE=ON \
            -DGDAL_USE_EXPAT=ON \
            -DGDAL_USE_FREEXL=ON \
            -DGDAL_USE_FYBA=ON \
            -DGDAL_USE_GEOS=ON \
            -DGDAL_USE_HDF5=ON \
            -DGDAL_USE_JSONC=ON \
            -DGDAL_USE_LERC_INTERNAL=ON \
            -DGDAL_USE_LIBKML=ON \
            -DGDAL_USE_LIBLZMA=ON \
            -DGDAL_USE_LZ4=ON \
            -DGDAL_USE_OPENJPEG=ON \
            -DGDAL_USE_POSTGRESQL=ON \
            -DGDAL_USE_QHULL=ON \
            -DGDAL_USE_SQLITE3=ON \
            -DGDAL_USE_TIFF=ON \
            -DGDAL_USE_WEBP=ON \
            -DGDAL_USE_ZSTD=ON \
            \
            # Use GDAL's internal GeoTIFF to avoid external libgeotiff pulling
            # in a different PROJ library version. GDAL_USE_GEOTIFF=OFF keeps
            # the external GeoTIFF package disabled; GDAL_USE_GEOTIFF_INTERNAL=ON
            # keeps internal GeoTIFF support explicit.
            # See https://github.com/OSGeo/gdal/issues/7100
            # -DRENAME_INTERNAL_GEOTIFF_SYMBOLS=ON \
            -DGDAL_USE_ECW=OFF \
            -DGDAL_USE_GEOTIFF=OFF \
            -DGDAL_USE_GEOTIFF_INTERNAL=ON \
            -DGDAL_USE_HEIF=OFF \
            -DGDAL_USE_SPATIALITE=OFF \
        ; \
    fi \
    \
    && make -j${NPROC:-$(nproc)} \
    && make install \
    && cd / \
    && rm -fr /usr/src/gdal

# Minimal command-line smoke test.
RUN set -ex \
    && ldconfig \
    && cs2cs \
    && ldd $(which gdalinfo) \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    && pcre2-config --version

# Keep the common source-built libraries reusable across PostgreSQL majors.
FROM master-deps AS builder

# -------------------------------------------
# STAGE  final
# -------------------------------------------
FROM docker.io/postgres:19rc1-trixie
ENV LD_LIBRARY_PATH=/usr/local/lib

ARG NPROC
ARG DOCKER_CMAKE_BUILD_TYPE
ARG DOCKER_ENABLE_IPO
ENV DOCKER_CMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE}
ENV DOCKER_ENABLE_IPO=${DOCKER_ENABLE_IPO}
ENV PGROUTING_VERSION=4.0.1-1.pgdg13+1

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      # Keep runtime Boost packages aligned with the Boost development series
      # selected by libboost-all-dev for this Debian suite.
      libboost-atomic1.83.0 \
      libboost-chrono1.83.0t64 \
      libboost-date-time1.83.0 \
      libboost-filesystem1.83.0 \
      libboost-program-options1.83.0 \
      libboost-serialization1.83.0 \
      libboost-system1.83.0 \
      libboost-test1.83.0 \
      libboost-thread1.83.0 \
      libboost-timer1.83.0 \
      libcurl3t64-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c5 \
      libmpfr6 \
      libpcre2-8-0 \
      libpcre2-posix3 \
      libprotobuf-c1 \
      libtiff6 \
      libxml2 \
      sqlite3 \
      # GDAL optional driver runtime dependencies
      libblosc1 \
      libcfitsio10t64 \
      libfreexl1 \
      libfyba0t64 \
      libgomp1 \
      libhdf5-310 \
      libkmlbase1t64 \
      libkmldom1t64 \
      libkmlengine1t64 \
      libopenjp2-7 \
      libqhull-r8.0 \
    && if [ -n "$PGROUTING_VERSION" ]; then \
      apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-pgrouting=$PGROUTING_VERSION; \
    fi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /_pgis*.* /
COPY --from=builder /usr/local /usr/local

ARG CGAL_GIT_BRANCH
ENV CGAL_GIT_BRANCH=${CGAL_GIT_BRANCH}
ENV CGAL_GIT_HASH=28811b671a12b5caa9e3688569dadbc6b3728fe6
ENV SFCGAL_GIT_HASH=137203dae01faab4a1287934f9457e925e3b4383
ENV PROJ_GIT_HASH=1df2be61c0e4732aa1326126113776b291ae7657
ENV GEOS_GIT_HASH=d0228513abb0c29c185443cf2bfb06c9281024b5
ENV GDAL_GIT_HASH=c8b4c45fca87d3e6fbf80e7a7898b8a661ad0edc

# Minimal command-line smoke test (fail fast).
RUN set -ex \
    && ldconfig \
    && cs2cs \
    && ldd $(which gdalinfo) \
    && gdalinfo --version \
    && gdal-config --formats \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    \
    # Verify that GDAL built the ogr2ogr PostgreSQL/PostGIS driver.
    && ogr2ogr --formats | grep -q "PostgreSQL/PostGIS" && exit 0 \
            || echo "ogr2ogr missing PostgreSQL driver" && exit 1

# Install PostGIS and stable companion extensions.
ENV POSTGIS_GIT_HASH=4db4d8050012b7a84e70ed11629bbc71daa20b6e
ENV H3_PG_GIT_HASH=ed9a09c834787abb5952318bccef1c4fee119f1d
ENV ADDRESS_STANDARDIZER_GIT_HASH=fa11ff53eb49b863d9ffff37f6afd5ff9299c581
ENV TIGER_GEOCODER_VERSION=2025.2
ENV TIGER_GEOCODER_SHA256=c33cfbfb40785db8754a36be66060e8d023773e7e1be8fb8a622bb3c48db9f54

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      autotools-dev \
      bison \
      build-essential \
      ca-certificates \
      cmake \
      docbook-xml \
      docbook5-xml \
      g++ \
      git \
      libboost-all-dev \
      libcunit1-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
      libpcre2-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
      libxml2-utils \
      make \
      pkg-config \
      "postgresql-server-dev-$PG_MAJOR=$PG_VERSION" \
      protobuf-c-compiler \
      xsltproc \
    && cd \
    # PostGIS master.
    && cd /usr/src/ \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/postgis/postgis.git \
    && cd postgis \
    && git checkout ${POSTGIS_GIT_HASH} \
    && git log -1 > /_pgis_last_commit.txt \
    && ./autogen.sh \
# Build PostGIS with LTO; the upstream library stack can opt into IPO separately
# through DOCKER_ENABLE_IPO.
    && ./configure \
        --enable-lto \
    && make -j${NPROC:-$(nproc)} \
    && make install \
    # h3-pg from the latest stable release.
    && cd /usr/src/ \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/postgis/h3-pg.git \
    && cd h3-pg \
    && git checkout ${H3_PG_GIT_HASH} \
    && git log -1 > /_pgis_h3_pg_last_commit.txt \
    && cmake -B build -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DBUILD_TESTING=ON \
    && cmake --build build -j${NPROC:-$(nproc)} \
    && cmake --install build --component h3-pg \
    && chown -R postgres:postgres build \
    # Skip the full h3_postgis_regress suite because tile_coverage is slow and flaky
    && if ! su postgres -c "ctest --test-dir /usr/src/h3-pg/build --output-on-failure -R '^(h3_regress|h3_inlined|h3_postgis_regress_fast)$'"; then \
        find /usr/src/h3-pg/build \( -path '*/test/log/*' -o -name 'regression.diffs' -o -name 'regression.out' -o -name 'regression.log' -o -name 'LastTest.log' \) -type f -print -exec sh -c 'echo "===== $1 ====="; cat "$1"' sh {} \; ; \
        exit 1; \
    fi \
    # address_standardizer from the latest stable release.
    && cd /usr/src/ \
    && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/postgis/address_standardizer.git \
    && cd address_standardizer \
    && git checkout ${ADDRESS_STANDARDIZER_GIT_HASH} \
    && git log -1 > /_pgis_address_standardizer_last_commit.txt \
    && make PG_CONFIG=/usr/lib/postgresql/$PG_MAJOR/bin/pg_config PG_CFLAGS=-Werror with_llvm=no \
    && make PG_CONFIG=/usr/lib/postgresql/$PG_MAJOR/bin/pg_config PG_CFLAGS=-Werror with_llvm=no install \
    # Tiger Geocoder 2025.2 is standalone from PostGIS 3.7 onward.
    && cd /usr/src \
    && curl --fail --silent --show-error --location --retry 5 --retry-delay 2 --retry-connrefused "https://download.osgeo.org/postgis/source/postgis_tiger_geocoder/postgis_tiger_geocoder-${TIGER_GEOCODER_VERSION}.tar.gz" -o postgis_tiger_geocoder.tar.gz \
    && echo "${TIGER_GEOCODER_SHA256} *postgis_tiger_geocoder.tar.gz" | sha256sum -c - \
    && tar -xzf postgis_tiger_geocoder.tar.gz \
    && cd postgis_tiger_geocoder \
    && make PG_CONFIG=/usr/lib/postgresql/$PG_MAJOR/bin/pg_config \
    && make PG_CONFIG=/usr/lib/postgresql/$PG_MAJOR/bin/pg_config install \
    && rm -f /usr/src/postgis_tiger_geocoder.tar.gz \
    && cd /usr/src/postgis \
# Refresh selected PROJ grids needed by the PostGIS regression suite.
# Workaround for https://trac.osgeo.org/postgis/ticket/5316
    && projsync --system-directory --file ch_swisstopo_CHENyx06_ETRS \
    && projsync --system-directory --file us_noaa_eshpgn \
    && projsync --system-directory --file us_noaa_prvi \
    && projsync --system-directory --file us_noaa_wmhpgn \
# Regression checks.
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb -c -l /tempdb/logfile -o '-F' start ' \
    && ldconfig \
    && cd /usr/src/address_standardizer \
    && if ! PGUSER=postgres make PG_CONFIG=/usr/lib/postgresql/$PG_MAJOR/bin/pg_config installcheck; then \
        if [ -f test/regression.diffs ]; then cat test/regression.diffs; fi; \
        exit 1; \
    fi \
    && cd /usr/src/postgis/regress \
    && make -j${NPROC:-$(nproc)} check RUNTESTFLAGS="--extension --verbose" PGUSER=postgres \
    && cd /usr/src/postgis/sfcgal \
    && make -j${NPROC:-$(nproc)} check RUNTESTFLAGS="--extension --verbose" PGUSER=postgres \
    \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_raster;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch; --needed for postgis_tiger_geocoder "' \
    # The explicit CREATE statements below make missing standalone controls fatal.
    # See: https://lists.osgeo.org/pipermail/postgis-devel/2026-February/030730.html
    && su postgres -c "psql -v ON_ERROR_STOP=1 -c \"DO \\\$\\\$ DECLARE extension_name text; BEGIN FOREACH extension_name IN ARRAY ARRAY['address_standardizer', 'address_standardizer_data_us', 'postgis_tiger_geocoder'] LOOP IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = extension_name) THEN EXECUTE format('CREATE EXTENSION IF NOT EXISTS %I', extension_name); ELSE RAISE NOTICE 'Extension % is not available, skipping', extension_name; END IF; END LOOP; END \\\$\\\$;\"" \
    # Require separately built controls; a missing extension must fail the image build. \
    && su postgres -c 'psql -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS address_standardizer;"' \
    && su postgres -c 'psql -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS address_standardizer_data_us;"' \
    && su postgres -c 'psql -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;"' \
    && cd /usr/src/postgis_tiger_geocoder \
    && PGUSER=postgres make PG_CONFIG=/usr/lib/postgresql/$PG_MAJOR/bin/pg_config installcheck \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS h3;"' \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS h3_postgis;"' \
    && su postgres -c 'psql -t -c "SELECT version();"' >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "SELECT PostGIS_Full_Version();"' >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "\dx"' >> /_pgis_full_version.txt \
    \
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
# Clean build dependencies and source trees.
    && cd / \
    && rm -rf /usr/src/postgis \
    && rm -rf /usr/src/h3-pg \
    && rm -rf /usr/src/address_standardizer \
    && rm -rf /usr/src/postgis_tiger_geocoder \
    && apt-get purge -y --autoremove \
      autoconf \
      automake \
      autotools-dev \
      bison \
      build-essential \
      cmake \
      docbook-xml \
      docbook5-xml \
      g++ \
      git \
      libboost-all-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
      libpcre2-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
      libxml2-utils \
      make \
      pkg-config \
      postgresql-server-dev-$PG_MAJOR \
      protobuf-c-compiler \
      xsltproc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

# Final smoke test.
RUN set -ex \
    && ldconfig \
    && cs2cs \
    && ldd $(which gdalinfo) \
    && gdalinfo --version \
    && gdal-config --formats \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    \
    # Is the "ca-certificates" package installed? (for accessing remote raster files)
    #   https://github.com/postgis/docker-postgis/issues/307
    && dpkg-query -W -f='${Status}' ca-certificates 2>/dev/null | grep -c "ok installed" \
    \
    # List last commits.
    && find /_pgis_*_last_commit.txt -type f -print -exec cat {} \;  \
    # List PostgreSQL and PostGIS version details.
    && cat _pgis_full_version.txt

USER postgres
