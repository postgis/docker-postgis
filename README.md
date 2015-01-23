postgis
=======

Docker image for running PostGIS 2.1 on Postgres 9 (9.0-9.4).

Based on the [official Postgres image](http://registry.hub.docker.com/_/postgres/).

Includes a `template_postgis` database with `postgis.sql`, `topology.sql`, and
`spatial_ref_sys.sql` loaded. Use this database as the template for your
database to gain access to PostGIS functionality in your database.

