FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /opt/osmium

COPY ./extraction ./extraction
COPY entrypoint.sh entrypoint.sh

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends osmium-tool wget tini; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /data/input /data/output; \
    chmod +x entrypoint.sh; \
    sed -i "s/\r$//" entrypoint.sh;

ENTRYPOINT [ "tini", "--" ]
CMD [ "./entrypoint.sh" ]


