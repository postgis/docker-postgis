FROM docker.io/postgis/postgis:18-3.6

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgis \
    && rm -rf /var/lib/apt/lists/*

USER postgres
