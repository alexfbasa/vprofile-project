#!/bin/bash

set -e -u

GRAFANA_RPM='https://dl.grafana.com/enterprise/release/grafana-enterprise-10.2.0-1.x86_64.rpm'
GRAF_DIR='/usr/sbin'
GRAF_SRC_DIR='/tmp/grafana'

ZABBIX_REPO='http://repo.zabbix.com/zabbix/4.4/rhel/8/x86_64/zabbix-release-4.4-1.el8.noarch.rpm'

# Instalação do PostgreSQL (caso não esteja instalado)
if ! rpm -q postgresql-server; then
    yum install -y postgresql-server postgresql-contrib >/dev/null 2>&1
    systemctl enable postgresql
    systemctl start postgresql
fi

if [[ ! -f ${GRAF_DIR?}/grafana-server ]]; then
    yum install -y $GRAFANA_RPM >/dev/null 2>&1
    # Adicione software adicional para exportar imagens PNG a partir do painel
    yum install -y fontconfig freetype* urw-fonts >/dev/null 2>&1
fi

if ! rpm -q zabbix-release; then
    yum install -y $ZABBIX_REPO >/dev/null 2>&1
    yum install -y zabbix-server-pgsql zabbix-web-pgsql >/dev/null 2>&1
fi

cp ${GRAF_SRC_DIR?}/config/grafana.ini /etc/grafana/grafana.ini
chown root:grafana /etc/grafana/grafana.ini
chmod 640 /etc/grafana/grafana.ini

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server

systemctl enable zabbix-server
systemctl start zabbix-server
systemctl enable zabbix-web
systemctl start zabbix-web

exit 0
