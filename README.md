# postgis

The `postgis` image provides a Docker container running Postgres 9 with
[PostGIS 2.1](http://postgis.net/docs/manual-2.1/) installed. This image is
based on the official [`postgres`](https://registry.hub.docker.com/_/postgres/)
image and provides variants for each version of Postgres 9 supported by the
base image (9.0-9.4).

The image provides a `template_postgis` template database with the `postgis`
and `postgis_topology` extensions enabled and with `postgis.sql`,
`topology.sql`, and `spatial_ref_sys.sql` loaded. Use this database as the
template for your database to gain access to PostGIS functionality in your
database (see the "[Usage](#Usage)" section below).

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
using `template_postgis` as your template:

```SQL
CREATE DATABASE some_database TEMPLATE template_postgis;
```

### Derived Image

It is possible to create a PostGIS-enabled database in a derived image using
the `/docker-entrypoint-initdb.d` mechanism described in the `postgres` image
documentation. To do so, you need to name your script so that it sorts after
`postgis.sh` to ensure that the `template_postgis` database is available. The
easiest way to do this is to prefix the name of your script with `xxx_postgis_`.

Here is an example Dockerfile for that initializes a new PostGIS database named
`my_gis_app` when the container is first started:

```Dockerfile
FROM mdillon/postgis:9.4
RUN echo "echo 'CREATE DATABASE my_gis_app TEMPLATE template_postgis' \
               | gosu postgres postgres --single -E" \
         > /docker-entrypoint-initdb.d/xxx_postgis_my_gis_app.sh
```
