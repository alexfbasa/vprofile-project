#!/bin/bash

# Informações da base de dados do Grafana
GRAFANA_DB="grafana_db"
GRAFANA_USER="grafana_user"
GRAFANA_PASSWORD="password123"  # Defina uma senha segura

# Informações da base de dados do Zabbix
ZABBIX_DB="zabbix"
ZABBIX_USER="zbx_monitor"
ZABBIX_PASSWORD="zbx_m0n1t0r1nG"

# Instalação do PostgreSQL (caso não esteja instalado)
if ! rpm -q postgresql-server; then
    yum install -y postgresql-server postgresql-contrib >/dev/null 2>&1
    systemctl enable postgresql
    systemctl start postgresql
fi

# Criação da base de dados do Grafana
su - postgres -c "psql -c 'CREATE DATABASE $GRAFANA_DB;'"
su - postgres -c "psql -c \"CREATE USER $GRAFANA_USER WITH ENCRYPTED PASSWORD '$GRAFANA_PASSWORD';\""
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $GRAFANA_DB TO $GRAFANA_USER;\""

# Download e instalação do Zabbix Server
ZABBIX_RPM='http://repo.zabbix.com/zabbix/4.4/rhel/8/x86_64/zabbix-server-pgsql-4.4.10-1.el8.x86_64.rpm'
yum install -y $ZABBIX_RPM >/dev/null 2>&1

# Criação da base de dados do Zabbix
su - postgres -c "psql -c 'CREATE DATABASE $ZABBIX_DB;'"
su - postgres -c "psql -c \"CREATE USER $ZABBIX_USER WITH ENCRYPTED PASSWORD '$ZABBIX_PASSWORD';\""
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $ZABBIX_DB TO $ZABBIX_USER;\""

# Populando o banco de dados do Zabbix com tabelas
zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | sudo -u zabbix psql $ZABBIX_DB

# Restante do script para instalação do Grafana
GRAFANA_RPM='https://dl.grafana.com/enterprise/release/grafana-enterprise-10.2.0-1.x86_64.rpm'
GRAF_DIR='/usr/sbin'
GRAF_SRC_DIR='/tmp/grafana'

if [[ ! -f ${GRAF_DIR?}/grafana-server ]]; then
    yum install -y $GRAFANA_RPM >/dev/null 2>&1
    # Adicione software adicional para exportar imagens PNG a partir do painel
    yum install -y fontconfig freetype* urw-fonts >/dev/null 2>&1
fi

cp /tmp/grafana/config/grafana.ini /etc/grafana/grafana.ini
chown root:grafana /etc/grafana/grafana.ini
chmod 640 /etc/grafana/grafana.ini

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server

exit 0
