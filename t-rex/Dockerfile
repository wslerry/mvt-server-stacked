FROM debian:bookworm-slim

ARG UID=1000
ARG GID=1000

RUN set -eux; \
    groupadd -g ${GID} trex && \
    useradd -u ${UID} -g ${GID} -m -s /bin/bash trex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    curl ca-certificates libgdal-dev tini; \
    curl -L -o t-rex.deb \
    https://github.com/t-rex-tileserver/t-rex/releases/download/v0.14.3/t-rex_0.14.3-1.bookworm_amd64.deb; \
    dpkg -i t-rex.deb || apt-get install -f -y; \
    rm t-rex.deb; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /opt/data /opt/config

COPY --chown=${UID}:${GID} entrypoint.sh /opt/apps/entrypoint.sh
RUN chmod +x /opt/apps/entrypoint.sh && sed -i 's/\r$//' /opt/apps/entrypoint.sh

USER ${UID}:${GID}
WORKDIR /opt/apps
EXPOSE 6767
ENTRYPOINT ["tini", "--"]
CMD ["/opt/apps/entrypoint.sh"]
