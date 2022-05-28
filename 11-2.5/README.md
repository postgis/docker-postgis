# postgis/postgis

[![Build Status](https://github.com/postgis/docker-postgis/workflows/Docker%20PostGIS%20CI/badge.svg)](https://github.com/postgis/docker-postgis/actions) [![Join the chat at https://gitter.im/postgis/docker-postgis](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/postgis/docker-postgis?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The `postgis/postgis` image provides tags for running Postgres with [PostGIS](http://postgis.net/) extensions installed. This image is based on the official [`postgres`](https://registry.hub.docker.com/_/postgres/) image and provides debian and alpine variants for PostGIS both 2.5.x and 3.2.x for each supported version of Postgres (9.6, 10, 11, 12, 13 and 14).  Additionally, an image version is provided which is built from the latest version of Postgres (13) with versions of PostGIS and its dependencies built from their respective master branches.

This image ensures that the default database created by the parent `postgres` image will have the following extensions installed:

* `postgis`
* `postgis_topology`
* `postgis_tiger_geocoder`

Note: As of PostGIS v3.x, raster has been factored out into a separate extension `postgis_raster` which must be installed separately.

Unless `-e POSTGRES_DB` is passed to the container at startup time, this database will be named after the admin user (either `postgres` or the user specified with `-e POSTGRES_USER`). If you would prefer to use the older template database mechanism for enabling PostGIS, the image also provides a PostGIS-enabled template database called `template_postgis`.

# Current versions ( 2022-05-28 )

Recomended version for the new users: `postgis/postgis:14-3.2`

### Debian based ( recomended ):

 * It's conservative in its release cycle to ensure high stability.
   * *"conservative"* ~= not the latest geos, proj, gdal packages.
 * Postgis, geos, proj, gdal packages from debian repository
   * debian:bullseye : geos=3.9; gdal=3.2; proj=7.2
   * debian:stretch  : geos=3.7; gdal=2.1; proj=4.9
* Easy to extend, matured

| DockerHub image | Dockerfile | OS | Postgres | PostGIS |
| --------------- | ---------- | -- | -------- | ------- |
| [postgis/postgis:10-2.5](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=10-2.5) | [Dockerfile](./10-2.5/Dockerfile) | debian:stretch | 10 | 2.5.5 |
| [postgis/postgis:10-3.2](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=10-3.2) | [Dockerfile](./10-3.2/Dockerfile) | debian:bullseye | 10 | 3.2.1 |
| [postgis/postgis:11-2.5](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=11-2.5) | [Dockerfile](./11-2.5/Dockerfile) | debian:stretch | 11 | 2.5.5 |
| [postgis/postgis:11-3.2](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=11-3.2) | [Dockerfile](./11-3.2/Dockerfile) | debian:bullseye | 11 | 3.2.1 |
| [postgis/postgis:12-3.2](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=12-3.2) | [Dockerfile](./12-3.2/Dockerfile) | debian:bullseye | 12 | 3.2.1 |
| [postgis/postgis:13-3.2](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=13-3.2) | [Dockerfile](./13-3.2/Dockerfile) | debian:bullseye | 13 | 3.2.1 |
| [postgis/postgis:14-3.2](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=14-3.2) | [Dockerfile](./14-3.2/Dockerfile) | debian:bullseye | 14 | 3.2.1 |

### Alpine based

* base os = [Alpine linux](https://alpinelinux.org/): designed to be small, simple and secure ; [musl libc](https://musl.libc.org/) based
* alpine:3.1.6 and Postgis 2.5:
   * geos=3.8; gdal=3.2; proj=7.2
* alpine:3.1.6 and Postgis 3.2:
   * geos=3.10; gdal=3.5; proj=9.0
* Postgis has been compiled from source ; harder to extend
* no SFCGAL support yet; (`postgis_sfcgal` is not working )

| DockerHub image | Dockerfile | OS | Postgres | PostGIS |
| --------------- | ---------- | -- | -------- | ------- |
| [postgis/postgis:10-2.5-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=10-2.5-alpine) | [Dockerfile](./10-2.5/alpine/Dockerfile) | alpine:3.16 | 10 | 2.5.5 |
| [postgis/postgis:10-3.2-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=10-3.2-alpine) | [Dockerfile](./10-3.2/alpine/Dockerfile) | alpine:3.16 | 10 | 3.2.1 |
| [postgis/postgis:11-2.5-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=11-2.5-alpine) | [Dockerfile](./11-2.5/alpine/Dockerfile) | alpine:3.16 | 11 | 2.5.5 |
| [postgis/postgis:11-3.2-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=11-3.2-alpine) | [Dockerfile](./11-3.2/alpine/Dockerfile) | alpine:3.16 | 11 | 3.2.1 |
| [postgis/postgis:12-3.2-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=12-3.2-alpine) | [Dockerfile](./12-3.2/alpine/Dockerfile) | alpine:3.16 | 12 | 3.2.1 |
| [postgis/postgis:13-3.2-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=13-3.2-alpine) | [Dockerfile](./13-3.2/alpine/Dockerfile) | alpine:3.16 | 13 | 3.2.1 |
| [postgis/postgis:14-3.2-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=14-3.2-alpine) | [Dockerfile](./14-3.2/alpine/Dockerfile) | alpine:3.16 | 14 | 3.2.1 |

### Test images

* alpha, beta and not released versions
* the `*-master` images template manually updating, so sometimes you can expact a few weeks delay.

| DockerHub image | Dockerfile | OS | Postgres | PostGIS |
| --------------- | ---------- | -- | -------- | ------- |
| [postgis/postgis:13-master](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=13-master) | [Dockerfile](./13-master/Dockerfile) | debian:bullseye | 13 | development: postgis, geos, proj, gdal |
| [postgis/postgis:14-3.3.0alpha1-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=14-3.3.0alpha1-alpine) | [Dockerfile](./14-3.3.0alpha1/alpine/Dockerfile) | alpine:3.16 | 14 | 3.3.0alpha1 |
| [postgis/postgis:14-master](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=14-master) | [Dockerfile](./14-master/Dockerfile) | debian:bullseye | 14 | development: postgis, geos, proj, gdal |
| [postgis/postgis:15beta1-3.2.1-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=15beta1-3.2.1-alpine) | [Dockerfile](./15beta1-3.2.1/alpine/Dockerfile) | alpine:3.16 | 15beta1 | 3.2.1 |
| [postgis/postgis:15beta1-3.3.0alpha1-alpine](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=15beta1-3.3.0alpha1-alpine) | [Dockerfile](./15beta1-3.3.0alpha1/alpine/Dockerfile) | alpine:3.16 | 15beta1 | 3.3.0alpha1 |
| [postgis/postgis:15beta1-master](https://registry.hub.docker.com/r/postgis/postgis/tags?page=1&name=15beta1-master) | [Dockerfile](./15beta1-master/Dockerfile) | debian:bullseye | 15beta1 | development: postgis, geos, proj, gdal |

## Usage

In order to run a basic container capable of serving a PostGIS-enabled database, start a container as follows:

    docker run --name some-postgis -e POSTGRES_PASSWORD=mysecretpassword -d postgis/postgis

For more detailed instructions about how to start and control your Postgres container, see the documentation for the `postgres` image [here](https://registry.hub.docker.com/_/postgres/).

Once you have started a database container, you can then connect to the database either directly on the running container:

    docker exec -ti some-postgis psql -U postgres

... or starting a new container to run as a client. In this case you can use a user-defined network to link both containers:

    docker network create some-network

    # Server container
    docker run --name some-postgis --network some-network -e POSTGRES_PASSWORD=mysecretpassword -d postgis/postgis

    # Client container
    docker run -it --rm --network some-network postgis/postgis psql -h some-postgis -U postgres

Check the documentation on the [`postgres` image](https://registry.hub.docker.com/_/postgres/) and [Docker networking](https://docs.docker.com/network/) for more details and alternatives on connecting different containers.

See [the PostGIS documentation](http://postgis.net/docs/postgis_installation.html#create_new_db_extensions) for more details on your options for creating and using a spatially-enabled database.

## Known Issues / Errors

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

