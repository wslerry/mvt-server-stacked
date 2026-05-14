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

These are one-shot pipeline tasks. Use `run --rm` so the container is automatically removed after it finishes.

Before the first run, create the host directories so Docker doesn't create them as root:

```bash
mkdir -p data/pbf tilemaker/pbf
```

- Clip and merge OSM data for Borneo Island:

    ```bash
    docker compose -f docker-compose-mbtiles.yml run --rm osmium
    ```

- Generate MBTILES/PMTILES:

    ```bash
    docker compose -f docker-compose-mbtiles.yml run --rm tilemaker
    ```

> Using `run --rm` instead of `up` ensures the container exits cleanly and is removed. `up` leaves the container in a stopped state after the process finishes.

### MVT Servers

#### 1: Prepare Your Environment
- Clone repository: `git clone git@github.com:wslerry/mvt-server-stacked.git`
- Copy `.env-template` to `.env` and fill in `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `TZ`, etc.
- Ensure Docker and Docker Compose are installed.


#### 2: Build Docker Images

```bash
docker compose build
```

Builds all custom images (`lerryws/osmium`, `lerryws/postgis`, `lerryws/maputnik:1.7.0`, `lerryws/maputnik:secure-latest`, `lerryws/t-rex`).

To rebuild maputnik-latest targeting a specific release:

```bash
docker compose build --build-arg MAPUTNIK_VERSION=v0.6.1 maputnik-latest
```


#### 3: Start Services

```bash
docker compose up -d
```

The internal bridge network is created automatically by compose — no manual `docker network create` needed.


#### 4: Check Services Status

```bash
docker compose ps
```

You should see containers for `maputnik-v170`, `maputnik-latest`, `maputnik_db`, `pgadmin_maputnik_db`, `martin`, `tileserver-gl`, and `trex`.


#### 5: Access Services

| Service | URL | Notes |
|---|---|---|
| maputnik v1.7.0 | `http://localhost:8081` | nginx, static build |
| maputnik latest | `http://localhost:8082` | standalone Go binary |
| pgAdmin | `http://localhost:8083` | use credentials from `.env` |
| Martin | `http://localhost:8084` | vector tile server |
| TileServer GL | `http://localhost:8085` | raster + vector tile server |
| t-rex | `http://localhost:6767` | vector tile server |

> Ports can be changed in `docker-compose.yml` if they clash with existing services.


#### 6: Configuration and Use

- **Database**: `maputnik_db` must be healthy before `martin` and `trex` start (`depends_on` with healthcheck is configured).
- **Map Editing**: Use either Maputnik interface to edit styles. Point the style source URLs at Martin (`localhost:8084`) or TileServer GL (`localhost:8085`).
- **Loading data**: Import PostGIS data and serve it through Martin or t-rex. Use Maputnik to visualise and edit styles.


#### 7: Troubleshooting

- Check logs: `docker logs <container_name>`
- Check all service health: `docker compose ps`
- If a service fails to start, check its dependency (`db` healthcheck must pass before `martin` and `trex` come up).
- t-rex config lives in `./configs/t_rex/`; Martin config is auto-saved to `./configs/martin/martin.config.yaml` on first run.
