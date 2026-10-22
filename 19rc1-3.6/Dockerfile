#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "make update"! PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker.io/postgres:19rc1-trixie AS postgis-build

ARG NPROC=
ARG POSTGIS_VERSION=3.6.4
ARG POSTGIS_SOURCE_VERSION=3.6.4
ARG POSTGIS_SHA256=4f80e1a4d227f088ae818f79180debd5894c075615823e0f556f73479cf1f200
ARG POSTGIS_MINOR=6
ARG ADDRESS_STANDARDIZER_GIT_HASH=fa11ff53eb49b863d9ffff37f6afd5ff9299c581
ARG TIGER_GEOCODER_VERSION=2025.2
ARG TIGER_GEOCODER_SHA256=c33cfbfb40785db8754a36be66060e8d023773e7e1be8fb8a622bb3c48db9f54

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bison \
        build-essential \
        ca-certificates \
        curl \
        git \
        libgdal-dev \
        libgeos-dev \
        libgmp-dev \
        libjson-c-dev \
        libpcre2-dev \
        libproj-dev \
        libprotobuf-c-dev \
        libpq-dev \
        libsqlite3-dev \
        libsfcgal-dev \
        libtiff-dev \
        libtool \
        libxml2-dev \
        pkg-config \
        "postgresql-server-dev-$PG_MAJOR=$PG_VERSION" \
        protobuf-c-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux \
    && mkdir -p /usr/src/postgis \
    && cd /usr/src/postgis \
    && curl --fail --silent --show-error --location --retry 5 --retry-delay 2 --retry-connrefused \
        "https://github.com/postgis/postgis/archive/${POSTGIS_SOURCE_VERSION}.tar.gz" -o postgis.tar.gz \
    && echo "${POSTGIS_SHA256} *postgis.tar.gz" | sha256sum -c - \
    && tar -xzf postgis.tar.gz --strip-components=1 \
    && rm postgis.tar.gz \
    && ./autogen.sh \
    && ./configure \
        --with-gdalconfig=/usr/bin/gdal-config \
        --with-geosconfig=/usr/bin/geos-config \
        --with-projdir=/usr \
        --with-sfcgal=/usr/bin/sfcgal-config \
    && make -j${NPROC:-$(nproc)} \
    && make install \
    && if [ "$POSTGIS_MINOR" -ge 7 ]; then \
        cd /usr/src \
        && git -c http.maxRetries=5 -c http.retryDelay=2 clone --quiet https://github.com/postgis/address_standardizer.git \
        && cd address_standardizer \
        && git checkout "$ADDRESS_STANDARDIZER_GIT_HASH" \
        && make PG_CONFIG="$(command -v pg_config)" PG_CFLAGS=-Wno-error with_llvm=no \
        && make PG_CONFIG="$(command -v pg_config)" PG_CFLAGS=-Wno-error with_llvm=no install; \
    fi \
    && if [ "$POSTGIS_MINOR" -ge 7 ] && [ "$PG_MAJOR" -ge 16 ]; then \
        cd /usr/src \
        && curl --fail --silent --show-error --location --retry 5 --retry-delay 2 --retry-connrefused \
            "https://download.osgeo.org/postgis/source/postgis_tiger_geocoder/postgis_tiger_geocoder-${TIGER_GEOCODER_VERSION}.tar.gz" -o postgis_tiger_geocoder.tar.gz \
        && echo "${TIGER_GEOCODER_SHA256} *postgis_tiger_geocoder.tar.gz" | sha256sum -c - \
        && mkdir -p postgis_tiger_geocoder \
        && tar -xzf postgis_tiger_geocoder.tar.gz --strip-components=1 -C postgis_tiger_geocoder \
        && cd postgis_tiger_geocoder \
        && make PG_CONFIG="$(command -v pg_config)" \
        && make PG_CONFIG="$(command -v pg_config)" install; \
    fi \
    && artifact_root=/postgis-artifacts \
    && pg_lib_dir="$(pg_config --pkglibdir)" \
    && pg_ext_dir="$(pg_config --sharedir)/extension" \
    && mkdir -p "$artifact_root$pg_lib_dir" "$artifact_root$pg_ext_dir" "$artifact_root/usr/bin" \
    && for file in "$pg_lib_dir"/postgis* "$pg_lib_dir"/rtpostgis* "$pg_lib_dir"/liblwgeom* "$pg_lib_dir"/address_standardizer*; do \
        if [ -e "$file" ]; then cp -a "$file" "$artifact_root$pg_lib_dir/"; fi; \
    done \
    && for file in "$pg_ext_dir"/postgis* "$pg_ext_dir"/address_standardizer*; do \
        if [ -e "$file" ]; then cp -a "$file" "$artifact_root$pg_ext_dir/"; fi; \
    done \
    && for file in /usr/bin/pgsql2shp /usr/bin/raster2pgsql /usr/bin/shp2pgsql; do \
        if [ -e "$file" ]; then cp -a "$file" "$artifact_root/usr/bin/"; fi; \
    done

FROM docker.io/postgres:19rc1-trixie

ARG POSTGIS_VERSION=3.6.4
ARG POSTGIS_MINOR=6
ARG H3_VERSION=
ARG PGROUTING_VERSION=4.0.1-1.pgdg13+1

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS ${POSTGIS_VERSION} spatial database extension with PostgreSQL 19rc1 trixie" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_VERSION=3.6.4
ENV H3_VERSION=${H3_VERSION}
ENV PGROUTING_VERSION=${PGROUTING_VERSION}

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gdal-bin \
        geos-bin \
        libgmp10 \
        libjson-c5 \
        libpcre2-8-0 \
        libprotobuf-c1 \
        libsqlite3-0 \
        libtiff6 \
        libxml2 \
        proj-bin \
        libsfcgal2 \
    && if [ -n "$H3_VERSION" ]; then \
        apt-get install -y --no-install-recommends "postgresql-$PG_MAJOR-h3=$H3_VERSION"; \
    fi \
    && if [ -n "$PGROUTING_VERSION" ]; then \
        apt-get install -y --no-install-recommends "postgresql-$PG_MAJOR-pgrouting=$PGROUTING_VERSION"; \
    fi \
    && if [ "$POSTGIS_MINOR" -ge 7 ] && [ "$PG_MAJOR" -lt 16 ]; then \
        rm -f "/usr/share/postgresql/$PG_MAJOR/extension/postgis_tiger_geocoder"* \
            "/usr/lib/postgresql/$PG_MAJOR/lib/postgis_tiger_geocoder"*; \
    fi \
    && rm -rf /var/lib/apt/lists/*

COPY --from=postgis-build /postgis-artifacts/ /

RUN set -eux \
    && ldconfig \
    && test -f "$(pg_config --sharedir)/extension/postgis.control" \
    && test -f "$(pg_config --pkglibdir)/postgis-3.so" \
    && mkdir -p /docker-entrypoint-initdb.d

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

USER postgres
