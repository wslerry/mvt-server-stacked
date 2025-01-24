FROM debian:bullseye-slim

WORKDIR /tmp

RUN set -eux; \
    apt update; \
    apt install -y curl ca-certificates libgdal28 tini; \
    curl -O -L https://github.com/t-rex-tileserver/t-rex/releases/download/v0.14.3/t-rex_0.14.3-1.bullseye_amd64.deb; \
    dpkg -i t-rex_0.14.3-1.bullseye_amd64.deb; \
    mkdir -p /opt/data /opt/config;

WORKDIR /opt/apps
COPY entrypoint.sh entrypoint.sh
RUN sed -i "s/\r$//" entrypoint.sh && chmod +x entrypoint.sh

EXPOSE 6767

ENTRYPOINT [ "tini", "--" ]

CMD [ "bash", "/opt/apps/entrypoint.sh" ]