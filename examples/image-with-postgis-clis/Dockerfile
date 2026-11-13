FROM docker.io/postgis/postgis:18-3.7

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgis \
    && rm -rf /var/lib/apt/lists/*

USER postgres
