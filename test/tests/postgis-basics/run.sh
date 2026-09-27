#!/bin/bash
# shellcheck disable=SC2119,SC2120
set -e

image="$1"

export POSTGRES_USER='my cool postgres user'
export POSTGRES_PASSWORD='my cool postgres password'
export POSTGRES_DB='my cool postgres database'

cname="postgis-container-$RANDOM-$RANDOM"
cid="$(docker run -d --read-only --cap-drop=ALL \
	--tmpfs /tmp:rw,nosuid,nodev \
	--tmpfs /var/run/postgresql:rw,nosuid,nodev \
	-e POSTGRES_USER -e POSTGRES_PASSWORD -e POSTGRES_DB --name "$cname" "$image")"
cleanup() {
    smoke_exit_code=$?
    if [ "$smoke_exit_code" -ne 0 ]; then docker logs "$cid" >&2 || true; fi
    docker rm -vf "$cid" >/dev/null 2>&1 || true
    exit "$smoke_exit_code"
}
trap cleanup EXIT

psql() {
	docker run --rm -i \
		--link "$cname":postgis \
		--entrypoint psql \
		-e PGPASSWORD="$POSTGRES_PASSWORD" \
		"$image" \
		--host postgis \
		--username "$POSTGRES_USER" \
		--dbname "$POSTGRES_DB" \
		--quiet --no-align --tuples-only --set ON_ERROR_STOP=1 \
		"$@"
}

tries=30
while ! echo 'SELECT 1' | psql &> /dev/null; do
	(( tries-- ))
	if [ $tries -le 0 ]; then
		echo >&2 'postgres failed to accept connections in a reasonable amount of time!'
		docker logs "$cname" >&2 || true
		echo 'SELECT 1' | psql # to hopefully get a useful error message
		false
	fi
	sleep 2
done

echo 'SELECT PostGIS_Version()' | psql
[ "$(echo 'SELECT ST_X(ST_Point(0,0))' | psql)" = 0 ]

for extension in postgis postgis_raster postgis_sfcgal postgis_topology fuzzystrmatch address_standardizer address_standardizer_data_us; do
	echo "CREATE EXTENSION IF NOT EXISTS $extension;" | psql >/dev/null
done

psql <<-'EOSQL'
	DO $$
	DECLARE
		unit_square geometry := ST_GeomFromText('POLYGON((0 0,0 1,1 1,0 0))', 4326);
	BEGIN
		IF NOT ST_IsValid(unit_square) THEN
			RAISE EXCEPTION 'ST_IsValid failed';
		END IF;
		IF NOT ST_Intersects(ST_SetSRID(ST_Point(0.5, 0.5), 4326), unit_square) THEN
			RAISE EXCEPTION 'ST_Intersects failed';
		END IF;
		IF abs(ST_Area(ST_Transform(unit_square, 3857)) - 6196329108.19) > 1000000 THEN
			RAISE EXCEPTION 'ST_Area or ST_Transform failed';
		END IF;
		IF abs(ST_Area(ST_Buffer(ST_SetSRID(ST_Point(0, 0), 3857), 1)) - pi()) > 0.05 THEN
			RAISE EXCEPTION 'ST_Buffer failed';
		END IF;
		IF abs(ST_Distance(ST_SetSRID(ST_Point(0, 0), 3857), ST_SetSRID(ST_Point(1, 0), 3857)) - 1) > 0.000001 THEN
			RAISE EXCEPTION 'ST_Distance failed';
		END IF;
		IF ST_SRID(ST_Transform(ST_SetSRID(ST_Point(2, 49), 4326), 3857)) <> 3857 THEN
			RAISE EXCEPTION 'ST_Transform failed';
		END IF;
	END
	$$;
EOSQL

response=$(echo $'SELECT zip FROM parse_address(\'1 Devonshire Place, Boston, MA 02109-1234\') AS a;' | psql)
[ "$response" = 02109 ]
[ "$(echo 'SELECT count(*) > 0 FROM us_gaz;' | psql)" = t ]
echo "address_standardizer extensions installed and work!"

[ "$(echo "SELECT levenshtein('kitten', 'sitting')" | psql)" = 3 ]
[ "$(echo 'SELECT ST_Width(ST_MakeEmptyRaster(2, 3, 0, 0, 1, -1, 0, 0, 0))' | psql)" = 2 ]
[ "$(echo 'SELECT postgis_sfcgal_version() IS NOT NULL' | psql)" = t ]
[ "$(echo "SELECT abs(CG_3DArea('POLYGON Z ((0 0 0, 0 1 0, 1 1 0, 1 0 0, 0 0 0))'::geometry) - 1) < 0.000001" | psql)" = t ]

topology_id=$(echo "SELECT topology.CreateTopology('smoke_topology', 4326)" | psql)
[ "$topology_id" -gt 0 ]
echo "SELECT topology.TopoGeo_AddPoint('smoke_topology', ST_SetSRID(ST_Point(0, 0), 4326), 0)" | psql >/dev/null
echo 'DROP SCHEMA smoke_topology CASCADE' | psql >/dev/null

tiger_available="$(echo "SELECT EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'postgis_tiger_geocoder')" | psql)"
if [ "$tiger_available" = t ]; then
	echo 'CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;' | psql >/dev/null
	response=$(echo "SET search_path = tiger, public; SELECT na.address, na.streetname, na.streettypeabbrev, na.zip FROM normalize_address('1 Devonshire Place, Boston, MA 02109-1234') AS na;" | psql)
	[ "$response" = '1|Devonshire|Pl|02109' ]
	echo "postgis_tiger_geocoder extension installed and works!"
else
	echo "postgis_tiger_geocoder is unavailable on this PostgreSQL/PostGIS combination; skipping Tiger smoke"
fi

# Require pgRouting when the image advertises a built version.
pgrouting_required=false
if [ "$(docker run --rm "$image" sh -c 'test -n "${PGROUTING_VERSION:-}" && printf true || printf false')" = true ]; then
	pgrouting_required=true
fi
pgrouting_available="$(echo "SELECT EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pgrouting')" | psql)"
if [ "$pgrouting_required" = true ]; then
	[ "$pgrouting_available" = t ]
elif [ "$pgrouting_available" != t ]; then
	echo "pgRouting is not available; skipping optional pgRouting smoke"
else
	echo "pgRouting is available in this optional image"
fi
if [ "$pgrouting_available" = t ]; then
	echo 'CREATE EXTENSION IF NOT EXISTS pgrouting;' | psql >/dev/null
	[ "$(echo 'SELECT pgr_version() IS NOT NULL' | psql)" = t ]
	psql <<-'EOSQL'
		CREATE TEMP TABLE smoke_edges (id bigint, source bigint, target bigint, cost double precision, reverse_cost double precision);
		INSERT INTO smoke_edges VALUES (1, 1, 2, 1, -1), (2, 2, 3, 1, -1);
		DO $$
		DECLARE
			route_nodes bigint;
			route_cost double precision;
		BEGIN
			SELECT count(*), max(agg_cost) INTO route_nodes, route_cost
			FROM pgr_dijkstra('SELECT id, source, target, cost, reverse_cost FROM smoke_edges', 1, 3, true);
			IF route_nodes <> 3 OR route_cost <> 2 THEN
				RAISE EXCEPTION 'pgr_dijkstra failed: nodes %, cost %', route_nodes, route_cost;
			END IF;
		END
		$$;
	EOSQL
	echo "pgRouting extension installed and works!"
fi

# Debian images require H3 when their generated Dockerfile pins an H3 package.
# Development images build H3 from source; Alpine remains optional.
h3_required=false
if [ "$(docker run --rm "$image" sh -c 'test -n "${H3_VERSION:-}" && printf true || printf false')" = true ]; then
	h3_required=true
fi
case "${image##*:}" in
	*-master) h3_required=true ;;
esac

test_h3="$(
	psql <<-'EOSQL'
	SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'h3')
		AND EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'h3_postgis')
		THEN 'available' ELSE 'skip' END;
	EOSQL
)"

if [ "$h3_required" = true ]; then
	[ "$test_h3" = available ]
elif [ "$test_h3" != available ]; then
	echo "H3 extensions are not available; skipping optional H3 smoke"
	exit 0
fi

echo 'CREATE EXTENSION IF NOT EXISTS h3; CREATE EXTENSION IF NOT EXISTS h3_postgis;' | psql >/dev/null
h3_cell="'8928308280fffff'::h3index"
[ "$(echo "SELECT h3_get_resolution($h3_cell)" | psql)" = 9 ]
[ "$(echo "SELECT h3_is_valid_cell($h3_cell)" | psql)" = t ]
[ "$(echo "SELECT ST_GeometryType(h3_cell_to_boundary_geometry($h3_cell))" | psql)" = ST_Polygon ]
[ "$(echo "SELECT count(*) FROM h3_grid_disk($h3_cell, 1)" | psql)" = 7 ]
if [ "$h3_required" = true ]; then
	echo "H3 extensions are required and work!"
else
	echo "H3 extensions are available and work!"
fi
