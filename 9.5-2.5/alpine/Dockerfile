FROM postgres:9.5-alpine

LABEL maintainer="PostGIS Project - https://postgis.net"

ENV POSTGIS_VERSION 2.5.5
ENV POSTGIS_SHA256 24b15ee36f3af02015da0e92a18f9046ea0b4fd24896196c8e6c2aa8e4b56baa

RUN set -eux \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/$POSTGIS_VERSION.tar.gz" \
    && echo "$POSTGIS_SHA256 *postgis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz \
    \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        clang-dev \
        file \
        g++ \
        gcc \
        gdal-dev \
        gettext-dev \
        json-c-dev \
        libtool \
        libxml2-dev \
        llvm11-dev \
        make \
        pcre-dev \
        perl \
        proj-dev \
        protobuf-c-dev \
     \
     # Geos setup
     && if   [ $(printf %.1s "$POSTGIS_VERSION") == 3 ]; then \
            apk add --no-cache --virtual .build-deps-geos geos-dev; \
        elif [ $(printf %.1s "$POSTGIS_VERSION") == 2 ]; then \
            apk add --no-cache --virtual .build-deps-geos cmake git ; \
            cd /usr/src ; \
            git clone https://github.com/libgeos/geos.git ; \
            cd geos ; \
            git checkout 24650422b3982f17cc493fe92a70228f2ad624b4 ; \
            mkdir cmake-build ; \
            cd cmake-build ; \
            cmake -DCMAKE_BUILD_TYPE=Release .. ; \
            make -j$(nproc) ; \
            make install ; \
            cd / ; \
            rm -fr /usr/src/geos ; \
        else \
            echo ".... unknown posgis ...." ; \
        fi \
    \
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
    && make -j$(nproc) check RUNTESTFLAGS=--extension PGUSER=postgres \
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
    && rm -rf /tmp/pgis_reg \
# add .postgis-rundeps
    && apk add --no-cache --virtual .postgis-rundeps \
        gdal \
        json-c \
        libstdc++ \
        pcre \
        proj \
        protobuf-c \
     # Geos setup
     && if [ $(printf %.1s "$POSTGIS_VERSION") == 3 ]; then \
            apk add --no-cache --virtual .postgis-rundeps-geos geos ; \
        fi \
# clean
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps .build-deps-geos

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
