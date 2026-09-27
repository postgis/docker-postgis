#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB" "${@}"; do
    echo "Updating PostGIS extensions '$DB' to $POSTGIS_VERSION"
    psql --dbname="$DB" -v ON_ERROR_STOP=1 -c "
        CREATE EXTENSION IF NOT EXISTS postgis VERSION '$POSTGIS_VERSION';

        CREATE EXTENSION IF NOT EXISTS postgis_topology VERSION '$POSTGIS_VERSION';

        -- Upgrade installed PostGIS-managed extensions, including raster and SFCGAL.
        SELECT postgis_extensions_upgrade('$POSTGIS_VERSION');

        -- Address Standardizer and PostGIS 3.7+ Tiger are maintained separately.
        DO \$\$
        DECLARE
            extension_name text;
            source_version text;
            target_version text;
            update_path text;
            has_any_update_path boolean;
        BEGIN
            IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'postgis_tiger_geocoder') THEN
                CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
                CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
            END IF;

            FOREACH extension_name IN ARRAY ARRAY[
                'address_standardizer',
                'address_standardizer_data_us',
                'postgis_tiger_geocoder'
            ] LOOP
                PERFORM 1
                FROM pg_extension e
                JOIN pg_available_extensions a ON a.name = e.extname
                WHERE e.extname = extension_name;

                IF NOT FOUND THEN
                    CONTINUE;
                END IF;

                SELECT e.extversion, a.default_version
                INTO STRICT source_version, target_version
                FROM pg_extension e
                JOIN pg_available_extensions a ON a.name = e.extname
                WHERE e.extname = extension_name;

                IF source_version = target_version THEN
                    CONTINUE;
                END IF;

                SELECT path INTO update_path
                FROM pg_extension_update_paths(extension_name::name)
                WHERE source::text = source_version AND target::text = target_version;

                IF update_path IS NOT NULL THEN
                    EXECUTE format('ALTER EXTENSION %I UPDATE TO %L', extension_name, target_version);
                ELSIF extension_name = 'postgis_tiger_geocoder' THEN
                    SELECT EXISTS (
                        SELECT 1
                        FROM pg_extension_update_paths(extension_name::name)
                        WHERE source::text = source_version AND target::text = 'ANY'
                    ) AND EXISTS (
                        SELECT 1
                        FROM pg_extension_update_paths(extension_name::name)
                        WHERE source::text = 'ANY' AND target::text = target_version
                    ) INTO has_any_update_path;

                    IF has_any_update_path THEN
                        EXECUTE format('ALTER EXTENSION %I UPDATE TO %L', extension_name, 'ANY');
                        EXECUTE format('ALTER EXTENSION %I UPDATE TO %L', extension_name, target_version);
                    ELSE
                        RAISE NOTICE 'Skipping % update from % to %: no installed update path',
                            extension_name, source_version, target_version;
                    END IF;
                ELSE
                    RAISE NOTICE 'Skipping % update from % to %: no installed update path',
                        extension_name, source_version, target_version;
                END IF;
            END LOOP;
        END
        \$\$;
    "
done
