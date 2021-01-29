# "experimental" ;  only for testing!
# multi-stage dockerfile;  minimal docker version >= 17.05
FROM postgres:12 as builder

LABEL maintainer="PostGIS Project - https://postgis.net"

WORKDIR /

# apt-get install
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libboost-atomic1.67.0 \
      libboost-chrono1.67.0 \
      libboost-date-time1.67.0 \
      libboost-filesystem1.67.0 \
      libboost-program-options1.67.0 \
      libboost-serialization1.67.0 \
      libboost-system1.67.0 \
      libboost-test1.67.0 \
      libboost-thread1.67.0 \
      libboost-timer1.67.0 \
      libcgal13 \
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
      git \
      g++ \
      libboost-all-dev \
      libcgal-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
      make \
      pkg-config \
      protobuf-c-compiler \
      xsltproc \
      libpcre3-dev

# sfcgal
ENV SFCGAL_VERSION master
ENV SFCGAL_GIT_HASH e1e67b58abf0e51dcce3bbb0ebd2429cca36c945

RUN set -ex \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone https://gitlab.com/Oslandia/SFCGAL.git \
    && cd SFCGAL \
    && git checkout ${SFCGAL_GIT_HASH} \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/SFCGAL

# proj
###ENV PROJ_VERSION master
###ENV PROJ_GIT_HASH db2950e56ea26a0949b71378d73559a16fc40f26

### Issue with proj v8 not being compatible
### see https://github.com/postgis/docker-postgis/pull/220#issuecomment-765864268
### Below is a temp fix
ENV PROJ_VERSION 7.2.1
ENV PROJ_GIT_HASH 1212e9b818e4511cc9389b9bdb5daa0bec1a12bd

RUN set -ex \
    && cd /usr/src \
    && git clone https://github.com/OSGeo/PROJ.git \
    && cd PROJ \
    && git checkout ${PROJ_GIT_HASH} \
    && ./autogen.sh \
    && ./configure --disable-static \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/PROJ

# geos
ENV GEOS_VERSION master
ENV GEOS_GIT_HASH b2e7efc30a979954bf7dfa8fb252473afcd509b8

RUN set -ex \
    && cd /usr/src \
    && git clone https://github.com/libgeos/geos.git \
    && cd geos \
    && git checkout ${GEOS_GIT_HASH} \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/geos

# gdal
ENV GDAL_VERSION master
ENV GDAL_GIT_HASH 93395860dd62e3850ed31b4c77c51a93fe2919c8

RUN set -ex \
    && cd /usr/src \
    && git clone https://github.com/OSGeo/gdal.git \
    && cd gdal \
    && git checkout ${GDAL_GIT_HASH} \
    && cd gdal \
    && ./autogen.sh \
    && ./configure --disable-static \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/gdal

# Minimal command line test.
RUN set -ex \
    && ldconfig \
    && cs2cs \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    && pcre-config  --version

FROM postgres:12

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      libboost-atomic1.67.0 \
      libboost-chrono1.67.0 \
      libboost-date-time1.67.0 \
      libboost-filesystem1.67.0 \
      libboost-program-options1.67.0 \
      libboost-serialization1.67.0 \
      libboost-system1.67.0 \
      libboost-test1.67.0 \
      libboost-thread1.67.0 \
      libboost-timer1.67.0 \
      libcgal13 \
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
      libpcre3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local /usr/local

# Minimal command line test.
RUN set -ex \
    && ldconfig \
    && cs2cs \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version \
    && pcre-config  --version

# install postgis
ENV POSTGIS_VERSION master
ENV POSTGIS_GIT_HASH dbd1425e11283d7c7b840e293073d336c6362b59

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
      git \
      g++ \
      libboost-all-dev \
      libcgal-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
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
    && git clone https://git.osgeo.org/gitea/postgis/postgis.git \
    && cd postgis \
    && git checkout ${POSTGIS_GIT_HASH} \
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
      git \
      g++ \
      libboost-all-dev \
      libcgal-dev \
      libcurl4-gnutls-dev \
      libgmp-dev \
      libjson-c-dev \
      libmpfr-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
      libpcre3-dev \
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

