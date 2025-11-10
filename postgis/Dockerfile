# ============== OFFICIAL POSTGIS (Debian 12) ==============
FROM postgis/postgis:16-3.4

# Build args
ARG TZ=Asia/Kuching
ENV TZ=${TZ}

# Switch to root temporarily for installs
USER root

# Install correct packages + fix timezone in ONE layer
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    postgresql-client-16 \
    osm2pgsql \
    git \
    curl \
    wget \
    ca-certificates; \
    \
    # Set timezone (Debian 12 way — no dpkg-reconfigure!) \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    \
    # Create dir \
    mkdir -p /opt/osm_data; \
    chown postgres:postgres /opt/osm_data; \
    \
    # Cleanup \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy files as postgres user
COPY --chown=postgres:postgres initdb-postgis.sh /docker-entrypoint-initdb.d/01-postgis.sh
COPY --chown=postgres:postgres openstreetmap-carto.style /opt/openstreetmap-carto.style

# Fix permissions
RUN chmod 755 /docker-entrypoint-initdb.d/01-postgis.sh && \
    sed -i 's/\r$//' /docker-entrypoint-initdb.d/01-postgis.sh

# Back to non-root
USER postgres

# Healthcheck
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
    CMD pg_isready -U postgres || exit 1

# Labels
LABEL org.opencontainers.image.title="Secure PostGIS 16 + osm2pgsql"
LABEL org.opencontainers.image.description="Production-ready, non-root, minimal"
