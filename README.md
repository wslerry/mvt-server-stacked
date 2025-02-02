# Mapbox Tile Vector Server Stacks

A learning process of MVT server stacks

TODO:
- add https://www.bbox.earth/
- add tilemaker (pbf to mbtiles)
- case study https://cyberjapandata.gsi.go.jp/ tech stack
- read https://dev.to/mierune/building-a-geospatial-server-with-bbox-server-4e5b
- study https://github.com/shiwaku/FOSS4G-2024-Japan-MapLibre-HandsOn?tab=readme-ov-file
- case study https://busrouter.sg/#/
- study https://openfreemap.org/

Technology stacks:
- [maputnik](https://github.com/maplibre/maputnik)
- [martin](https://github.com/maplibre/martin)
- [tileserver-gl](https://github.com/maptiler/tileserver-gl)
- [osmium](https://osmcode.org/osmium-tool/)
- [tilemaker](https://tilemaker.org/)
- [bbox](https://www.bbox.earth/)
- [t-rex](https://github.com/t-rex-tileserver/t-rex/)
- [pgadmin](https://www.pgadmin.org/)
- [postgresql](https://www.postgresql.org/)
- [postgis](https://postgis.net/)


## Usage

### OSM PBF -> MBTILES/PMTILES

- Clipping and merge OSM data for Borneo Island:

    `docker compose -f docker-compose-mbtiles.yml up osmium`

- Generate MBTILES/PMTILES:
    `docker compose -f docker-compose-mbtiles.yml up tilemaker`

### MVT Servers

####  1: Prepare Your Environment
- Clone repository into your system `git clone git@github.com:wslerry/mvt-server-stacked.git`
- Edit .env File:
    - Copy `.env-template` to `.env`.
    - Edit `.env` to set environment variables like `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, etc., according to your requirements.
- Ensure Docker and Docker Compose are installed on your system. Follow the official Docker installation for your OS if needed.


####  2: Network Setup
- Open your terminal and run:
    `docker network create maputnik-network`
 - This command creates the maputnik-network which will be used by the containers to communicate.


#### 3: Build Docker Images
- In the terminal, navigate to your project folder if not already there, and run:
    `docker compose build`
- This builds all the images defined in your docker-compose.yml file.


#### 4: Start Services
- After building, start all services in detached mode with:
    `docker compose up -d`
- This command will run your services in the background.


#### 5: Check Services Status
- Verify Running Services:
    `docker compose ps`
- to see if all services are running. You should see containers for `maputnik1`, `maputnik2`, `db`, `pgadmin`, `martin`, `tileserver-gl`, and `trex`.


#### 6: Access Services
- Maputnik Editors: 
    - Access `maputnik-v170` at `localhost:8081`.
    - Access `maputnik-latest` at `localhost:8082`.
- PostgreSQL Database (pgAdmin):
    - Access `pgAdmin` through `localhost:8083`. Log in with the credentials you set in your .env file.
- Martin (Vector Tile Server):
    - Available at `localhost:8084`.
- TileServer GL:
    - Access at `localhost:8085`.
- t-rex (Another Vector Tile Server):
    - Available at `localhost:8086`.
- You might want to change setting of these ports if it clash with your system.


#### 7: Configuration and Use
- Database Connection: Ensure your database (`db`) is up and running. Check logs if there are issues with startup or connection.
- Map Editing: Use `Maputnik` interfaces to edit styles. Remember, changes might require a restart or refresh of your tile server to take effect.
- Testing: Load some data into your PostGIS database and serve it through `Martin` or `t-rex`. Use your `Maputnik` setup to visualize or edit the styles.


#### 8: Troubleshooting

- Check Docker logs for any container with docker logs [container_name].
- If there are dependency issues, ensure services start in the correct order or tweak `depends_on` in `docker-compose.yml`.