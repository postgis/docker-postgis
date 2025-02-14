# 🚧🔧💡🧹 WIP: Experimental development:

* 🧪🐳 test images (amd64 + arm64) for the users: https://hub.docker.com/r/imresamu/postgis
  * 🧪 internal amd64 only repo: https://hub.docker.com/r/imresamu/postgis-amd64/tags
  * 🧪 internal arm64 only repo: https://hub.docker.com/r/imresamu/postgis-arm64/tags
* 🧪 code: https://github.com/ImreSamu/docker-postgis
* Status: Experimental, under active development

------------------------
# 🐳🐘🌍 postgis/postgis
[![Build Status](https://github.com/imresamu/docker-postgis/workflows/Build%20PostGIS%20images/badge.svg)](https://github.com/imresamu/docker-postgis/actions) [![Join the chat at https://gitter.im/postgis/docker-postgis](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/postgis/docker-postgis?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**Important:** _Please note that this README document is larger than the 25,000 character limit set by Docker Hub. As a result, the version available on Docker Hub will be trimmed and not complete._
_For the complete and untrimmed version of the README, it is recommended to visit the project GitHub page:_ https://github.com/ImreSamu/docker-postgis/blob/master/README.md

The `imresamu/postgis` image provides tags for running Postgres with [PostGIS](http://postgis.net/) extensions installed. This image is based on the official [`postgres`](https://registry.hub.docker.com/_/postgres/) image and provides debian and alpine variants for PostGIS which is compatible with PostgreSQL versions 12, 13, 14, 15, 16 and 17.  Additionally, an image version is provided which is built from the latest two versions of Postgres (16,17) with versions of PostGIS and its dependencies built from their respective master branches.

This image ensures that the default database created by the parent `postgres` image will have the following extensions installed:

| installed extensions | [initialized](https://github.com/imresamu/docker-postgis/blob/master/initdb-postgis.sh)|
|---------------------|-----|
| `postgis`           | yes |
| `postgis_topology`  | yes |
| `postgis_tiger_geocoder` | yes |
| `postgis_raster` | |
| `postgis_sfcgal` | |
| `address_standardizer`| |
| `address_standardizer_data_us`| |

Unless `-e POSTGRES_DB` is passed to the container at startup time, this database will be named after the admin user (either `postgres` or the user specified with `-e POSTGRES_USER`). If you would prefer to use the older template database mechanism for enabling PostGIS, the image also provides a PostGIS-enabled template database called `template_postgis`.


## Versions (2025-02-14)


We provide multi-platform image support for the following architectures:

- `amd64`: Also known as x86-64.
  -  Use `--platform=linux/amd64` when specifying the platform.
- `arm64`: Also known as AArch64.  
  - Use `--platform=linux/arm64` when specifying the platform.

Notes:

- The `arm64` architecture support is still experimental. Please refer to the 'arch' column in the version information to determine whether an `arm64` version is available for a specific release.
- We currently do not support 32-bit architectures. Our images are only available for 64-bit architectures.

## Build Status

| Arch | Build system | Status|
| ---- | :-:          | :-:   |
| Amd64| [GithubCI-logs](https://github.com/ImreSamu/docker-postgis/actions/workflows/main.yml)     | [![Build PostGIS images](https://github.com/ImreSamu/docker-postgis/actions/workflows/main.yml/badge.svg)](https://github.com/ImreSamu/docker-postgis/actions/workflows/main.yml) |
| Arm64 | [CircleCI-logs](https://app.circleci.com/pipelines/github/ImreSamu/docker-postgis) | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/ImreSamu/docker-postgis/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/ImreSamu/docker-postgis/tree/master) |

### 🌟Recommended Versions for New Users

For those new to PostGIS, we recommend the following image versions:

- `imresamu/postgis:17-3.5-bookworm`: This image includes a minimal setup of PostgreSQL with the PostGIS extension. ( debian bookworm based, easy to extend with debian packages )
- `imresamu/postgis:17-recent-bookworm`: (experimental) Latest postgis with the latest geos,proj,gdal,sfcgal. ( debian based, extending is complex ! )
- `imresamu/postgis:16-3.4-bundle0-bookworm`: (experimental) This image includes additional geospatial-related extras along with PostgreSQL and PostGIS.

### 🥇Debian - bookworm  (recommended)

- This Docker-PostGIS version has a cautious release cycle to guarantee high stability.
  - By "cautious", we mean it does not always have the latest versions of geos, proj, gdal, and sfcgal packages.
- We use PostGIS, geos, proj, gdal, and sfcgal packages from the Debian repository.
  - In the Debian Bullseye repository, the versions are: geos=3.11, gdal=3.6, proj=9.1, and sfcgal=1.4.
- This version is easy to extend and has matured over time.

<!-- bookworm_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`12-3.5-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5-bookworm), [`12-3.5.2-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5.2-bookworm), [`12-3.5`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/12-3.5/bookworm/Dockerfile) | amd64 arm64 | bookworm | 12 | 3.5.2 |
| [`13-3.5-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5-bookworm), [`13-3.5.2-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5.2-bookworm), [`13-3.5`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/13-3.5/bookworm/Dockerfile) | amd64 arm64 | bookworm | 13 | 3.5.2 |
| [`14-3.5-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5-bookworm), [`14-3.5.2-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5.2-bookworm), [`14-3.5`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-3.5/bookworm/Dockerfile) | amd64 arm64 | bookworm | 14 | 3.5.2 |
| [`15-3.5-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5-bookworm), [`15-3.5.2-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5.2-bookworm), [`15-3.5`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/15-3.5/bookworm/Dockerfile) | amd64 arm64 | bookworm | 15 | 3.5.2 |
| [`16-3.5-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5-bookworm), [`16-3.5.2-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5.2-bookworm), [`16-3.5`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.5/bookworm/Dockerfile) | amd64 arm64 | bookworm | 16 | 3.5.2 |
| [`17-3.5-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5-bookworm), [`17-3.5.2-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5.2-bookworm), [`17-3.5`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5), [`latest`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=latest) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/17-3.5/bookworm/Dockerfile) | amd64 arm64 | bookworm | 17 | 3.5.2 |
<!-- bookworm_end  -->

### 📘Debian - bullseye

- We use PostGIS, geos, proj, gdal, and sfcgal packages from the Debian repository.
  - In the Debian Bullseye repository, the versions are: geos=3.9, gdal=3.2, proj=7.2, and sfcgal=1.3.9.
- This version is easy to extend and has matured over time.

<!-- bullseye_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`12-3.5-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5-bullseye), [`12-3.5.2-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5.2-bullseye) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/12-3.5/bullseye/Dockerfile) | amd64 arm64 | bullseye | 12 | 3.5.2 |
| [`13-3.5-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5-bullseye), [`13-3.5.2-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5.2-bullseye) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/13-3.5/bullseye/Dockerfile) | amd64 arm64 | bullseye | 13 | 3.5.2 |
| [`14-3.5-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5-bullseye), [`14-3.5.2-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5.2-bullseye) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-3.5/bullseye/Dockerfile) | amd64 arm64 | bullseye | 14 | 3.5.2 |
| [`15-3.5-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5-bullseye), [`15-3.5.2-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5.2-bullseye) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/15-3.5/bullseye/Dockerfile) | amd64 arm64 | bullseye | 15 | 3.5.2 |
| [`16-3.5-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5-bullseye), [`16-3.5.2-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5.2-bullseye) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.5/bullseye/Dockerfile) | amd64 arm64 | bullseye | 16 | 3.5.2 |
| [`17-3.5-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5-bullseye), [`17-3.5.2-bullseye`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5.2-bullseye) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/17-3.5/bullseye/Dockerfile) | amd64 arm64 | bullseye | 17 | 3.5.2 |
<!-- bullseye_end  -->


### 🧪Recent ( experimental )

* These images are similar to the debian-based `*-master` images ( same Dockerfile template ) However, for every build, we use the latest released tag from each library (such as postgis, geos, proj, gdal, cgal, sfcgal).
* These images are ideal for testing purposes, but expanding them is not straightforward.
* The specific versions of the libraries used (like postgis, geos, proj, gdal, cgal, sfcgal) can be found in the tags of the image or in the Dockerfile.

<!-- recent_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`16-recent-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-recent-bookworm), [`16-recent-postgis3.5.2-geos3.13.0-proj9.5.1-gdal3.10.2-cgal6.0.1-sfcgal2.0.0-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-recent-postgis3.5.2-geos3.13.0-proj9.5.1-gdal3.10.2-cgal6.0.1-sfcgal2.0.0-bookworm), [`16-recent-postgis3.5-geos3.13-proj9.5-gdal3.10-cgal6.0-sfcgal2.0-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-recent-postgis3.5-geos3.13-proj9.5-gdal3.10-cgal6.0-sfcgal2.0-bookworm), [`16-recent`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-recent) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-recent/bookworm/Dockerfile) | amd64 arm64 | bookworm | 16 | postgis=tags/3.5.2, geos=tags/3.13.0, proj=tags/9.5.1, gdal=tags/v3.10.2, cgal=tags/v6.0.1, sfcgal=tags/v2.0.0 |
| [`17-recent-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-recent-bookworm), [`17-recent-postgis3.5.2-geos3.13.0-proj9.5.1-gdal3.10.2-cgal6.0.1-sfcgal2.0.0-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-recent-postgis3.5.2-geos3.13.0-proj9.5.1-gdal3.10.2-cgal6.0.1-sfcgal2.0.0-bookworm), [`17-recent-postgis3.5-geos3.13-proj9.5-gdal3.10-cgal6.0-sfcgal2.0-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-recent-postgis3.5-geos3.13-proj9.5-gdal3.10-cgal6.0-sfcgal2.0-bookworm), [`17-recent`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-recent), [`recent`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=recent) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/17-recent/bookworm/Dockerfile) | amd64 arm64 | bookworm | 17 | postgis=tags/3.5.2, geos=tags/3.13.0, proj=tags/9.5.1, gdal=tags/v3.10.2, cgal=tags/v6.0.1, sfcgal=tags/v2.0.0 |
<!-- recent_end  -->

### 🧪Debian Geo Bundle ( experimental )

This repository provides Debian-based PostGIS Docker images enriched with additional geospatial packages such as [pgRouting](https://pgrouting.org/), [h3-pg]( https://github.com/zachasme/h3-pg), [pgsql-ogr-fdw](https://github.com/pramsey/pgsql-ogr-fdw), [MobilityDB](https://mobilitydb.com/), [PL/Python3](https://www.postgresql.org/docs/current/plpython.html), [pgPointcloud](https://pgpointcloud.github.io/pointcloud/), [pgVector](https://github.com/pgvector/pgvector), [TimeScaleDB](https://www.timescale.com/) and others.
These images serve as a comprehensive solution for various server side geospatial needs.
Please note that the included package list is subject to change as we continue to refine the 'bundle0'.


<!-- bundle0_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`16-3.5-bundle0-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5-bundle0-bookworm), [`16-3.5.2-bundle0-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5.2-bundle0-bookworm), [`16-3.5-bundle0`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5-bundle0) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.5-bundle0/bookworm/Dockerfile) | amd64 arm64 | bookworm | 16 | 3.5.2 |
<!-- bundle0_end  -->


### ⛰️Alpine 3.21 based

- The base operating system is [Alpine Linux](https://alpinelinux.org/). It is designed to be small, simple, and secure, and it's based on [musl libc](https://musl.libc.org/).
- In the Alpine 3.21 version, the package versions are: geos=3.13, gdal=3.10, proj=9.5, and sfcgal=2.0
- PostGIS is compiled from source, making it a bit more challenging to extend.

<!-- alpine3.21_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`12-3.3-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.3-alpine3.21), [`12-3.3.8-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.3.8-alpine3.21), [`12-3.3-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.3-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/12-3.3/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 12 | 3.3.8 |
| [`12-3.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.4-alpine3.21), [`12-3.4.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.4.4-alpine3.21), [`12-3.4-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.4-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/12-3.4/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 12 | 3.4.4 |
| [`12-3.5-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5-alpine3.21), [`12-3.5.2-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5.2-alpine3.21), [`12-3.5-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/12-3.5/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 12 | 3.5.2 |
| [`13-3.3-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.3-alpine3.21), [`13-3.3.8-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.3.8-alpine3.21), [`13-3.3-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.3-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/13-3.3/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 13 | 3.3.8 |
| [`13-3.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.4-alpine3.21), [`13-3.4.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.4.4-alpine3.21), [`13-3.4-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.4-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/13-3.4/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 13 | 3.4.4 |
| [`13-3.5-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5-alpine3.21), [`13-3.5.2-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5.2-alpine3.21), [`13-3.5-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/13-3.5/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 13 | 3.5.2 |
| [`14-3.3-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.3-alpine3.21), [`14-3.3.8-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.3.8-alpine3.21), [`14-3.3-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.3-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-3.3/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 14 | 3.3.8 |
| [`14-3.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.4-alpine3.21), [`14-3.4.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.4.4-alpine3.21), [`14-3.4-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.4-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-3.4/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 14 | 3.4.4 |
| [`14-3.5-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5-alpine3.21), [`14-3.5.2-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5.2-alpine3.21), [`14-3.5-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-3.5/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 14 | 3.5.2 |
| [`15-3.3-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.3-alpine3.21), [`15-3.3.8-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.3.8-alpine3.21), [`15-3.3-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.3-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/15-3.3/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 15 | 3.3.8 |
| [`15-3.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.4-alpine3.21), [`15-3.4.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.4.4-alpine3.21), [`15-3.4-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.4-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/15-3.4/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 15 | 3.4.4 |
| [`15-3.5-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5-alpine3.21), [`15-3.5.2-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5.2-alpine3.21), [`15-3.5-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/15-3.5/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 15 | 3.5.2 |
| [`16-3.3-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.3-alpine3.21), [`16-3.3.8-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.3.8-alpine3.21), [`16-3.3-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.3-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.3/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 16 | 3.3.8 |
| [`16-3.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.4-alpine3.21), [`16-3.4.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.4.4-alpine3.21), [`16-3.4-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.4-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.4/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 16 | 3.4.4 |
| [`16-3.5-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5-alpine3.21), [`16-3.5.2-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5.2-alpine3.21), [`16-3.5-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.5/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 16 | 3.5.2 |
| [`17-3.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.4-alpine3.21), [`17-3.4.4-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.4.4-alpine3.21), [`17-3.4-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.4-alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/17-3.4/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 17 | 3.4.4 |
| [`17-3.5-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5-alpine3.21), [`17-3.5.2-alpine3.21`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5.2-alpine3.21), [`17-3.5-alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5-alpine), [`alpine`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=alpine) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/17-3.5/alpine3.21/Dockerfile) | amd64 arm64 | alpine3.21 | 17 | 3.5.2 |
<!-- alpine3.21_end  -->

### ⛰️Alpine 3.20 based

- The base operating system is [Alpine Linux](https://alpinelinux.org/). It is designed to be small, simple, and secure, and it's based on [musl libc](https://musl.libc.org/).
- In the Alpine 3.20 version, the package versions are: geos=3.12.1, gdal=3.9.0, proj=9.4.0, and sfcgal=1.5.1
- PostGIS is compiled from source, making it a bit more challenging to extend.

<!-- alpine3.20_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`12-3.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.4-alpine3.20), [`12-3.4.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.4.4-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/12-3.4/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 12 | 3.4.4 |
| [`12-3.5-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5-alpine3.20), [`12-3.5.2-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=12-3.5.2-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/12-3.5/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 12 | 3.5.2 |
| [`13-3.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.4-alpine3.20), [`13-3.4.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.4.4-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/13-3.4/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 13 | 3.4.4 |
| [`13-3.5-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5-alpine3.20), [`13-3.5.2-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=13-3.5.2-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/13-3.5/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 13 | 3.5.2 |
| [`14-3.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.4-alpine3.20), [`14-3.4.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.4.4-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-3.4/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 14 | 3.4.4 |
| [`14-3.5-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5-alpine3.20), [`14-3.5.2-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-3.5.2-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-3.5/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 14 | 3.5.2 |
| [`15-3.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.4-alpine3.20), [`15-3.4.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.4.4-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/15-3.4/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 15 | 3.4.4 |
| [`15-3.5-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5-alpine3.20), [`15-3.5.2-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=15-3.5.2-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/15-3.5/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 15 | 3.5.2 |
| [`16-3.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.4-alpine3.20), [`16-3.4.4-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.4.4-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.4/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 16 | 3.4.4 |
| [`16-3.5-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5-alpine3.20), [`16-3.5.2-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-3.5.2-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-3.5/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 16 | 3.5.2 |
| [`17-3.5-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5-alpine3.20), [`17-3.5.2-alpine3.20`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-3.5.2-alpine3.20) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/17-3.5/alpine3.20/Dockerfile) | amd64 arm64 | alpine3.20 | 17 | 3.5.2 |
<!-- alpine3.20_end  -->


### 🧪Locked ( experimental )

* Locked old postgis versions for testing.
* Definition in the [./locked.yml](locked.yml) 
   * and the image identifiers : <pg_version>-l<any_unique_postgis_id>
<!-- locked_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`14-l3.1.9gcp-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-l3.1.9gcp-bookworm), [`14-l3.1.9gcp-postgis3.1.9-geos3.6.6-proj6.3.1-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=14-l3.1.9gcp-postgis3.1.9-geos3.6.6-proj6.3.1-bookworm) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/14-l3.1.9gcp/bookworm/Dockerfile) | amd64 arm64 | bookworm | 14 | postgis=tags/3.1.9, geos=tags/3.6.6, proj=tags/6.3.1, gdal=tags/v3.6.4, cgal=tags/v5.6, sfcgal=tags/v1.5.1 |
<!-- locked_end  -->

### 📋Test images

- We provide alpha, beta, release candidate (rc), and development (identified as ~master) versions.
- The template for the `*-master` images is updated manually, which might lead to a delay of a few weeks sometimes.
- The ~master SFCGAL version is 1.5 or higher. The cgal version is locked on the [5.6.x-branch](https://github.com/CGAL/cgal/tree/5.6.x-branch).

<!-- test_begin  -->
| `docker.io/imresamu/postgis:` tags | Dockerfile | Arch | OS | Postgres | PostGIS |
| ---- | :-: | :-: | :-: | :-: | :-: |
| [`16-master-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-master-bookworm), [`16-master`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=16-master) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/16-master/bookworm/Dockerfile) | amd64 arm64 | bookworm | 16 | development: postgis, geos, proj, gdal, cgal, sfcgal |
| [`17-master-bookworm`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-master-bookworm), [`17-master`](https://registry.hub.docker.com/r/imresamu/postgis/tags?page=1&name=17-master) | [Dockerfile](https://github.com/imresamu/docker-postgis/blob/master/17-master/bookworm/Dockerfile) | amd64 arm64 | bookworm | 17 | development: postgis, geos, proj, gdal, cgal, sfcgal |
<!-- test_end  -->

## 🚀Usage

In order to run a basic container capable of serving a PostGIS-enabled database, start a container as follows:

    docker run --name some-postgis -e POSTGRES_PASSWORD=mysecretpassword -d imresamu/postgis

For more detailed instructions about how to start and control your Postgres container, see the documentation for the `postgres` image [here](https://registry.hub.docker.com/_/postgres/).

Once you have started a database container, you can then connect to the database either directly on the running container:

    docker exec -ti some-postgis psql -U postgres

... or starting a new container to run as a client. In this case you can use a user-defined network to link both containers:

    docker network create some-network

    # Server container
    docker run --name some-postgis --network some-network -e POSTGRES_PASSWORD=mysecretpassword -d imresamu/postgis

    # Client container
    docker run -it --rm --network some-network imresamu/postgis psql -h some-postgis -U postgres

Check the documentation on the [`postgres` image](https://registry.hub.docker.com/_/postgres/) and [Docker networking](https://docs.docker.com/network/) for more details and alternatives on connecting different containers.

See [the PostGIS documentation](http://postgis.net/docs/postgis_installation.html#create_new_db_extensions) for more details on your options for creating and using a spatially-enabled database.

## 🔧Supported Environment Variables:

Since the docker-postgis repository is an extension of the official Docker PostgreSQL repository, all environment variables supported there are also supported here:

- `POSTGRES_PASSWORD`
- `POSTGRES_USER`
- `POSTGRES_DB`
- `POSTGRES_INITDB_ARGS`
- `POSTGRES_INITDB_WALDIR`
- `POSTGRES_HOST_AUTH_METHOD`
- `PGDATA`

Read more:  https://github.com/docker-library/docs/blob/master/postgres/README.md

Warning: **the Docker specific variables will only have an effect if you start the container with a data directory that is empty;** any pre-existing database will be left untouched on container startup.

It's important to note that the environment variables for the Docker image are different from those of the [libpq — C Library](https://www.postgresql.org/docs/current/libpq-envars.html)  (`PGDATABASE`,`PGUSER`,`PGPASSWORD` )


## ⚠️ Troubleshooting tips:

Troubleshooting can often be challenging. It's important to know that the docker-postgis repository is an extension of the official Docker PostgreSQL repository. Therefore, if you encounter any issues, it's worth testing whether the problem can be reproduced with the [official PostgreSQL Docker images](https://hub.docker.com/_/postgres). If so, it's recommended to search for solutions based on this. The following websites are suggested:

- Upstream docker postgres repo: https://github.com/docker-library/postgres
  - search for the open or closed issues !
- Docker Community Forums: https://forums.docker.com
- Docker Community Slack: https://dockr.ly/slack
- Stack Overflow: https://stackoverflow.com/questions/tagged/docker+postgresql

If your problem is Postgis related:

- Stack Overflow : docker + postgis https://stackoverflow.com/questions/tagged/docker+postgis
- Postgis issue tracker: https://trac.osgeo.org/postgis/report

And if you don't have a postgres docker experience - read this blog post:

- https://www.docker.com/blog/how-to-use-the-postgres-docker-official-image/


## 🔒Security

It's crucial to be aware that in a cloud environment, with default settings, these images are vulnerable, and there's a high risk of cryptominer infection if the ports are left open. ( [Read More](https://github.com/docker-library/postgres/issues/770#issuecomment-704460980) )

- Note that ports which are not bound to the host (i.e., `-p 5432:5432` instead of `-p 127.0.0.1:5432:5432`) will be accessible from the outside. This also applies if you configured UFW to block this specific port, as Docker manages its own iptables rules. ( [Read More](https://docs.docker.com/network/iptables/) )

#### Recomendations:

- You can add options for using SSL ( [see postgres example](https://github.com/docker-library/postgres/issues/989#issuecomment-1222648067) )
  - `-c ssl=on -c ssl_cert_file=/var/lib/postgresql/server.crt -c ssl_key_file=/var/lib/postgresql/server.key`
- Or you can use [SSH Tunnels](https://www.postgresql.org/docs/15/ssh-tunnels.html) with `-p 127.0.0.1:5432:5432`

#### Security scanner information:

- Scan the base `postgres` docker Image:
It's important to also scan the base `postgres` Docker image for potential security issues. If your security scanner reports vulnerabilities (known as CVEs) in the image, you may wonder why. To get a better understanding, please read the Docker Library FAQ, especially the section titled ["Why does my security scanner show that an image has CVEs?"](https://github.com/docker-library/faq#why-does-my-security-scanner-show-that-an-image-has-cves)
For more specific issues related to the postgres docker image, you can search using these links:
  - [search for repo:docker-library/postgres trivy](https://github.com/search?q=repo%3Adocker-library%2Fpostgres+trivy&type=issues)
  - [search for repo:docker-library/postgres CVE](https://github.com/search?q=repo%3Adocker-library%2Fpostgres+CVE&type=issues)

- Optimizing Security Scans:
It's advisable to focus on scanning and fixing issues that can be resolved.
Use this command to scan for fixable issues only:
  * `trivy image --ignore-unfixed postgis/postgis:16-3.4-alpine`
  * `trivy image --ignore-unfixed postgres:16-alpine`
For more details, you can read this article: https://pythonspeed.com/articles/docker-security-scanner/

#### Limitations on Updates:
Unfortunately, we don't have control over updates to Debian and Alpine distributions or the upstream `postgres` image.
Because of this, there might be some issues that we cannot fix right away.
On the positive side, the `postgis/postgis` images are regenerated every Monday. This process is to ensure they include the latest changes and improvements. As a result, these images are consistently kept up-to-date.

#### Suggestions Welcome:
We are always open to suggestions to enhance security. If you have any ideas, please let us know.

## ❗Known Issues / Errors

When You encouter errors due to PostGIS update `OperationalError: could not access file "$libdir/postgis-X.X`, run:

`docker exec some-postgis update-postgis.sh`

It will update to Your newest PostGIS. Update is idempotent, so it won't hurt when You run it more than once, You will get notification like:

```
Updating PostGIS extensions template_postgis to X.X.X
NOTICE:  version "X.X.X" of extension "postgis" is already installed
NOTICE:  version "X.X.X" of extension "postgis_topology" is already installed
NOTICE:  version "X.X.X" of extension "postgis_tiger_geocoder" is already installed
ALTER EXTENSION
Updating PostGIS extensions docker to X.X.X
NOTICE:  version "X.X.X" of extension "postgis" is already installed
NOTICE:  version "X.X.X" of extension "postgis_topology" is already installed
NOTICE:  version "X.X.X" of extension "postgis_tiger_geocoder" is already installed
ALTER EXTENSION
```
