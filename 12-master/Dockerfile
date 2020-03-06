FROM postgres:12

LABEL maintainer="PostGIS Project - https://postgis.net"

ENV SFCGAL_VERSION master
ENV SFCGAL_GIT_HASH b11af653fd84f5a4a959e4369019dd3962f904c3
ENV PROJ_VERSION master
ENV PROJ_GIT_HASH b8db2500285e3d4feaa5778ec7fa888bd6c6a479
ENV GDAL_VERSION master
ENV GDAL_GIT_HASH 0bfd1bcb38b3fe321fd15f3c485cfb91537faf0e
ENV GEOS_VERSION master
ENV GEOS_GIT_HASH e37d04f8384b2e1fee83d64c6221adc3749a404a
ENV POSTGIS_VERSION master
ENV POSTGIS_GIT_HASH 87922037fd09b68ad2ada409f776e06590924256

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
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
      libgmp10 \
      libgmpxx4ldbl \
      libjson-c3 \
      libmpfr6 \
      libprotobuf-c1 \
      libtiff5 \
      libxml2 \
      sqlite3 \
      curl \
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
    # sfcgal
    && mkdir -p /usr/src/sfcgal \
    && cd /usr/src/sfcgal \
    && git init \
    && git remote add origin https://github.com/Oslandia/SFCGAL.git \
    && git fetch --depth 1 origin :${SFCGAL_GIT_HASH} \
    && git reset --hard FETCH_HEAD \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
    && rm /usr/local/lib/libSFCGAL.la \
    && cd / \
    && rm -fr /usr/src/sfcgal \
    # proj4
    && mkdir -p /usr/src/proj \
    && cd /usr/src/proj \
    && git init \
    && git remote add origin https://github.com/OSGeo/PROJ.git \
    && git fetch --depth 1 origin :${PROJ_GIT_HASH} \
    && git reset --hard FETCH_HEAD \
    && ./autogen.sh \
    && ./configure --disable-static \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/proj \
    # geos
    && mkdir -p /usr/src/geos \
    && cd /usr/src/geos \
    && git init \
    && git remote add origin https://github.com/libgeos/geos.git \
    && git fetch --depth 1 origin :${GEOS_GIT_HASH} \
    && git reset --hard FETCH_HEAD \
    && ./autogen.sh \
    && ./configure --disable-static \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/geos \
    # gdal
    && mkdir -p /usr/src/gdal \
    && cd /usr/src/gdal \
    && git init \
    && git remote add origin https://github.com/OSGeo/gdal.git \
    && git fetch --depth 1 origin :${GDAL_GIT_HASH} \
    && git reset --hard FETCH_HEAD \
    && cd gdal \
    && ./autogen.sh \
    && ./configure --disable-static \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/gdal \
    # postgis
    && mkdir -p /usr/src/postgis \
    && cd /usr/src/postgis \
    && git init \
    && git remote add origin https://git.osgeo.org/gitea/postgis/postgis.git \
    && git fetch --depth 1 origin :${POSTGIS_GIT_HASH} \
    && git reset --hard FETCH_HEAD \
    && ./autogen.sh \
# configure options taken from:
# https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
    && ./configure \
#       --with-gui \
    && make -j$(nproc) \
    && make install \
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
      make \
      pkg-config \
      postgresql-server-dev-$PG_MAJOR \
      protobuf-c-compiler \
      xsltproc \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin

