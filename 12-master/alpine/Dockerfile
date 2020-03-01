FROM postgres:12-alpine

LABEL maintainer="PostGIS Project - https://postgis.net"

ENV POSTGIS_VERSION master
ENV POSTGIS_GIT_HASH fc5f9e4307eb9a4f8bccac1d10d63d2d8f4ab9bd

RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        git \
    \
    && mkdir -p /usr/src/postgis \
    && cd /usr/src/postgis \
    && git init \
    && git remote add origin https://git.osgeo.org/gitea/postgis/postgis.git \
    && git fetch --depth 1 origin :${POSTGIS_GIT_HASH} \
    && git reset --hard FETCH_HEAD \
    \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        file \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        perl \
        clang-dev \
        g++ \
        gcc \
        gdal-dev \
        geos-dev \
        llvm9-dev \
        proj-dev \
        protobuf-c-dev \
    && ./autogen.sh \
# configure options taken from:
# https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
    && ./configure \
#       --with-gui \
    && make \
    && make install \
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
        geos \
        gdal \
        proj \
        libstdc++ \
        protobuf-c \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin
