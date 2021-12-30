FROM postgres:10-alpine3.15

LABEL maintainer="PostGIS Project - https://postgis.net"

ENV POSTGIS_VERSION 3.2.0
ENV POSTGIS_SHA256 c725d1be6d57ad199bbb6393cc3546defb70de1c78fe1787f7ccef2d51c3647b

#   for PostGIS 2.5 - building an older GEOS/PROJ/GDAL
ENV POSTGIS2_GEOS_VERSION tags/3.8.2
ENV POSTGIS2_PROJ_VERSION tags/7.2.1
ENV POSTGIS2_GDAL_VERSION tags/v3.2.3

RUN set -euxo pipefail; \
    \
    apk add --no-cache --virtual .fetch-deps \
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
        cunit-dev \
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
# GEOS/PROJ/GDAL setup
     && if   [ $(printf %.1s "$POSTGIS_VERSION") == 3 ]; then \
            apk add --no-cache --virtual .build-deps-geos-proj-gdal geos-dev proj-dev gdal-dev ; \
        elif [ $(printf %.1s "$POSTGIS_VERSION") == 2 ]; then \
            \
            apk add --no-cache --virtual   .run-deps-geos-proj-gdal \
                curl \
                expat \
                libpng \
                openjpeg \
                sqlite \
                sqlite-libs \
                tiff \
            ; \
            apk add --no-cache --virtual .build-deps-geos-proj-gdal \
                 curl-dev \
                 expat-dev \
                 libpng-dev \
                 openjpeg-dev \
                 sqlite-dev \
                 tiff-dev \
                 \
                 cmake \
                 git \
                 linux-headers \
            ; \
            # =========== PROJ ===============
            cd /usr/src ; \
            git clone https://github.com/OSGeo/PROJ.git ; \
            cd PROJ ; \
            git checkout ${POSTGIS2_PROJ_VERSION} -b proj_build ; \
            ./autogen.sh ; \
            ./configure --disable-static ; \
            make -j$(nproc) ; \
            make install ; \
            rm -fr /usr/src/PROJ ; \
            \
            # =========== GEOS ===============
            cd /usr/src ; \
            git clone https://github.com/libgeos/geos.git ; \
            cd geos ; \
            git checkout ${POSTGIS2_GEOS_VERSION} -b geos_build ; \
            mkdir cmake-build ; \
            cd cmake-build ; \
                cmake -DCMAKE_BUILD_TYPE=Release .. ; \
                make -j$(nproc) ; \
                make check ; \
                make install ; \
            rm -fr /usr/src/geos ; \
            \
            # =========== GDAL ===============
            cd /usr/src ; \
            git clone https://github.com/OSGeo/gdal.git ; \
            cd gdal ; \
            git checkout ${POSTGIS2_GDAL_VERSION} -b gdal_build ; \
            if [ -d "gdal" ] ; then \
                echo "Directory 'gdal' dir exists -> older version!" ; \
                cd gdal ; \
            else \
                echo "Directory 'gdal' does not exists! Newer version! " ; \
            fi ; \
            # https://github.com/OSGeo/gdal/issues/4341#issuecomment-906294159  \
            # workaround for: required file 'config.rpath' not found ; \
            touch config.rpath ; \
            \
            ./autogen.sh ; \
            ./configure --disable-static ; \
            make -j$(nproc) ; \
            make install ; \
            rm -fr /usr/src/gdal ; \
        else \
            echo ".... unknown PosGIS ...." ; \
        fi \
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
    && su postgres -c 'pg_ctl -D /tempdb --mode=immediate stop' \
    && rm -rf /tempdb \
    && rm -rf /tmp/pgis_reg \
# add .postgis-rundeps
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
        libstdc++ \
        pcre \
        protobuf-c \
# geos/proj/gdal setup
     && if [ $(printf %.1s "$POSTGIS_VERSION") == 3 ]; then \
            apk add --no-cache --virtual .postgis-rundeps-geos-proj-gdal geos proj gdal ; \
        fi \
# clean
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps .build-deps-geos-proj-gdal \
# post check - if missing any libs
    && if [ $(printf %.1s "$POSTGIS_VERSION") == 2 ]; then \
           cs2cs \
        && gdalinfo --version \
        && geos-config --version \
        && ogr2ogr --version \
        && proj ; \
    fi

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
