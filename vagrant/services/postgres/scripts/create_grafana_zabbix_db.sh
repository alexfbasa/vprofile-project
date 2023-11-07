#!/bin/bash
# Define variables
GRAFANA_USER="grafana_user"
GRAFANA_PASSWORD="grn_pas7sw0rd30"
GRAFANA_DB="grafana_db"

ZABBIX_USER="zbx_monitor"
ZBX_PASSWORD="zbx_m0n1t0r1nG"
ZABBIX_DB="zabbix_db"

ZBX_DB_SCHEMA='https://cdn.zabbix.com/zabbix/sources/stable/6.0/zabbix-6.0.23.tar.gz'

sudo -u postgres createuser -S $ZABBIX_USER


# Create the Grafana user and database
psql -U postgres -c "CREATE ROLE $GRAFANA_USER WITH LOGIN PASSWORD '$GRAFANA_PASSWORD';"
psql -U postgres -c "CREATE DATABASE $GRAFANA_DB;"
psql -U postgres -c "ALTER DATABASE $GRAFANA_DB OWNER TO $GRAFANA_USER;"

# Create the Zabbix user and database
psql -U postgres -c "CREATE ROLE $ZABBIX_USER WITH LOGIN PASSWORD '$ZBX_PASSWORD';"
psql -U postgres -c "CREATE DATABASE $ZABBIX_DB;"
psql -U postgres -c "ALTER DATABASE $ZABBIX_DB OWNER TO $ZABBIX_USER;"

cd /tmp || exit
wget $ZBX_DB_SCHEMA
tar zxvf zabbix-6.0.23.tar.gz
cd zabbix-6.0.23/database/postgresql || exit

psql -U $ZABBIX_USER -d $ZABBIX_DB -a -f schema.sql
psql -U $ZABBIX_USER -d $ZABBIX_DB -a -f images.sql
psql -U $ZABBIX_USER -d $ZABBIX_DB -a -f data.sql

exit 0
