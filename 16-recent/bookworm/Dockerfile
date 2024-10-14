#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#       source: "Dockerfile.master.template"
# PLEASE DO NOT EDIT IT DIRECTLY.
#
# "Experimental"; solely for testing purposes. Anticipate frequent changes!
# This is a multi-stage Dockerfile, requiring a minimum Docker version of 17.05.

ARG PGIS1_BASE_IMAGE=postgres:16-bookworm

ARG PGIS1_POSTGIS_REPOSITORY=https://github.com/postgis/postgis.git
ARG PGIS1_GEOS_REPOSITORY=https://github.com/libgeos/geos.git
ARG PGIS1_GDAL_REPOSITORY=https://github.com/OSGeo/gdal.git
ARG PGIS1_PROJ_REPOSITORY=https://github.com/OSGeo/PROJ.git
ARG PGIS1_SFCGAL_REPOSITORY=https://gitlab.com/sfcgal/SFCGAL.git
ARG PGIS1_CGAL_REPOSITORY=https://github.com/CGAL/cgal.git

# Should valid git checkout ( SHA1, tags, branches )
ARG PGIS1_POSTGIS_CHECKOUT=tags/3.5.0
ARG PGIS1_GEOS_CHECKOUT=tags/3.13.0
ARG PGIS1_GDAL_CHECKOUT=tags/v3.9.3
ARG PGIS1_PROJ_CHECKOUT=tags/9.5.0
ARG PGIS1_SFCGAL_CHECKOUT=tags/v2.0.0
ARG PGIS1_CGAL_CHECKOUT=tags/v6.0

# Skip SHA1 check if PGIS1_*_CHECKOUT_SHA1 is empty or 'nocheck'
# Otherwise, verify that the commit hash matches
ARG PGIS1_POSTGIS_CHECKOUT_SHA1=d2c3ca48e648571deda98d8e4d9bb4e2c82fde16
ARG PGIS1_GEOS_CHECKOUT_SHA1=d7957246c588aa9c690efe67924fd70e741a06ab
ARG PGIS1_GDAL_CHECKOUT_SHA1=501754d048e07b07932ec268b6ed3c43ea0819e3
ARG PGIS1_PROJ_CHECKOUT_SHA1=0a407325fbb5bf42407a7dc5d4f948be9707e302
ARG PGIS1_SFCGAL_CHECKOUT_SHA1=5d4eb5e896c41e592534ba1e79ccc721c66d66e3
ARG PGIS1_CGAL_CHECKOUT_SHA1=50219fc33bc53b5846e9a4257befc6baef3f395a

ARG PGIS1_BOOST_VERSION=1.74.0
ARG PGIS1_CMAKE_BUILD_TYPE=Release

ARG PGIS1_GDAL_BUILD=with_extra
# Full GDAL build ; with arrow, parquet and extra dependencies

FROM ${PGIS1_BASE_IMAGE} as builder

WORKDIR /

ARG PGIS1_BOOST_VERSION
ENV PGIS1_BOOST_VERSION=${PGIS1_BOOST_VERSION}

# apt-get install
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libboost-atomic${PGIS1_BOOST_VERSION} \
      libboost-chrono${PGIS1_BOOST_VERSION} \
      libboost-date-time${PGIS1_BOOST_VERSION} \
      libboost-filesystem${PGIS1_BOOST_VERSION} \
      libboost-program-options${PGIS1_BOOST_VERSION} \
      libboost-serialization${PGIS1_BOOST_VERSION} \
      libboost-system${PGIS1_BOOST_VERSION} \
      libboost-test${PGIS1_BOOST_VERSION} \
      libboost-thread${PGIS1_BOOST_VERSION} \
      libboost-timer${PGIS1_BOOST_VERSION} \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c5 \
      libmpfr6 \
      libprotobuf-c1 \
      libtiff6 \
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
      liblz4-dev \
      liblzma-dev \
      libwebp-dev \
      libzstd-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG PGIS1_CMAKE_BUILD_TYPE
ENV PGIS1_CMAKE_BUILD_TYPE=${PGIS1_CMAKE_BUILD_TYPE}

FROM builder as cgal-sfcgal-builder

# cgal & sfcgal
ARG PGIS1_SFCGAL_REPOSITORY
ENV PGIS1_SFCGAL_REPOSITORY ${PGIS1_SFCGAL_REPOSITORY}
ARG PGIS1_SFCGAL_CHECKOUT
ENV PGIS1_SFCGAL_CHECKOUT ${PGIS1_SFCGAL_CHECKOUT}
ARG PGIS1_SFCGAL_CHECKOUT_SHA1

ARG PGIS1_CGAL_REPOSITORY
ENV PGIS1_CGAL_REPOSITORY ${PGIS1_CGAL_REPOSITORY}
ARG PGIS1_CGAL_CHECKOUT
ENV PGIS1_CGAL_CHECKOUT ${PGIS1_CGAL_CHECKOUT}
ARG PGIS1_CGAL_CHECKOUT_SHA1

RUN set -eux \
    && cd /usr/src \
    && mkdir cgal \
    && cd cgal \
    && git init \
    && git remote add origin ${PGIS1_CGAL_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_CGAL_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Skip SHA1 check if PGIS1_CGAL_CHECKOUT_SHA1 is empty or 'nocheck'
    # Otherwise, verify that the commit hash matches PGIS1_CGAL_CHECKOUT_SHA1
    && if [ -z "${PGIS1_CGAL_CHECKOUT_SHA1}" ] \
       || [ "${PGIS1_CGAL_CHECKOUT_SHA1}" = "nocheck" ]; then \
         echo "Skipping CGAL SHA1 check"; \
       else \
         if [ "$(git rev-parse HEAD)" != "${PGIS1_CGAL_CHECKOUT_SHA1}" ]; then \
           echo "CGAL SHA1 problem! Stop!"; \
           exit 1; \
         fi; \
       fi \
    && git log -1 > /_pgis_cgal_last_commit.txt \
    && cd /usr/src \
    && mkdir SFCGAL \
    && cd SFCGAL \
    && git init \
    && git remote add origin ${PGIS1_SFCGAL_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_SFCGAL_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Skip SHA1 check if PGIS1_SFCGAL_CHECKOUT_SHA1 is empty or 'nocheck'
    # Otherwise, verify that the commit hash matches PGIS1_SFCGAL_CHECKOUT_SHA1
    && if [ -z "${PGIS1_SFCGAL_CHECKOUT_SHA1}" ] \
       || [ "${PGIS1_SFCGAL_CHECKOUT_SHA1}" = "nocheck" ]; then \
         echo "Skipping SFCGAL SHA1 check"; \
       else \
         if [ "$(git rev-parse HEAD)" != "${PGIS1_SFCGAL_CHECKOUT_SHA1}" ]; then \
           echo "SFCGAL SHA1 problem! Stop!"; \
           exit 1; \
         fi; \
       fi \
    && git log -1 > /_pgis_sfcgal_last_commit.txt \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. \
       -DCGAL_DIR=/usr/src/cgal \
       -DCMAKE_BUILD_TYPE=${PGIS1_CMAKE_BUILD_TYPE} \
       -DSFCGAL_BUILD_BENCH=OFF \
       -DSFCGAL_BUILD_EXAMPLES=OFF \
       -DSFCGAL_BUILD_TESTS=OFF \
       -DSFCGAL_WITH_OSG=OFF \
    && make -j$(nproc) \
    && make install \
    # clean
    && rm -fr /usr/src/SFCGAL \
    && rm -fr /usr/src/cgal


FROM builder as proj-builder

# proj
ARG PGIS1_PROJ_REPOSITORY
ENV PGIS1_PROJ_REPOSITORY ${PGIS1_PROJ_REPOSITORY}
ARG PGIS1_PROJ_CHECKOUT
ENV PGIS1_PROJ_CHECKOUT ${PGIS1_PROJ_CHECKOUT}
ARG PGIS1_PROJ_CHECKOUT_SHA1

RUN set -eux \
    && cd /usr/src \
    && mkdir PROJ \
    && cd PROJ \
    && git init \
    && git remote add origin ${PGIS1_PROJ_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_PROJ_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Skip SHA1 check if PGIS1_PROJ_CHECKOUT_SHA1 is empty or 'nocheck'
    # Otherwise, verify that the commit hash matches PGIS1_PROJ_CHECKOUT_SHA1
    && if [ -z "${PGIS1_PROJ_CHECKOUT_SHA1}" ] \
       || [ "${PGIS1_PROJ_CHECKOUT_SHA1}" = "nocheck" ]; then \
         echo "Skipping PROJ SHA1 check"; \
       else \
         if [ "$(git rev-parse HEAD)" != "${PGIS1_PROJ_CHECKOUT_SHA1}" ]; then \
           echo "PROJ SHA1 problem! Stop!"; \
           exit 1; \
         fi; \
       fi \
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
        && cmake .. -DCMAKE_BUILD_TYPE=${PGIS1_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
        && make -j$(nproc) \
        && make install \
        ; \
    fi \
    \
    && rm -fr /usr/src/PROJ


FROM builder as geos-builder

# geos
ARG PGIS1_GEOS_REPOSITORY
ENV PGIS1_GEOS_REPOSITORY ${PGIS1_GEOS_REPOSITORY}
ARG PGIS1_GEOS_CHECKOUT
ENV PGIS1_GEOS_CHECKOUT ${PGIS1_GEOS_CHECKOUT}
ARG PGIS1_GEOS_CHECKOUT_SHA1

RUN set -eux \
    && cd /usr/src \
    && mkdir geos \
    && cd geos \
    && git init \
    && git remote add origin ${PGIS1_GEOS_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_GEOS_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Skip SHA1 check if PGIS1_GEOS_CHECKOUT_SHA1 is empty or 'nocheck'
    # Otherwise, verify that the commit hash matches PGIS1_GEOS_CHECKOUT_SHA1
    && if [ -z "${PGIS1_GEOS_CHECKOUT_SHA1}" ] \
       || [ "${PGIS1_GEOS_CHECKOUT_SHA1}" = "nocheck" ]; then \
         echo "Skipping GEOS SHA1 check"; \
       else \
         if [ "$(git rev-parse HEAD)" != "${PGIS1_GEOS_CHECKOUT_SHA1}" ]; then \
           echo "GEOS SHA1 problem! Stop!"; \
           exit 1; \
         fi; \
       fi \
    && git log -1 > /_pgis_geos_last_commit.txt \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. -DCMAKE_BUILD_TYPE=${PGIS1_CMAKE_BUILD_TYPE} -DBUILD_TESTING=OFF \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/geos


FROM builder as stage0-builder

COPY --from=cgal-sfcgal-builder /_pgis*.* /
COPY --from=cgal-sfcgal-builder /usr/local /usr/local

COPY --from=proj-builder /_pgis*.* /
COPY --from=proj-builder /usr/local /usr/local

COPY --from=geos-builder /_pgis*.* /
COPY --from=geos-builder /usr/local /usr/local
# gdal
ARG PGIS1_GDAL_REPOSITORY
ENV PGIS1_GDAL_REPOSITORY ${PGIS1_GDAL_REPOSITORY}
ARG PGIS1_GDAL_CHECKOUT
ENV PGIS1_GDAL_CHECKOUT ${PGIS1_GDAL_CHECKOUT}
ARG PGIS1_GDAL_CHECKOUT_SHA1



# Install Arrow C++
#  also check the "Build final image" section too, for the final installation
RUN set -eux \
    # add backports \
    && apt-get update \
    && apt install -y -V ca-certificates wget \
    && wget https://apache.jfrog.io/artifactory/arrow/debian/apache-arrow-apt-source-latest-bookworm.deb \
    && apt-get install -y -V ./apache-arrow-apt-source-latest-bookworm.deb \
    && apt-get update \
    # Automatically determine the latest PGIS1 Arrow version and SOVERSION
    && apt-cache showpkg libarrow-dev \
    && PGIS1_ARROW_VERSION=$(apt-cache showpkg libarrow-dev | grep -m1 'Versions:' -A1 | tail -n1 | grep -oP '^\S+') \
    && apt-cache depends libarrow-dev=${PGIS1_ARROW_VERSION} | tee /_pgis1_libarrow-dev-dependencies.txt \
    && PGIS1_ARROW_SOVERSION=$(grep 'Depends: libarrow' /_pgis1_libarrow-dev-dependencies.txt | grep -oP 'libarrow\K[0-9]+') \
    && echo "Detected PGIS1_ARROW_VERSION=$PGIS1_ARROW_VERSION" \
    && echo "Detected PGIS1_ARROW_SOVERSION=$PGIS1_ARROW_SOVERSION" \
    # Backup the version variables - reusing in a later stage
    && echo "PGIS1_ARROW_VERSION=$PGIS1_ARROW_VERSION" > /_pgis1_arrow_environment.env \
    && echo "PGIS1_ARROW_SOVERSION=$PGIS1_ARROW_SOVERSION" >> /_pgis1_arrow_environment.env \
    # Install Arrow C++
    && apt-get install -y --no-install-recommends \
      libarrow${PGIS1_ARROW_SOVERSION} \
      libparquet${PGIS1_ARROW_SOVERSION} \
      libarrow-dataset${PGIS1_ARROW_SOVERSION} \
      libarrow-dev=${PGIS1_ARROW_VERSION} \
      libparquet-dev=${PGIS1_ARROW_VERSION} \
      libarrow-acero-dev=${PGIS1_ARROW_VERSION} \
      libarrow-dataset-dev=${PGIS1_ARROW_VERSION} \
      \
      libblosc-dev \
      libcfitsio-dev \
      libfreexl-dev \
      libfyba-dev \
      libhdf5-dev \
      libheif-dev \
      libkml-dev \
      libnetcdf-dev \
      libopenjp2-7-dev \
      libpng-dev \
      libqhull-dev \
      libspatialite-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## GDAL_build-end

RUN set -eux \
    && ldconfig \
    && cd /usr/src \
    && mkdir gdal \
    && cd gdal \
    && git init \
    && git remote add origin ${PGIS1_GDAL_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_GDAL_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Skip SHA1 check if PGIS1_GDAL_CHECKOUT_SHA1 is empty or 'nocheck'
    # Otherwise, verify that the commit hash matches PGIS1_GDAL_CHECKOUT_SHA1
    && if [ -z "${PGIS1_GDAL_CHECKOUT_SHA1}" ] \
       || [ "${PGIS1_GDAL_CHECKOUT_SHA1}" = "nocheck" ]; then \
         echo "Skipping GDAL SHA1 check"; \
       else \
         if [ "$(git rev-parse HEAD)" != "${PGIS1_GDAL_CHECKOUT_SHA1}" ]; then \
           echo "GDAL SHA1 problem! Stop!"; \
           exit 1; \
         fi; \
       fi \
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
        && cmake .. \
            -DCMAKE_BUILD_TYPE=${PGIS1_CMAKE_BUILD_TYPE} \
            -DBUILD_TESTING=OFF \
            -DBUILD_DOCS=OFF \
            \
            -DGDAL_HIDE_INTERNAL_SYMBOLS=ON \
            -DRENAME_INTERNAL_TIFF_SYMBOLS=ON \
            -DGDAL_USE_CURL=ON \
            -DGDAL_USE_DEFLATE=ON \
            -DGDAL_USE_EXPAT=ON \
            -DGDAL_USE_GEOS=ON \
            -DGDAL_USE_JSONC=ON \
            -DGDAL_USE_LIBLZMA=ON \
            -DGDAL_USE_LIBXML2=ON \
            -DGDAL_USE_LZ4=ON \
            -DGDAL_USE_POSTGRESQL=ON \
            -DGDAL_USE_SQLITE3=ON \
            -DGDAL_USE_TIFF=ON \
            -DGDAL_USE_WEBP=ON \
            -DGDAL_USE_ZLIB=ON \
            -DGDAL_USE_ZSTD=ON \
            \
            -DGDAL_USE_ARROW=ON \
            -DGDAL_USE_ARROWDATASET=ON \
            -DGDAL_USE_BLOSC=ON \
            -DGDAL_USE_CFITSIO=ON \
            -DGDAL_USE_FREEXL=ON \
            -DGDAL_USE_FYBA=ON \
            -DGDAL_USE_HDF5=ON \
            -DGDAL_USE_HEIF=ON \
            -DGDAL_USE_LERC_INTERNAL=ON \
            -DGDAL_USE_LIBKML=ON \
            -DGDAL_USE_NETCDF=ON \
            -DGDAL_USE_OPENJPEG=ON \
            -DGDAL_USE_PARQUET=ON \
            -DGDAL_USE_PNG=ON \
            -DGDAL_USE_QHULL=ON \
            -DGDAL_USE_SPATIALITE=ON \
        ; \
    fi \
    \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/gdal

# Minimal command line test.
RUN set -eux \
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
# final stage
# -------------------------------------------
FROM ${PGIS1_BASE_IMAGE}

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS - 16-recent spatial database extension with PostgreSQL 16 bookworm" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ARG PGIS1_CMAKE_BUILD_TYPE
ARG PGIS1_BASE_IMAGE
ARG PGIS1_BOOST_VERSION

ENV PGIS1_CMAKE_BUILD_TYPE=${PGIS1_CMAKE_BUILD_TYPE} \
    PGIS1_BASE_IMAGE=${PGIS1_BASE_IMAGE} \
    PGIS1_BOOST_VERSION=${PGIS1_BOOST_VERSION}

RUN set -eux \
    && apt-get update \
    && apt-get install -y -V --no-install-recommends \
      \
      curl \
      libboost-atomic${PGIS1_BOOST_VERSION} \
      libboost-chrono${PGIS1_BOOST_VERSION} \
      libboost-date-time${PGIS1_BOOST_VERSION} \
      libboost-filesystem${PGIS1_BOOST_VERSION} \
      libboost-program-options${PGIS1_BOOST_VERSION} \
      libboost-serialization${PGIS1_BOOST_VERSION} \
      libboost-system${PGIS1_BOOST_VERSION} \
      libboost-test${PGIS1_BOOST_VERSION} \
      libboost-thread${PGIS1_BOOST_VERSION} \
      libboost-timer${PGIS1_BOOST_VERSION} \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c5 \
      libmpfr6 \
      libpcre3 \
      libprotobuf-c1 \
      libtiff6 \
      libxml2 \
      sqlite3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=stage0-builder /_pgis*.* /
COPY --from=stage0-builder /usr/local /usr/local

# Install Arrow + Parquet + other GDAL extra dependencies

RUN set -eux \
    # Install Arrow + Parquet
    && apt-get update \
    && apt-get install -y -V ca-certificates wget \
    && wget https://apache.jfrog.io/artifactory/arrow/debian/apache-arrow-apt-source-latest-bookworm.deb \
    && apt-get install -y -V ./apache-arrow-apt-source-latest-bookworm.deb \
    && apt-get update \
    # Load the PGIS1_ARROW version variables
    && . /_pgis1_arrow_environment.env \
    # Use the PGIS1_ARROW_SOVERSION as needed
    && echo "Using PGIS1_ARROW_SOVERSION=$PGIS1_ARROW_SOVERSION" \
    && apt-get install -y -V --no-install-recommends \
      libarrow${PGIS1_ARROW_SOVERSION} \
      libparquet${PGIS1_ARROW_SOVERSION} \
      libarrow-dataset${PGIS1_ARROW_SOVERSION} \
      \
      # Install GDAL extra dependencies
      libblosc1 \
      libcrypto++8 \
      libfreexl1 \
      libfyba0 \
      libhdf5-103-1 \
      libheif1 \
      libkmlbase1 \
      libkmldom1 \
      libkmlengine1 \
      libnetcdf19 \
      libopenjp2-7 \
      libpng16-16 \
      libqhull-r8.0 \
      librasterlite2-1 \
      libspatialite7 \
      netcdf-bin \
      libcfitsio10 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ARG PGIS1_GDAL_CHECKOUT
ARG PGIS1_GDAL_REPOSITORY
ARG PGIS1_GEOS_CHECKOUT
ARG PGIS1_GEOS_REPOSITORY
ARG PGIS1_PROJ_CHECKOUT
ARG PGIS1_PROJ_REPOSITORY
ARG PGIS1_SFCGAL_CHECKOUT
ARG PGIS1_SFCGAL_REPOSITORY
ARG PGIS1_CGAL_REPOSITORY
ARG PGIS1_CGAL_CHECKOUT

ARG PGIS1_POSTGIS_CHECKOUT
ARG PGIS1_POSTGIS_REPOSITORY
ARG PGIS1_POSTGIS_CHECKOUT_SHA1

ENV PGIS1_GDAL_CHECKOUT=${PGIS1_GDAL_CHECKOUT} \
    PGIS1_GDAL_REPOSITORY=${PGIS1_GDAL_REPOSITORY} \
    PGIS1_GEOS_CHECKOUT=${PGIS1_GEOS_CHECKOUT} \
    PGIS1_GEOS_REPOSITORY=${PGIS1_GEOS_REPOSITORY} \
    PGIS1_PROJ_CHECKOUT=${PGIS1_PROJ_CHECKOUT} \
    PGIS1_PROJ_REPOSITORY=${PGIS1_PROJ_REPOSITORY} \
    PGIS1_CGAL_CHECKOUT=${PGIS1_CGAL_CHECKOUT} \
    PGIS1_CGAL_REPOSITORY=${PGIS1_CGAL_REPOSITORY} \
    PGIS1_SFCGAL_CHECKOUT=${PGIS1_SFCGAL_CHECKOUT} \
    PGIS1_SFCGAL_REPOSITORY=${PGIS1_SFCGAL_REPOSITORY} \
    PGIS1_POSTGIS_CHECKOUT=${PGIS1_POSTGIS_CHECKOUT} \
    PGIS1_POSTGIS_REPOSITORY=${PGIS1_POSTGIS_REPOSITORY}

# Minimal command line test ( fail fast )
RUN set -eux \
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

# Specify GDAL_CONFIG and LD_LIBRARY_PATH for PostGIS build;
# The arm64 build is very senitive.
ENV GDAL_CONFIG /usr/local/bin/gdal-config
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# temporary workaround for : nitdb: invalid locale settings; check LANG and LC_* environment variables
#   https://github.com/docker-library/postgres/issues/1112#issuecomment-1746076388
RUN set -eux \
    && echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && locale-gen

RUN set -eux \
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
      libpcre3-dev \
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
    && cd \
    # postgis
    && cd /usr/src \
    && mkdir postgis \
    && cd postgis \
    && git init \
    && git remote add origin ${PGIS1_POSTGIS_REPOSITORY} \
    && git fetch --depth 1 origin ${PGIS1_POSTGIS_CHECKOUT} \
    && git checkout FETCH_HEAD \
    # Skip SHA1 check if PGIS1_POSTGIS_CHECKOUT_SHA1 is empty or 'nocheck'
    # Otherwise, verify that the commit hash matches PGIS1_POSTGIS_CHECKOUT_SHA1
    && if [ -z "${PGIS1_POSTGIS_CHECKOUT_SHA1}" ] \
       || [ "${PGIS1_POSTGIS_CHECKOUT_SHA1}" = "nocheck" ]; then \
         echo "Skipping POSTGIS SHA1 check"; \
       else \
         if [ "$(git rev-parse HEAD)" != "${PGIS1_POSTGIS_CHECKOUT_SHA1}" ]; then \
           echo "POSTGIS SHA1 problem! Stop!"; \
           exit 1; \
         fi; \
       fi \
    && git log -1 > /_pgis_last_commit.txt \
    && ldconfig \
    && ./autogen.sh \
# configure options taken from:
# https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
    && ./configure \
        --enable-lto \
    && make -j$(nproc) \
    && make install \
# refresh proj data - workarounds: https://trac.osgeo.org/postgis/ticket/5316
    && if command -v projsync >/dev/null 2>&1; then \
           projsync --system-directory --file ch_swisstopo_CHENyx06_ETRS \
        && projsync --system-directory --file us_noaa_eshpgn \
        && projsync --system-directory --file us_noaa_prvi \
        && projsync --system-directory --file us_noaa_wmhpgn ; \
    fi \
# regress check
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb -c -l /tmp/logfile -o '-F' start ' \
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
    && rm -rf /tmp/logfile \
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
      docbook-xml \
      docbook5-xml \
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

# last final test
RUN set -eux \
    && ldconfig \
    && cs2cs \
    && ldd $(which gdalinfo) \
    && gdalinfo --version \
    && gdal-config --formats \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    # check any missing dependencies
    && ldd /usr/lib/postgresql/$PG_MAJOR/lib/*.so | grep 'not found' && exit 1 || true \
    \
    # Is the "ca-certificates" package installed? (for accessing remote raster files)
    #   https://github.com/postgis/docker-postgis/issues/307
    && dpkg-query -W -f='${Status}' ca-certificates 2>/dev/null | grep -c "ok installed" \
    \
    # list last commits.
    && find /_pgis*_commit.txt -type f -print -exec cat {} \;  \
    # list postgresql, postgis version
    && cat _pgis_full_version.txt
