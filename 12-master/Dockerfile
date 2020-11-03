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
      libpq5 \
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
      libpq-dev \
      libprotobuf-c-dev \
      libsqlite3-dev \
      libtiff-dev \
      libtool \
      libxml2-dev \
      make \
      pkg-config \
      protobuf-c-compiler \
      xsltproc

# sfcgal
ENV SFCGAL_VERSION master
#ENV SFCGAL_GIT_HASH ea18c06a0f5e6b433e36cad0593c3fe730e5b055
ENV SFCGAL_GIT_HASH 823db7a318b8841f8296e80036ef993ddf19ebf5
#ENV SFCGAL_GIT_HASH ea18c06a0f5e6b433e36cad0593c3fe730e5b055

RUN set -ex \
    && mkdir -p /usr/src/sfcgal \
    && cd /usr/src/sfcgal \
    && git init \
    && git remote add origin https://gitlab.com/Oslandia/SFCGAL.git \
    && git fetch --depth 1 origin :${SFCGAL_GIT_HASH} \
    && git reset --hard FETCH_HEAD \
    && mkdir cmake-build \
    && cd cmake-build \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/sfcgal

# proj4
ENV PROJ_VERSION master
#ENV PROJ_GIT_HASH c64c209f4abeec7ae4e8cdde8d6c5ba9921354fa
ENV PROJ_GIT_HASH 9751f31ca9aa42d075421b038f93fe1b1640ffd3
#ENV PROJ_GIT_HASH 64d46a6b2939272a0590d3e149ffec5b9ec0336f

RUN set -ex \
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
    && rm -fr /usr/src/proj

# geos
ENV GEOS_VERSION master
#ENV GEOS_GIT_HASH 1b6521ef1c8ecd8098e8d27233030b689a33992f
ENV GEOS_GIT_HASH 7657bc03d6a587ef02caa689068b130d56ba45e1
#ENV GEOS_GIT_HASH 708d32b2cd2dd3bedc38ff1d839368656b1f9626

RUN set -ex \
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
    && rm -fr /usr/src/geos

# gdal
ENV GDAL_VERSION master
#ENV GDAL_GIT_HASH 32a665eb3a82eec7d0da4caf8d7265fd5c968289
ENV GDAL_GIT_HASH 20d44a181f73b87ebb7c1660498bb9e78e572e54
#ENV GDAL_GIT_HASH 107eac104832e24a4961cdb00c472c1b6273195c

RUN set -ex \
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
    && rm -fr /usr/src/gdal

# run ldconfig
RUN set -ex \
    && ldconfig

# Minimal command line test.
RUN set -ex \
    && cs2cs \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version

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
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local
COPY --from=builder /usr/local .
WORKDIR /

RUN set -ex \
    && ldconfig

# Minimal command line test.
RUN set -ex \
    && cs2cs \
    && gdalinfo --version \
    && geos-config --version \
    && ogr2ogr --version \
    && proj \
    && sfcgal-config --version

# install postgis
ENV POSTGIS_VERSION master
#ENV POSTGIS_GIT_HASH 873d3e5a099dff60614be54c65657eebab184e80
ENV POSTGIS_GIT_HASH 13f821e5906e1a2663eb43b410bb6bd1deba88b6
#ENV POSTGIS_GIT_HASH 3175d66209ac30dcdb6a01d253f3540f934cdff5

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
      libpq-dev \
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
      libpq-dev \
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

