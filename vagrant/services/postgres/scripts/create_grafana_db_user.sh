#!/bin/bash

GRAFANA_DB="grafana_db"
GRAFANA_USER="grafana_user"
GRAFANA_PASSWORD="password123"  # Defina uma senha segura

su - postgres -c "psql -c 'CREATE DATABASE $GRAFANA_DB;'"
su - postgres -c "psql -c \"CREATE USER $GRAFANA_USER WITH ENCRYPTED PASSWORD '$GRAFANA_PASSWORD';\""
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $GRAFANA_DB TO $GRAFANA_USER;\""
