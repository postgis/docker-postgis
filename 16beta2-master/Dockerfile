#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#

# "Experimental"; solely for testing purposes. Anticipate frequent changes!
# This is a multi-stage Dockerfile, requiring a minimum Docker version of 17.05.

ARG DOCKER_CMAKE_BUILD_TYPE=Release
ARG CGAL_GIT_BRANCH=5.6.x-branch
FROM postgres:16beta2-bullseye as builder

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS - master  spatial database extension with PostgreSQL 16beta2 bullseye" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

WORKDIR /

# apt-get install
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libboost-atomic1.74.0 \
      libboost-chrono1.74.0 \
      libboost-date-time1.74.0 \
      libboost-filesystem1.74.0 \
      libboost-program-options1.74.0 \
      libboost-serialization1.74.0 \
      libboost-system1.74.0 \
      libboost-test1.74.0 \
      libboost-thread1.74.0 \
      libboost-timer1.74.0 \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c5 \
      libmpfr6 \
      libprotobuf-c1 \
      libtiff5 \
      libxml2 \
      sqlite3 \
      # build dependency
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
      libpcre3-dev \
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
      # gdal+
      libblosc-dev \
      libcfitsio-dev \
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

# cgal & sfcgal
# By utilizing the latest commit of the CGAL 5.x.x-branch and implementing a header-only build for SFCGAL,
# one can benefit from the latest CGAL patches while avoiding compatibility issues.
ARG CGAL_GIT_BRANCH
ENV CGAL_GIT_BRANCH=${CGAL_GIT_BRANCH}
ENV CGAL5X_GIT_HASH dd3b569e7abd66ba181d8d5567b62b1b88f187d1
ENV SFCGAL_GIT_HASH ae0a12da1e7a32d163930789e62874ca6ff0792c
RUN set -ex \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --branch ${CGAL_GIT_BRANCH} https://github.com/CGAL/cgal  \
    && cd cgal \
    && git checkout ${CGAL5X_GIT_HASH} \
    && git log -1 > /_pgis_cgal_last_commit.txt \
    && cd /usr/src \
    && git clone https://gitlab.com/Oslandia/SFCGAL.git \
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
    && make -j$(nproc) \
    && make install \
    #
    ## testing with -DSFCGAL_BUILD_TESTS=ON
    # && CTEST_OUTPUT_ON_FAILURE=TRUE ctest \
    #
    # clean
    && rm -fr /usr/src/SFCGAL \
    && rm -fr /usr/src/cgal

# proj
ENV PROJ_GIT_HASH fde3d58e4af51f8e6c9cafeeb2b0299ab1218d91
RUN set -ex \
    && cd /usr/src \
    && git clone https://github.com/OSGeo/PROJ.git \
    && cd PROJ \
    && git checkout ${PROJ_GIT_HASH} \
    && git log -1 > /_pgis_proj_last_commit.txt \
    # check the autotools exist? https://github.com/OSGeo/PROJ/pull/3027
    && if [ -f "autogen.sh" ] ; then \
        set -eux \
        && echo "autotools version: 'autogen.sh' exists! Older version!"  \
        && ./autogen.sh \
        && ./configure --disable-static \
        && make -j$(nproc) \
        && make install \
        ; \
    else \
        set -eux \
        && echo "cmake version: 'autogen.sh' does not exists! Newer version!" \
        && mkdir build \
        && cd build \
        && cmake .. -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
        && make -j$(nproc) \
        && make install \
        ; \
    fi \
    \
    && rm -fr /usr/src/PROJ

# geos
ENV GEOS_GIT_HASH 3d4870f7970dfac1b090e8a0d05d9b969a9d1180
RUN set -ex \
    && cd /usr/src \
    && git clone https://github.com/libgeos/geos.git \
    && cd geos \
    && git checkout ${GEOS_GIT_HASH} \
    && git log -1 > /_pgis_geos_last_commit.txt \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/geos

# gdal
ENV GDAL_GIT_HASH d5ae41aed1960dfd511d3c1edfbcefbe85d1adb2
RUN set -ex \
    && cd /usr/src \
    && git clone https://github.com/OSGeo/gdal.git \
    && cd gdal \
    && git checkout ${GDAL_GIT_HASH} \
    && git log -1 > /_pgis_gdal_last_commit.txt \
    \
    # gdal project directory structure - has been changed !
    && if [ -d "gdal" ] ; then \
        echo "Directory 'gdal' dir exists -> older version!" ; \
        cd gdal ; \
    else \
        echo "Directory 'gdal' does not exists! Newer version! " ; \
    fi \
    \
    && if [ -f "./autogen.sh" ]; then \
        # Building with autoconf ( old/deprecated )
        set -eux \
        && ./autogen.sh \
        && ./configure --disable-static \
        ; \
    else \
        # Building with cmake
        set -eux \
        && mkdir build \
        && cd build \
        # config based on: https://salsa.debian.org/debian-gis-team/gdal/-/blob/master/debian/rules
        && cmake .. -DCMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
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
            # OFF and Not working https://github.com/OSGeo/gdal/issues/7100
            # -DRENAME_INTERNAL_GEOTIFF_SYMBOLS=ON \
            -DGDAL_USE_ECW=OFF \
            -DGDAL_USE_GEOTIFF=OFF \
            -DGDAL_USE_HEIF=OFF \
            -DGDAL_USE_SPATIALITE=OFF \
        ; \
    fi \
    \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/gdal

# Minimal command line test.
RUN set -ex \
    && ldconfig \
    && cs2cs \
    && ldd $(which gdalinfo) \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    && pcre-config  --version

# -------------------------------------------
# STAGE  final
# -------------------------------------------
FROM postgres:16beta2-bullseye

ARG DOCKER_CMAKE_BUILD_TYPE
ENV DOCKER_CMAKE_BUILD_TYPE=${DOCKER_CMAKE_BUILD_TYPE}

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libboost-atomic1.74.0 \
      libboost-chrono1.74.0 \
      libboost-date-time1.74.0 \
      libboost-filesystem1.74.0 \
      libboost-program-options1.74.0 \
      libboost-serialization1.74.0 \
      libboost-system1.74.0 \
      libboost-test1.74.0 \
      libboost-thread1.74.0 \
      libboost-timer1.74.0 \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c5 \
      libmpfr6 \
      libpcre3 \
      libprotobuf-c1 \
      libtiff5 \
      libxml2 \
      sqlite3 \
      # gdal+
      libblosc1 \
      libcfitsio9 \
      libfreexl1 \
      libfyba0 \
      libhdf5-103-1 \
      libkmlbase1 \
      libkmldom1 \
      libkmlengine1 \
      libopenjp2-7 \
      libqhull-r8.0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /_pgis*.* /
COPY --from=builder /usr/local /usr/local

ARG CGAL_GIT_BRANCH
ENV CGAL_GIT_BRANCH=${CGAL_GIT_BRANCH}
ENV CGAL5X_GIT_HASH dd3b569e7abd66ba181d8d5567b62b1b88f187d1
ENV SFCGAL_GIT_HASH ae0a12da1e7a32d163930789e62874ca6ff0792c
ENV PROJ_GIT_HASH fde3d58e4af51f8e6c9cafeeb2b0299ab1218d91
ENV GEOS_GIT_HASH 3d4870f7970dfac1b090e8a0d05d9b969a9d1180
ENV GDAL_GIT_HASH d5ae41aed1960dfd511d3c1edfbcefbe85d1adb2

# Minimal command line test ( fail fast )
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
    # Testing ogr2ogr PostgreSQL driver.
    && ogr2ogr --formats | grep -q "PostgreSQL/PostGIS" && exit 0 \
            || echo "ogr2ogr missing PostgreSQL driver" && exit 1

# install postgis
ENV POSTGIS_GIT_HASH 6c7661430ebcce4521b23bd97b0a0d2be5ea027d

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
      g++ \
      git \
      libboost-all-dev \
      libcunit1-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
      libpcre3-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
      make \
      pkg-config \
      postgresql-server-dev-$PG_MAJOR \
      protobuf-c-compiler \
      xsltproc \
    && cd \
    # postgis
    && cd /usr/src/ \
    && git clone https://github.com/postgis/postgis.git \
    && cd postgis \
    && git checkout ${POSTGIS_GIT_HASH} \
    && git log -1 > /_pgis_last_commit.txt \
    && ./autogen.sh \
# configure options taken from:
# https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
    && ./configure \
        --enable-lto \
    && make -j$(nproc) \
    && make install \
# refresh proj data - workarounds: https://trac.osgeo.org/postgis/ticket/5316
    && projsync --system-directory --file ch_swisstopo_CHENyx06_ETRS \
    && projsync --system-directory --file us_noaa_eshpgn \
    && projsync --system-directory --file us_noaa_prvi \
    && projsync --system-directory --file us_noaa_wmhpgn \
# regress check
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb start' \
    && ldconfig \
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
    && su postgres -c 'psql -t -c "SELECT version();"' >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "SELECT PostGIS_Full_Version();"' >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "\dx"' >> /_pgis_full_version.txt \
    \
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
    && rm -rf /tmp/pgis_reg \
# clean
    && cd / \
    && rm -rf /usr/src/postgis \
    && apt-get purge -y --autoremove \
      autoconf \
      automake \
      autotools-dev \
      bison \
      build-essential \
      cmake \
      g++ \
      git \
      libboost-all-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
      libpcre3-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
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

# last final test
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
    # list last commits.
    && find /_pgis_*_last_commit.txt -type f -print -exec cat {} \;  \
    # list postgresql, postgis version
    && cat _pgis_full_version.txt
