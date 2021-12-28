# postgis/postgis

[![Build Status](https://github.com/postgis/docker-postgis/workflows/Docker%20PostGIS%20CI/badge.svg)](https://github.com/postgis/docker-postgis/actions) [![Join the chat at https://gitter.im/postgis/docker-postgis](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/postgis/docker-postgis?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The `postgis/postgis` image provides tags for running Postgres with [PostGIS](http://postgis.net/) extensions installed. This image is based on the official [`postgres`](https://registry.hub.docker.com/_/postgres/) image and provides debian and alpine variants for PostGIS both 2.5.x and 3.2.x for each supported version of Postgres (9.6, 10, 11, 12, 13 and 14).  Additionally, an image version is provided which is built from the latest version of Postgres (13) with versions of PostGIS and its dependencies built from their respective master branches.

This image ensures that the default database created by the parent `postgres` image will have the following extensions installed:

* `postgis`
* `postgis_topology`
* `postgis_tiger_geocoder`

Note: As of PostGIS v3.x, raster has been factored out into a separate extension `postgis_raster` which must be installed separately.

Unless `-e POSTGRES_DB` is passed to the container at startup time, this database will be named after the admin user (either `postgres` or the user specified with `-e POSTGRES_USER`). If you would prefer to use the older template database mechanism for enabling PostGIS, the image also provides a PostGIS-enabled template database called `template_postgis`.

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

