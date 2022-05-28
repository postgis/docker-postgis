FROM postgres:10-alpine3.16

LABEL maintainer="PostGIS Project - https://postgis.net"

ENV POSTGIS_VERSION 3.2.1
ENV POSTGIS_SHA256 1e9cc4c4f390e4c3be4f5c125a72f39dfa847412332952429952cbd731ac9ba3

RUN set -eux \
    \
    &&  if   [ $(printf %.1s "$POSTGIS_VERSION") == 3 ]; then \
            set -eux ; \
            #
            # using only v3.16
            #
            #GEOS: https://pkgs.alpinelinux.org/packages?name=geos&branch=v3.16 \
            export GEOS_ALPINE_VER=3.10 ; \
            #GDAL: https://pkgs.alpinelinux.org/packages?name=gdal&branch=v3.16 \
            export GDAL_ALPINE_VER=3.5 ; \
            #PROJ: https://pkgs.alpinelinux.org/packages?name=proj&branch=v3.16 \
            export PROJ_ALPINE_VER=9.0 ; \
            #
        elif [ $(printf %.1s "$POSTGIS_VERSION") == 2 ]; then \
            set -eux ; \
            #
            # using older branches v3.13; v3.14 for GEOS,GDAL,PROJ
            #
            #GEOS: https://pkgs.alpinelinux.org/packages?name=geos&branch=v3.13 \
            export GEOS_ALPINE_VER=3.8 ; \
            #GDAL: https://pkgs.alpinelinux.org/packages?name=gdal&branch=v3.14 \
            export GDAL_ALPINE_VER=3.2 ; \
            #PROJ: https://pkgs.alpinelinux.org/packages?name=proj&branch=v3.14 \
            export PROJ_ALPINE_VER=7.2 ; \
            #
            \
            echo 'https://dl-cdn.alpinelinux.org/alpine/v3.14/main'      >> /etc/apk/repositories ; \
            echo 'https://dl-cdn.alpinelinux.org/alpine/v3.14/community' >> /etc/apk/repositories ; \
            echo 'https://dl-cdn.alpinelinux.org/alpine/v3.13/main'      >> /etc/apk/repositories ; \
            echo 'https://dl-cdn.alpinelinux.org/alpine/v3.13/community' >> /etc/apk/repositories ; \
            \
        else \
            set -eux ; \
            echo ".... unknown \$POSTGIS_VERSION ...." ; \
            exit 1 ; \
        fi \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/${POSTGIS_VERSION}.tar.gz" \
    && echo "${POSTGIS_SHA256} *postgis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz \
    \
    && apk add --no-cache --virtual .build-deps \
        \
        gdal-dev~=${GDAL_ALPINE_VER} \
        geos-dev~=${GEOS_ALPINE_VER} \
        proj-dev~=${PROJ_ALPINE_VER} \
        \
        autoconf \
        automake \
        clang-dev \
        file \
        g++ \
        gcc \
        gettext-dev \
        json-c-dev \
        libtool \
        libxml2-dev \
        llvm-dev \
        make \
        pcre-dev \
        perl \
        protobuf-c-dev \
    \
# build PostGIS
    \
    && cd /usr/src/postgis \
    && gettextize \
    && ./autogen.sh \
    && ./configure \
        --with-pcredir="$(pcre-config --prefix)" \
    && make -j$(nproc) \
    && make install \
    \
# regress check
    && mkdir /tempdb \
    && chown -R postgres:postgres /tempdb \
    && su postgres -c 'pg_ctl -D /tempdb init' \
    && su postgres -c 'pg_ctl -D /tempdb start' \
    && cd regress \
    && make -j$(nproc) check RUNTESTFLAGS=--extension   PGUSER=postgres \
    #&& make -j$(nproc) check RUNTESTFLAGS=--dumprestore PGUSER=postgres \
    #&& make garden                                      PGUSER=postgres \
    \
    && su postgres -c 'psql    -c "CREATE EXTENSION IF NOT EXISTS postgis;"' \
    && su postgres -c 'psql -t -c "SELECT version();"'              >> /_pgis_full_version.txt \
    && su postgres -c 'psql -t -c "SELECT PostGIS_Full_Version();"' >> /_pgis_full_version.txt \
    \
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
    && rm -rf /tmp/pgis_reg \
# add .postgis-rundeps
    && apk add --no-cache --virtual .postgis-rundeps \
        \
        gdal~=${GDAL_ALPINE_VER} \
        geos~=${GEOS_ALPINE_VER} \
        proj~=${PROJ_ALPINE_VER} \
        \
        json-c \
        libstdc++ \
        pcre \
        protobuf-c \
# clean
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps \
# print PostGIS_Full_Version() for the log. ( experimental & internal )
    && cat /_pgis_full_version.txt

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
