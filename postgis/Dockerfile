FROM postgis/postgis

ARG TZ=Asia/Kuching
ENV TZ=${TZ}

WORKDIR /

RUN set -x && apt-get update && \
    apt-get install -y postgresql-client osm2pgsql git curl wget && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/osm_data && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN set -x && wget -O /opt/osm_data/malaysia-singapore-brunei-latest.osm.pbf \ 
    "https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf"

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./openstreetmap-carto.style /openstreetmap-carto.style

RUN chmod 755 /docker-entrypoint-initdb.d/postgis.sh && \
    sed -i "s/\r$//" /docker-entrypoint-initdb.d/postgis.sh