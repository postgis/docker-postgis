FROM postgres:12
LABEL maintainer="Mike Dillon <mike@appropriate.io>"

ENV SFCGAL_VERSION master
ENV SFCGAL_GIT_HASH b11af653fd84f5a4a959e4369019dd3962f904c3
ENV PROJ_VERSION master
ENV PROJ_GIT_HASH 0bcf2b5aaacdabce159ed96b2421d2810038e7b6
ENV GDAL_VERSION master
ENV GDAL_GIT_HASH d528bab40586f4b6ed7e03f3ada2ab6861edfaca
ENV GEOS_VERSION master
ENV GEOS_GIT_HASH 7ad488a7334552dae774d1130559c46a921efc02
ENV POSTGIS_VERSION master
ENV POSTGIS_GIT_HASH fc5f9e4307eb9a4f8bccac1d10d63d2d8f4ab9bd

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
      autoconf2.13 \
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
      postgresql-server-dev-12 \
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
    && make \
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
    && make \
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
    && make \
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
    && make \
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
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apt-get purge -y --autoremove \
      autoconf2.13 \
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
      postgresql-server-dev-12 \
      protobuf-c-compiler \
      xsltproc \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin

