#!/usr/bin/bash

export DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}

sleep 10

echo "create configuration file"
if [ ! -f /opt/config/pg_config.toml ]; then
    echo "Configuration file not found. Creating configuration file..."
    t_rex genconfig --dbconn ${DATABASE_URL} > /opt/config/pg_config.toml
else
    echo "Configuration file already exists and will be recreate."
    t_rex genconfig --dbconn ${DATABASE_URL} > /opt/config/pg_config.toml
fi

echo "Start serving t_rex"
t_rex serve --bind=0.0.0.0 --openbrowser=false --config=/opt/config/pg_config.toml

tail -f /dev/null