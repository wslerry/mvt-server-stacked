FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG UID=1000
ARG GID=1000

RUN set -eux; \
    groupadd -g ${GID} osmium && \
    useradd -u ${UID} -g ${GID} -m -s /bin/bash osmium; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    osmium-tool ca-certificates wget curl tini; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /data/input /data/output; \
    chown ${UID}:${GID} /data/output

WORKDIR /opt/osmium
COPY --chown=${UID}:${GID} extraction ./extraction
COPY --chown=${UID}:${GID} entrypoint.sh .
RUN chmod +x entrypoint.sh && \
    sed -i 's/\r$//' entrypoint.sh

USER ${UID}:${GID}
ENTRYPOINT ["tini", "--"]
CMD ["./entrypoint.sh"]
