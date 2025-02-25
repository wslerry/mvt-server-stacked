#!/bin/bash

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
psql --dbname="$POSTGRES_DB" <<-'EOSQL'
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
    echo "Loading PostGIS extensions into $DB"
    psql --dbname="$DB" <<-'EOSQL'
        CREATE EXTENSION IF NOT EXISTS postgis;
        CREATE EXTENSION IF NOT EXISTS postgis_topology;
        CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
        CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        CREATE EXTENSION IF NOT EXISTS hstore;
EOSQL
done

# Ensure that the OSM data file exists or download it
OSM_FILE=/opt/osm_data/${OSM_FILENAME:-"malaysia-singapore-brunei-latest.osm.pbf"}
# OSM_URL="https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf"

if [ ! -f "$OSM_FILE" ]; then
    echo "No OSM data found in the system. System exit..."
    exit 1
else
    echo "OSM data file already exists"
fi

# if [ ! -f "$OSM_FILE" ]; then
#     echo "OSM data file not found at $OSM_FILE, downloading..."
#     mkdir -p /opt/osm_data
#     curl -L -o "$OSM_FILE" "$OSM_URL"
#     if [ $? -ne 0 ]; then
#         echo "Failed to download OSM data file from $OSM_URL"
#         exit 1
#     fi
# else
#     echo "OSM data file already exists at $OSM_FILE"
# fi

# Import OSM data into PostgreSQL
osm2pgsql --style /openstreetmap-carto.style -d "$POSTGRES_DB" -U "$PGUSER" -k --slim "$OSM_FILE"

# sanity check
echo "Sanity check on tables..."
for table in planet_osm_point planet_osm_line planet_osm_polygon planet_osm_roads planet_osm_ways planet_osm_nodes planet_osm_rels; do
    if psql -U "$PGUSER" -d "$POSTGRES_DB" -c "\dt" | grep -q "$table"; then
        echo "Table $table exists."
        ROW_COUNT=$(psql -U "$PGUSER" -d "$POSTGRES_DB" -t -c "SELECT COUNT(*) FROM $table;")
        if [ "$ROW_COUNT" -gt 0 ]; then
            echo "$ROW_COUNT data imported into $table."
        else
            echo "No data found in $table."
        fi
    else
        echo "Table $table does not exist."
    fi
done

DB_SIZE=$(psql -U "$PGUSER" -d "$POSTGRES_DB" -t -c "SELECT pg_size_pretty(pg_database_size('$POSTGRES_DB'))")
echo "Database size is $DB_SIZE"

# Create a flag file to indicate that the database has been initialized
touch /var/lib/postgresql/data/DB_INITED

# Wait for the database to be initialized
while [ ! -e /var/lib/postgresql/data/DB_INITED ]
do
    echo "Waiting while database is initializing..."
    sleep 10
done

# echo "DB successfully created, waiting for PostgreSQL to be ready..."
# until pg_isready -d "$POSTGRES_DB" -h db -p 5432 -U "$PGUSER"; do
#     echo "Waiting for PostgreSQL to come up..."
#     sleep 1
# done

echo "PostgreSQL is ready and OSM data has been imported."