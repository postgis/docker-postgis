
# postgis v1 - internal api
# - multi-stage dockerfile;  minimal docker version >= 17.05
# - debian based; expected https://github.com/docker-library/postgres/ upstream
# - status: Experimental!

# API version expecting v1
ARG PGIS_API_VERSION

ARG PGIS_V1_BASE_IMAGE=postgres:12

ARG PGIS_V1_SFCGAL_REPOSITORY=https://gitlab.com/Oslandia/SFCGAL.git
ARG PGIS_V1_PROJ_REPOSITORY=https://github.com/OSGeo/PROJ.git
ARG PGIS_V1_GEOS_REPOSITORY=https://github.com/libgeos/geos.git
ARG PGIS_V1_GDAL_REPOSITORY=https://github.com/OSGeo/gdal.git
ARG PGIS_V1_POSTGIS_REPOSITORY=https://git.osgeo.org/gitea/postgis/postgis.git

ARG PGIS_V1_SFCGAL_CHECKOUT=e4fcf6b2e166a862db568a0419fe100849d3f447
ARG PGIS_V1_PROJ_CHECKOUT=0c9a7bb22c75229a296b8125bc486531fab8a223
ARG PGIS_V1_GEOS_CHECKOUT=1d971b32346a9e8845beb9b80b30074213f72a68
ARG PGIS_V1_GDAL_CHECKOUT=a7dd21943f93db1cefe6c4d0b425b43f42ebbccf
ARG PGIS_V1_POSTGIS_CHECKOUT=7de3ba7c17844c499f5763e6492b11b544e1cf1d

ARG PGIS_V1_BOOST_VERSION=1.67.0
ARG PGIS_V1_CDAL_VERSION=13

# ------------------------------------------------------
#   build step1
# ------------------------------------------------------
FROM postgres:12 as pgis-v1-builder-postgres-12

ARG PGIS_V1_BASE_IMAGE
ENV PGIS_V1_BASE_IMAGE ${PGIS_V1_BASE_IMAGE}

ARG PGIS_API_VERSION
ENV PGIS_API_VERSION=${PGIS_API_VERSION}

ARG PGIS_V1_BOOST_VERSION
ENV PGIS_V1_BOOST_VERSION=${PGIS_V1_BOOST_VERSION}
ARG PGIS_V1_CDAL_VERSION
ENV PGIS_V1_CDAL_VERSION=${PGIS_V1_CDAL_VERSION}

WORKDIR /

RUN set -eux \
    # Check the api version - should be "v1"
    && echo "PGIS_API_VERSION=${PGIS_API_VERSION}" \
    && if [ "${PGIS_API_VERSION}" = "v1" ]; then \
         echo "::: -> expected api version = v1 --> OK  :)" ; \
       else \
         echo "::: -> bad api version ; expecting v1 -> please update!" ; \
         exit 1 ; \
       fi \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libboost-atomic${PGIS_V1_BOOST_VERSION} \
      libboost-chrono${PGIS_V1_BOOST_VERSION} \
      libboost-date-time${PGIS_V1_BOOST_VERSION} \
      libboost-filesystem${PGIS_V1_BOOST_VERSION} \
      libboost-program-options${PGIS_V1_BOOST_VERSION} \
      libboost-serialization${PGIS_V1_BOOST_VERSION} \
      libboost-system${PGIS_V1_BOOST_VERSION} \
      libboost-test${PGIS_V1_BOOST_VERSION} \
      libboost-thread${PGIS_V1_BOOST_VERSION} \
      libboost-timer${PGIS_V1_BOOST_VERSION} \
      libcgal${PGIS_V1_CDAL_VERSION} \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c3 \
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
      libcgal-dev \
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
      protobuf-c-compiler \
      xsltproc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# sfcgal
ARG PGIS_V1_SFCGAL_REPOSITORY
ENV PGIS_V1_SFCGAL_REPOSITORY ${PGIS_V1_SFCGAL_REPOSITORY}
ARG PGIS_V1_SFCGAL_CHECKOUT
ENV PGIS_V1_SFCGAL_CHECKOUT ${PGIS_V1_SFCGAL_CHECKOUT}

RUN set -eux \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone ${PGIS_V1_SFCGAL_REPOSITORY} \
    && cd SFCGAL \
    && git checkout ${PGIS_V1_SFCGAL_CHECKOUT} \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/SFCGAL

# proj
ARG PGIS_V1_PROJ_REPOSITORY
ENV PGIS_V1_PROJ_REPOSITORY ${PGIS_V1_PROJ_REPOSITORY}
ARG PGIS_V1_PROJ_CHECKOUT
ENV PGIS_V1_PROJ_CHECKOUT ${PGIS_V1_PROJ_CHECKOUT}
RUN set -eux \
    && cd /usr/src \
    && git clone ${PGIS_V1_PROJ_REPOSITORY} \
    && cd PROJ \
    && git checkout ${PGIS_V1_PROJ_CHECKOUT} \
    && ./autogen.sh \
    && ./configure --disable-static \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/PROJ

# geos
ARG PGIS_V1_GEOS_REPOSITORY
ENV PGIS_V1_GEOS_REPOSITORY ${PGIS_V1_GEOS_REPOSITORY}
ARG PGIS_V1_GEOS_CHECKOUT
ENV PGIS_V1_GEOS_CHECKOUT ${PGIS_V1_GEOS_CHECKOUT}
RUN set -eux \
    && cd /usr/src \
    && git clone ${PGIS_V1_GEOS_REPOSITORY} \
    && cd geos \
    && git checkout ${PGIS_V1_GEOS_CHECKOUT} \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/geos

# gdal
ARG PGIS_V1_GDAL_REPOSITORY
ENV PGIS_V1_GDAL_REPOSITORY ${PGIS_V1_GDAL_REPOSITORY}
ARG PGIS_V1_GDAL_CHECKOUT
ENV PGIS_V1_GDAL_CHECKOUT ${PGIS_V1_GDAL_CHECKOUT}
RUN set -eux \
    && cd /usr/src \
    && git clone ${PGIS_V1_GDAL_REPOSITORY} \
    && cd gdal \
    && git checkout ${PGIS_V1_GDAL_CHECKOUT} \
    && cd gdal \
    && ./autogen.sh \
    && ./configure --disable-static \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/gdal

# Minimal command line test.
RUN set -eux \
    && ldconfig \
    && cs2cs \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    && pcre-config  --version

# ------------------------------------------------------
#   build step2
# ------------------------------------------------------
FROM ${PGIS_V1_BASE_IMAGE}
LABEL maintainer="PostGIS Project - https://postgis.net"

ARG PGIS_V1_BASE_IMAGE
ENV PGIS_V1_BASE_IMAGE ${PGIS_V1_BASE_IMAGE}

ARG PGIS_V1_BOOST_VERSION
ENV PGIS_V1_BOOST_VERSION=${PGIS_V1_BOOST_VERSION}
ARG PGIS_V1_CDAL_VERSION
ENV PGIS_V1_CDAL_VERSION=${PGIS_V1_CDAL_VERSION}

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libboost-atomic${PGIS_V1_BOOST_VERSION} \
      libboost-chrono${PGIS_V1_BOOST_VERSION} \
      libboost-date-time${PGIS_V1_BOOST_VERSION} \
      libboost-filesystem${PGIS_V1_BOOST_VERSION} \
      libboost-program-options${PGIS_V1_BOOST_VERSION} \
      libboost-serialization${PGIS_V1_BOOST_VERSION} \
      libboost-system${PGIS_V1_BOOST_VERSION} \
      libboost-test${PGIS_V1_BOOST_VERSION} \
      libboost-thread${PGIS_V1_BOOST_VERSION} \
      libboost-timer${PGIS_V1_BOOST_VERSION} \
      libcgal${PGIS_V1_CDAL_VERSION} \
      libcurl3-gnutls \
      libexpat1 \
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c3 \
      libmpfr6 \
      libpcre3 \
      libprotobuf-c1 \
      libtiff5 \
      libxml2 \
      sqlite3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=pgis-v1-builder-postgres-12 /usr/local /usr/local

ARG PGIS_V1_SFCGAL_REPOSITORY
ENV PGIS_V1_SFCGAL_REPOSITORY ${PGIS_V1_SFCGAL_REPOSITORY}
ARG PGIS_V1_SFCGAL_CHECKOUT
ENV PGIS_V1_SFCGAL_CHECKOUT ${PGIS_V1_SFCGAL_CHECKOUT}

ARG PGIS_V1_PROJ_REPOSITORY
ENV PGIS_V1_PROJ_REPOSITORY ${PGIS_V1_PROJ_REPOSITORY}
ARG PGIS_V1_PROJ_CHECKOUT
ENV PGIS_V1_PROJ_CHECKOUT ${PGIS_V1_PROJ_CHECKOUT}

ARG PGIS_V1_GEOS_REPOSITORY
ENV PGIS_V1_GEOS_REPOSITORY ${PGIS_V1_GEOS_REPOSITORY}
ARG PGIS_V1_GEOS_CHECKOUT
ENV PGIS_V1_GEOS_CHECKOUT ${PGIS_V1_GEOS_CHECKOUT}

ARG PGIS_V1_GDAL_REPOSITORY
ENV PGIS_V1_GDAL_REPOSITORY ${PGIS_V1_GDAL_REPOSITORY}
ARG PGIS_V1_GDAL_CHECKOUT
ENV PGIS_V1_GDAL_CHECKOUT ${PGIS_V1_GDAL_CHECKOUT}

# Minimal command line test.
RUN set -eux \
    && ldconfig \
    \
    && cs2cs \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version

# install postgis
ARG PGIS_V1_POSTGIS_REPOSITORY
ENV PGIS_V1_POSTGIS_REPOSITORY ${PGIS_V1_POSTGIS_REPOSITORY}
ARG PGIS_V1_POSTGIS_CHECKOUT
ENV PGIS_V1_POSTGIS_CHECKOUT ${PGIS_V1_POSTGIS_CHECKOUT}

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
      gettext \
      git \
      libboost-all-dev \
      libcgal-dev \
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
      postgresql-server-dev-${PG_MAJOR} \
      protobuf-c-compiler \
      xsltproc \
    && cd \
    # postgis
    && cd /usr/src/ \
    && git clone ${PGIS_V1_POSTGIS_REPOSITORY} \
    && cd postgis \
    && git checkout ${PGIS_V1_POSTGIS_CHECKOUT} \
    && gettextize \
    && ./autogen.sh \
# configure options taken from:
# https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
    && ./configure \
#       --with-gui \
        --with-pcredir="$(pcre-config --prefix)" \
    && make -j$(nproc) \
    && make install \
# regress check
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb start' \
    && ldconfig \
    && cd regress \
    && make -j$(nproc) check RUNTESTFLAGS=--extension PGUSER=postgres \
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
      ca-certificates \
      cmake \
      g++ \
      gettext \
      git \
      libboost-all-dev \
      libcgal-dev \
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
      postgresql-server-dev-${PG_MAJOR} \
      protobuf-c-compiler \
      xsltproc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

