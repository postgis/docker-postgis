# Using PostGIS CLIs
The base postgis/postgis image does not have PostGIS-related CLIs installed. To use PostGIS CLIs that are NOT installed by default (for example `raster2pgsql`) it's necessary to extend the base image.

```sh
# Create a Docker image
docker build -t my-postgis .

# Run as a Docker container
docker run --name my-postgis -p 5432:5432 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=password -d my-postgis
```