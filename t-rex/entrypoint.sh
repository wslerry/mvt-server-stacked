#!/bin/bash

DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}
TREX_CONFIG=/opt/config/pg_config.toml

sleep 5

create_config() {
    echo "create configuration file"
    if [ ! -f ${TREX_CONFIG} ]; then
        echo "Configuration file not found. Creating configuration file..."
        t_rex genconfig --dbconn ${DATABASE_URL} > ${TREX_CONFIG}
    fi
}

recreate_config() {
    rm -rf ${TREX_CONFIG}
    create_config
}

serve_mvt() {
    if [ ! -f ${TREX_CONFIG} ]; then
        echo "Configuration file not found. Creating configuration file..."
        t_rex genconfig --dbconn ${DATABASE_URL} > ${TREX_CONFIG}
    fi

    # t_rex serve --bind=0.0.0.0 --openbrowser=false --config=${TREX_CONFIG}
    t_rex serve --bind=0.0.0.0 --openbrowser=false --dbconn ${DATABASE_URL} --cache /tmp/mvtcache
}

if [ $# -eq 0 ]; then
    echo "Starting default application..."
    serve_mvt
else
    case "$1" in
        create)
            create_config
            exit 0
            ;;
        recreate)
            recreate_config
            exit 0
            ;;
        *)
            echo "Usage: $0 {create|recreate}"
            exit 1
            ;;
    esac
fi
