#!/bin/bash

set -e -u

GRAFANA_RPM='https://dl.grafana.com/enterprise/release/grafana-enterprise-10.2.0-1.x86_64.rpm'
GRAF_DIR='/usr/sbin'
GRAF_SRC_DIR='/tmp/grafana'

if [[ ! -f ${GRAF_DIR?}/grafana-server ]]
then
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
