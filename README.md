# postgis

[![Build Status](https://travis-ci.org/appropriate/docker-postgis.svg)](https://travis-ci.org/appropriate/docker-postgis) [![Join the chat at https://gitter.im/appropriate/docker-postgis](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/appropriate/docker-postgis?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The `postgis` image provides a Docker container running Postgres 9 with
[PostGIS 2.1](http://postgis.net/docs/manual-2.1/) installed. This image is
based on the official [`postgres`](https://registry.hub.docker.com/_/postgres/)
image and provides variants for each version of Postgres 9 supported by the
base image (9.0-9.4).

On the version 9.1+ images, the PostGIS extension can be installed into your
database in [the standard way](http://postgis.net/docs/postgis_installation.html#create_new_db_extensions) via `psql`:

```SQL
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
```

If you are using 9.0 or would otherwise prefer to use the older template database
mechanism for installing PostGIS, the image also provides a `template_postgis` template
database with `postgis.sql`, `topology.sql`, and `spatial_ref_sys.sql` loaded.

## Usage

In order to run a basic container capable of serving a PostGIS-enabled database,
start a container as follows:

    docker run --name some-postgis -e POSTGRES_PASSWORD=mysecretpassword -d mdillon/postgis

For more detailed instructions about how to start and control your Postgres
container, see the documentation for the `postgres` image
[here](https://registry.hub.docker.com/_/postgres/).

Once you have started a database container, you can then connect to the
database as follows:

    docker run -it --link some-postgis:postgres --rm postgres \
        sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'

Using the resulting `psql` shell, you can create a PostGIS-enabled database by
using the `CREATE EXTENSION` mechanism (or by using `template_postgis` for Postgres 9.0):

```SQL
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
```

See [the PostGIS documentation](http://postgis.net/docs/postgis_installation.html#create_new_db_extensions)
for more details on your options for creating and using a spatially-enabled database.
